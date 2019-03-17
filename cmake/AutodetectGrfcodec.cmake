macro(_autodetect_program FRIENDLY NAME EXECUTABLE)
    if (DEFINED ${NAME}_FOUND)
        return()
    endif (DEFINED ${NAME}_FOUND)

    message(STATUS "Detecting ${FRIENDLY}")
    find_program(${NAME}_EXECUTABLE ${EXECUTABLE})
    if (${NAME}_EXECUTABLE STREQUAL "${NAME}_EXECUTABLE-NOTFOUND")
        message(STATUS "Detecting ${FRIENDLY} - not found")
        set(${NAME}_FOUND NO)
    else (${NAME}_EXECUTABLE STREQUAL "${NAME}_EXECUTABLE-NOTFOUND")
        message(STATUS "Detecting ${FRIENDLY} - found")
        set(${NAME}_FOUND YES)
    endif (${NAME}_EXECUTABLE STREQUAL "${NAME}_EXECUTABLE-NOTFOUND")

    # Make sure these values are cached properly
    set(${NAME}_FOUND "${${NAME}_FOUND}" CACHE INTERNAL "")
endmacro()

function(autodetect_grfcodec)
    _autodetect_program(nforenum NFORENUM nforenum)
    _autodetect_program(grfcodec GRFCODEC grfcodec)
endfunction()
