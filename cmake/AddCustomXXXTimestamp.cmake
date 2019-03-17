# Generated files can be older than their dependencies, causing useless
# regenerations. This function replaces each file in OUTPUT with a .timestamp
# file, adds a command to touch it and move the original file in BYPRODUCTS,
# then calls add_custom_command(). Any add_custom_target() depending on files
# in original OUTPUT must use add_custom_target_timestamp() instead to have the
# correct dependencies.
#
# add_custom_command_timestamp(OUTPUT output1 [output2 ...]
#                       COMMAND command1 [ARGS] [args1...]
#                       [COMMAND command2 [ARGS] [args2...] ...]
#                       [MAIN_DEPENDENCY depend]
#                       [DEPENDS [depends...]]
#                       [BYPRODUCTS [files...]]
#                       [IMPLICIT_DEPENDS <lang1> depend1
#                                         [<lang2> depend2] ...]
#                       [WORKING_DIRECTORY dir]
#                       [COMMENT comment]
#                       [VERBATIM] [APPEND] [USES_TERMINAL])
function(add_custom_command_timestamp)
    set(OPTIONS VERBATIM APPEND USES_TERMINAL)
    set(SINGLES MAIN_DEPENDENCY WORKING_DIRECTORY COMMENT)
    set(MULTIS OUTPUT COMMAND DEPENDS BYPRODUCTS IMPLICIT_DEPENDS)

    # Add a marker to multi value keywords and parse the command line
    set(COMMAND_LINE ${ARGN})
    foreach(MULTI IN LISTS MULTIS)
        string(REPLACE "${MULTI}" "${MULTI};:::" COMMAND_LINE "${COMMAND_LINE}")
    endforeach(MULTI)
    cmake_parse_arguments(PARAM "${OPTIONS}" "${SINGLES}" "${MULTIS}" ${COMMAND_LINE})

    # Edit OUTPUT, add the touch command, move to BYPRODUCTS
    string(REPLACE ":::;" "" OUTPUTS "${PARAM_OUTPUT}")
    set(PARAM_OUTPUT ":::")
    if (NOT PARAM_BYPRODUCTS)
        set(PARAM_BYPRODUCTS ":::")
    endif ()
    foreach(OUTPUT IN LISTS OUTPUTS)
        get_filename_component(OUTPUT_FILENAME ${OUTPUT} NAME)
        string(APPEND PARAM_COMMAND ";:::;${CMAKE_COMMAND};-E;touch;${CMAKE_CURRENT_BINARY_DIR}/${OUTPUT_FILENAME}.timestamp")
        list(APPEND PARAM_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${OUTPUT_FILENAME}.timestamp)
        list(APPEND PARAM_BYPRODUCTS ${OUTPUT})
        set_source_files_properties(${OUTPUT} PROPERTIES BYPRODUCT 1)
    endforeach(OUTPUT)

    # Generate the new command line
    unset(COMMAND_LINE)
    foreach(OPTION IN LISTS OPTIONS)
        if (PARAM_${OPTION})
            list(APPEND COMMAND_LINE "${OPTION}")
        endif (PARAM_${OPTION})
    endforeach(OPTION)
    foreach(SINGLE IN LISTS SINGLES)
        if (PARAM_${SINGLE})
            list(APPEND COMMAND_LINE "${SINGLE}" "${PARAM_${SINGLE}}")
        endif (PARAM_${SINGLE})
    endforeach(SINGLE)
    foreach(MULTI IN LISTS MULTIS)
        if (PARAM_${MULTI})
            string(REPLACE ":::" "${MULTI}" PARAM_${MULTI} "${PARAM_${MULTI}}")
            list(APPEND COMMAND_LINE "${PARAM_${MULTI}}")
        endif (PARAM_${MULTI})
    endforeach(MULTI)

    add_custom_command(${COMMAND_LINE})
endfunction(add_custom_command_timestamp)

# Generated files can be older than their dependencies, causing useless
# regenerations. This function adds a .timestamp file for each file in DEPENDS
# replaced by add_custom_command_timestamp(), then calls add_custom_target().
#
# add_custom_target_timestamp(Name [ALL] [command1 [args1...]]
#                      [COMMAND command2 [args2...] ...]
#                      [DEPENDS depend depend depend ... ]
#                      [BYPRODUCTS [files...]]
#                      [WORKING_DIRECTORY dir]
#                      [COMMENT comment]
#                      [VERBATIM] [USES_TERMINAL]
#                      [SOURCES src1 [src2...]])
function(add_custom_target_timestamp)
    set(OPTIONS VERBATIM USES_TERMINAL)
    set(SINGLES WORKING_DIRECTORY COMMENT)
    set(MULTIS COMMAND DEPENDS BYPRODUCTS SOURCES)

    # Add a marker to multi value keywords and parse the command line
    set(COMMAND_LINE ${ARGN})
    foreach(MULTI IN LISTS MULTIS)
        string(REPLACE "${MULTI}" "${MULTI};:::" COMMAND_LINE "${COMMAND_LINE}")
    endforeach(MULTI)
    cmake_parse_arguments(PARAM "${OPTIONS}" "${SINGLES}" "${MULTIS}" ${COMMAND_LINE})

    # Edit DEPENDS
    string(REPLACE ":::;" "" DEPENDS "${PARAM_DEPENDS}")
    set(PARAM_DEPENDS ":::")
    foreach(DEPEND IN LISTS DEPENDS)
        list(APPEND PARAM_DEPENDS "${DEPEND}")
        get_source_file_property(BYPRODUCT ${DEPEND} BYPRODUCT)
        if (NOT "${BYPRODUCT}" STREQUAL "NOTFOUND")
            get_filename_component(DEPEND_FILENAME ${DEPEND} NAME)
            list(APPEND PARAM_DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${DEPEND_FILENAME}.timestamp)
        endif (NOT "${BYPRODUCT}" STREQUAL "NOTFOUND")
    endforeach(DEPEND)

    # Generate the new command line
    set(COMMAND_LINE ${PARAM_UNPARSED_ARGUMENTS})
    foreach(OPTION IN LISTS OPTIONS)
        if (PARAM_${OPTION})
            list(APPEND COMMAND_LINE "${OPTION}")
        endif (PARAM_${OPTION})
    endforeach(OPTION)
    foreach(SINGLE IN LISTS SINGLES)
        if (PARAM_${SINGLE})
            list(APPEND COMMAND_LINE "${SINGLE}" "${PARAM_${SINGLE}}")
        endif (PARAM_${SINGLE})
    endforeach(SINGLE)
    foreach(MULTI IN LISTS MULTIS)
        if (PARAM_${MULTI})
            string(REPLACE ":::" "${MULTI}" PARAM_${MULTI} "${PARAM_${MULTI}}")
            list(APPEND COMMAND_LINE "${PARAM_${MULTI}}")
        endif (PARAM_${MULTI})
    endforeach(MULTI)

    add_custom_target(${COMMAND_LINE})
endfunction(add_custom_target_timestamp)
