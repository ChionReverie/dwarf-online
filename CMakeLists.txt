cmake_minimum_required(VERSION 3.19)
project(DwarfOnline)

# Ask for C++-20 standard from compilers
set(CMAKE_CXX_STANDARD 20)
# Require the standard support from compilers.
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# Use only standard c++ to keep code portable
set(CMAKE_CXX_EXTENSIONS OFF)

set(BUILD_STATIC_LIBS ON CACHE INTERNAL "" FORCE)
# set(CPR_FORCE_USE_SYSTEM_CURL OFF CACHE INTERNAL "" FORCE)

include(FetchContent)

FetchContent_Declare(DFHack
    GIT_REPOSITORY https://github.com/DFHack/dfhack.git
    GIT_TAG 53.06-r1
)

FetchContent_Declare(curl
  URL https://curl.se/download/curl-8.17.0.tar.gz
  DOWNLOAD_EXTRACT_TIMESTAMP true
  OVERRIDE_FIND_PACKAGE
)

FetchContent_Declare(cpr
  GIT_REPOSITORY https://github.com/libcpr/cpr.git
  GIT_TAG "1.13.0"  # or a specific version tag
)

FetchContent_MakeAvailable(dfhack curl cpr)

set(CPR_USE_SYSTEM_CURL ON)
# set(BUILD_SHARED_LIBS)
# add_definitions(-DBUILD_SHARED_LIBS=OFF)


set(CODEGEN_OUT include/df/codegen.out.xml)

include(${dfhack_SOURCE_DIR}/plugins/Plugins.cmake)

if(UNIX)
    add_definitions(-DLINUX_BUILD)
    set(GCC_COMMON_FLAGS "-fvisibility=hidden -mtune=generic -Wall -Werror -Wl,--disable-new-dtags -Wno-unknown-pragmas")
endif()

## Dependencies
add_subdirectory(client)