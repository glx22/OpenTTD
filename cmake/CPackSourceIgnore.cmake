find_package(Git QUIET)
# ${CMAKE_SOURCE_DIR}/.git may be a directory or a regular file
if (GIT_FOUND AND EXISTS "${CMAKE_SOURCE_DIR}/.git")
    execute_process(COMMAND ${GIT_EXECUTABLE} ls-files -o --directory
                    OUTPUT_VARIABLE CPACK_SOURCE_IGNORE_FILES
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )
    string(REPLACE "\n" ";" CPACK_SOURCE_IGNORE_FILES "${CPACK_SOURCE_IGNORE_FILES}")
    string(REPLACE "(" "\\(" CPACK_SOURCE_IGNORE_FILES "${CPACK_SOURCE_IGNORE_FILES}")
endif ()

list(APPEND CPACK_SOURCE_IGNORE_FILES ".git/")
