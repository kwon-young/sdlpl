/*  Part of the SDL3 pack for SWI-Prolog.

    SDL_surface.h — surface creation and management.

    @see https://wiki.libsdl.org/SDL3/SDL_surface
*/

:- module(sdl_surface, [
    sdl_destroysurface/1,
    sdl_createsurfacefrom/6
]).

:- use_module(library(sdl/foreign), [
    sdl_createsurfacefrom_/6,
    sdl_destroysurface/1,
    sdl_surface_blob_portray/2
]).
:- reexport(library(sdl/foreign), [sdl_destroysurface/1]).
:- use_module(library(sdl/pixels), [sdl_pixel_format/2]).
:- use_module(library(ptr)).

:- multifile error:has_type/2.
error:has_type(sdl_surface_blob,  X) :- blob(X, sdl_surface_blob).

:- multifile prolog:error_message//1.
prolog:error_message(type_error(sdl_surface_blob, Culprit)) -->
   [ 'sdl_surface_blob, found ~q'-[Culprit] ].

user:portray(Surface) :-
   blob(Surface, sdl_surface_blob), !,
   sdl_surface_blob_portray(current_output, Surface).

%!  sdl_destroysurface(+Surface:blob) is det.
%
%   Destroy a previously created surface blob.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_DestroySurface

%!  sdl_createsurfacefrom(-Surface:blob, +Width:positive_integer, +Height:positive_integer, +Format:sdl_pixel_format, +Pixels:ptr_blob, +Pitch:integer) is det.
%
%   Wrap existing pixel data in an SDL surface without copying.  Pixels is
%   a PtrBlob (e.g. from cairo_image_surface_get_data) whose pointed-to
%   buffer is borrowed by the surface; the surface keeps a reference to the
%   buffer so it stays valid for the surface's lifetime.  Format is one of
%   the atoms enumerated by sdl_pixel_format/2, and Pitch is the byte
%   stride of a row.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_CreateSurfaceFrom

sdl_createsurfacefrom(Surface, Width, Height, Format, Pixels, Pitch) :-
   must_be(var, Surface),
   must_be(positive_integer, Width),
   must_be(positive_integer, Height),
   must_be(sdl_pixel_format, Format),
   must_be(ptr_blob, Pixels),
   must_be(integer, Pitch),
   sdl_pixel_format(Format, IntFormat),
   sdl_createsurfacefrom_(Surface, Width, Height, IntFormat, Pixels, Pitch).
