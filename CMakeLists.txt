cmake_minimum_required(VERSION 3.16)

project(sdlpl LANGUAGES CXX)

# Generate compile_commands.json for clangd / neovim (LSP).
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# --- SWI-Prolog -------------------------------------------------------------
# Provides the swipl::libswipl imported target (carries the include dir) and
# the SWIPL_EXECUTABLE variable.
find_package(SWIPL REQUIRED)
# swipl --arch gives the platform subdir it loads foreign libs from.
execute_process(
  COMMAND ${SWIPL_EXECUTABLE} --arch
  OUTPUT_VARIABLE SWIARCH
  OUTPUT_STRIP_TRAILING_WHITESPACE)
set(PACKSODIR "lib/${SWIARCH}")

# --- SDL2 -------------------------------------------------------------------
find_package(SDL2 REQUIRED)
find_package(SDL2_image REQUIRED)

# --- target -----------------------------------------------------------------
add_library(sdl SHARED sdl.cpp)

target_link_libraries(sdl PRIVATE swipl::libswipl SDL2::SDL2 SDL2_image::SDL2_image)

# SWI-Prolog's foreign loader expects sdl.so, not libsdl.so.
set_target_properties(sdl PROPERTIES PREFIX "")

# Place the shared object where swipl expects it: lib/<arch>/sdl.so
set_target_properties(sdl PROPERTIES
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${PACKSODIR}"
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${PACKSODIR}")

# --- convenience targets ----------------------------------------------------
add_custom_target(check
  COMMAND ${SWIPL_EXECUTABLE}
          -p library=${CMAKE_SOURCE_DIR}/prolog
          -p foreign=${CMAKE_BINARY_DIR}/${PACKSODIR}
          -g "load_files('tests/sdl.plt',[if(changed),imports([])]),run_tests,halt"
          -t halt
  DEPENDS sdl
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  VERBATIM)
