/*  Part of the SDL3 pack for SWI-Prolog.

    SDL_image — image loading via SDL3_image.

    @see https://wiki.libsdl.org/SDL_image
*/

:- module(sdl_image, [
    img_load/2
]).

:- use_module(library(sdl/foreign), [img_load_/2]).

%!  img_load(+File:string, -Surface:blob) is det.
%
%   Load an image file into a surface blob.  File is the path to an
%   image; the resulting format is auto-detected.
%
%   @see https://wiki.libsdl.org/SDL_image/IMG_Load

img_load(Surface, File) :-
   must_be(string, File),
   must_be(var, Surface),
   img_load_(Surface, File).
