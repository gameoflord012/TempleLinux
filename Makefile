INITRAMFS_X86_64=build/initramfs_x86_64.cpio.gz
INITRAMFS_ARM=build/initramfs_arm.cpio.gz

ARM-GCC=arm-linux-gnueabihf-gcc
GCC=GCC

all: build qemu

install: build config.txt cmdline.txt 
	mkdir -p install
	cp $(INITRAMFS) install/
	cp bzImage install/
	cp config.txt install/
	cp cmdline.txt install/

build:
	mkdir -p build/
	
	$(GCC) -static -o build/x86_64/init init.c
	$(ARM-GCC) -static -o build/arm/init init.c
	chmod +x build/x86_64/init build/arm/init

	mkdir -p build/rootfs/arm/proc build/rootfs/arm/sys build/rootfs/arm/dev
	mkdir -p build/rootfs/x86_64/proc build/rootfs/x86_64/sys build/rootfs/x86_64/dev

	cp build/ build/rootfs/

	cd build/rootfs/arm && find . | cpio -H newc -o | gzip > "../$(INITRAMFS_ARM)" 
	cd build/rootfs/x86_64 && find . | cpio -H newc -o | gzip > "../$(INITRAMFS_X86_64)" 

qemu:
	qemu-system-x86_64 \
		-kernel bzImage \
		-initrd build/initramfs.cpio.gz \
		-append "console=ttyS0 init=/init" \
		-nographic -m 256m
