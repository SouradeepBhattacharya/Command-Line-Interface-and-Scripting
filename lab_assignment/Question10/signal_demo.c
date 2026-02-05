#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

/*
 * signal_demo.c
 *
 * This program demonstrates signal handling between a parent and two child
 * processes. The parent installs handlers for SIGTERM and SIGINT and
 * then runs indefinitely. One child sleeps for 5 seconds before sending
 * SIGTERM to the parent. The second child sleeps for 10 seconds before
 * sending SIGINT to the parent. When the parent receives SIGTERM or
 * SIGINT, it prints a message indicating which signal was received. After
 * handling SIGINT, the parent exits gracefully after cleaning up any
 * remaining children.
 */

static volatile sig_atomic_t sigterm_received = 0;
static volatile sig_atomic_t sigint_received = 0;

void handle_sigterm(int signum) {
    (void)signum; /* unused parameter */
    sigterm_received = 1;
    write(STDOUT_FILENO, "Parent received SIGTERM\n", 24);
}

void handle_sigint(int signum) {
    (void)signum;
    sigint_received = 1;
    write(STDOUT_FILENO, "Parent received SIGINT\n", 23);
}

int main(void) {
    pid_t pid1, pid2;

    /* Install signal handlers in the parent process */
    struct sigaction sa_term;
    sa_term.sa_handler = handle_sigterm;
    sigemptyset(&sa_term.sa_mask);
    sa_term.sa_flags = 0;
    if (sigaction(SIGTERM, &sa_term, NULL) == -1) {
        perror("sigaction SIGTERM");
        return EXIT_FAILURE;
    }

    struct sigaction sa_int;
    sa_int.sa_handler = handle_sigint;
    sigemptyset(&sa_int.sa_mask);
    sa_int.sa_flags = 0;
    if (sigaction(SIGINT, &sa_int, NULL) == -1) {
        perror("sigaction SIGINT");
        return EXIT_FAILURE;
    }

    /* Fork first child that will send SIGTERM after 5 seconds */
    pid1 = fork();
    if (pid1 < 0) {
        perror("fork");
        return EXIT_FAILURE;
    }
    if (pid1 == 0) {
        sleep(5);
        kill(getppid(), SIGTERM);
        _exit(0);
    }

    /* Fork second child that will send SIGINT after 10 seconds */
    pid2 = fork();
    if (pid2 < 0) {
        perror("fork");
        return EXIT_FAILURE;
    }
    if (pid2 == 0) {
        sleep(10);
        kill(getppid(), SIGINT);
        _exit(0);
    }

    /* Parent runs indefinitely until both signals are received */
    while (1) {
        pause(); /* Wait for signals */
        if (sigterm_received) {
            /* Could perform cleanup or ignore termination; here we just
             * acknowledge the signal. Do not exit yet. */
            sigterm_received = 0;
        }
        if (sigint_received) {
            /* Time to exit gracefully */
            sigint_received = 0;
            break;
        }
    }

    /* Wait for children to finish to avoid zombies */
    int status;
    while (wait(&status) > 0) {
        /* Reap all children */
    }

    printf("Parent exiting gracefully.\n");
    return EXIT_SUCCESS;
}