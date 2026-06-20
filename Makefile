INITRAMFS_X86_64=initramfs_x86_64.cpio.gz
INITRAMFS_ARM=initramfs_arm.cpio.gz

ARM-GCC=arm-linux-gnueabihf-gcc
GCC=gcc

all: build qemu

install: build config.txt cmdline.txt 
	mkdir -p install/x86_64
	cp build/initrd/$(INITRAMFS_X86_64) install/x86_64
	cp bzImage install/x86_64

	mkdir -p install/arm
	cp build/initrd/$(INITRAMFS_ARM) install/arm

build:
	mkdir -p build/rootfs/arm/proc build/rootfs/arm/sys build/rootfs/arm/dev
	mkdir -p build/rootfs/x86_64/proc build/rootfs/x86_64/sys build/rootfs/x86_64/dev
	mkdir -p build/lib/x86_64
	mkdir -p build/lib/arm
	mkdir -p build/initrd

	$(GCC) -static -o build/lib/x86_64/init init.c
	$(ARM-GCC) -static -o build/lib/arm/init init.c
	chmod +x build/lib/x86_64/init build/lib/arm/init

	cp -r build/lib/* build/rootfs/

	cd build/rootfs/arm && find . | cpio -H newc -o | gzip > "../../initrd/$(INITRAMFS_ARM)" 
	cd build/rootfs/x86_64 && find . | cpio -H newc -o | gzip > "../../initrd/$(INITRAMFS_X86_64)" 

qemu:
	qemu-system-x86_64 \
		-kernel bzImage \
		-initrd build/initrd/$(INITRAMFS_X86_64)\
		-append "console=ttyS0 init=/init" \
		-nographic -m 256m

clean:
	rm -rf build install
