#include <sys/mount.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>
#include <string.h>
#include <errno.h>
#include <termios.h>
#include <unistd.h>

void ls_dir(const char *path) {
		DIR *d = opendir(path);

		if (d == NULL) {
				fprintf(stderr, "Error: %s: path: %s\n", strerror(errno), path);
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
						fprintf(stderr, "Error: %d\n", n);
				}

				if (buf[n - 1] == '\n') {
						buf[n - 1] = '\0';
						n--;
				}
				else {
						perror("Error: input too long :(");
						tcflush(0, TCIFLUSH);
						return -1;
				}


				// dispatch command

				char *cmd = buf;
				int cmd_end_pos = n;

				for (int i = 0; i < n; i++) {
						if (buf[i] == ' ') {
								buf[i] = '\0';
								cmd_end_pos = i;
								break;
						}
				}

				printf("[execute %s]\nargs: %s\n", cmd, buf + cmd_end_pos + 1);
		}
}
