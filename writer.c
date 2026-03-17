#include <stdio.h>
#include <syslog.h>

int main(int argc, char *argv[]) {
    openlog(NULL, 0, LOG_USER);

    if (argc != 3) {
        syslog(LOG_ERR, "Invalid number of arguments");
        return 1;
    }

    FILE *file = fopen(argv[1], "w");
    if (file == NULL) {
        syslog(LOG_ERR, "Error opening file");
        return 1;
    }

    fprintf(file, "%s", argv[2]);
    fclose(file);

    syslog(LOG_DEBUG, "Writing %s to %s", argv[2], argv[1]);

    closelog();
    return 0;
}
