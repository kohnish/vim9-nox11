#include "json_msg_handler.h"
#include <string.h>

void handle_msg(const char *msg_str) {
    // ToDo: support cmd. For now defaults to edit or vsplit
    printf("{\"cmd\": \"remote\", \"file_path\": \"%s\"}", msg_str);
    fflush(stdout);
}
