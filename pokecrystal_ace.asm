
INCLUDE "charmap.asm"


; Game memory locations
GetSRAMBank = $2FCB ; Opens SRAM and switches to the bank in a
CloseSRAM = $2FE1 ; Closes SRAM
_hl = $2FEC ; Jumps to hl
_de = $2FED ; Jumps to de
CopyBytes = $3026 ; Copies BC bytes from HL to DE
CopyName2 = $30D9 ; Copies a $50-terminated string from DE to HL
SaveChecksumBank = 5
SaveChecksum = $4E13 ; Computes the file's checksum and writes it back
sPlayerName = $A00B
sMomsName = $A016
wPlayerName = $D47D


; convert from SRAM game data to WRAM game data
from_sram equs "$D47B - $A009 +"
to_sram   equs "$A009 - $D47B +"


; This is required to get around a nasty cyclic dependency near ExploitNames
; Please **DO NOT REMOVE**
InitialPayloadAddr = to_sram $DA0E ; Unused section of WRAM (apparently?)


; org "Section name", SRAM_bank, SRAM_addr
org: macro
if DEF(base_addr)
    PURGE base_addr
endc
PURGE sect_addr

base_addr = from_sram \3 ; This section's base addr when loaded into WRAM

SECTION \1, ROM0[(\2) * $2000 + (\3) - $A000]
sect_addr:
endm
; Define sect_addr so first `org` works
sect_addr = 0


; Declares a label, and declares its WRAM label as well (prepends a w)
label: macro
\1:
w\1 = \1 - sect_addr + base_addr ; Declare where this label will end up in WRAM
s\1 = \1 - sect_addr + (to_sram base_addr) ; Declare where it will end up in SRAM as well
endm


 org "Payload data", 0, $BF12
 label OAMHook
    call DMALoader - DMAPayload + $C000
    ld [$ff00+c], a


 label DMAPayload
    ; Stuff goes here
    ret

; Copy, loaded to WRAM that's restored to the save file
 label ExploitName
    ; Player name
    db "<GREEN><RED><RED><RED>"
    ret
    db $15, $00
    ; !!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!!!!!!
    ; We can't refer to wInitialPayload from here, due to cyclic dependency issues
    ; Instead, we're using the address directly
    ; PLEASE MAKE SURE THIS DOES NOT BREAK!!
    jp from_sram InitialPayloadAddr
    db "@"

 label DMALoader
    ld a, [$A000]
    inc a
    jr nz, .SRAMIsOpen ; Do nothing if SRAM is open (we might break stuff otherwise)

    inc a ; ld a, 1
    call GetSRAMBank
    ld hl, sPlayerName
    ld a, [hl] ; Check if player name is still our exploit's
    cp "<GREEN>"
    jr z, .noSavePatching
    ld de, ExploitName - DMAPayload + $C000
    call CopyName2
    call SaveChecksum ; Also opens and closes SRAM, but heh
.noSavePatching
    call CloseSRAM
.SRAMIsOpen

    call $C000 ; DMAPayload
    ; Set up regs so DMA goes through smoothly
    ld c, $46 ; LOW(rDMA)
    ld a, $C4 ; HIGH(wVirtualOAM)
    ret
 label DMAPayloadEnd

 label NewPlayerName
    ; Should be patched in by the patcher program, here's a default for now.
    db "GCL@@@@@@@@"


 org "Initial payload", 1, InitialPayloadAddr
 label InitialPayload
    di
    push bc
    push de
    push hl
    ; Get SRA0, where everything is stored
    xor a
    call GetSRAMBank

    ; Hook OAM DMA
    ld hl, sOAMHook
    ld bc, 4 << 8 | $80
.copyOAMHook
    ld a, [hli]
    ld [$ff00+c], a
    inc c
    dec b
    jr nz, .copyOAMHook
    ; Copy loader to WRAM
    ld hl, sDMAPayload
    ld de, $C000
    ld bc, DMAPayloadEnd - DMAPayload
    call CopyBytes
    ; Restore player name from SRAM
    ld de, sNewPlayerName
    ld hl, wPlayerName
    call CopyName2

    call CloseSRAM
    pop hl
    pop de
    pop bc
    scf
    reti


; Names triggering the exploit

 org "Player name", 1, $A00B
    ; Player name
    db "<GREEN><RED><RED><RED>" ; Skip to $CD52
    ret ; Write "ret" there
    db $15, $00 ; Trigger wrong jump to $CD52
    jp wInitialPayload ; Code executed
    db "@" ; Terminator/padding

 org "Red name", 1, $A02C
    ; Red's name
    db $15, $04, "PK", $FF, $50 ; Skip 255 chars
    db "@"

 org "Green name", 1, $A037
    ; Green's name
    db $15, $04, "MN", $E5, $50 ; Skip 229
    db "<RED><RED><RED><RED>@" ; Skip 255 + 255 + 255 + 255 = 1020 chars
