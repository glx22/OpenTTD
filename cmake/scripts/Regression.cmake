cmake_minimum_required(VERSION 3.5)

if (NOT REGRESSION_TEST)
    message(FATAL_ERROR "Script needs REGRESSION_TEST defined (tip: use -DREGRESSION_TEST=..)")
endif (NOT REGRESSION_TEST)
if (NOT OPENTTD_EXECUTABLE)
    message(FATAL_ERROR "Script needs OPENTTD_EXECUTABLE defined (tip: use -DOPENTTD_EXECUTABLE=..)")
endif (NOT OPENTTD_EXECUTABLE)

if (NOT EXISTS ai/regression/${REGRESSION_TEST}/test.sav)
    message(FATAL_ERROR "Regression test ${REGRESSION_TEST} does not exist (tip: check ai/regression folder for the exist spelling; include 'tst_'!)")
endif ()

# Remove any existing info.nut, disabling that AI
file(GLOB INFO_NUTS ai/regression/*/info.nut)
foreach(INFO_NUT IN LISTS INFO_NUTS)
    execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${INFO_NUT})
endforeach(INFO_NUT)

# Enabling the AI for the test we are running
execute_process(COMMAND ${CMAKE_COMMAND} -E copy
                        ai/regression/regression_info.nut
                        ai/regression/${REGRESSION_TEST}/info.nut
)

# Run the regression test
execute_process(COMMAND ${OPENTTD_EXECUTABLE}
                        -x
                        -c ai/regression/regression.cfg
                        -g ai/regression/${REGRESSION_TEST}/test.sav
                        -snull
                        -mnull
                        -vnull:ticks=30000
                        -d script=2
                        -d misc=9
                OUTPUT_VARIABLE REGRESSION_OUTPUT
                ERROR_VARIABLE REGRESSION_RESULT
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_STRIP_TRAILING_WHITESPACE
)

if (REGRESSION_OUTPUT)
    message(FATAL_ERROR "Unexpected output: ${REGRESSION_OUTPUT}")
endif (REGRESSION_OUTPUT)

if (NOT REGRESSION_RESULT)
    message(FATAL_ERROR "Regression did not output anything; did the compilation fail?")
endif (NOT REGRESSION_RESULT)

# For some reason pointer can be printed as '0x(nil)'
string(REPLACE "0x(nil)" "0x00000000" REGRESSION_RESULT "${REGRESSION_RESULT}")

# Convert the output to a format that is expected (and more readable) by result.txt
string(REPLACE "\ndbg: [script]" "\n" REGRESSION_RESULT "${REGRESSION_RESULT}")
string(REPLACE "\n " "\nERROR: " REGRESSION_RESULT "${REGRESSION_RESULT}")
string(REPLACE "\nERROR: [1] " "\n" REGRESSION_RESULT "${REGRESSION_RESULT}")
string(REPLACE "\n[P] " "\n" REGRESSION_RESULT "${REGRESSION_RESULT}")
string(REGEX REPLACE "dbg: ([^\n]*)\n?" "" REGRESSION_RESULT "${REGRESSION_RESULT}")

# Read the expected result
file(READ ai/regression/${REGRESSION_TEST}/result.txt REGRESSION_EXPECTED)

# Convert the string to a list
string(REPLACE "\n" ";" REGRESSION_RESULT "${REGRESSION_RESULT}")
string(REPLACE "\n" ";" REGRESSION_EXPECTED "${REGRESSION_EXPECTED}")

set(ARGC 0)
set(ERROR NO)

# Compare the output
foreach(RESULT IN LISTS REGRESSION_RESULT)
    list(GET REGRESSION_EXPECTED ${ARGC} EXPECTED)

    if (NOT RESULT STREQUAL EXPECTED)
        message("${ARGC}: - ${EXPECTED}")
        message("${ARGC}: + ${RESULT}'")
        set(ERROR YES)
    endif (NOT RESULT STREQUAL EXPECTED)

    math(EXPR ARGC "${ARGC} + 1")
endforeach(RESULT)

if (ERROR)
    message(FATAL_ERROR "Regression failed")
endif (ERROR)
