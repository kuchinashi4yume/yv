#ifndef YV_MACOS_MENU_H
#define YV_MACOS_MENU_H

#ifdef __cplusplus
extern "C" {
#endif

void yv_macos_menu_setup(void);
void yv_macos_window_set_min_size(void *native_window, double width, double height);

#ifdef __cplusplus
}
#endif

#endif