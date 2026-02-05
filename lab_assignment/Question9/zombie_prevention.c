#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

/*
 * zombie_prevention.c
 *
 * This program demonstrates how to prevent zombie processes. It creates
 * multiple child processes using fork(). Each child immediately exits after
 * printing its own PID. The parent process loops, calling wait() to reap
 * terminated children and printing the PID of each cleaned up child. By
 * waiting for each child, we ensure that no zombies remain.
 */

int main(void) {
    const int num_children = 3;
    pid_t pids[num_children];

    for (int i = 0; i < num_children; i++) {
        pid_t pid = fork();
        if (pid < 0) {
            perror("fork");
            return EXIT_FAILURE;
        } else if (pid == 0) {
            /* Child process */
            printf("Child process %d (PID=%d) started, exiting now.\n", i + 1, getpid());
            _exit(0);
        } else {
            /* Parent process stores child's PID */
            pids[i] = pid;
        }
    }

    /* Parent waits for all children to terminate */
    for (int i = 0; i < num_children; i++) {
        int status;
        pid_t child_pid = wait(&status);
        if (child_pid > 0) {
            printf("Parent cleaned up child with PID %d\n", child_pid);
        } else {
            perror("wait");
        }
    }

    printf("All children have been reaped. No zombie processes remain.\n");
    return EXIT_SUCCESS;
}