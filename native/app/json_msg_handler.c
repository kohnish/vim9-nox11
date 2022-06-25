#include "json_msg_handler.h"
#include <stdlib.h>
#include <string.h>

#define AUTO_FREE_STR __attribute__((__cleanup__(free_str))) 

static void free_str(char **str) {
    free(*str);
}

static void print_trimmed_msg(const char *msg_str, const char *cmd) {
    size_t len = strlen(msg_str) + 1;
    char *msg_copy AUTO_FREE_STR = (char *)malloc(len);
    strcpy(msg_copy, msg_str);
    msg_copy[len - 4] = 0;
    printf("{\"cmd\": \"%s\", \"file_path\": \"%s\"}\n", cmd, msg_copy);
}

void handle_msg(const char *msg_str) {
    const char *filename = strrchr(msg_str, '/');
    if (filename) {
        --filename;
        if (strcmp(filename, " /v") == 0) {
            print_trimmed_msg(msg_str, "remote_vsplit");
        } else if (strcmp(filename, " /t") == 0) {
            print_trimmed_msg(msg_str, "remote_tab");
        } else if (strcmp(filename, " /e") == 0) {
            print_trimmed_msg(msg_str, "remote");
        } else {
            printf("{\"cmd\": \"remote\", \"file_path\": \"%s\"}\n", msg_str);
        }
    } else {
        printf("{\"cmd\": \"remote\", \"file_path\": \"%s\"}\n", msg_str);
    }
    fflush(stdout);
}
