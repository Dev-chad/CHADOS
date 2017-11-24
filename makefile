all: BootLoader Kernel32 Kernel64 Utility Disk.img

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

Kernel64:
	@echo
	@echo ============== Build 64bit kernel ============
	@echo
	
	make -C kernel64

	@echo
	@echo ============== Build Complete ============
	@echo

Disk.img: boot/BootLoader.bin kernel32/Kernel32.bin kernel64/Kernel64.bin
	@echo
	@echo ============== Disk Image Build ============
	@echo

	./ImageMaker $^

	@echo
	@echo ============== All Build Complete ============
	@echo

Utility:
	@echo
	@echo ============== Build Utility ============
	@echo
	
	make -C utility

	@echo
	@echo ============== Build Complete ============
	@echo

run: all
	qemu-system-x86_64 -L . -fda Disk.img -localtime -M pc

clean:
	make -C boot clean
	make -C kernel32 clean
	make -C kernel64 clean
	make -C utility clean
	rm -f Disk.img
	rm -f ImageMaker
