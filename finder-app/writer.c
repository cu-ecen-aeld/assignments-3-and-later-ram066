#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>

int main(int argc, char *argv[])
{
    openlog(NULL, 0, LOG_USER);

    if (argc != 3) {
        syslog(LOG_ERR, "Invalid number of arguments");
        return 1;
    }

    FILE *fp = fopen(argv[1], "w");
    if (fp == NULL) {
        syslog(LOG_ERR, "Failed to open file");
        return 1;
    }

    fprintf(fp, "%s", argv[2]);
    fclose(fp);

    syslog(LOG_DEBUG, "Writing %s to %s", argv[2], argv[1]);

    closelog();
    return 0;
}
