#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>

int main(int argc, char *argv[])
{
    openlog("writer", LOG_PID, LOG_USER);

    // MUST be 3 arguments
    if (argc < 3) {
        fprintf(stderr, "Error: No string specified\n");
        syslog(LOG_ERR, "Invalid arguments");
        closelog();
        return 1;
    }

    const char *writefile = argv[1];
    const char *writestr  = argv[2];

    FILE *fp = fopen(writefile, "w");
    if (!fp) {
        perror("fopen");
        syslog(LOG_ERR, "Error opening file %s", writefile);
        closelog();
        return 1;
    }

    fprintf(fp, "%s", writestr);
    fclose(fp);

    syslog(LOG_DEBUG, "Writing %s to %s", writestr, writefile);
    closelog();

    return 0;
}

