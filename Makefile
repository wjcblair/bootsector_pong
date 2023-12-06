all:
	fasm main.asm
	qemu-system-i386 -fda main.bin
