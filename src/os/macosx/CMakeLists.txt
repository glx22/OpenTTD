add_files(
    crashlog_osx.cpp
    macos.h
    macos.mm
    osx_stdafx.h
    splash.h
    string_osx.h
    CONDITION APPLE
)

add_files(
    splash.cpp
    string_osx.cpp
    CONDITION APPLE AND OPTION_COCOA
)
