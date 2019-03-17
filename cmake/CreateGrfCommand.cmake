function(create_grf_command)
    set(EXTRA_PNG_SOURCE_FILES ${ARGV})

    get_filename_component(GRF_SOURCE_FOLDER_NAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
    get_filename_component(GRF_BINARY_FILE ${CMAKE_CURRENT_SOURCE_DIR}/../${GRF_SOURCE_FOLDER_NAME}.grf ABSOLUTE)
    file(GLOB_RECURSE GRF_PNG_SOURCE_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.png)
    set(GRF_PNG_SOURCE_FILES ${GRF_PNG_SOURCE_FILES} ${EXTRA_PNG_SOURCE_FILES})

    # Copy over all the PNG files to the correct folder
    foreach(GRF_PNG_SOURCE_FILE IN LISTS GRF_PNG_SOURCE_FILES)
        get_filename_component(GRF_PNG_SOURCE_FILE_NAME "${GRF_PNG_SOURCE_FILE}" NAME)
        set(GRF_PNG_BINARY_FILE "${CMAKE_CURRENT_BINARY_DIR}/sprites/${GRF_PNG_SOURCE_FILE_NAME}")

        add_custom_command(OUTPUT ${GRF_PNG_BINARY_FILE}
                COMMAND ${CMAKE_COMMAND} -E copy
                        ${GRF_PNG_SOURCE_FILE}
                        ${GRF_PNG_BINARY_FILE}
                MAIN_DEPENDENCY ${GRF_PNG_SOURCE_FILE}
                COMMENT "Copying ${GRF_PNG_SOURCE_FILE_NAME} sprite file"
        )

        list(APPEND GRF_PNG_BINARY_FILES ${GRF_PNG_BINARY_FILE})
    endforeach(GRF_PNG_SOURCE_FILE)

    add_custom_command(OUTPUT ${GRF_BINARY_FILE}
            COMMAND ${CMAKE_COMMAND}
                    -DGRF_SOURCE_FOLDER=${CMAKE_CURRENT_SOURCE_DIR}
                    -DGRF_BINARY_FILE=${GRF_BINARY_FILE}
                    -DNFORENUM_EXECUTABLE=${NFORENUM_EXECUTABLE}
                    -DGRFCODEC_EXECUTABLE=${GRFCODEC_EXECUTABLE}
                    -P ${CMAKE_SOURCE_DIR}/cmake/scripts/CreateGRF.cmake
            DEPENDS ${GRF_PNG_BINARY_FILES}
                    ${CMAKE_SOURCE_DIR}/cmake/scripts/CreateGRF.cmake
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
            COMMENT "Generating ${GRF_SOURCE_FOLDER_NAME}.grf"
    )

    # For conviance, if you want to only test building the GRF
    add_custom_target(${GRF_SOURCE_FOLDER_NAME}.grf
            DEPENDS
            ${GRF_BINARY_FILE}
    )
endfunction()
