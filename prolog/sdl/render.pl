/*  Part of the SDL3 pack for SWI-Prolog.

    SDL_render.h — 2D hardware-accelerated renderer, textures, drawing.

    @see https://wiki.libsdl.org/SDL3/SDL_render
*/

:- module(sdl_render, [
    sdl_createrenderer/3,
    sdl_setrendervsync/2,
    sdl_destroyrenderer/1,
    sdl_renderclear/1,
    sdl_rendertexture/4,
    sdl_renderpresent/1,
    sdl_createtexturefromsurface/3,
    sdl_createtexture/6,
    sdl_destroytexture/1,
    sdl_setrenderdrawcolor/5,
    sdl_renderrect/2,
    sdl_renderfillrect/2,
    sdl_updatetexture/4,
    sdl_locktexture/4,
    sdl_unlocktexture/1,
    sdl_texture_access/2
]).

:- use_module(library(sdl/foreign), [
    sdl_createrenderer_/3,
    sdl_setrendervsync_/2,
    sdl_destroyrenderer/1,
    sdl_renderclear/1,
    sdl_rendertexture_/4,
    sdl_renderpresent/1,
    sdl_createtexturefromsurface_/3,
    sdl_createtexture_/6,
    sdl_destroytexture/1,
    sdl_setrenderdrawcolor_/5,
    sdl_renderrect_/2,
    sdl_renderfillrect_/2,
    sdl_updatetexture_/4,
    sdl_locktexture_/4,
    sdl_unlocktexture_/1,
    sdl_renderer_blob_portray/2,
    sdl_texture_blob_portray/2
]).
:- reexport(library(sdl/foreign), [
    sdl_destroyrenderer/1,
    sdl_renderclear/1,
    sdl_renderpresent/1,
    sdl_destroytexture/1
]).
:- use_module(library(sdl/pixels), [sdl_pixel_format/2]).
:- use_module(library(sdl/surface)).   % for sdl_surface_blob type
:- use_module(library(ptr)).

:- multifile error:has_type/2.
error:has_type(sdl_renderer_blob, X) :- blob(X, sdl_renderer_blob).
error:has_type(sdl_texture_blob,  X) :- blob(X, sdl_texture_blob).
error:has_type(sdl_texture_access, X) :- sdl_texture_access(X, _).

:- multifile prolog:error_message//1.
prolog:error_message(type_error(sdl_renderer_blob, Culprit)) -->
   [ 'sdl_renderer_blob, found ~q'-[Culprit] ].
prolog:error_message(type_error(sdl_texture_blob, Culprit)) -->
   [ 'sdl_texture_blob, found ~q'-[Culprit] ].
prolog:error_message(type_error(sdl_texture_access, Culprit)) -->
   { findall(F, sdl_texture_access(F, _), Fs) },
   [ 'sdl_texture_access (one of ~q), found ~q'-[Fs, Culprit] ].

%!  sdl_renderclear(+Renderer:blob) is det.
%
%   Clear the current rendering target with the drawing color.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_RenderClear

%!  sdl_renderpresent(+Renderer:blob) is det.
%
%   Present the rendered frame to the screen.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_RenderPresent

%!  sdl_destroyrenderer(+Renderer:blob) is det.
%
%   Destroy a previously created renderer blob.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_DestroyRenderer

%!  sdl_destroytexture(+Texture:blob) is det.
%
%   Destroy a previously created texture blob.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_DestroyTexture

user:portray(Renderer) :-
   blob(Renderer, sdl_renderer_blob), !,
   sdl_renderer_blob_portray(current_output, Renderer).
user:portray(Texture) :-
   blob(Texture, sdl_texture_blob), !,
   sdl_texture_blob_portray(current_output, Texture).

%!  sdl_createrenderer(-Renderer:blob, +Window:blob, +Name:term) is det.
%
%   Create a 2D hardware-accelerated renderer for the given window.  Name
%   selects the driver (null for the default) or a string naming a driver.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_CreateRenderer

sdl_createrenderer(Renderer, Window, Name) :-
   must_be(var, Renderer),
   must_be(sdl_window_blob, Window),
   must_be((oneof([null]) ; string), Name),
   sdl_createrenderer_(Renderer, Window, Name).

%!  sdl_setrendervsync(+Renderer:blob, +VSync:integer) is det.
%
%   Toggle the renderer's vsync synchronization.  VSync is 0 (off), 1 (on)
%   or a negative value for "late" vsync.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_SetRenderVSync

sdl_setrendervsync(Renderer, VSync) :-
   must_be(sdl_renderer_blob, Renderer),
   must_be(integer, VSync),
   sdl_setrendervsync_(Renderer, VSync).

%!  sdl_createtexturefromsurface(-Texture:blob, +Renderer:blob, +Surface:blob) is det.
%
%   Create a texture from an existing surface blob.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_CreateTextureFromSurface

sdl_createtexturefromsurface(Texture, Renderer, Surface) :-
   must_be(var, Texture),
   must_be(sdl_renderer_blob, Renderer),
   must_be(sdl_surface_blob, Surface),
   sdl_createtexturefromsurface_(Texture, Renderer, Surface).

%!  sdl_rendertexture(+Renderer:blob, +Texture:blob, +Srcrect:term, +Dstrect:term) is det.
%
%   Draw a texture to the renderer.  Each of Srcrect and Dstrect is null
%   for the corresponding full region, or a term rect(X, Y, W, H).
%
%   @see https://wiki.libsdl.org/SDL3/SDL_RenderTexture

sdl_rendertexture(Renderer, Texture, Srcrect, Dstrect) :-
   must_be(sdl_renderer_blob, Renderer),
   must_be(sdl_texture_blob, Texture),
   maplist(
      must_be((compound(rect(number, number, number, number)) ; oneof([null]))),
      [Srcrect, Dstrect]),
   sdl_rendertexture_(Renderer, Texture, Srcrect, Dstrect).

%!  sdl_setrenderdrawcolor(+Renderer:blob, +R:between(0,255), +G:between(0,255), +B:between(0,255), +A:between(0,255)) is det.
%
%   Set the color used by sdl_renderrect/2 and sdl_renderfillrect/2.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_SetRenderDrawColor

sdl_setrenderdrawcolor(Renderer, R, G, B, A) :-
   must_be(sdl_renderer_blob, Renderer),
   must_be(between(0, 255), R),
   must_be(between(0, 255), G),
   must_be(between(0, 255), B),
   must_be(between(0, 255), A),
   sdl_setrenderdrawcolor_(Renderer, R, G, B, A).

%!  sdl_renderrect(+Renderer:blob, +Rect:rect) is det.
%
%   Draw a rectangle outline.  Rect is a term rect(X, Y, W, H) of numbers.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_RenderRect

sdl_renderrect(Renderer, Rect) :-
   must_be(sdl_renderer_blob, Renderer),
   must_be(compound(rect(number, number, number, number)), Rect),
   sdl_renderrect_(Renderer, Rect).

%!  sdl_renderfillrect(+Renderer:blob, +Rect:rect) is det.
%
%   Draw a filled rectangle.  Rect is a term rect(X, Y, W, H) of numbers.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_RenderFillRect

sdl_renderfillrect(Renderer, Rect) :-
   must_be(sdl_renderer_blob, Renderer),
   must_be(compound(rect(number, number, number, number)), Rect),
   sdl_renderfillrect_(Renderer, Rect).

%!  sdl_texture_access(?Access:atom, ?Value:integer) is nondet.
%
%   Texture access patterns.
%   *  `static`
%   *  `streaming`
%   *  `target`
%
%   @see https://wiki.libsdl.org/SDL3/SDL_TextureAccess

% --- texture access enum ----------------------------------------------------

sdl_texture_access(static, 0).
sdl_texture_access(streaming, 1).
sdl_texture_access(target, 2).

%!  sdl_createtexture(-Texture:blob, +Renderer:blob, +Format:sdl_pixel_format, +Access:sdl_texture_access, +Width:positive_integer, +Height:positive_integer) is det.
%
%   Create a texture.  Format is one of the atoms enumerated by
%   sdl_pixel_format/2 and Access one of the atoms enumerated by
%   sdl_texture_access/2.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_CreateTexture

% --- create texture ---------------------------------------------------------

sdl_createtexture(Texture, Renderer, Format, Access, Width, Height) :-
   must_be(var, Texture),
   must_be(sdl_renderer_blob, Renderer),
   must_be(sdl_pixel_format, Format),
   must_be(sdl_texture_access, Access),
   must_be(positive_integer, Width),
   must_be(positive_integer, Height),
   sdl_pixel_format(Format, IntFormat),
   sdl_texture_access(Access, IntAccess),
   sdl_createtexture_(Texture, Renderer, IntFormat, IntAccess, Width, Height).

%!  sdl_updatetexture(+Texture:blob, +Rect:term, +Pixels:ptr_blob, +Pitch:integer) is det.
%
%   Update a texture with new pixel data from a PtrBlob, avoiding
%   creating/destroying a texture every frame when streaming dynamically
%   rendered content (e.g. cairo).  Rect is null for the entire texture, or
%   a term rect(X, Y, W, H).
%
%   @see https://wiki.libsdl.org/SDL3/SDL_UpdateTexture

sdl_updatetexture(Texture, Rect, Pixels, Pitch) :-
   must_be(sdl_texture_blob, Texture),
   must_be((compound(rect(number, number, number, number)) ; oneof([null])), Rect),
   must_be(ptr_blob, Pixels),
   must_be(integer, Pitch),
   sdl_updatetexture_(Texture, Rect, Pixels, Pitch).

%!  sdl_locktexture(+Texture:blob, +Rect:term, -Pixels:ptr, -Pitch:integer)
%                  is det.
%
%   Lock a texture so it can be updated.  On success Pixels is a PtrBlob to
%   the locked region and Pitch its row stride.  Rect is null for the whole
%   texture, or a term rect(X, Y, W, H).  Use sdl_unlocktexture/1 when done.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_LockTexture

sdl_locktexture(Texture, Rect, Pixels, Pitch) :-
   must_be(sdl_texture_blob, Texture),
   must_be((compound(rect(number, number, number, number)) ; oneof([null])), Rect),
   must_be(var, Pixels),
   must_be(var, Pitch),
   sdl_locktexture_(Texture, Rect, Pixels, Pitch).

%!  sdl_unlocktexture(+Texture:blob) is det.
%
%   Unlock a texture previously locked with sdl_locktexture/4.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_UnlockTexture

sdl_unlocktexture(Texture) :-
   must_be(sdl_texture_blob, Texture),
   sdl_unlocktexture_(Texture).
