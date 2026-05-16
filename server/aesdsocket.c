#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <syslog.h>
#include <signal.h>
#include <fcntl.h>

#define PORT 9000
#define FILE_PATH "/var/tmp/aesdsocketdata"
#define BUFFER_SIZE 1024

int server_fd;
int exit_flag = 0;

void signal_handler(int sig)
{
 //   syslog(LOG_INFO, "Caught signal, exiting");
   // exit_flag = 1;
syslog(LOG_DEBUG, "Caught signal, exiting");

    if(server_fd != -1)
    {
        close(server_fd);
    }

    remove("/var/tmp/aesdsocketdata");

    closelog();

    exit(EXIT_SUCCESS);
}

int main(int argc, char *argv[])
{
    int daemon_mode = 0;

    if(argc == 2 && strcmp(argv[1], "-d") == 0)
        daemon_mode = 1;

    openlog("aesdsocket", LOG_PID, LOG_USER);

    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);

    struct sockaddr_in server_addr, client_addr;

    server_fd = socket(AF_INET, SOCK_STREAM, 0);
    if(server_fd == -1)
        return -1;

    int opt = 1;
    setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(PORT);
    server_addr.sin_addr.s_addr = INADDR_ANY;

    if(bind(server_fd, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0)
        return -1;

    if(daemon_mode)
    {
        pid_t pid = fork();
        if(pid > 0)
            exit(0);

        setsid();
        chdir("/");
        close(STDIN_FILENO);
        close(STDOUT_FILENO);
        close(STDERR_FILENO);
    }

    listen(server_fd, 5);

    while(!exit_flag)
    {
        socklen_t addrlen = sizeof(client_addr);
        int client_fd = accept(server_fd, (struct sockaddr*)&client_addr, &addrlen);

        if(client_fd < 0)
            continue;

        char ip[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &client_addr.sin_addr, ip, sizeof(ip));

        syslog(LOG_INFO, "Accepted connection from %s", ip);

        FILE *fp = fopen(FILE_PATH, "a+");

        char buffer[BUFFER_SIZE];
        int bytes;

        while((bytes = recv(client_fd, buffer, BUFFER_SIZE, 0)) > 0)
        {
            fwrite(buffer, 1, bytes, fp);

            if(memchr(buffer, '\n', bytes))
                break;
        }

        fflush(fp);
        fclose(fp);

        fp = fopen(FILE_PATH, "r");

        while((bytes = fread(buffer,1,BUFFER_SIZE,fp)) > 0)
        {
            send(client_fd, buffer, bytes, 0);
        }

        fclose(fp);

        close(client_fd);

        syslog(LOG_INFO, "Closed connection from %s", ip);
    }

    close(server_fd);
    remove(FILE_PATH);
    closelog();

    return 0;
}
