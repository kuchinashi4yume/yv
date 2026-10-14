#include "yv.h"
#include "yv_config.h"
#include "yv_www.h"
#include "yv/yv_macos.h"

#include <webview/webview.h>

#include <stdio.h>

int yv_run(void) {
    unsigned short port = 0;
    if (yv_www_start(NULL, &port) != 0) {
        yv_show_error("failed to start the local http server");
        return 1;
    }

    char url[64];
    int written = snprintf(url, sizeof(url), "http://127.0.0.1:%u/", port);
    if (written < 0 || (size_t)written >= sizeof(url)) {
        yv_www_stop();
        yv_show_error("failed to construct the local url");
        return 1;
    }

    webview_t webview = webview_create(0, 0);
    if (webview == NULL) {
        yv_www_stop();
        yv_show_error("failed to create webview");
        return 1;
    }

    char msg[64];

    webview_error_t error_set_title = webview_set_title(webview, YV_WINDOW_TITLE);
    if (error_set_title != WEBVIEW_ERROR_OK) {
        snprintf(msg, sizeof(msg), "failed to set webview title.\nerror code: %d", (int)error_set_title);
        webview_destroy(webview);
        yv_www_stop();
        yv_show_error(msg);
        return 1;
    }
    
    webview_error_t error_set_size = webview_set_size(webview, YV_WINDOW_WIDTH, YV_WINDOW_HEIGHT, WEBVIEW_HINT_NONE);
    if (error_set_size != WEBVIEW_ERROR_OK) {
        snprintf(msg, sizeof(msg), "failed to set webview size.\nerror code: %d", (int)error_set_size);
        webview_destroy(webview);
        yv_www_stop();
        yv_show_error(msg);
        return 1;
    }
    
    yv_macos_window_set_min_size(webview_get_window(webview), YV_WINDOW_MIN_WIDTH, YV_WINDOW_MIN_HEIGHT);
    
    yv_macos_menu_setup();

    webview_error_t navigate_error = webview_navigate(webview, url);
    if (navigate_error != WEBVIEW_ERROR_OK) {
        snprintf(msg, sizeof(msg), "failed to navigate webview.\nerror code: %d", (int)navigate_error);
        webview_destroy(webview);
        yv_www_stop();
        yv_show_error(msg);
        return 1;
    }

    webview_error_t run_error = webview_run(webview);
    if (run_error != WEBVIEW_ERROR_OK) {
        snprintf(msg, sizeof(msg), "failed to run webview.\nerror code: %d", (int)run_error);
        webview_destroy(webview);
        yv_www_stop();
        yv_show_error(msg);
        return 1;
    }
    
    webview_destroy(webview);
    yv_www_stop();

    return 0;
}