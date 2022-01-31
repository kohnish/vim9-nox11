#include "json_msg_handler.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <uv.h>

static void alloc_buffer(uv_handle_t *handle, size_t suggested_size, uv_buf_t *buf) {
    (void)handle;
    (void)suggested_size;
    static char buf_base[MAX_VIM_INPUT];
    memset(buf_base, 0, MAX_VIM_INPUT);
    *buf = uv_buf_init(buf_base, MAX_VIM_INPUT);
}

static void read_pipe_in(uv_stream_t *stream, ssize_t nread, const uv_buf_t *buf) {
    (void)nread;
    static char line[MAX_VIM_INPUT] = {0};
    memset(line, 0, MAX_VIM_INPUT);
    int counter = 0;
    for (size_t i = 0; i < strlen(buf->base); i++) {
        if (buf->base[i] == '\n') {
            handle_msg(line);
            memset(line, 0, MAX_VIM_INPUT);
            counter = 0;
        } else {
            line[counter] = buf->base[i];
            counter++;
        }
    }
    uv_close((uv_handle_t *)stream, NULL);
}

static void on_connection(uv_stream_t *server, int status) {
    (void)status;
    static uv_pipe_t stream = {0};
    int ret = uv_pipe_init(server->loop, &stream, 0);
    stream.data = server;
    if (ret == 0) {
        ret = uv_accept(server, (uv_stream_t *)&stream);
    }

    if (ret == 0) {
        ret = uv_read_start((uv_stream_t *)&stream, alloc_buffer, read_pipe_in);
    }
}

static void on_signal(uv_signal_t *handle, int signum) {
    if (signum == SIGINT) {
        uv_stop(handle->loop);
    }
}

int main(int argc, char *argv[]) {
    static uv_loop_t loop;
    static uv_signal_t sig_handle;
    static uv_pipe_t pipe_handle;
    int ret;
    static char sock_path[PATH_MAX] = {0};
    if (argc == 2) {
        strcpy(sock_path, argv[1]);
    } else {
        fprintf(stderr,"%s %i %i\n", __func__, __LINE__, argc);
        return -1;
    }

    uv_loop_init(&loop);

    ret = uv_pipe_init(&loop, &pipe_handle, 0);
    int b_ret = uv_pipe_bind(&pipe_handle, sock_path);
    ret = uv_listen((uv_stream_t *)&pipe_handle, 0, on_connection);
    if (ret) {
        fprintf(stderr, "%s %i %i\n", __func__, __LINE__, ret);
        if (b_ret == 0) {
            unlink(sock_path);
        }
        return -2;
    }

    uv_signal_init(&loop, &sig_handle);
    uv_signal_start(&sig_handle, on_signal, SIGINT);
    uv_run(&loop, UV_RUN_DEFAULT);

    unlink(sock_path);

    return 0;
}
