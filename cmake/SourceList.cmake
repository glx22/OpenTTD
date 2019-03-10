macro(source_list)
    if (SDL_FOUND)
        set(OPTION_SDL YES)
    else (SDL_FOUND)
        set(OPTION_SDL NO)
    endif (SDL_FOUND)

    if (ALLEGRO_FOUND)
        set(OPTION_ALLEGRO YES)
    else (ALLEGRO_FOUND)
        set(OPTION_ALLEGRO NO)
    endif (ALLEGRO_FOUND)

    if (SSE_FOUND)
        set(OPTION_USE_SSE YES)
    else (SSE_FOUND)
        set(OPTION_USE_SSE NO)
    endif (SSE_FOUND)

    if (XAUDIO2_FOUND)
        set(OPTION_USE_XAUDIO2 YES)
    else (XAUDIO2_FOUND)
        set(OPTION_USE_XAUDIO2 NO)
    endif (XAUDIO2_FOUND)

    if (FLUIDSYNTH_FOUND)
        set(OPTION_FLUIDSYNTH YES)
    else (FLUIDSYNTH_FOUND)
        set(OPTION_FLUIDSYNTH NO)
    endif (FLUIDSYNTH_FOUND)

    set(OPTION_COCOA NO)
    set(OPTION_OSX NO)
    set(OPTION_WIN32 NO)

    if (APPLE)
        set(OPTION_OSX YES)
        set(OPTION_COCOA YES)
    elseif (WIN32)
        set(OPTION_WIN32 YES)
    endif ()

    # These OSes used to be supported by OpenTTD, but have no CMake code yet
    set(OPTION_HAIKU NO)
    set(OPTION_DOS NO)
    set(OPTION_OS2 NO)

    file(READ ${CMAKE_SOURCE_DIR}/source.list SOURCE_LIST)
    string(REPLACE "\n" ";" SOURCE_LIST "${SOURCE_LIST}")
    string(REGEX REPLACE ";\t*" ";" SOURCE_LIST "${SOURCE_LIST}")
    string(REGEX REPLACE "[;]+;" ";" SOURCE_LIST "${SOURCE_LIST}")
    string(REGEX REPLACE ";$" "" SOURCE_LIST "${SOURCE_LIST}")

    set(SCAN_SKIP 0)
    set(SCAN_DEPTH 0)
    foreach (FILE IN LISTS SOURCE_LIST)
        if (${FILE} MATCHES "^#end")
            if (${SCAN_DEPTH} EQUAL ${SCAN_SKIP})
                math(EXPR SCAN_SKIP "${SCAN_SKIP} - 1")
            endif (${SCAN_DEPTH} EQUAL ${SCAN_SKIP})

            math(EXPR SCAN_DEPTH "${SCAN_DEPTH} - 1")

            continue()
        endif (${FILE} MATCHES "^#end")

        if (${FILE} MATCHES "^#else")
            if (${SCAN_DEPTH} EQUAL ${SCAN_SKIP})
                math(EXPR SCAN_SKIP "${SCAN_SKIP} - 1")
            else (${SCAN_DEPTH} EQUAL ${SCAN_SKIP})
                math(EXPR SCAN_DEPTH_PARENT "${SCAN_DEPTH} - 1")
                if (${SCAN_DEPTH_PARENT} EQUAL ${SCAN_SKIP})
                    math(EXPR SCAN_SKIP "${SCAN_SKIP} + 1")
                endif (${SCAN_DEPTH_PARENT} EQUAL ${SCAN_SKIP})
            endif (${SCAN_DEPTH} EQUAL ${SCAN_SKIP})

            continue()
        endif (${FILE} MATCHES "^#else")

        if (${FILE} MATCHES "^#if")
            if (NOT ${SCAN_DEPTH} EQUAL ${SCAN_SKIP})
                math(EXPR SCAN_DEPTH "${SCAN_DEPTH} + 1")
                continue()
            endif (NOT ${SCAN_DEPTH} EQUAL ${SCAN_SKIP})

            math(EXPR SCAN_DEPTH "${SCAN_DEPTH} + 1")

            string(REGEX MATCH "#if (.*)" IF_DEFINE ${FILE})
            set(IF_DEFINE ${CMAKE_MATCH_1})

            if (DEFINED OPTION_${IF_DEFINE})
                if (${OPTION_${IF_DEFINE}})
                    math(EXPR SCAN_SKIP "${SCAN_SKIP} + 1")
                endif (${OPTION_${IF_DEFINE}})
                continue()
            endif (DEFINED OPTION_${IF_DEFINE})

            message(FATAL_ERROR "Define ${IF_DEFINE} is not set")
        endif (${FILE} MATCHES "^#if")

        # Skip any other line starting with #
        if (${FILE} MATCHES "^#")
            continue()
        endif (${FILE} MATCHES "^#")

        # Skip the line if this is not our scan depth
        if (NOT ${SCAN_DEPTH} EQUAL ${SCAN_SKIP})
            continue()
        endif (NOT ${SCAN_DEPTH} EQUAL ${SCAN_SKIP})

        # TODO -- For now, ignore these ugly entries
        if (${FILE} MATCHES "../objs/*")
            continue()
        endif (${FILE} MATCHES "../objs/*")

        list(APPEND SOURCE_FILES ${CMAKE_SOURCE_DIR}/src/${FILE})
    endforeach(FILE)
endmacro()

set_property(GLOBAL PROPERTY source_list)
function(add_files)
    get_property(SOURCE_FILES2 GLOBAL PROPERTY source_list)
    foreach(FILE ${ARGV})
        if (NOT "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_SOURCE_DIR}")
            list(APPEND SOURCE_FILES2 ${CMAKE_CURRENT_SOURCE_DIR}/${FILE})
        else()
            list(APPEND SOURCE_FILES2 ${tmp} ${CMAKE_SOURCE_DIR}/src/${FILE})
        endif()
    endforeach()
    set_property(GLOBAL PROPERTY source_list "${SOURCE_FILES2}")
endfunction(add_files)

function(CheckSourceEquality)
	get_property(SOURCE_FILES2 GLOBAL PROPERTY source_list)

    foreach(FILE ${SOURCE_FILES2})
        list(FIND SOURCE_FILES "${FILE}" FOUND)
        if(FOUND LESS 0)
            message(STATUS "${FILE} only in SOURCE_FILES2")
        endif(FOUND LESS 0)
    endforeach()

    foreach(FILE ${SOURCE_FILES})
        list(FIND SOURCE_FILES2 "${FILE}" FOUND)
        if(FOUND LESS 0)
            message(STATUS "${FILE} only in SOURCE_FILES")
        endif(FOUND LESS 0)
    endforeach()
endfunction(CheckSourceEquality)
