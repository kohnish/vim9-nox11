#include "json_msg_handler.h"
#include <string.h>

void handle_msg(uv_loop_t *loop, const char *msg_str) {
    (void)loop;
    if (strlen(msg_str) == 0) {
        return;
    }
    printf("{\"cmd\": \"remote_tab\", \"file_path\": \"%s\"}", msg_str);
    fflush(stdout);
}
