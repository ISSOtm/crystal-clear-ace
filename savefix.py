#!/usr/bin/python3

from sys import argv

if len(argv) != 2:
    print("Usage: {} path/to/file.sav" % argv[0])


def ofs_from_addr(bank, addr):
    return bank * 0x2000 + addr - 0xA000

# Taken from game data
# Address of sGameData
start_bank = 1
start_addr = 0xA009
# Operand at 5:502B
checksum_len = 0xB7A
# Address of sChecksum
checksum_bank = 1
checksum_addr = 0xAD0D


sav_name = argv[1]
with open(sav_name, "rb+") as sav_file:
    sav_file.seek(ofs_from_addr(start_bank, start_addr))

    checksum = 0
    # Game code uses do...while, but a while is the same here
    while checksum_len != 0:
        byte = sav_file.read(1)[0]
        checksum = (checksum + byte) % 0x10000

        checksum_len -= 1
    
    # Write back checksum
    sav_file.seek(ofs_from_addr(checksum_bank, checksum_addr))
    sav_file.write(checksum.to_bytes(2, "little"))
