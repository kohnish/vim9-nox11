#ifndef JSON_MSG_HANDLER_H
#define JSON_MSG_HANDLER_H

#include <uv.h>

#define MAX_VIM_INPUT 65536
#define MAX_REAL_RESPONSE_SIZE (PATH_MAX * 2)

#ifdef __cplusplus
extern "C" {
#endif

void handle_msg(uv_loop_t *loop, const char *msg_str);

#ifdef __cplusplus
}
#endif

#endif /* JSON_MSG_HANDLER_H */
