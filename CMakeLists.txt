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

# --- SDL2 -------------------------------------------------------------------
find_package(SDL2 REQUIRED)
find_package(SDL2_image REQUIRED)

# --- target -----------------------------------------------------------------
# A MODULE library is loaded dynamically by SWI-Prolog.  target_link_swipl
# adds the SWI include dirs, links libswipl only when the platform needs it,
# and strips the "lib" prefix so the file is sdl.so (not libsdl.so).
add_library(sdl MODULE sdl.cpp)
target_link_swipl(sdl)
target_link_libraries(sdl PRIVATE SDL2::SDL2 SDL2_image::SDL2_image)

# Place the shared object at <build>/lib/<arch>/sdl.so, mirroring the pack
# layout so local builds and installed packs are structured identically.
set_target_properties(sdl PROPERTIES
  LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${swipl_module_dir}
  RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${swipl_module_dir})

# Install the shared object into the pack's lib/<arch> directory, where
# use_foreign_library(foreign(sdl)) expects it.
install(TARGETS sdl
        DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/${swipl_module_dir})

# --- tests ------------------------------------------------------------------
enable_testing()
add_test(
  NAME sdl
  COMMAND ${SWIPL}
          -p library=${CMAKE_SOURCE_DIR}/prolog
          -p foreign=$<TARGET_FILE_DIR:sdl>
          -g "load_files('tests/sdl.plt',[if(changed),imports([])]),run_tests,halt"
          -t halt
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

add_custom_target(check
  COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
  DEPENDS sdl)
