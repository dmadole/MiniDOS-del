
all: del.bin

lbr: del.lbr

del.bin: del.asm include/bios.inc include/kernel.inc
	asm02 -L -b del.asm
	-rm -f del.build

del.lbr: del.bin
	lbradd del.lbr del.bin

clean:
	-rm -f del.lst
	-rm -f del.bin
	-rm -f del.lbr

