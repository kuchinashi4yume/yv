#include "yv.h"
#include "yv_www.h"
#include "yv/yv_macos_menu.h"

#include <webview/webview.h>

#include <stdio.h>

void yv_run(void) {
    unsigned short port = 0;
    if (yv_http_start(NULL, &port) != 0) return;

    char url[64];
    int written = snprintf(url, sizeof(url), "http://127.0.0.1:%u/", port);
    if (written < 0 || (size_t)written >= sizeof(url)) {
        yv_http_stop();
        return;
    }

    webview_t webview = webview_create(0, 0);
    if (webview == NULL) {
        yv_http_stop();
        return;
    }

    webview_set_title(webview, "yv");
    webview_set_size(webview, 800, 600, WEBVIEW_HINT_NONE);
    
    yv_macos_menu_setup();

    webview_navigate(webview, url);

    webview_run(webview);
    
    webview_destroy(webview);
    yv_http_stop();
}