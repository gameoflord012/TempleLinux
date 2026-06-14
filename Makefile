all:
	gcc -static -o build/init init.c
	mkdir -p build/rootfs/proc build/rootfs/sys build/rootfs/dev
	cp init build/rootfs/init
	chmod +x build/rootfs/init
	cd build/rootfs && find . | cpio -H newc -o | gzip > ../initramfs.cpio.gz

qemu:
	qemu-system-x86_64 \
		-kernel bzImage \
		-initrd build/initramfs.cpio.gz \
		-append "console=ttyS0 init=/init" \
		-nographic -m 256m
