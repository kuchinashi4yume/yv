#-------------------------------------------------------------------------------------------------------------------------------------
# Set CMake Minimum Version
# Set ${PROJECT_NAME}
#------------------------------------------------------------------------------------------------------------------------------------- 
cmake_minimum_required(VERSION 3.20)

project(yv LANGUAGES C CXX OBJC)





#-------------------------------------------------------------------------------------------------------------------------------------
# Language and build settings
#-------------------------------------------------------------------------------------------------------------------------------------
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)





#-------------------------------------------------------------------------------------------------------------------------------------
# Default Environment Variables
#-------------------------------------------------------------------------------------------------------------------------------------

# config file name
set(YV_CONFIG_FILE_NAME "yv_config.json")

# config file
set(YV_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
set(YV_CONFIG_HEADER_IN_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/yv_config.h.in")
set(YV_CONFIG_HEADER_PATH "${YV_GENERATED_DIR}/yv_config.h")





#-------------------------------------------------------------------------------------------------------------------------------------
# Read and validate application configuration
#-------------------------------------------------------------------------------------------------------------------------------------

# Set config json file path
set(YV_CONFIG_FILE "${CMAKE_CURRENT_SOURCE_DIR}/${YV_CONFIG_FILE_NAME}")

# Check config json file is exists
if(NOT EXISTS "${YV_CONFIG_FILE}")
    message(FATAL_ERROR "Missing configuration file: ${YV_CONFIG_FILE}")
endif()

# Read config json file
file(READ "${YV_CONFIG_FILE}" YV_CONFIG_JSON)

# Check the config json file is a valid json file
string(JSON YV_CONFIG_ROOT_TYPE
    ERROR_VARIABLE YV_CONFIG_JSON_ERROR
    TYPE "${YV_CONFIG_JSON}"
)

if(NOT YV_CONFIG_JSON_ERROR STREQUAL "NOTFOUND")
    message(FATAL_ERROR
        "Invalid JSON in ${YV_CONFIG_FILE}: ${YV_CONFIG_JSON_ERROR}"
    )
endif()

if(NOT YV_CONFIG_ROOT_TYPE STREQUAL "OBJECT")
    message(FATAL_ERROR
        "Invalid ${YV_CONFIG_FILE}: the root value must be a JSON object"
    )
endif()





#-------------------------------------------------------------------------------------------------------------------------------------
# Read a required field and verify its JSON type.
#-------------------------------------------------------------------------------------------------------------------------------------

# Usage: yv_json_get_required(OUTPUT_VARIABLE STRING name)
#        yv_json_get_required(OUTPUT_VARIABLE NUMBER window width)
function(yv_json_get_required OUTPUT_VARIABLE EXPECTED_TYPE)
    string(JOIN "." _field_path ${ARGN})

    string(JSON _actual_type
        ERROR_VARIABLE _json_error
        TYPE "${YV_CONFIG_JSON}" ${ARGN}
    )

    if(NOT _json_error STREQUAL "NOTFOUND")
        message(FATAL_ERROR
            "${YV_CONFIG_FILE}: missing or invalid field '${_field_path}' (${_json_error})"
        )
    endif()

    if(NOT _actual_type STREQUAL "${EXPECTED_TYPE}")
        message(FATAL_ERROR
            "${YV_CONFIG_FILE}: '${_field_path}' must be JSON type ${EXPECTED_TYPE}, "
            "but found ${_actual_type}"
        )
    endif()

    string(JSON _value
        ERROR_VARIABLE _json_error
        GET "${YV_CONFIG_JSON}" ${ARGN}
    )

    if(NOT _json_error STREQUAL "NOTFOUND")
        message(FATAL_ERROR
            "${YV_CONFIG_FILE}: unable to read '${_field_path}' (${_json_error})"
        )
    endif()

    set("${OUTPUT_VARIABLE}" "${_value}" PARENT_SCOPE)
endfunction()

yv_json_get_required(YV_PRODUCT_NAME STRING name)
yv_json_get_required(YV_VERSION STRING version)
yv_json_get_required(YV_IDENTIFIER STRING identifier)
yv_json_get_required(YV_FRONTEND_DIST STRING frontendDist)
yv_json_get_required(YV_WINDOW_TITLE STRING window title)
yv_json_get_required(YV_WINDOW_WIDTH NUMBER window width)
yv_json_get_required(YV_WINDOW_HEIGHT NUMBER window height)
yv_json_get_required(YV_WINDOW_MIN_WIDTH NUMBER window minWidth)
yv_json_get_required(YV_WINDOW_MIN_HEIGHT NUMBER window minHeight)
yv_json_get_required(YV_ICON_RELATIVE_PATH STRING icon)

# check; name 
if(YV_PRODUCT_NAME STREQUAL "")
    message(FATAL_ERROR "${YV_CONFIG_FILE}: 'name' must not be empty")
endif()

# check; window.title 
if(YV_WINDOW_TITLE STREQUAL "")
    message(FATAL_ERROR "${YV_CONFIG_FILE}: 'window.title' must not be empty")
endif()

# check; version
if(NOT YV_VERSION MATCHES "^[0-9]+\\.[0-9]+\\.[0-9]+$")
    message(FATAL_ERROR
        "${YV_CONFIG_FILE}: 'version' must use MAJOR.MINOR.PATCH format, e.g. 0.2.0"
    )
endif()

# check; identifer
if(NOT YV_IDENTIFIER MATCHES "^[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)+$")
    message(FATAL_ERROR
        "${YV_CONFIG_FILE}: 'identifier' must be a reverse-DNS-style identifier, "
        "e.g. com.example.app"
    )
endif()

# check; width height minWidth minHeight
foreach(_dimension IN ITEMS
    YV_WINDOW_WIDTH
    YV_WINDOW_HEIGHT
    YV_WINDOW_MIN_WIDTH
    YV_WINDOW_MIN_HEIGHT
)
    if(NOT "${${_dimension}}" MATCHES "^[1-9][0-9]*$")
        message(FATAL_ERROR
            "${YV_CONFIG_FILE}: '${_dimension}' must be a positive integer"
        )
    endif()
endforeach()

# check; width > minWidth
if(YV_WINDOW_WIDTH LESS YV_WINDOW_MIN_WIDTH)
    message(FATAL_ERROR
        "${YV_CONFIG_FILE}: window.width must be greater than or equal to minWidth"
    )
endif()

# check; height > minHeight
if(YV_WINDOW_HEIGHT LESS YV_WINDOW_MIN_HEIGHT)
    message(FATAL_ERROR
        "${YV_CONFIG_FILE}: window.height must be greater than or equal to minHeight"
    )
endif()





#-------------------------------------------------------------------------------------------------------------------------------------
# Resolve configured paths relative to the project root.
#-------------------------------------------------------------------------------------------------------------------------------------
# is frontendDist exists
get_filename_component(
    YV_FRONTEND_DIR
    "${YV_FRONTEND_DIST}"
    ABSOLUTE
    BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
)

if(NOT IS_DIRECTORY "${YV_FRONTEND_DIR}")
    message(FATAL_ERROR
        "${YV_CONFIG_FILE}: frontendDist directory does not exist: ${YV_FRONTEND_DIR}"
    )
endif()

# is icon exists
get_filename_component(
    YV_ICON_PATH
    "${YV_ICON_RELATIVE_PATH}"
    ABSOLUTE
    BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
)

if(NOT EXISTS "${YV_ICON_PATH}")
    message(FATAL_ERROR
        "${YV_CONFIG_FILE}: icon file does not exist: ${YV_ICON_PATH}"
    )
endif()

# set icon
get_filename_component(YV_ICON_NAME "${YV_ICON_PATH}" NAME)





#-------------------------------------------------------------------------------------------------------------------------------------
# Escape string values so they can be safely emitted as C string literals.
#-------------------------------------------------------------------------------------------------------------------------------------
function(yv_escape_c_string INPUT_VARIABLE OUTPUT_VARIABLE)
    set(_value "${INPUT_VARIABLE}")

    string(ASCII 10 _newline)
    string(ASCII 13 _carriage_return)
    string(ASCII 9 _tab)

    string(REPLACE "\\" "\\\\" _value "${_value}")
    string(REPLACE "\"" "\\\"" _value "${_value}")
    string(REPLACE "${_newline}" "\\n" _value "${_value}")
    string(REPLACE "${_carriage_return}" "\\r" _value "${_value}")
    string(REPLACE "${_tab}" "\\t" _value "${_value}")

    set("${OUTPUT_VARIABLE}" "${_value}" PARENT_SCOPE)
endfunction()

yv_escape_c_string("${YV_PRODUCT_NAME}" YV_PRODUCT_NAME_C)
yv_escape_c_string("${YV_WINDOW_TITLE}" YV_WINDOW_TITLE_C)





#-------------------------------------------------------------------------------------------------------------------------------------
# Generate the header consumed by the C and Objective-C application code.
#-------------------------------------------------------------------------------------------------------------------------------------
file(MAKE_DIRECTORY "${YV_GENERATED_DIR}")

configure_file(
    ${YV_CONFIG_HEADER_IN_PATH}
    ${YV_CONFIG_HEADER_PATH}
    @ONLY
)





#-------------------------------------------------------------------------------------------------------------------------------------
# Dependencies: Initialize
#-------------------------------------------------------------------------------------------------------------------------------------
include(FetchContent)

# CMake 4.x: provide a policy floor for third-party subprojects.
# CMake versions older than 4.0 do not use this variable.
if(CMAKE_VERSION VERSION_GREATER_EQUAL 4.0)
    set(CMAKE_POLICY_VERSION_MINIMUM 3.10)
endif()





#-------------------------------------------------------------------------------------------------------------------------------------
# Dependencies: webview/webview
#-------------------------------------------------------------------------------------------------------------------------------------
FetchContent_Declare(
    webview
    GIT_REPOSITORY https://github.com/webview/webview.git
    GIT_TAG 0.12.0
)

set(WEBVIEW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(WEBVIEW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(WEBVIEW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(WEBVIEW_BUILD_AMALGAMATION OFF CACHE BOOL "" FORCE)
set(WEBVIEW_BUILD_STATIC_LIBRARY ON CACHE BOOL "" FORCE)
set(WEBVIEW_BUILD_SHARED_LIBRARY OFF CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(webview)





#-------------------------------------------------------------------------------------------------------------------------------------
# Dependencies: civetweb/civetweb
#-------------------------------------------------------------------------------------------------------------------------------------
FetchContent_Declare(
    civetweb
    GIT_REPOSITORY https://github.com/civetweb/civetweb.git
    GIT_TAG v1.16
)

set(CIVETWEB_BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(CIVETWEB_ENABLE_SERVER_EXECUTABLE OFF CACHE BOOL "" FORCE)
set(CIVETWEB_INSTALL_EXECUTABLE OFF CACHE BOOL "" FORCE)
set(CIVETWEB_ENABLE_CXX OFF CACHE BOOL "" FORCE)
set(CIVETWEB_ENABLE_WEBSOCKETS OFF CACHE BOOL "" FORCE)
set(CIVETWEB_ENABLE_HTTP2 OFF CACHE BOOL "" FORCE)
set(CIVETWEB_ENABLE_IPV6 OFF CACHE BOOL "" FORCE)
set(CIVETWEB_ENABLE_LUA OFF CACHE BOOL "" FORCE)
set(CIVETWEB_ENABLE_DUKTAPE OFF CACHE BOOL "" FORCE)
set(CIVETWEB_ENABLE_SERVER_STATS OFF CACHE BOOL "" FORCE)
set(CIVETWEB_ENABLE_X_DOM_SOCKET OFF CACHE BOOL "" FORCE)
set(CIVETWEB_ENABLE_SSL OFF CACHE BOOL "" FORCE)
set(CIVETWEB_ENABLE_ZLIB OFF CACHE BOOL "" FORCE)
set(CIVETWEB_ENABLE_ASAN OFF CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(civetweb)





#-------------------------------------------------------------------------------------------------------------------------------------
# Application target and bundle resources
#-------------------------------------------------------------------------------------------------------------------------------------
set_source_files_properties(
    "${YV_ICON_PATH}"
    PROPERTIES
        MACOSX_PACKAGE_LOCATION "Resources"
)

add_executable(${PROJECT_NAME}
    MACOSX_BUNDLE
    src/main.c
    src/yv.c
    src/yv_www.c
    src/yv/yv_macos.m
    "${YV_ICON_PATH}"
    ${YV_CONFIG_HEADER_PATH}
)





#-------------------------------------------------------------------------------------------------------------------------------------
# Web assets
#-------------------------------------------------------------------------------------------------------------------------------------
file(GLOB_RECURSE YV_WEB_FILES
    CONFIGURE_DEPENDS
    LIST_DIRECTORIES FALSE
    "${YV_FRONTEND_DIR}/*"
)

if(NOT YV_WEB_FILES)
    message(FATAL_ERROR
        "No frontend files found in configured directory: ${YV_FRONTEND_DIR}"
    )
endif()

foreach(YV_WEB_FILE IN LISTS YV_WEB_FILES)
    file(RELATIVE_PATH YV_WEB_RELATIVE_PATH
        "${YV_FRONTEND_DIR}"
        "${YV_WEB_FILE}"
    )

    get_filename_component(YV_WEB_RELATIVE_DIR
        "${YV_WEB_RELATIVE_PATH}"
        DIRECTORY
    )

    if(YV_WEB_RELATIVE_DIR STREQUAL "")
        set(YV_WEB_BUNDLE_LOCATION "Resources/www")
    else()
        set(YV_WEB_BUNDLE_LOCATION "Resources/www/${YV_WEB_RELATIVE_DIR}")
    endif()

    set_source_files_properties(
        "${YV_WEB_FILE}"
        PROPERTIES
            MACOSX_PACKAGE_LOCATION "${YV_WEB_BUNDLE_LOCATION}"
    )
endforeach()

target_sources(${PROJECT_NAME}
    PRIVATE
        ${YV_WEB_FILES}
)





#-------------------------------------------------------------------------------------------------------------------------------------
# Include directories and compiler options
#-------------------------------------------------------------------------------------------------------------------------------------
target_include_directories(${PROJECT_NAME}
    PRIVATE
        "${CMAKE_CURRENT_SOURCE_DIR}/include"
        "${CMAKE_CURRENT_SOURCE_DIR}/src"
        "${YV_GENERATED_DIR}"
)

set_source_files_properties(
    src/yv/yv_macos.m
    PROPERTIES
        COMPILE_OPTIONS "-fobjc-arc"
)

target_compile_options(${PROJECT_NAME}
    PRIVATE
        -Wall
        -Wextra
        -Wpedantic
)





#-------------------------------------------------------------------------------------------------------------------------------------
# macOS bundle metadata
#-------------------------------------------------------------------------------------------------------------------------------------
set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE_BUNDLE_NAME "${YV_PRODUCT_NAME}"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "${YV_VERSION}"
    MACOSX_BUNDLE_BUNDLE_VERSION "${YV_VERSION}"
    MACOSX_BUNDLE_GUI_IDENTIFIER "${YV_IDENTIFIER}"
    MACOSX_BUNDLE_ICON_FILE "${YV_ICON_NAME}"
)





#-------------------------------------------------------------------------------------------------------------------------------------
# Link libraries
#-------------------------------------------------------------------------------------------------------------------------------------
target_link_libraries(${PROJECT_NAME}
    PRIVATE
        webview::core_static
        civetweb-c-library
        "-framework CoreFoundation"
        "-framework Cocoa"
)





#-------------------------------------------------------------------------------------------------------------------------------------
# Install
#-------------------------------------------------------------------------------------------------------------------------------------
install(
    TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
)