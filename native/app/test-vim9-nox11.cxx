#include "json_msg_handler.h"
#include "vim9_nox11_env.h"
#include <gtest/gtest.h>

TEST(handle_msg_1, handle_msg_1) {
    handle_msg("+1 test/test /v");
    handle_msg("test/test /v");
    handle_msg("test/test");
}
