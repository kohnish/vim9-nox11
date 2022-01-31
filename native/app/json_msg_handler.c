#include "json_msg_handler.h"
#include <string.h>

void handle_msg(const char *msg_str) {
    printf("{\"cmd\": \"remote_tab\", \"file_path\": \"%s\"}", msg_str);
    fflush(stdout);
}
