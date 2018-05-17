

.PHONY: rtc run

# Command to run BGB
# Please change this to fit your needs
BGB = wine D:\\Jeux\\bgb\\bgb.exe

RGBASM = rgbasm
RGBLINK = rgblink


pokecrystal_ace.sav: pokecrystal_ace.asm base_save.sav
	$(RGBASM) -o $(@:.sav=.o) $<
	$(RGBLINK) -O base_save.sav -o $@ -t $(@:.sav=.o)
	./savefix.py $@

rtc:
	# TODO: grab RTC bytes to a temp file
	truncate 32768 base_file.sav
	$(MAKE) pokecrystal_ace.sav
	# Append RTC bytes to file
	# Remove temp file


run:
	$(BGB) -rom ./pokecrystal_ace.gbc -nobattsave -loadbatt ./pokecrystal_ace.sav
