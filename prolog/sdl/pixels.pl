/*  Part of the SDL3 pack for SWI-Prolog.

    SDL_pixels.h — pixel format enumeration.

    @see https://wiki.libsdl.org/SDL3/SDL_pixels
*/

:- module(sdl_pixels, [
    sdl_pixel_format/2
]).

:- multifile error:has_type/2.
error:has_type(sdl_pixel_format, X) :- sdl_pixel_format(X, _).

:- multifile prolog:error_message//1.
prolog:error_message(type_error(sdl_pixel_format, Culprit)) -->
   { findall(F, sdl_pixel_format(F, _), Fs) },
   [ 'sdl_pixel_format (one of ~q), found ~q'-[Fs, Culprit] ].

%!  sdl_pixel_format(?Format:atom, ?Value:integer) is nondet.
%
%   Enumerate the SDL pixel formats and their exact bit values.  Each
%   format is a Prolog atom linked to its SDL 32-bit pixel format value.
%
%   The user-facing format atoms are:
%     *  `argb8888`, `rgba8888`, `bgra8888`, `abgr8888`
%     *  `xrgb8888`, `xbgr8888`, `rgbx8888`, `bgrx8888`
%     *  `argb32`, `rgba32`, `bgra32`, `abgr32`
%     *  `xrgb32`, `xbgr32`, `rgbx32`, `bgrx32`
%     *  `rgb24`, `bgr24`
%     *  `rgb565`, `bgr565`
%
%   The *8888, *24 and *565 formats are platform-independent.  The *32
%   aliases are platform-dependent: they resolve to the concrete 8888
%   formats according to the CPU byte order of the running platform,
%   as shown in the values below (valid for little-endian builds).  The
%   pack ships as a unit (.pl + .so built for the same platform), so this
%   is always consistent.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_PixelFormat

sdl_pixel_format(argb8888, 0x16362004).
sdl_pixel_format(rgba8888, 0x16462004).
sdl_pixel_format(bgra8888, 0x16862004).
sdl_pixel_format(abgr8888, 0x16762004).
sdl_pixel_format(xrgb8888, 0x16161804).
sdl_pixel_format(xbgr8888, 0x16561804).
sdl_pixel_format(rgbx8888, 0x16261804).
sdl_pixel_format(bgrx8888, 0x16661804).
sdl_pixel_format(argb32, 0x16862004).  % = bgra8888 on LE
sdl_pixel_format(rgba32, 0x16762004).  % = abgr8888 on LE
sdl_pixel_format(bgra32, 0x16362004).  % = argb8888 on LE
sdl_pixel_format(abgr32, 0x16462004).  % = rgba8888 on LE
sdl_pixel_format(xrgb32, 0x16661804).  % = bgrx8888 on LE
sdl_pixel_format(xbgr32, 0x16261804).  % = rgbx8888 on LE
sdl_pixel_format(rgbx32, 0x16561804).  % = xbgr8888 on LE
sdl_pixel_format(bgrx32, 0x16161804).  % = xrgb8888 on LE
sdl_pixel_format(rgb24, 0x17101803).
sdl_pixel_format(bgr24, 0x17401803).
sdl_pixel_format(rgb565, 0x15151002).
sdl_pixel_format(bgr565, 0x15551002).
