#ifndef YV_WWW_H
#define YV_WWW_H

#ifdef __cplusplus
extern "C" {
#endif

int yv_http_start(const char *document_root, unsigned short *port);
void yv_http_stop(void);

#ifdef __cplusplus
}
#endif

#endif