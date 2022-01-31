#ifndef JSON_MSG_HANDLER_H
#define JSON_MSG_HANDLER_H

#include <uv.h>

#define MAX_VIM_INPUT (PATH_MAX + 10)
#define MAX_REAL_RESPONSE_SIZE (PATH_MAX + 100)

#ifdef __cplusplus
extern "C" {
#endif

void handle_msg(const char *msg_str);

#ifdef __cplusplus
}
#endif

#endif /* JSON_MSG_HANDLER_H */
