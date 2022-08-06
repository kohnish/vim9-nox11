#include "json_msg_handler.h"
#include <stdlib.h>
#include <string.h>

void handle_msg(const char *msg_str) {
    char msg[MAX_VIM_INPUT] = {0};
    char *rest = msg;
    strcpy(msg, msg_str);
    // won't work on wrong message
    const char *line = strtok_r(msg, " ", &rest);
    const char *filename = strtok_r(NULL, " ", &rest);
    const char *cmd = strtok_r(NULL, " ", &rest);
    printf("{\"cmd\": \"%s\", \"file_path\": \"%s\", \"line\": \"%s\"}\n", cmd, filename, line);
    fflush(stdout);
}
