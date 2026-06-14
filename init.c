#include <sys/mount.h>
#include <unistd.h>
#include <stdio.h>

#include <sys/types.h>
#include <dirent.h>
#include <string.h>
#include <errno.h>

void ls_dir(const char *path) {
	DIR *d = opendir(path);

	if (d == NULL) {
		printf("Error: %s, Path: %s\n", strerror(errno), path);
		return;
	}

	struct dirent *e;
	
	while ((e = readdir(d)) != NULL) {
		printf("%s\n", e->d_name);
	}

	closedir(d);
}

int main() {
	mount("proc",     "/proc", "proc",     0, NULL);
	mount("sysfs",    "/sys",  "sysfs",    0, NULL);
	mount("devtmpfs", "/dev",  "devtmpsf", 0, NULL);

	write(1, "\n === Hello World ===\n", 23);

	char buf[256];
	while(1) {
		write(1, "> ", 2);

		int n = read(0, buf, sizeof(buf));

		if (n <= 0) {
			printf("error: %d\n", n);
		}

		if (buf[n - 1] == '\n') {
			buf[n - 1] = '\0';
		}
		
		ls_dir(buf);
	}
}
