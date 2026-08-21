/*  Part of the SDL3 pack for SWI-Prolog.

    This is the main entry point. It re-exports all themed submodules so
    that `:- use_module(library(sdl)).` provides the complete user-facing API.
*/

:- module(sdl, [
    % The module export list is implicitly populated by reexport/1,
    % but can be explicitly listed here for documentation if desired.
]).

:- reexport(library(sdl/init)).
:- reexport(library(sdl/video)).
:- reexport(library(sdl/render)).
:- reexport(library(sdl/events)).
:- reexport(library(sdl/surface)).
:- reexport(library(sdl/pixels)).
:- reexport(library(sdl/image)).
:- reexport(library(sdl/gpu)).
