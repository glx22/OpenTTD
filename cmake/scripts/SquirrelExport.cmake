cmake_minimum_required(VERSION 3.17)

if(NOT SCRIPT_API_SOURCE_FILE)
    message(FATAL_ERROR "Script needs SCRIPT_API_SOURCE_FILE defined")
endif()
if(NOT SCRIPT_API_BINARY_FILE)
    message(FATAL_ERROR "Script needs SCRIPT_API_BINARY_FILE defined")
endif()
if(NOT SCRIPT_API_FILE)
    message(FATAL_ERROR "Script needs SCRIPT_API_FILE defined")
endif()
if(NOT APIUC)
    message(FATAL_ERROR "Script needs APIUC defined")
endif()
if(NOT APILC)
    message(FATAL_ERROR "Script needs APILC defined")
endif()

macro(dump_fileheader)
    get_filename_component(SCRIPT_API_FILE_NAME "${SCRIPT_API_FILE}" NAME_WE)
    string(APPEND SQUIRREL_EXPORT "\n#include \"../${SCRIPT_API_FILE_NAME}.hpp\"")
    if(NOT "${APIUC}" STREQUAL "Template")
        string(REPLACE "script_" "template_" SCRIPT_API_FILE_NAME "${SCRIPT_API_FILE_NAME}")
        string(APPEND SQUIRREL_EXPORT "\n#include \"../template/${SCRIPT_API_FILE_NAME}.sq.hpp\"")
    endif()
endmacro()

macro(open_namespace)
    if(NOT NAMESPACE_OPENED)
        string(APPEND SQUIRREL_EXPORT "\nnamespace SQConvert {")
        set(NAMESPACE_OPENED TRUE)
    endif()
endmacro()

macro(dump_class_templates NAME)
    string(REGEX REPLACE "^Script" "" REALNAME ${NAME})

    string(APPEND SQUIRREL_EXPORT "\n\ttemplate <> struct Param<${NAME} *> { static inline ${NAME} *Get(HSQUIRRELVM vm, int index) { return  static_cast<${NAME} *>(Squirrel::GetRealInstance(vm, index, \"${REALNAME}\")); } };")
    string(APPEND SQUIRREL_EXPORT "\n\ttemplate <> struct Param<${NAME} &> { static inline ${NAME} &Get(HSQUIRRELVM vm, int index) { return *static_cast<${NAME} *>(Squirrel::GetRealInstance(vm, index, \"${REALNAME}\")); } };")
    string(APPEND SQUIRREL_EXPORT "\n\ttemplate <> struct Param<const ${NAME} *> { static inline const ${NAME} *Get(HSQUIRRELVM vm, int index) { return  static_cast<${NAME} *>(Squirrel::GetRealInstance(vm, index, \"${REALNAME}\")); } };")
    string(APPEND SQUIRREL_EXPORT "\n\ttemplate <> struct Param<const ${NAME} &> { static inline const ${NAME} &Get(HSQUIRRELVM vm, int index) { return *static_cast<${NAME} *>(Squirrel::GetRealInstance(vm, index, \"${REALNAME}\")); } };")
    if("${NAME}" STREQUAL "ScriptEvent")
        string(APPEND SQUIRREL_EXPORT "\n\ttemplate <> struct Return<${NAME} *> { static inline int Set(HSQUIRRELVM vm, ${NAME} *res) { if (res == nullptr) { sq_pushnull(vm); return 1; } Squirrel::CreateClassInstanceVM(vm, \"${REALNAME}\", res, nullptr, DefSQDestructorCallback<${NAME}>, true); return 1; } };")
    elseif("${NAME}" STREQUAL "ScriptText")
        string(APPEND SQUIRREL_EXPORT "\n")
        string(APPEND SQUIRREL_EXPORT "\n\ttemplate <> struct Param<Text *> {")
        string(APPEND SQUIRREL_EXPORT "\n\t\tstatic inline Text *Get(HSQUIRRELVM vm, int index) {")
        string(APPEND SQUIRREL_EXPORT "\n\t\t\tif (sq_gettype(vm, index) == OT_INSTANCE) {")
        string(APPEND SQUIRREL_EXPORT "\n\t\t\t\treturn Param<ScriptText *>::Get(vm, index);")
        string(APPEND SQUIRREL_EXPORT "\n\t\t\t}")
        string(APPEND SQUIRREL_EXPORT "\n\t\t\tif (sq_gettype(vm, index) == OT_STRING) {")
        string(APPEND SQUIRREL_EXPORT "\n\t\t\t\treturn new RawText(Param<const std::string &>::Get(vm, index));")
        string(APPEND SQUIRREL_EXPORT "\n\t\t\t}")
        string(APPEND SQUIRREL_EXPORT "\n\t\t\tif (sq_gettype(vm, index) == OT_NULL) {")
        string(APPEND SQUIRREL_EXPORT "\n\t\t\t\treturn nullptr;")
        string(APPEND SQUIRREL_EXPORT "\n\t\t\t}")
        string(APPEND SQUIRREL_EXPORT "\n\t\t\tthrow sq_throwerror(vm, fmt::format(\"parameter {} has an invalid type ; expected: 'Text'\", index - 1));")
        string(APPEND SQUIRREL_EXPORT "\n\t\t}")
        string(APPEND SQUIRREL_EXPORT "\n\t};")
    else()
        string(APPEND SQUIRREL_EXPORT "\n\ttemplate <> struct Return<${NAME} *> { static inline int Set(HSQUIRRELVM vm, ${NAME} *res) { if (res == nullptr) { sq_pushnull(vm); return 1; } res->AddRef(); Squirrel::CreateClassInstanceVM(vm, \"${REALNAME}\", res, nullptr, DefSQDestructorCallback<${NAME}>, true); return 1; } };")
    endif()
endmacro()

macro(reset_reader)
    unset(ENUMS)
    unset(ENUM_VALUES)
    unset(CONST_VALUES)
    unset(STRUCTS)
    unset(ENUM_STRING_TO_ERRORS)
    unset(ENUM_ERROR_TO_STRINGS)
    unset(METHODS)
    unset(STATIC_METHODS)
    unset(CLS)
    unset(START_SQUIRREL_DEFINE_ON_NEXT_LINE)
    unset(CLS_IN_API)
endmacro()

reset_reader()

file(STRINGS "${SCRIPT_API_FILE}" SOURCE_LINES)

set(NUM_LINE 0)
set(CLS_LEVEL 0)
set(BRACE_LEVEL 0)

macro(doxygen_check)
    if(NOT "${DOXYGEN_SKIP}" STREQUAL "")
        message(FATAL_ERROR "${SCRIPT_API_FILE}:${NUM_LINE}: a DOXYGEN_API block was not properly closed")
    endif()
endmacro()

foreach(LINE IN LISTS SOURCE_LINES)
    math(EXPR NUM_LINE "${NUM_LINE} + 1")
    # Ignore special doxygen blocks
    if("${LINE}" MATCHES "^#ifndef DOXYGEN_API")
        doxygen_check()
        set(DOXYGEN_SKIP "next")
        continue()
    endif()
    if("${LINE}" MATCHES "^#ifdef DOXYGEN_API")
        doxygen_check()
        set(DOXYGEN_SKIP "true")
        continue()
    endif()
    if("${LINE}" MATCHES "^#endif /\\* DOXYGEN_API \\*/")
        unset(DOXYGEN_SKIP)
        continue()
    endif()
    if("${LINE}" MATCHES "^#else")
        if(DOXYGEN_SKIP STREQUAL "next")
            set(DOXYGEN_SKIP "true")
        elseif(DOXYGEN_SKIP STREQUAL "true")
            set(DOXYGEN_SKIP "false")
        endif()
        continue()
    endif()
    if("${DOXYGEN_SKIP}" STREQUAL "true")
        continue()
    endif()

    if("${LINE}" MATCHES "^([\t ]*)\\* @api (.*)$")
        set(LINE ${CMAKE_MATCH_2})
        # By default, classes are not selected
        if(NOT CLS_LEVEL)
            set(API_SELECTED FALSE)
        endif()

        if("${APIUC}" STREQUAL "Template")
            set(API_SELECTED TRUE)
            if("${LINE}" STREQUAL "none" OR "${LINE}" STREQUAL "-all")
                set(API_SELECTED FALSE)
            endif()
            continue()
        endif()

        if("${LINE}" STREQUAL "none" OR "${LINE}" STREQUAL "-all")
            set(API_SELECTED FALSE)
        elseif("${LINE}" MATCHES "-${APILC}")
            set(API_SELECTED FALSE)
        elseif("${LINE}" MATCHES "${APILC}")
            set(API_SELECTED TRUE)
        endif()
        continue()
    endif()

    # Remove the old squirrel stuff
    if("${LINE}" MATCHES "#ifdef DEFINE_SQUIRREL_CLASS")
        set(SQUIRREL_STUFF TRUE)
        continue()
    endif()
    if("${LINE}" MATCHES "^#endif /\\* DEFINE_SQUIRREL_CLASS \\*/")
        unset(SQUIRREL_STUFF)
        continue()
    endif()
    if(SQUIRREL_STUFF)
        continue()
    endif()

    # Count braces to skip function bodies
    string(REGEX REPLACE "[^{]" "" OPENING_BRACES "${LINE}")
    string(LENGTH "${OPENING_BRACES}" OPENING_BRACES)
    string(REGEX REPLACE "[^}]" "" CLOSING_BRACES "${LINE}")
    string(LENGTH "${CLOSING_BRACES}" CLOSING_BRACES)
    math(EXPR BRACE_LEVEL "${BRACE_LEVEL} + ${OPENING_BRACES} - ${CLOSING_BRACES}")

    # Ignore forward declarations of classes
    if("${LINE}" MATCHES "^(\t*)class(.*);")
        continue()
    endif()

    # We only want to have public functions exported for now
    if("${LINE}" MATCHES "^(\t*)class (.*) (: public|: protected|: private|:) ([^ ]*)")
        if(NOT CLS_LEVEL)
            if(NOT DEFINED API_SELECTED)
                message(WARNING "${SCRIPT_API_FILE}:${NUM_LINE}: Class '${CMAKE_MATCH_2}' has no @api. It won't be published to any API.")
                set(API_SELECTED FALSE)
            endif()
            unset(IS_PUBLIC)
            unset(CLS_PARAMS)
            set(CLS_TYPES "x")
            set(CLS_IN_API ${API_SELECTED})
            unset(API_SELECTED)
            set(CLS "${CMAKE_MATCH_2}")
            set(SUPER_CLS "${CMAKE_MATCH_4}")
        elseif(CLS_LEVEL EQUAL 1)
            if(NOT DEFINED API_SELECTED)
                set(API_SELECTED ${CLS_IN_API})
            endif()

            if(API_SELECTED)
                list(APPEND STRUCTS "${CLS}::${CMAKE_MATCH_2}")
            endif()
            unset(API_SELECTED)
        endif()
        math(EXPR CLS_LEVEL "${CLS_LEVEL} + 1")
        continue()
    endif()
    if("${LINE}" MATCHES "^(\t*)public")
        if(CLS_LEVEL EQUAL 1)
            set(IS_PUBLIC TRUE)
        endif()
        continue()
    endif()
    if("${LINE}" MATCHES "^(\t*)protected")
        if(CLS_LEVEL EQUAL 1)
            unset(IS_PUBLIC)
        endif()
        continue()
    endif()
    if("${LINE}" MATCHES "^(\t*)private")
        if(CLS_LEVEL EQUAL 1)
            unset(IS_PUBLIC)
        endif()
        continue()
    endif()

    # Ignore the comments
    if("${LINE}" MATCHES "^#")
        continue()
    endif()
    if("${LINE}" MATCHES "/\\*.*\\*/")
        unset(COMMENT)
        continue()
    endif()
    if("${LINE}" MATCHES "/\\*")
        set(COMMENT TRUE)
        continue()
    endif()
    if("${LINE}" MATCHES "\\*/")
        unset(COMMENT)
        continue()
    endif()
    if(COMMENT)
        continue()
    endif()

    # We need to make specialized conversions for structs
    if("${LINE}" MATCHES "^(\t*)struct ([^ ]*)")
        math(EXPR CLS_LEVEL "${CLS_LEVEL} + 1")

        # Check if we want to publish this struct
        if(NOT DEFINED API_SELECTED)
            set(API_SELECTED ${CLS_IN_API})
        endif()
        if(NOT API_SELECTED)
            unset(API_SELECTED)
            continue()
        endif()
        unset(API_SELECTED)

        if(NOT IS_PUBLIC OR NOT CLS_LEVEL EQUAL 1)
            continue()
        endif()

        list(APPEND STRUCTS "${CLS}::${CMAKE_MATCH_2}")
        continue()
    endif()

    # We need to make specialized conversions for enums
    if("${LINE}" MATCHES "^(\t*)enum ([^ ]*)")
        math(EXPR CLS_LEVEL "${CLS_LEVEL} + 1")

        # Check if we want to publish this enum
        if(NOT DEFINED API_SELECTED)
            set(API_SELECTED ${CLS_IN_API})
        endif()
        if(NOT API_SELECTED)
            unset(API_SELECTED)
            continue()
        endif()
        unset(API_SELECTED)

        if(NOT IS_PUBLIC)
            continue()
        endif()

        set(IN_ENUM TRUE)
        list(APPEND ENUMS "${CLS}::${CMAKE_MATCH_2}")
        continue()
    endif()

    # Maybe the end of the class, if so we can start with the Squirrel export pretty soon
    if(BRACE_LEVEL LESS CLS_LEVEL)
        math(EXPR CLS_LEVEL "${CLS_LEVEL} - 1")
        if(CLS_LEVEL)
            unset(IN_ENUM)
            continue()
        endif()

        if(CLS)
            set(START_SQUIRREL_DEFINE_ON_NEXT_LINE TRUE)
        endif()
        continue()
    endif()

    # Empty/white lines. When we may do the Squirrel export, do that export.
    if("${LINE}" MATCHES "^([ \t]*)$")
        if(NOT START_SQUIRREL_DEFINE_ON_NEXT_LINE)
            continue()
        endif()

        if(NOT CLS_IN_API)
            reset_reader()
            continue()
        endif()

        if(NOT HAS_FILEHEADER)
            dump_fileheader()
            set(HAS_FILEHEADER TRUE)
        endif()

        unset(IS_PUBLIC)
        unset(NAMESPACE_OPENED)

        string(REGEX REPLACE "^Script" "${APIUC}" API_CLS "${CLS}")
        string(REGEX REPLACE "^Script" "${APIUC}" API_SUPER_CLS "${SUPER_CLS}")

        string(APPEND SQUIRREL_EXPORT "\n")

        if("${APIUC}" STREQUAL "Template")
            # Then check whether we have structs/classes to print
            if(DEFINED STRUCTS)
                open_namespace()
                string(APPEND SQUIRREL_EXPORT "\n\t/* Allow inner classes/structs to be used as Squirrel parameters */")
                foreach(STRUCT IN LISTS STRUCTS)
                    dump_class_templates(${STRUCT})
                endforeach()
            endif()

            open_namespace()
            string(APPEND SQUIRREL_EXPORT "\n\t/* Allow ${CLS} to be used as Squirrel parameter */")
            dump_class_templates(${CLS})

            string(APPEND SQUIRREL_EXPORT "\n} // namespace SQConvert")

            reset_reader()
            continue()
        endif()

        string(APPEND SQUIRREL_EXPORT "\n")
        string(APPEND SQUIRREL_EXPORT "\ntemplate <> SQInteger PushClassName<${CLS}, ScriptType::${APIUC}>(HSQUIRRELVM vm) { sq_pushstring(vm, \"${API_CLS}\"); return 1; }")
        string(APPEND SQUIRREL_EXPORT "\n")

        # Then do the registration functions of the class.
        string(APPEND SQUIRREL_EXPORT "\nvoid SQ${API_CLS}_Register(Squirrel &engine)")
        string(APPEND SQUIRREL_EXPORT "\n{")
        string(APPEND SQUIRREL_EXPORT "\n\tDefSQClass<${CLS}, ScriptType::${APIUC}> SQ${API_CLS}(\"${API_CLS}\");")
        if("${SUPER_CLS}" STREQUAL "Text")
            string(APPEND SQUIRREL_EXPORT "\n\tSQ${API_CLS}.PreRegister(engine);")
        else()
            string(APPEND SQUIRREL_EXPORT "\n\tSQ${API_CLS}.PreRegister(engine, \"${API_SUPER_CLS}\");")
        endif()
        if((DEFINED CLS_PARAMS OR DEFINED METHODS) AND NOT "${SUPER_CLS}" MATCHES "^ScriptEvent" AND NOT "${CLS}" STREQUAL "ScriptEvent")
            if("${CLS_TYPES}" STREQUAL "v")
                string(APPEND SQUIRREL_EXPORT "\n\tSQ${API_CLS}.AddSQAdvancedConstructor(engine);")
            else()
                string(APPEND SQUIRREL_EXPORT "\n\tSQ${API_CLS}.AddConstructor<void (${CLS}::*)(${CLS_PARAMS})>(engine, \"${CLS_TYPES}\");")
            endif()
        endif()
        string(APPEND SQUIRREL_EXPORT "\n")

        # Enum values
        set(MLEN 0)
        foreach(ENUM_VALUE IN LISTS ENUM_VALUES)
            string(LENGTH "${ENUM_VALUE}" LEN)
            if(MLEN LESS LEN)
                set(MLEN ${LEN})
            endif()
        endforeach()
        foreach(ENUM_VALUE IN LISTS ENUM_VALUES)
            string(LENGTH "${ENUM_VALUE}" LEN)
            math(EXPR LEN "${MLEN} - ${LEN}")
            unset(SPACES)
            foreach(i RANGE ${LEN})
                string(APPEND SPACES " ")
            endforeach()
            string(APPEND SQUIRREL_EXPORT "\n\tSQ${API_CLS}.DefSQConst(engine, ${CLS}::${ENUM_VALUE},${SPACES}\"${ENUM_VALUE}\");")
        endforeach()
        if(MLEN)
            string(APPEND SQUIRREL_EXPORT "\n")
        endif()

        # Const values
        set(MLEN 0)
        foreach(CONST_VALUE IN LISTS CONST_VALUES)
            string(LENGTH "${CONST_VALUE}" LEN)
            if(MLEN LESS LEN)
                set(MLEN ${LEN})
            endif()
        endforeach()
        foreach(CONST_VALUE IN LISTS CONST_VALUES)
            string(LENGTH "${CONST_VALUE}" LEN)
            math(EXPR LEN "${MLEN} - ${LEN}")
            unset(SPACES)
            foreach(i RANGE ${LEN})
                string(APPEND SPACES " ")
            endforeach()
            string(APPEND SQUIRREL_EXPORT "\n\tSQ${API_CLS}.DefSQConst(engine, ${CLS}::${CONST_VALUE},${SPACES}\"${CONST_VALUE}\");")
        endforeach()
        if(MLEN)
            string(APPEND SQUIRREL_EXPORT "\n")
        endif()

        # Mapping of OTTD strings to errors
        set(MLEN 0)
        foreach(ENUM_STRING_TO_ERROR IN LISTS ENUM_STRING_TO_ERRORS)
            string(REPLACE ":" ";" ENUM_STRING_TO_ERROR "${ENUM_STRING_TO_ERROR}")
            list(GET ENUM_STRING_TO_ERROR 0 ENUM_STRING)
            string(LENGTH "${ENUM_STRING}" LEN)
            if(MLEN LESS LEN)
                set(MLEN ${LEN})
            endif()
        endforeach()
        foreach(ENUM_STRING_TO_ERROR IN LISTS ENUM_STRING_TO_ERRORS)
            string(REPLACE ":" ";" ENUM_STRING_TO_ERROR "${ENUM_STRING_TO_ERROR}")
            list(GET ENUM_STRING_TO_ERROR 0 ENUM_STRING)
            list(GET ENUM_STRING_TO_ERROR 1 ENUM_ERROR)
            string(LENGTH "${ENUM_STRING}" LEN)
            math(EXPR LEN "${MLEN} - ${LEN}")
            unset(SPACES)
            foreach(i RANGE ${LEN})
                string(APPEND SPACES " ")
            endforeach()
            string(APPEND SQUIRREL_EXPORT "\n\tScriptError::RegisterErrorMap(${ENUM_STRING},${SPACES}${CLS}::${ENUM_ERROR});")
        endforeach()
        if(MLEN)
            string(APPEND SQUIRREL_EXPORT "\n")
        endif()

        # Mapping of errors to human 'readable' strings.
        set(MLEN 0)
        foreach(ENUM_ERROR_TO_STRING IN LISTS ENUM_ERROR_TO_STRINGS)
            string(LENGTH "${ENUM_ERROR_TO_STRING}" LEN)
            if(MLEN LESS LEN)
                set(MLEN ${LEN})
            endif()
        endforeach()
        foreach(ENUM_ERROR_TO_STRING IN LISTS ENUM_ERROR_TO_STRINGS)
            string(LENGTH "${ENUM_ERROR_TO_STRING}" LEN)
            math(EXPR LEN "${MLEN} - ${LEN}")
            unset(SPACES)
            foreach(i RANGE ${LEN})
                string(APPEND SPACES " ")
            endforeach()
            string(APPEND SQUIRREL_EXPORT "\n\tScriptError::RegisterErrorMapString(${CLS}::${ENUM_ERROR_TO_STRING},${SPACES}\"${ENUM_ERROR_TO_STRING}\");")
        endforeach()
        if(MLEN)
            string(APPEND SQUIRREL_EXPORT "\n")
        endif()

        # Static methods
        set(MLEN 0)
        foreach(STATIC_METHOD IN LISTS STATIC_METHODS)
            string(REPLACE ":" ";" STATIC_METHOD "${STATIC_METHOD}")
            list(GET STATIC_METHOD 0 FUNCNAME)
            string(LENGTH "${FUNCNAME}" LEN)
            if(MLEN LESS LEN)
                set(MLEN ${LEN})
            endif()
        endforeach()
        foreach(STATIC_METHOD IN LISTS STATIC_METHODS)
            string(REPLACE ":" ";" STATIC_METHOD "${STATIC_METHOD}")
            list(GET STATIC_METHOD 0 FUNCNAME)
            list(GET STATIC_METHOD 1 TYPES)
            string(LENGTH "${FUNCNAME}" LEN)
            math(EXPR LEN "${MLEN} - ${LEN}")
            if("${TYPES}" STREQUAL "v")
                if(LEN GREATER 8)
                    math(EXPR LEN "${LEN} - 8")
                else()
                    set(LEN 0)
                endif()
            endif()
            unset(SPACES)
            foreach(i RANGE ${LEN})
                string(APPEND SPACES " ")
            endforeach()
            if("${TYPES}" STREQUAL "v")
                string(APPEND SQUIRREL_EXPORT "\n\tSQ${API_CLS}.DefSQAdvancedStaticMethod(engine, &${CLS}::${FUNCNAME},${SPACES}\"${FUNCNAME}\");")
            else()
                string(APPEND SQUIRREL_EXPORT "\n\tSQ${API_CLS}.DefSQStaticMethod(engine, &${CLS}::${FUNCNAME},${SPACES}\"${FUNCNAME}\",${SPACES}\"${TYPES}\");")
            endif()
        endforeach()
        if(MLEN)
            string(APPEND SQUIRREL_EXPORT "\n")
        endif()

        # Non-static methods
        set(MLEN 0)
        foreach(METHOD IN LISTS METHODS)
            string(REPLACE ":" ";" METHOD "${METHOD}")
            list(GET METHOD 0 FUNCNAME)
            string(LENGTH "${FUNCNAME}" LEN)
            if(MLEN LESS LEN)
                set(MLEN ${LEN})
            endif()
        endforeach()
        foreach(METHOD IN LISTS METHODS)
            string(REPLACE ":" ";" METHOD "${METHOD}")
            list(GET METHOD 0 FUNCNAME)
            list(GET METHOD 1 TYPES)
            string(LENGTH "${FUNCNAME}" LEN)
            math(EXPR LEN "${MLEN} - ${LEN}")
            if("${TYPES}" STREQUAL "v")
                if(LEN GREATER 8)
                    math(EXPR LEN "${LEN} - 8")
                else()
                    set(LEN 0)
                endif()
            endif()
            unset(SPACES)
            foreach(i RANGE ${LEN})
                string(APPEND SPACES " ")
            endforeach()
            if("${TYPES}" STREQUAL "v")
                string(APPEND SQUIRREL_EXPORT "\n\tSQ${API_CLS}.DefSQAdvancedMethod(engine, &${CLS}::${FUNCNAME},${SPACES}\"${FUNCNAME}\");")
            else()
                string(APPEND SQUIRREL_EXPORT "\n\tSQ${API_CLS}.DefSQMethod(engine, &${CLS}::${FUNCNAME},${SPACES}\"${FUNCNAME}\",${SPACES}\"${TYPES}\");")
            endif()
        endforeach()
        if(MLEN)
            string(APPEND SQUIRREL_EXPORT "\n")
        endif()

        string(APPEND SQUIRREL_EXPORT "\n\tSQ${API_CLS}.PostRegister(engine);")
        string(APPEND SQUIRREL_EXPORT "\n}")

        reset_reader()

        continue()
    endif()

    # Skip non-public functions
    if(NOT IS_PUBLIC)
        continue()
    endif()

    if(NOT BRACE_LEVEL EQUAL CLS_LEVEL)
        continue()
    endif()

    # Add enums
    if(IN_ENUM)
        string(REGEX MATCH "([^,\t ]+)" ENUM_VALUE "${LINE}")
        list(APPEND ENUM_VALUES "${ENUM_VALUE}")

        # Check if this a special error enum
        list(GET ENUMS -1 ENUM)
        if("${ENUM}" MATCHES ".*::ErrorMessages")
            # syntax:
            # enum ErrorMessages {
            #\tERR_SOME_ERROR,\t// [STR_ITEM1, STR_ITEM2, ...]
            # }

            # Set the mappings
            if("${LINE}" MATCHES "\\[(.*)\\]")
                string(REGEX REPLACE "[ \t]" "" MAPPINGS "${CMAKE_MATCH_1}")
                string(REPLACE "," ";" MAPPINGS "${MAPPINGS}")

                foreach(MAPPING IN LISTS MAPPINGS)
                    list(APPEND ENUM_STRING_TO_ERRORS "${MAPPING}:${ENUM_VALUE}")
                endforeach()

                list(APPEND ENUM_ERROR_TO_STRINGS "${ENUM_VALUE}")
            endif()
        endif()
        continue()
    endif()

    # Add a const (non-enum) value
    if("${LINE}" MATCHES "^[ \t]*static const [^ ]+ ([^ ]+) = -?\\(?[^ ]*\\)?[^ ]+;")
        list(APPEND CONST_VALUES "${CMAKE_MATCH_1}")
        continue()
    endif()
    if("${LINE}" MATCHES "^[ \t]*static constexpr [^ ]+ ([^ ]+) = -?\\(?[^ ]*\\)?[^ ]+;")
        list(APPEND CONST_VALUES "${CMAKE_MATCH_1}")
        continue()
    endif()

    # Add a method to the list
    if("${LINE}" MATCHES "^.*\\(.*\\).*$")
        if(NOT CLS_LEVEL EQUAL 1)
            continue()
        endif()
        if("${LINE}" MATCHES "~")
            if(DEFINED API_SELECTED)
                message(WARNING "${SCRIPT_API_FILE}:${NUM_LINE}: Destructor for '${CLS}' has @api. Tag ignored.")
                unset(API_SELECTED)
            endif()
            continue()
        endif()

        unset(IS_STATIC)
        if("${LINE}" MATCHES "static ")
            set(IS_STATIC TRUE)
        endif()

        string(REGEX REPLACE "(virtual|static|const)[ \t]+" "" LINE "${LINE}")
        string(REGEX REPLACE "{.*" "" LINE "${LINE}")
        set(PARAM_S "${LINE}")
        string(REGEX REPLACE "\\*" "" LINE "${LINE}")
        string(REGEX REPLACE "\\(.*" "" LINE "${LINE}")

        # Parameters start at first "(". Further "(" will appear in ctor lists.
        string(REGEX MATCH "\\(.*" PARAM_S "${PARAM_S}")
        string(REGEX REPLACE "\\).*" "" PARAM_S "${PARAM_S}")
        string(REGEX REPLACE "^\\(" "" PARAM_S "${PARAM_S}")

        string(REGEX MATCH "([^ \t]+)( ([^ ]+))?" RESULT "${LINE}")
        set(FUNCTYPE "${CMAKE_MATCH_1}")
        set(FUNCNAME "${CMAKE_MATCH_3}")
        if("${FUNCTYPE}" STREQUAL "${CLS}" AND NOT FUNCNAME)
            if(DEFINED API_SELECTED)
                message(WARNING "${SCRIPT_API_FILE}:${NUM_LINE}: Constructor for '${CLS}' has @api. Tag ignored.")
                unset(API_SELECTED)
            endif()
            set(CLS_PARAMS "${PARAM_S}")
            if(NOT PARAM_S)
                continue()
            endif()
        elseif(NOT FUNCNAME)
            continue()
        endif()

        string(REPLACE "," ";" PARAMS "${PARAM_S}")
        if(IS_STATIC)
            set(TYPES ".")
        else()
            set(TYPES "x")
        endif()

        foreach(PARAM IN LISTS PARAMS)
            string(STRIP "${PARAM}" PARAM)
            if("${PARAM}" MATCHES "\\*|&")
                if("${PARAM}" MATCHES "^char")
                    # Many types can be converted to string, so use '.', not 's'. (handled by our glue code)
                    string(APPEND TYPES ".")
                elseif("${PARAM}" MATCHES "^void")
                    string(APPEND TYPES "p")
                elseif("${PARAM}" MATCHES "^Array")
                    string(APPEND TYPES "a")
                elseif("${PARAM}" MATCHES "^const Array")
                    string(APPEND TYPES "a")
                elseif("${PARAM}" MATCHES "^Text")
                    string(APPEND TYPES ".")
                elseif("${PARAM}" MATCHES "^std::string")
                    string(APPEND TYPES ".")
                else()
                    string(APPEND TYPES "x")
                endif()
            elseif("${PARAM}" MATCHES "^bool")
                string(APPEND TYPES "b")
            elseif("${PARAM}" MATCHES "^HSQUIRRELVM")
                set(TYPES "v")
            else()
                string(APPEND TYPES "i")
            endif()
        endforeach()

        # Check if we want to publish this function
        if(NOT DEFINED API_SELECTED)
            set(API_SELECTED ${CLS_IN_API})
        endif()
        if(NOT API_SELECTED)
            unset(API_SELECTED)
            continue()
        endif()
        unset(API_SELECTED)

        if("${FUNCTYPE}" STREQUAL "${CLS}" AND NOT FUNCNAME)
            set(CLS_TYPES "${TYPES}")
        elseif("${FUNCNAME}" MATCHES "^_" AND NOT "${TYPES}" STREQUAL "v")
        elseif(IS_STATIC)
            list(APPEND STATIC_METHODS "${FUNCNAME}:${TYPES}")
        else()
            list(APPEND METHODS "${FUNCNAME}:${TYPES}")
        endif()
        continue()
    endif()
endforeach()

doxygen_check()

configure_file(${SCRIPT_API_SOURCE_FILE} ${SCRIPT_API_BINARY_FILE})
