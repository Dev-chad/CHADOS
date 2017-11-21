all: BootLoader.bin

BootLoader.bin: Source/BootLoader.asm
	nasm -o $@ $<

clean:
	rm -f BootLoader.bin
