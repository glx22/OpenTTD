cmake_minimum_required(VERSION 3.5)

project(OpenTTD)

if (${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message(FATAL_ERROR "In-source builds not allowed. Please run \"cmake ..\" from the bin directory")
endif (${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")

include(Options REQUIRED)
set_options()

if (APPLE)
    set(DEFAULT_PERSONAL_DIR "Documents/OpenTTD")
    set(DEFAULT_SHARED_DIR "/Library/Application Support/OpenTTD")
    set(DEFAULT_GLOBAL_DIR "(not set)")
elseif (WIN32)
    set(DEFAULT_PERSONAL_DIR "OpenTTD")
    set(DEFAULT_SHARED_DIR "(not set)")
    set(DEFAULT_GLOBAL_DIR "(not set)")
elseif (UNIX)
    set(DEFAULT_PERSONAL_DIR ".openttd")
    set(DEFAULT_SHARED_DIR "(not set)")
    set(DEFAULT_GLOBAL_DIR "${CMAKE_INSTALL_PREFIX}/share/games/openttd")
else ()
    message(FATAL_ERROR "Unknown OS found; please consider creating a Pull Request to add support for this OS.")
endif ()

if (NOT PERSONAL_DIR)
    set(PERSONAL_DIR "${DEFAULT_PERSONAL_DIR}" CACHE STRING "Personal directory")
    message(STATUS "Detecting Personal Data directory - ${PERSONAL_DIR}")
endif (NOT PERSONAL_DIR)

if (NOT SHARED_DIR)
    set(SHARED_DIR "${DEFAULT_SHARED_DIR}" CACHE STRING "Shared directory")
    message(STATUS "Detecting Shared Data directory - ${SHARED_DIR}")
endif (NOT SHARED_DIR)

if (NOT GLOBAL_DIR)
    set(GLOBAL_DIR "${DEFAULT_GLOBAL_DIR}" CACHE STRING "Global directory")
    message(STATUS "Detecting Global Data directory - ${GLOBAL_DIR}")
endif (NOT GLOBAL_DIR)


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

if (MSVC)
    # Switch to MT (static) instead of MD (dynamic) binary

    # For MSVC two generators are available
    # - a command line generator (Ninja) using CMAKE_BUILD_TYPE to specify the
    #   configuration of the build tree
    # - an IDE generator (Visual Studio) using CMAKE_CONFIGURATION_TYPES to
    #   specify all configurations that will be available in the generated solution
    list(APPEND MSVC_CONFIGS "${CMAKE_BUILD_TYPE}" "${CMAKE_CONFIGURATION_TYPES}")

    # Set usage of static runtime for all configurations
    foreach(MSVC_CONFIG ${MSVC_CONFIGS})
        string(TOUPPER "CMAKE_CXX_FLAGS_${MSVC_CONFIG}" MSVC_FLAGS)
        string(REPLACE "/MD" "/MT" ${MSVC_FLAGS} "${${MSVC_FLAGS}}")
    endforeach()

    # Add DPI manifest to project; other WIN32 targets get this via ottdres.rc
    list(APPEND GENERATED_SOURCE_FILES "${CMAKE_SOURCE_DIR}/os/windows/openttd.manifest")
endif (MSVC)

# Add some -D flags for Debug builds. We cannot use add_definitions(), because
# it does not appear to support the $<> tags.
add_compile_options(
    "$<$<CONFIG:Debug>:-D_DEBUG>"
    "$<$<CONFIG:Debug>:-D_FORTIFY_SOURCE=2>"
)

if (MSVC)
    add_compile_options(/W3)
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
    add_compile_options(
        -W
        -Wall
        -Wcast-qual
        -Wextra
        -Wsign-compare
        -Wundef
        -Wpointer-arith
        -Wwrite-strings
        -Wredundant-decls
        -Wformat-security
        -Wformat=2
        -Winit-self
        -Wnon-virtual-dtor

        # Often parameters are unused, which is fine.
        -Wno-unused-parameter
        # We use 'ABCD' multichar for SaveLoad chunks identifiers
        -Wno-multichar

        # TODO -- Claim is that this is needed when compiling without asserts
        #-Wno-unused-variable
        #-Wno-unused-but-set-parameter
        #-Wno-unused-but-set-variable

        # Compilers complains about that we break strict-aliasing.
        #  On most places we don't see how to fix it, and it doesn't
        #  break anything. So disable strict-aliasing to make the
        #  compiler all happy.
        -fno-strict-aliasing
    )

    if (NOT WIN32)
        # rdynamic is used to get useful stack traces from crash reports.
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -rdynamic")
    endif (NOT WIN32)

    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        add_compile_options(
            # GCC 4.2+ automatically assumes that signed overflows do
            # not occur in signed arithmetics, whereas we are not
            # sure that they will not happen. It furthermore complains
            # about its own optimized code in some places.
            -fno-strict-overflow

            # Prevent optimisation supposing enums are in a range specified by the standard
            # For details, see http://gcc.gnu.org/PR43680
            -fno-tree-vrp

            # -flifetime-dse=2 (default since GCC 6) doesn't play
            # well with our custom pool item allocator
            -flifetime-dse=1
        )
    endif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
else ()
    message(FATAL_ERROR "No warning flags are set for this compiler yet; please consider creating a Pull Request to add support for this compiler.")
endif ()

add_executable(openttd WIN32 ${GENERATED_SOURCE_FILES})
# All other files are added via target_sources()

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

# Find all the files in the regression folder; they need to be copied to the
# build folder before we can run the regression
file(GLOB_RECURSE REGRESSION_SOURCE_FILES ${CMAKE_SOURCE_DIR}/regression/*)
foreach(REGRESSION_SOURCE_FILE IN LISTS REGRESSION_SOURCE_FILES)
    string(REGEX REPLACE "^${CMAKE_SOURCE_DIR}/regression/" "${CMAKE_BINARY_DIR}/ai/" REGRESSION_BINARY_FILE "${REGRESSION_SOURCE_FILE}")
    string(REGEX REPLACE "^${CMAKE_SOURCE_DIR}/regression/" "" REGRESSION_SOURCE_FILE_NAME "${REGRESSION_SOURCE_FILE}")

    if ("${REGRESSION_SOURCE_FILE_NAME}" STREQUAL "regression.cfg")
        continue()
    endif ("${REGRESSION_SOURCE_FILE_NAME}" STREQUAL "regression.cfg")

    add_custom_command(OUTPUT ${REGRESSION_BINARY_FILE}
            COMMAND ${CMAKE_COMMAND} -E copy
                    ${REGRESSION_SOURCE_FILE}
                    ${REGRESSION_BINARY_FILE}
            MAIN_DEPENDENCY ${REGRESSION_SOURCE_FILE}
            COMMENT "Copying ${REGRESSION_SOURCE_FILE_NAME} regression file"
    )

    list(APPEND REGRESSION_BINARY_FILES ${REGRESSION_BINARY_FILE})
endforeach(REGRESSION_SOURCE_FILE)

# Copy the regression configuration in a special folder, so all autogenerated
# folders end up in the same place after running regression.
add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/regression/regression.cfg
        COMMAND ${CMAKE_COMMAND} -E copy
                ${CMAKE_SOURCE_DIR}/regression/regression.cfg
                ${CMAKE_BINARY_DIR}/regression/regression.cfg
        MAIN_DEPENDENCY ${CMAKE_SOURCE_DIR}/regression/regression.cfg
        COMMENT "Copying ${REGRESSION_SOURCE_FILE_NAME} regression file"
)
list(APPEND REGRESSION_BINARY_FILES ${CMAKE_BINARY_DIR}/regression/regression.cfg)

# Create a new target which copies all regression files
add_custom_target(regression_files
        ALL  # this is needed because 'make test' doesn't resolve dependencies, and otherwise this is never executed
        DEPENDS
        ${REGRESSION_BINARY_FILES}
)

enable_testing()

# Find all the tests we have, and create a target for them
file(GLOB REGRESSION_TESTS ${CMAKE_SOURCE_DIR}/regression/*)
foreach(REGRESSION_TEST IN LISTS REGRESSION_TESTS)
    get_filename_component(REGRESSION_TEST_NAME "${REGRESSION_TEST}" NAME)

    if ("${REGRESSION_TEST_NAME}" STREQUAL "regression.cfg")
        continue()
    endif ("${REGRESSION_TEST_NAME}" STREQUAL "regression.cfg")

    add_custom_target(regression_${REGRESSION_TEST_NAME}
            COMMAND ${CMAKE_COMMAND}
                    -DOPENTTD_EXECUTABLE=$<TARGET_FILE:openttd>
                    -DEDITBIN_EXECUTABLE=${EDITBIN_EXECUTABLE}
                    -DREGRESSION_TEST=${REGRESSION_TEST_NAME}
                    -P "${CMAKE_SOURCE_DIR}/cmake/scripts/Regression.cmake"
            DEPENDS openttd regression_files
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            COMMENT "Running regression test ${REGRESSION_TEST_NAME}"
            )

    # Also make sure that 'make test' runs the regression
    add_test(NAME regression_${REGRESSION_TEST_NAME}
            COMMAND ${CMAKE_COMMAND}
                    -DOPENTTD_EXECUTABLE=$<TARGET_FILE:openttd>
                    -DEDITBIN_EXECUTABLE=${EDITBIN_EXECUTABLE}
                    -DREGRESSION_TEST=${REGRESSION_TEST_NAME}
                    -P "${CMAKE_SOURCE_DIR}/cmake/scripts/Regression.cmake"
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

    list(APPEND REGRESSION_TARGETS regression_${REGRESSION_TEST_NAME})
endforeach(REGRESSION_TEST)

# Create a new target which runs the regression
add_custom_target(regression
        DEPENDS ${REGRESSION_TARGETS})
