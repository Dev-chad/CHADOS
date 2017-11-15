all: Kernel32.bin

Kernel32.bin: Entry.s
	nasm -o Kernel32.bin Entry.s

clean:
	rm -f Kernel32.bin
