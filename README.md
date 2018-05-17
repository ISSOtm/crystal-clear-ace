# Crystal Clear ACE

A Pokémon Crystal save file that executes arbitrary code before even loading it.

Inspired by [MrCheeze's R/B "Virus"](https://github.com/MrCheeze/pokered-self-replicator).


## How to use

Any save file can be patched with the exploit using Make, [RGBDS](https://github.com/rednex/rgbds) and Python 3. Simply replace `base_file.sav` with the save file to be patched, then run `make`. (The original file will be left untouched, if you're wondering.)

**NOTE**: The save file may not include RTC data, which some emulators such as VBA append to the save file. If you get an error about overlay files requiring alignment, please run `make rtc` **BROKEN FOR NOW, HELP APPRECIATED**.

`make run` attempts to launch BGB to run the game using this save file. You will probably need to edit the `BGB` variable in the Makefile to spell the command required to launch BGB.


## FAQ

Q: Any precautions I need to take?<br>
A: Please ensure you always save your game correctly. The exploit may not re-install itself after saving if you reset mid-save. We're looking forward to fix this.

Q: What does this change to my game?<br>
A: Nothing for now. We haven't decided yet what the exploit should do.

Q: Can I use this for Pokémon Gold or Silver as well?<br>
A: No. The exploit we're using leverages bad bounds checking on a Crystal-only function (related to the Mobile Adapter, if you're curious).

Q: What versions of Pokémon Crystal does this work on?<br>
A: This has been developed and confirmed to full work on US Pokémon Crystal 1.0 (MD5 hash `9f2922b235a5eeb78d65594e82ef5dde`), and has been reported to work on EU Crystal 1.1 (MD5 hash `54858AA278A0576B545FDC35CDBD1CF8`), so I would expect it to work on US 1.1 and EU 1.0 as well (if you test it, please send us feedback!). It will most certainy not work on any JP Crystal, though.

Q: I don't want to install RGBDS, isn't there anything simpler?<br>
A: Not yet, but I'm working on a simpler solution to patch SAV files. Please stay tuned.

Q: Can I use this on my GBC, or 3DS VC?<br>
A: If you possess the ability to inject save files into your game, then yes, you can. If you can't, a method to do this using ACE might be developed in the future.

Q: The source code is horribly dirty, you know that?<br>
A: I tried to write code as cleanly as possible, but RGBDS isn't designed to output code outside of ROM, so I had to heavily hack my way around that, which causes a LOT of issues (such as not being able to reference labels prior to declaring them).


## Credits

[Original research](https://forums.glitchcity.info/index.php?topic=8344.0) by [Npo](https://forums.glitchcity.info/index.php?action=profile;u=2080), refined and ported to RGBDS by [ISSOtm](https://github.com/ISSOtm).

Largely helped by the [pokecrystal disassembly](https://github.com/pret/pokecrystal).