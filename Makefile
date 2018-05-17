

.PHONY: clean rtc run

# Command to run BGB
# Please change this to fit your needs
BGB = wine D:\\Jeux\\bgb\\bgb.exe

RGBASM = rgbasm
RGBLINK = rgblink


pokecrystal_ace.sav: pokecrystal_ace.asm base_save.sav
	$(RGBASM) -o $(@:.sav=.o) $<
	$(RGBLINK) -O base_save.sav -o $@ -t $(@:.sav=.o)
	truncate -s 32768 $@
	./savefix.py $@

rtc: original.sav
	dd if=$< of=rtc.bin bs=1 skip=32768 count=48
	cp $< base_save.sav
	truncate -s 32768 base_save.sav
	$(MAKE) pokecrystal_ace.sav
	rm base_save.sav
	mv pokecrystal_ace.sav tmp.sav
	cat tmp.sav rtc.bin > pokecrystal_ace.sav
	rm tmp.sav rtc.bin


clean:
	-rm pokecrystal_ace.sav pokecrystal_ace.o
	-rm rtc.bin tmp.sav


run:
	$(BGB) -rom ./pokecrystal_ace.gbc -nobattsave -loadbatt ./pokecrystal_ace.sav
