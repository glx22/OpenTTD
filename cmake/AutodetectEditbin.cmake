# Autodetect editbin. Only useful for MSVC.
#
# autodetect_editbin()
#
function(autodetect_editbin)
    if (DEFINED EDITBIN_FOUND)
        return()
    endif (DEFINED EDITBIN_FOUND)

    message(STATUS "Detecting editbin")
    find_program(EDITBIN_EXECUTABLE editbin.exe)

    if (EDITBIN_EXECUTABLE STREQUAL "EDITBIN_EXECUTABLE-NOTFOUND")
        # Possibly we are not inside MSVC; cl.exe and editbin.exe are normally
        # in the same folder, to make an attempt on finding it relative to
        # where the CXX compiler is.
        get_filename_component(MSVC_COMPILE_DIRECTORY ${CMAKE_CXX_COMPILER} DIRECTORY)
        find_program(EDITBIN_EXECUTABLE editbin.exe ${MSVC_COMPILE_DIRECTORY})
    endif (EDITBIN_EXECUTABLE STREQUAL "EDITBIN_EXECUTABLE-NOTFOUND")

    if (EDITBIN_EXECUTABLE STREQUAL "EDITBIN_EXECUTABLE-NOTFOUND")
        message(FATAL_ERROR "editbin is required for this platform; this should be shipped with MSVC!")
    endif (EDITBIN_EXECUTABLE STREQUAL "EDITBIN_EXECUTABLE-NOTFOUND")

    message(STATUS "Detecting editbin - found")

    # Make sure these values are cached properly
    set(EDITBIN_FOUND YES CACHE INTERNAL "")
endfunction()
