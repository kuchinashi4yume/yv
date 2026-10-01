#include "yv.h"
// #include "yv_http.h"

#include <webview/webview.h>

void run(void) {
    webview_t webview = webview_create(0, 0);

    webview_set_title(webview, "yv");
    webview_set_size(webview, 800, 600, WEBVIEW_HINT_NONE);
    webview_navigate(webview, "http://naver.com");
    webview_run(webview);
    webview_destroy(webview);
}