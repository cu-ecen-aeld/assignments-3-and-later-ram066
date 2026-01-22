#include <stdio.h>
#include <stdbool.h>
#include <stdarg.h>
#include <stdlib.h>     // system(), exit(), EXIT_FAILURE
#include <unistd.h>     // fork(), execv(), dup2(), STDOUT_FILENO
#include <sys/wait.h>   // waitpid(), WIFEXITED, WEXITSTATUS
#include <sys/types.h>  // pid_t
#include <fcntl.h>      // open(), O_WRONLY, O_CREAT, O_TRUNC
#include <stdio.h>      // fflush()

bool do_system(const char *command);

bool do_exec(int count, ...);

bool do_exec_redirect(const char *outputfile, int count, ...);
