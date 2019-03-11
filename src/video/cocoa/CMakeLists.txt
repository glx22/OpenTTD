cmake_minimum_required(VERSION 3.5)

if (NOT WIN32)
    add_files(
        cocoa_keys.h
        cocoa_v.h
    )
endif (NOT WIN32)

if (APPLE)
# OSX Files
    if (OPTION_COCOA)
        add_files(
            cocoa_v.mm
            event.mm
            fullscreen.mm
            wnd_quartz.mm
            wnd_quickdraw.mm
        )
    endif (OPTION_COCOA)
endif (APPLE)
