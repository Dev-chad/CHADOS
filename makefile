all: BootLoader Kernel32 Disk.img

BootLoader:
	@echo 
	@echo ============== Build Boot Loader ============
	@echo
	
	make -C boot

	@echo 
	@echo ============== Build Complete ============
	@echo

Kernel32:
	@echo
	@echo ============== Build 32bit kernel ============
	@echo
	
	make -C kernel32

	@echo
	@echo ============== Build Complete ============
	@echo

Disk.img: boot/BootLoader.bin kernel32/Kernel32.bin
	@echo
	@echo ============== Disk Image Build ============
	@echo

	cat $^ > Disk.img

	@echo
	@echo ============== All Build Complete ============
	@echo

run: all
	qemu-system-i386 -L . -fda Disk.img -localtime -M pc

clean:
	make -C boot clean
	make -C kernel32 clean
	rm -f Disk.img
