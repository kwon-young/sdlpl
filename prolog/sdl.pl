:- module(sdl, [sdl_init/1, sdl_quit/0,
                sdl_createwindow/5, sdl_setwindowposition/3, sdl_destroywindow/1,
                sdl_createrenderer/3, sdl_setrendervsync/2, sdl_destroyrenderer/1,
                sdl_renderclear/1, sdl_rendertexture/4, sdl_renderpresent/1,
                sdl_updatetexture/4, sdl_createtexture/6,
                sdl_locktexture/4, sdl_unlocktexture/1,
                img_load/2,
                sdl_destroysurface/1, sdl_createsurfacefrom/6,
                sdl_createtexturefromsurface/3, sdl_destroytexture/1,
                sdl_pollevent/1,
                sdl_setrenderdrawcolor/5, sdl_renderrect/2, sdl_renderfillrect/2,
                sdl_init_flag/2, sdl_window_flag/2, sdl_windowpos/2,
                sdl_pixel_format/2
                ]).
:- use_foreign_library(foreign(sdl)).
:- use_module(library(ptr)).

:- multifile error:has_type/2.
error:has_type(sdl_window_blob,   X) :- blob(X, sdl_window_blob).
error:has_type(sdl_renderer_blob, X) :- blob(X, sdl_renderer_blob).
error:has_type(sdl_surface_blob,  X) :- blob(X, sdl_surface_blob).
error:has_type(sdl_texture_blob,  X) :- blob(X, sdl_texture_blob).
error:has_type(sdl_init_flag,   X) :- sdl_init_flag(X, _).
error:has_type(sdl_window_flag, X) :- sdl_window_flag(X, _).
error:has_type(sdl_windowpos,   X) :- ( atom(X) -> sdl_windowpos(X, _) ; integer(X) ).
error:has_type(sdl_pixel_format, X) :- sdl_pixel_format(X, _).
error:has_type(sdl_texture_access, X) :- sdl_texture_access(X, _).

% Rich error messages listing the valid atoms for each flag type.
:- multifile prolog:error_message//1.
prolog:error_message(type_error(sdl_init_flag, Culprit)) -->
   { findall(F, sdl_init_flag(F, _), Fs) },
   [ 'sdl_init_flag (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_window_flag, Culprit)) -->
   { findall(F, sdl_window_flag(F, _), Fs) },
   [ 'sdl_window_flag (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_windowpos, Culprit)) -->
   { findall(F, sdl_windowpos(F, _), Fs) },
   [ 'sdl_windowpos (one of ~q or an integer pixel offset), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_pixel_format, Culprit)) -->
   { findall(F, sdl_pixel_format(F, _), Fs) },
   [ 'sdl_pixel_format (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_texture_access, Culprit)) -->
   { findall(F, sdl_texture_access(F, _), Fs) },
   [ 'sdl_texture_access (one of ~q), found ~q'-[Fs, Culprit] ].

user:portray(Window) :-
   blob(Window, sdl_window_blob), !,
   sdl_window_blob_portray(current_output, Window).
user:portray(Renderer) :-
   blob(Renderer, sdl_renderer_blob), !,
   sdl_renderer_blob_portray(current_output, Renderer).
user:portray(Surface) :-
   blob(Surface, sdl_surface_blob), !,
   sdl_surface_blob_portray(current_output, Surface).
user:portray(Texture) :-
   blob(Texture, sdl_texture_blob), !,
   sdl_texture_blob_portray(current_output, Texture).

sdl_init_flag(audio, 0x00000010).
sdl_init_flag(video, 0x00000020).
sdl_init_flag(joystick, 0x00000200).
sdl_init_flag(haptic, 0x00001000).
sdl_init_flag(gamepad, 0x00002000).
sdl_init_flag(events, 0x00004000).
sdl_init_flag(sensor, 0x00008000).
sdl_init_flag(camera, 0x00010000).
sdl_init_flag(everything, Flag) :-
   maplist(sdl_init_flag, [audio, video, events, joystick, haptic,
                           gamepad, sensor, camera], Flags),
   or_list(Flags, Flag).

or_list(List, Or) :-
   foldl([B, A, C]>>(C is A \/ B), List, 0, Or).

sdl_init(Flags) :-
   must_be(list(sdl_init_flag), Flags),
   maplist(sdl_init_flag, Flags, IntFlags),
   or_list(IntFlags, IntFlag),
   sdl_init_(IntFlag).

sdl_window_flag(fullscreen, 0x00000001).
sdl_window_flag(opengl, 0x00000002).
sdl_window_flag(occluded, 0x00000004).
sdl_window_flag(hidden, 0x00000008).
sdl_window_flag(borderless, 0x00000010).
sdl_window_flag(resizable, 0x00000020).
sdl_window_flag(minimized, 0x00000040).
sdl_window_flag(maximized, 0x00000080).
sdl_window_flag(mouse_grabbed, 0x00000100).
sdl_window_flag(input_focus, 0x00000200).
sdl_window_flag(mouse_focus, 0x00000400).
sdl_window_flag(external, 0x00000800).
%sdl_window_flag(modal, 0x00001000). requires a parent window
sdl_window_flag(high_pixel_density, 0x00002000).
sdl_window_flag(mouse_capture, 0x00004000).
sdl_window_flag(mouse_relative_mode, 0x00008000).
sdl_window_flag(always_on_top, 0x00010000).
sdl_window_flag(utility, 0x00020000).
%sdl_window_flag(tooltip, 0x00040000). requires a parent window
%sdl_window_flag(popup_menu, 0x00080000). requires a parent window
sdl_window_flag(keyboard_grabbed, 0x00100000).
sdl_window_flag(fill_document, 0x00200000).
sdl_window_flag(vulkan, 0x10000000).
sdl_window_flag(metal, 0x20000000).
sdl_window_flag(transparent, 0x40000000).
sdl_window_flag(not_focusable, 0x80000000).
sdl_window_flag(input_grabbed, Flag) :-
   sdl_window_flag(mouse_grabbed, Flag).
sdl_window_flag(allow_highdpi, Flag) :-
   sdl_window_flag(high_pixel_density, Flag).

% SDL_WINDOWPOS_CENTERED / SDL_WINDOWPOS_UNDEFINED. A window position
% coordinate may be either one of these atoms or a plain integer pixel
% offset; sdl_setwindowposition/3 validates via the sdl_windowpos type and
% translates atoms below before calling the foreign predicate.
sdl_windowpos(centered, 0x2fff0000).
sdl_windowpos(undefined, 0x1fff0000).

sdl_createwindow(Handle, Title, Width, Height, Flags) :-
   must_be(var, Handle),
   must_be(string, Title),
   must_be(positive_integer, Width),
   must_be(positive_integer, Height),
   must_be(list(sdl_window_flag), Flags),
   maplist(sdl_window_flag, Flags, IntFlags),
   or_list(IntFlags, IntFlag),
   sdl_createwindow_(Handle, Title, Width, Height, IntFlag).

sdl_setwindowposition(Window, X, Y) :-
   must_be(sdl_window_blob, Window),
   must_be(sdl_windowpos, X),
   must_be(sdl_windowpos, Y),
   coord(X, Xp),
   coord(Y, Yp),
   sdl_setwindowposition_(Window, Xp, Yp).

coord(C, Cp) :- ( atom(C) -> sdl_windowpos(C, Cp) ; Cp = C ).

sdl_createrenderer(Renderer, Window, Name) :-
   must_be(var, Renderer),
   must_be(sdl_window_blob, Window),
   must_be((oneof([null]) ; string), Name),
   sdl_createrenderer_(Renderer, Window, Name).

sdl_setrendervsync(Renderer, VSync) :-
   must_be(sdl_renderer_blob, Renderer),
   must_be(integer, VSync),
   sdl_setrendervsync_(Renderer, VSync).

img_load(Surface, File) :-
   must_be(string, File),
   must_be(var, Surface),
   img_load_(Surface, File).

sdl_createtexturefromsurface(Texture, Renderer, Surface) :-
   must_be(var, Texture),
   must_be(sdl_renderer_blob, Renderer),
   must_be(sdl_surface_blob, Surface),
   sdl_createtexturefromsurface_(Texture, Renderer, Surface).

sdl_rendertexture(Renderer, Texture, Srcrect, Dstrect) :-
   must_be(sdl_renderer_blob, Renderer),
   must_be(sdl_texture_blob, Texture),
   maplist(
      must_be((compound(rect(number, number, number, number)) ; oneof([null]))),
      [Srcrect, Dstrect]),
   sdl_rendertexture_(Renderer, Texture, Srcrect, Dstrect).

event_struct(quit, []).
event_struct(mousemotion, [windowID, which, state, x, y, xrel, yrel]).
event_struct(mousebutton, [windowID, which, button, state, clicks, x, y]).
event_struct(keyboard, [windowID, state, repeat, keysym]).

sdl_pollevent(Event) :-
   sdl_pollevent_(SDL_Event),
   compound_name_arguments(SDL_Event, Tag, Args),
   event_struct(Tag, Names),
   AllNames = [type, timestamp | Names],
   pairs_keys_values(Pairs, AllNames, Args),
   dict_create(Event, Tag, Pairs).

sdl_setrenderdrawcolor(Renderer, R, G, B, A) :-
   must_be(sdl_renderer_blob, Renderer),
   must_be(between(0, 255), R),
   must_be(between(0, 255), G),
   must_be(between(0, 255), B),
   must_be(between(0, 255), A),
   sdl_setrenderdrawcolor_(Renderer, R, G, B, A).

sdl_renderrect(Renderer, Rect) :-
   must_be(sdl_renderer_blob, Renderer),
   must_be(compound(rect(number, number, number, number)), Rect),
   sdl_renderrect_(Renderer, Rect).

sdl_renderfillrect(Renderer, Rect) :-
   must_be(sdl_renderer_blob, Renderer),
   must_be(compound(rect(number, number, number, number)), Rect),
   sdl_renderfillrect_(Renderer, Rect).

% --- pixel formats ----------------------------------------------------------
% The *8888, *24, and *565 formats are platform-independent.  The *32
% aliases are platform-dependent: they resolve to different concrete
% 8888 formats depending on SDL_BYTEORDER.  The values below are for
% little-endian (x86/ARM-LE); on big-endian they would swap.  Since the
% pack ships as a unit (.pl + .so built for the same platform), this is
% correct.

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

% --- surface from pixel data ------------------------------------------------
% Wraps existing pixel data (referenced by a PtrBlob) in an SDL surface
% without copying.  The resulting surface holds a parent_ ref to the
% PtrBlob, keeping the underlying buffer alive.  See SDL_CreateSurfaceFrom.

sdl_createsurfacefrom(Surface, Width, Height, Format, Pixels, Pitch) :-
   must_be(var, Surface),
   must_be(positive_integer, Width),
   must_be(positive_integer, Height),
   must_be(sdl_pixel_format, Format),
   must_be(ptr_blob, Pixels),
   must_be(integer, Pitch),
   sdl_pixel_format(Format, IntFormat),
    sdl_createsurfacefrom_(Surface, Width, Height, IntFormat, Pixels, Pitch).

% --- update texture ---------------------------------------------------------
% Updates a texture with new pixel data from a PtrBlob.  Avoids
% creating/destroying a texture every frame when streaming dynamically
% rendered content (e.g. cairo).  Rect is null for the entire texture.

sdl_updatetexture(Texture, Rect, Pixels, Pitch) :-
   must_be(sdl_texture_blob, Texture),
   must_be((compound(rect(number, number, number, number)) ; oneof([null])), Rect),
   must_be(ptr_blob, Pixels),
   must_be(integer, Pitch),
   sdl_updatetexture_(Texture, Rect, Pixels, Pitch).

% --- texture access enum ----------------------------------------------------

sdl_texture_access(static, 0).
sdl_texture_access(streaming, 1).
sdl_texture_access(target, 2).

% --- create texture ---------------------------------------------------------
% Creates a texture with the specified format, access mode, and dimensions.
% Use sdl_createtexture/6 with streaming access for textures that are
% updated frequently (e.g. cairo-rendered content each frame).

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

% --- lock / unlock texture --------------------------------------------------
% Zero-copy rendering: lock the texture to get a direct pixel pointer
% (PtrBlob), write to it (e.g. via cairo_image_surface_create_for_data),
% then unlock to submit the changes to the GPU.

sdl_locktexture(Texture, Rect, Pixels, Pitch) :-
   must_be(sdl_texture_blob, Texture),
   must_be((compound(rect(number, number, number, number)) ; oneof([null])), Rect),
   must_be(var, Pixels),
   must_be(var, Pitch),
   sdl_locktexture_(Texture, Rect, Pixels, Pitch).

sdl_unlocktexture(Texture) :-
   must_be(sdl_texture_blob, Texture),
   sdl_unlocktexture_(Texture).
