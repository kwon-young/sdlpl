cmake_minimum_required(VERSION 3.16)

project(sdlpl LANGUAGES CXX)

# Generate compile_commands.json for clangd / neovim (LSP).
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# --- SWI-Prolog -------------------------------------------------------------
# Locate the swipl.cmake helper shipped with SWI-Prolog.  The pack manager
# sets SWIPL_HOME_DIR for us; for local (non-pack) builds we discover it from
# the swipl executable.  swipl.cmake then figures out include dirs, linking
# requirements and the per-architecture module directory (swipl_module_dir).
if(DEFINED ENV{SWIPL_HOME_DIR})
  set(SWIPL_HOME_DIR $ENV{SWIPL_HOME_DIR})
else()
  find_program(SWIPL_EXECUTABLE swipl REQUIRED)
  execute_process(
    COMMAND ${SWIPL_EXECUTABLE} -g "current_prolog_flag(home,H),write(H)" -t halt
    OUTPUT_VARIABLE SWIPL_HOME_DIR
    OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

list(INSERT CMAKE_MODULE_PATH 0 ${SWIPL_HOME_DIR}/cmake)
include(swipl)

# --- SDL3 -------------------------------------------------------------------
find_package(SDL3 REQUIRED)
find_package(SDL3_image REQUIRED)

# --- Cairo ------------------------------------------------------------------
# Cairo ships a pkg-config file but not a CMake config file on most
# distributions, so discover it via PkgConfig.  pkg_check_modules creates
# the cairo::cairo IMPORTED target.
find_package(PkgConfig REQUIRED)
pkg_check_modules(CAIRO REQUIRED IMPORTED_TARGET cairo)

# --- targets ----------------------------------------------------------------
# A MODULE library is loaded dynamically by SWI-Prolog.  target_link_swipl
# adds the SWI include dirs, links libswipl only when the platform needs it,
# and strips the "lib" prefix so the file is sdl.so (not libsdl.so).
add_library(sdl MODULE sdl.cpp)
target_link_swipl(sdl)
target_link_libraries(sdl PRIVATE SDL3::SDL3 SDL3_image::SDL3_image)

add_library(cairo MODULE cairo.cpp)
target_link_swipl(cairo)
target_link_libraries(cairo PRIVATE PkgConfig::CAIRO)

# Place the shared objects directly into the pack's lib/<arch> directory in the
# source tree.  This is where use_foreign_library(foreign(sdl)) and
# use_foreign_library(foreign(cairo)) load them from and where swipl_add_test()
# looks for them.  The pack build flow runs tests before install, so the modules
# must be present here at build time.  The directory is gitignored.
set_target_properties(sdl cairo PROPERTIES
  LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${swipl_module_dir}
  RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${swipl_module_dir})

install(TARGETS sdl cairo
        DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/${swipl_module_dir})

# --- tests ------------------------------------------------------------------
enable_testing()
swipl_add_test(sdl)
