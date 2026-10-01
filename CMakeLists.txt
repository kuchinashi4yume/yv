cmake_minimum_required(VERSION 3.20)

project(yv LANGUAGES C CXX)

set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(YV_VERSION 0.0.2)


# ============================================================
# WebView dependency
# ============================================================

include(FetchContent)

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


# ============================================================
# Application
# ============================================================

add_executable(${PROJECT_NAME}
    MACOSX_BUNDLE

    src/main.c
    src/yv.c
)


# ============================================================
# Include directories
# ============================================================

target_include_directories(${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)


# ============================================================
# Bundle metadata
# ============================================================

set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE TRUE

    MACOSX_BUNDLE_BUNDLE_NAME
        "yv"

    MACOSX_BUNDLE_SHORT_VERSION_STRING
        "${YV_VERSION}"

    MACOSX_BUNDLE_BUNDLE_VERSION
        "${YV_VERSION}"

    MACOSX_BUNDLE_GUI_IDENTIFIER
        "com.kuchinashi4yume.yv"
)


# ============================================================
# Web assets
# ============================================================

file(
    GLOB_RECURSE
    YV_WEB_FILES
    CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/www/*"
)

foreach(FILE IN LISTS YV_WEB_FILES)

    if(IS_DIRECTORY "${FILE}")
        continue()
    endif()

    file(
        RELATIVE_PATH
        RELATIVE_FILE
        "${CMAKE_CURRENT_SOURCE_DIR}/www"
        "${FILE}"
    )

    get_filename_component(
        RELATIVE_DIR
        "${RELATIVE_FILE}"
        DIRECTORY
    )

    if(RELATIVE_DIR STREQUAL "")
        set(
            BUNDLE_LOCATION
            "Resources/www"
        )
    else()
        set(
            BUNDLE_LOCATION
            "Resources/www/${RELATIVE_DIR}"
        )
    endif()

    set_source_files_properties(
        "${FILE}"
        PROPERTIES
            MACOSX_PACKAGE_LOCATION
            "${BUNDLE_LOCATION}"
    )

endforeach()

target_sources(
    ${PROJECT_NAME}
    PRIVATE
        ${YV_WEB_FILES}
)


# ============================================================
# Compiler warnings
# ============================================================

target_compile_options(
    ${PROJECT_NAME}
    PRIVATE
        -Wall
        -Wextra
        -Wpedantic
)


# ============================================================
# Libraries
# ============================================================

target_link_libraries(
    ${PROJECT_NAME}
    PRIVATE
        webview::core_static
)


# ============================================================
# Install
# ============================================================

install(
    TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
)