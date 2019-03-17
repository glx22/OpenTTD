cmake_minimum_required(VERSION 3.5)

project(OpenTTD)

if (${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message(FATAL_ERROR "In-source builds not allowed. Please run \"cmake ..\" from the bin directory")
endif (${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")

include(Options REQUIRED)
set_options()
set_directory_options()

# Make sure we have Threads available. We don't use autodetect_library here,
# as the CMake 'FindThreads' is a lot more clever, always available, and
# gives us a Threads::Threads dependency to link to our application.
find_package(Threads REQUIRED)

include(AutodetectLibrary REQUIRED)
autodetect_library("zlib" ZLIB ZLIB zlib "" zlib.h z)
autodetect_library("LZMA" LIBLZMA LibLZMA liblzma "" lzma.h lzma)
autodetect_library("lzo" LZO LZO lzo2 lzo lzo1x.h lzo2 lzo)
autodetect_library("PNG" PNG PNG libpng "" png.h png)
autodetect_library("SDL" SDL SDL sdl SDL SDL.h SDL)
autodetect_library("Allegro" ALLEGRO ALLEGRO allegro "" allegro.h alleg)
autodetect_library("fluidsynth" FLUIDSYNTH FLUIDSYNTH fluidsynth "" fluidsynth.h fluidsynth)
autodetect_library("FreeType" FREETYPE Freetype freetype2 freetype2 ft2build.h freetype)
autodetect_library("FontConfig" FONTCONFIG FONTCONFIG fontconfig fontconfig fontconfig.h fontconfig)
autodetect_library("icu-lx" ICU_lx ICU icu-lx "" NOTFOUND NOTFOUND) # Manual lookup is not supported
autodetect_library("icu-i18n" ICU_i18n ICU icu-i18n "" NOTFOUND NOTFOUND) # Manual lookup is not supported
autodetect_library("xdg-basedir" XDG_BASEDIR XDG_BASEDIR libxdg-basedir "" basedir.h xdg-basedir)
if (APPLE)
    autodetect_library("iconv" Iconv Iconv iconv "" iconv.h iconv)

    find_library(AUDIOTOOLBOX_LIBRARY AudioToolbox)
    find_library(AUDIOUNIT_LIBRARY AudioUnit)
    find_library(CARBON_LIBRARY Carbon)
    find_library(COCOA_LIBRARY Cocoa)
endif (APPLE)

if (MSVC)
    include(AutodetectEditbin REQUIRED)
    autodetect_editbin()
endif (MSVC)

# LZO is an utter mess, and works on most platforms by accident.
# The pkg-config that ships with LZO, sets the includepath to the folder
# "lzo", so something like "/usr/include/lzo".
# Now the file "lzo/lzo1x.h" includes "lzo/lzoconf.h". This obvious is wrong,
# as there is no way to include that based on the includepath. Now this, by
# accident, goes unnoticed for most platforms, as it is very likely
# "/usr/include" is also on your searchpath. Other platforms have fixed this
# issue by patching "lzo/lzo1x.h" to include "lzoconf.h" (which is honestly
# the only correct way to do this). With brew on OSX however, they don't
# modify the source, use an unpatched pkg-config, and don't put the root
# folder in the search path for includes. So there this breaks.
# As such, we 'fix' things here by also making sure the root folder is
# included in the search path.
if (LZO_FOUND)
    get_filename_component(LZO_INCLUDE_DIRS "${LZO_INCLUDE_DIRS}/.." ABSOLUTE)
endif (LZO_FOUND)

include(AutodetectSSE REQUIRED)
autodetect_sse()

include(AutodetectXaudio2 REQUIRED)
autodetect_xaudio2()

include(AutodetectGrfcodec REQUIRED)
autodetect_grfcodec()

# IPO is only properly supported from CMake 3.9. Despite the fact we are
# CMake 3.5, still enable IPO if we detect we are 3.9+.
if (NOT CMAKE_VERSION VERSION_LESS 3.9)
    cmake_policy(SET CMP0069 NEW)
    include(CheckIPOSupported)
    check_ipo_supported(RESULT IPO_FOUND)
endif (NOT CMAKE_VERSION VERSION_LESS 3.9)

show_options()

if (UNIX AND NOT APPLE AND NOT OPTION_DEDICATED)
    if (NOT SDL_FOUND)
        message(FATAL_ERROR "SDL is required for this platform")
    endif (NOT SDL_FOUND)
endif (UNIX AND NOT APPLE AND NOT OPTION_DEDICATED)
if (APPLE)
    if (NOT AUDIOTOOLBOX_LIBRARY)
        message(FATAL_ERROR "AudioToolbox is required for this platform")
    endif (NOT AUDIOTOOLBOX_LIBRARY)
    if (NOT AUDIOUNIT_LIBRARY)
        message(FATAL_ERROR "AudioUnit is required for this platform")
    endif (NOT AUDIOUNIT_LIBRARY)
    if (NOT CARBON_LIBRARY)
        message(FATAL_ERROR "Carbon is required for this platform")
    endif (NOT CARBON_LIBRARY)
    if (NOT COCOA_LIBRARY)
        message(FATAL_ERROR "Cocoa is required for this platform")
    endif (NOT COCOA_LIBRARY)
endif (APPLE)

if (MSVC)
    # C++17 for MSVC
    set(CMAKE_CXX_STANDARD 17)
else (MSVC)
    # C++11 for all other targets
    set(CMAKE_CXX_STANDARD 11)
endif (MSVC)

set(CMAKE_CXX_STANDARD_REQUIRED YES)
set(CMAKE_CXX_EXTENSIONS NO)

list(APPEND GENERATED_SOURCE_FILES "${CMAKE_BINARY_DIR}/generated/rev.cpp")
if (WIN32)
    list(APPEND GENERATED_SOURCE_FILES "${CMAKE_BINARY_DIR}/generated/ottdres.rc")
endif (WIN32)

# Generate a target to determine version, which is execute every 'make' run
add_custom_target(find_version
        ${CMAKE_COMMAND}
                -DFIND_VERSION_BINARY_DIR=${CMAKE_BINARY_DIR}/generated
                -P "${CMAKE_SOURCE_DIR}/cmake/scripts/FindVersion.cmake"
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        BYPRODUCTS ${GENERATED_SOURCE_FILES}
)

include(SourceList REQUIRED)
include(Endian REQUIRED)
add_endian_definition()

# Needed by rev.cpp
include_directories(${CMAKE_SOURCE_DIR}/src)
# Needed by everything that uses Squirrel
include_directories(${CMAKE_SOURCE_DIR}/src/3rdparty/squirrel/include)

include(CompileFlags REQUIRED)
compile_flags()

add_executable(openttd WIN32 ${GENERATED_SOURCE_FILES})
# All other files are added via target_sources()

include(AddCustomXXXTimestamp REQUIRED)
add_subdirectory(${CMAKE_SOURCE_DIR}/src)
add_subdirectory(${CMAKE_SOURCE_DIR}/media/baseset)

add_dependencies(openttd
    find_version)

target_link_libraries(openttd
    openttd::languages
    openttd::settings
    openttd::basesets
    Threads::Threads
)

if (IPO_FOUND)
    set_target_properties(openttd PROPERTIES INTERPROCEDURAL_OPTIMIZATION_RELEASE True)
    set_target_properties(openttd PROPERTIES INTERPROCEDURAL_OPTIMIZATION_MINSIZEREL True)
    set_target_properties(openttd PROPERTIES INTERPROCEDURAL_OPTIMIZATION_RELWITHDEBINFO True)
endif (IPO_FOUND)
set_target_properties(openttd PROPERTIES VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/bin")
process_compile_flags()

if (APPLE OR UNIX)
    add_definitions(-DUNIX)
endif (APPLE OR UNIX)

link_library(PNG ENCOURAGED)
link_library(ZLIB ENCOURAGED)
link_library(LIBLZMA ENCOURAGED)
link_library(LZO ENCOURAGED)
link_library(XDG_BASEDIR)

if (NOT OPTION_DEDICATED)
    link_library(FLUIDSYNTH)
    link_library(SDL)
    link_library(ALLEGRO)
    link_library(FREETYPE)
    link_library(FONTCONFIG)
    link_library(ICU_lx)
    link_library(ICU_i18n)
endif (NOT OPTION_DEDICATED)

if (APPLE)
    link_library(Iconv)

    target_link_libraries(openttd ${AUDIOTOOLBOX_LIBRARY})
    target_link_libraries(openttd ${AUDIOUNIT_LIBRARY})
    target_link_libraries(openttd ${CARBON_LIBRARY})
    target_link_libraries(openttd ${COCOA_LIBRARY})

    add_definitions(-DWITH_COCOA)
    add_definitions(-DENABLE_COCOA_QUARTZ)
    add_definitions(-DNO_QUICKTIME)
endif (APPLE)

if (NOT PERSONAL_DIR STREQUAL "(not set)")
    add_definitions(-DWITH_PERSONAL_DIR)
    add_definitions(-DPERSONAL_DIR="${PERSONAL_DIR}")
endif (NOT PERSONAL_DIR STREQUAL "(not set)")

if (NOT SHARED_DIR STREQUAL "(not set)")
    add_definitions(-DWITH_SHARED_DIR)
    add_definitions(-DSHARED_DIR="${SHARED_DIR}")
endif (NOT SHARED_DIR STREQUAL "(not set)")

if (NOT GLOBAL_DIR STREQUAL "(not set)")
    add_definitions(-DGLOBAL_DATA_DIR="${GLOBAL_DIR}")
endif (NOT GLOBAL_DIR STREQUAL "(not set)")

if (SSE_FOUND)
    add_definitions(-DWITH_SSE)
endif (SSE_FOUND)

add_definitions_based_on_options()

if (WIN32)
    add_definitions(-DUNICODE -D_UNICODE)
    add_definitions(-DWITH_UNISCRIBE)

    target_link_libraries(openttd
        ws2_32
        winmm
        imm32
    )
endif (WIN32)

if (CMAKE_SIZEOF_VOID_P EQUAL 8)
    add_definitions(-D_SQ64)
endif (CMAKE_SIZEOF_VOID_P EQUAL 8)

include(CreateRegression REQUIRED)
create_regression()
