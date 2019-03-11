add_files(
    cocoa_keys.h
    cocoa_v.h
    cocoa_v.mm
    CONDITION APPLE AND OPTION_COCOA
)

add_files(
    event.mm
    fullscreen.mm
    wnd_quartz.mm
    wnd_quickdraw.mm
    CONDITION APPLE
)
