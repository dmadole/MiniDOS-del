
del.prg: del.asm include/bios.inc include/kernel.inc
	asm02 -L -b del.asm
	-rm -f del.build

clean:
	-rm -f del.lst
	-rm -f del.bin

