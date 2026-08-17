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
                sdl_pixel_format/2,
                sdl_creategpudevice/4, sdl_destroygpudevice/1,
                sdl_claimwindowforgpudevice/2,
                sdl_releasewindowfromgpudevice/2,
                sdl_acquiregpucommandbuffer/2,
                sdl_submitgpucommandbuffer/1,
                sdl_cancelgpucommandbuffer/1,
                sdl_acquiregpuswapchaintexture/5,
                sdl_waitandacquiregpuswapchaintexture/5,
                sdl_begingpurenderpass/4,
                sdl_endgpurenderpass/1,
                sdl_creategputexture/3,
                sdl_releasegputexture/1,
                sdl_gpu_load_op/2,
                sdl_gpu_store_op/2,
                sdl_gpu_texture_type/2,
                sdl_gpu_texture_format/2,
                sdl_gpu_texture_usage/2,
                sdl_gpu_sample_count/2,
                sdl_gpu_shader_format/2,
                sdl_getnumgpudrivers/1, sdl_getgpudriver/2
                ]).
:- use_foreign_library(foreign(sdl)).
:- use_module(library(ptr)).

:- multifile error:has_type/2.
error:has_type(sdl_window_blob,   X) :- blob(X, sdl_window_blob).
error:has_type(sdl_renderer_blob, X) :- blob(X, sdl_renderer_blob).
error:has_type(sdl_surface_blob,  X) :- blob(X, sdl_surface_blob).
error:has_type(sdl_texture_blob,  X) :- blob(X, sdl_texture_blob).
error:has_type(sdl_gpu_device_blob, X) :- blob(X, sdl_gpu_device_blob).
error:has_type(sdl_gpu_cmdbuf_blob, X) :- blob(X, sdl_gpu_cmdbuf_blob).
error:has_type(sdl_gpu_swapchain_texture_blob, X) :- blob(X, sdl_gpu_swapchain_texture_blob).
error:has_type(sdl_gpu_renderpass_blob, X) :- blob(X, sdl_gpu_renderpass_blob).
error:has_type(sdl_gpu_texture_blob, X) :- blob(X, sdl_gpu_texture_blob).
error:has_type(sdl_gpu_load_op, X) :- sdl_gpu_load_op(X, _).
error:has_type(sdl_gpu_store_op, X) :- sdl_gpu_store_op(X, _).
error:has_type(sdl_gpu_texture_type, X) :- sdl_gpu_texture_type(X, _).
error:has_type(sdl_gpu_texture_format, X) :- sdl_gpu_texture_format(X, _).
error:has_type(sdl_gpu_texture_usage, X) :- sdl_gpu_texture_usage(X, _).
error:has_type(sdl_gpu_sample_count, X) :- sdl_gpu_sample_count(X, _).
error:has_type(sdl_gpu_color_target, X) :-
   compound(X),
   compound_name_arity(X, color_target, 11).
error:has_type(sdl_gpu_depth_stencil_target, X) :-
   compound(X),
   compound_name_arity(X, depth_stencil_target, 10).
error:has_type(sdl_gpu_texture_create_info, X) :-
   compound(X),
   compound_name_arity(X, gpu_texture_create_info, 8).
error:has_type(sdl_init_flag,   X) :- sdl_init_flag(X, _).
error:has_type(sdl_window_flag, X) :- sdl_window_flag(X, _).
error:has_type(sdl_windowpos,   X) :- ( atom(X) -> sdl_windowpos(X, _) ; integer(X) ).
error:has_type(sdl_pixel_format, X) :- sdl_pixel_format(X, _).
error:has_type(sdl_texture_access, X) :- sdl_texture_access(X, _).
error:has_type(sdl_gpu_shader_format, X) :- sdl_gpu_shader_format(X, _).
error:has_type(sdl_gpu_driver, X) :- sdl_gpu_driver(X).

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
prolog:error_message(type_error(sdl_gpu_device_blob, Culprit)) -->
   [ 'sdl_gpu_device_blob, found ~q'-[Culprit] ].
prolog:error_message(type_error(sdl_gpu_cmdbuf_blob, Culprit)) -->
   [ 'sdl_gpu_cmdbuf_blob, found ~q'-[Culprit] ].
prolog:error_message(type_error(sdl_gpu_swapchain_texture_blob, Culprit)) -->
   [ 'sdl_gpu_swapchain_texture_blob, found ~q'-[Culprit] ].
prolog:error_message(type_error(sdl_gpu_renderpass_blob, Culprit)) -->
   [ 'sdl_gpu_renderpass_blob, found ~q'-[Culprit] ].
prolog:error_message(type_error(sdl_gpu_texture_blob, Culprit)) -->
   [ 'sdl_gpu_texture_blob, found ~q'-[Culprit] ].
prolog:error_message(type_error(sdl_gpu_load_op, Culprit)) -->
   { findall(F, sdl_gpu_load_op(F, _), Fs) },
   [ 'sdl_gpu_load_op (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_store_op, Culprit)) -->
   { findall(F, sdl_gpu_store_op(F, _), Fs) },
   [ 'sdl_gpu_store_op (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_texture_type, Culprit)) -->
   { findall(F, sdl_gpu_texture_type(F, _), Fs) },
   [ 'sdl_gpu_texture_type (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_texture_format, Culprit)) -->
   { findall(F, sdl_gpu_texture_format(F, _), Fs) },
   [ 'sdl_gpu_texture_format, found ~q'-[Culprit] ].
prolog:error_message(type_error(sdl_gpu_texture_usage, Culprit)) -->
   { findall(F, sdl_gpu_texture_usage(F, _), Fs) },
   [ 'sdl_gpu_texture_usage (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_sample_count, Culprit)) -->
   { findall(F, sdl_gpu_sample_count(F, _), Fs) },
   [ 'sdl_gpu_sample_count (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_color_target, Culprit)) -->
   [ 'sdl_gpu_color_target (color_target/11 compound), found ~q'-[Culprit] ].
prolog:error_message(type_error(sdl_gpu_depth_stencil_target, Culprit)) -->
   [ 'sdl_gpu_depth_stencil_target (depth_stencil_target/10 compound), found ~q'-[Culprit] ].
prolog:error_message(type_error(sdl_gpu_texture_create_info, Culprit)) -->
   [ 'sdl_gpu_texture_create_info (gpu_texture_create_info/8 compound), found ~q'-[Culprit] ].
prolog:error_message(type_error(sdl_gpu_shader_format, Culprit)) -->
   { findall(F, sdl_gpu_shader_format(F, _), Fs) },
   [ 'sdl_gpu_shader_format (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_driver, Culprit)) -->
   { findall(F, gpu_driver_(F), Fs) },
   [ 'sdl_gpu_driver (one of ~q), found ~q'-[Fs, Culprit] ].

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
user:portray(Device) :-
   blob(Device, sdl_gpu_device_blob), !,
   sdl_gpu_device_blob_portray(current_output, Device).
user:portray(CmdBuf) :-
   blob(CmdBuf, sdl_gpu_cmdbuf_blob), !,
   sdl_gpu_cmdbuf_blob_portray(current_output, CmdBuf).
user:portray(Texture) :-
   blob(Texture, sdl_gpu_swapchain_texture_blob), !,
   sdl_gpu_swapchain_texture_blob_portray(current_output, Texture).
user:portray(RenderPass) :-
   blob(RenderPass, sdl_gpu_renderpass_blob), !,
   sdl_gpu_renderpass_blob_portray(current_output, RenderPass).
user:portray(Texture) :-
   blob(Texture, sdl_gpu_texture_blob), !,
   sdl_gpu_texture_blob_portray(current_output, Texture).

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

% --- SDL_gpu: shader format flags -------------------------------------------
% SDL_GPUShaderFormat is a bitmask telling SDL_gpu which backend shader
% bytecode formats the application is prepared to supply (spirv for Vulkan,
% dxbc/dxil for D3D12, msl/metallib for Metal, private for NDA platforms).
% SDL_CreateGPUDevice selects a backend that supports at least one of the
% requested formats.  When using SDL_ShaderCross to cross-compile a single
% HLSL source, pass every format the host can produce and let SDL pick.

sdl_gpu_shader_format(private,  0x00000001).
sdl_gpu_shader_format(spirv,    0x00000002).
sdl_gpu_shader_format(dxbc,     0x00000004).
sdl_gpu_shader_format(dxil,     0x00000008).
sdl_gpu_shader_format(msl,      0x00000010).
sdl_gpu_shader_format(metallib, 0x00000020).

% --- SDL_gpu: driver names --------------------------------------------------
% SDL_gpu's compiled-in backends are enumerated at runtime via
% SDL_GetNumGPUDrivers / SDL_GetGPUDriver.  On a Linux build only `vulkan`
% is available; on Windows `vulkan` and `direct3d12`; on macOS `vulkan`
% and `metal`.  The atom `null` represents a NULL driver name (SDL chooses
% the best backend); it is not a sdl_gpu_driver and is handled separately by
% sdl_creategpudevice.  Driver names are atoms throughout the Prolog API;
% they are translated to raw C strings only inside the foreign predicate at
% the SDL call boundary.

% Internal nondeterministic enumerator over compiled-in driver atoms.
% Used by sdl_gpu_driver/1 (membership check) and the error-message hook
% (listing valid atoms).  Not exported.
gpu_driver_(Name) :-
   sdl_getnumgpudrivers(Count),
   Last is Count - 1,
   between(0, Last, Index),
   sdl_getgpudriver(Index, Name).

% Deterministic type-check helper: succeeds once iff Name is an atom
% matching a GPU driver compiled into this SDL build.  Not exported.
sdl_gpu_driver(Name) :-
   findall(D, gpu_driver_(D), Ds),
   memberchk(Name, Ds).

% --- SDL_gpu: create / destroy device ---------------------------------------
% Creates a GPU device.  ShaderFormats is a list of sdl_gpu_shader_format
% atoms (OR-ed together) selecting which backend shader bytecode formats the
% application is prepared to supply; SDL picks a backend that supports at
% least one.  Debug enables the GPU validation layer.  Name is the atom
% `null` (use the default driver) or a sdl_gpu_driver atom.  The returned
% device owns no parent: it is the root handle from which windows and
% resources are claimed/created.

sdl_creategpudevice(Device, ShaderFormats, Debug, Name) :-
   must_be(var, Device),
   must_be(list(sdl_gpu_shader_format), ShaderFormats),
   must_be(boolean, Debug),
   must_be((oneof([null]) ; sdl_gpu_driver), Name),
   maplist(sdl_gpu_shader_format, ShaderFormats, IntFlags),
   or_list(IntFlags, IntFlag),
   sdl_creategpudevice_(Device, IntFlag, Debug, Name).

sdl_destroygpudevice(Device) :-
   must_be(sdl_gpu_device_blob, Device),
   sdl_destroygpudevice_(Device).

% --- SDL_gpu: claim / release window ----------------------------------------
% Claims a window for GPU rendering (creates its swapchain) or releases it.
% The window must have been created with the backend-matching window flag
% (`vulkan` on Linux/Windows, `metal` on macOS).  These are state mutations
% on existing handles — no new blob is produced, like sdl_setwindowposition.
%
% The device blob maintains a registered-ref list of claimed windows so the
% window blob cannot be garbage-collected while the claim is live (mirrors
% the SDLRendererBlob -> SDLWindowBlob parent ref).  sdl_releasewindowfrom-
% gpudevice/2 throws existence_error(claimed_window, Window) if the window
% is not currently claimed by the device, catching double-release and
% release-without-claim bugs.  SDL_DestroyGPUDevice releases all claimed
% windows on the SDL side and clears the ref list, so explicit release is
% only required to reclaim a window before device destruction.

sdl_claimwindowforgpudevice(Device, Window) :-
   must_be(sdl_gpu_device_blob, Device),
   must_be(sdl_window_blob, Window),
   sdl_claimwindowforgpudevice_(Device, Window).

sdl_releasewindowfromgpudevice(Device, Window) :-
   must_be(sdl_gpu_device_blob, Device),
   must_be(sdl_window_blob, Window),
   sdl_releasewindowfromgpudevice_(Device, Window).

% --- SDL_gpu: command buffer ------------------------------------------------
% A command buffer is acquired per frame from the device, commands are
% recorded into it, then it is submitted to the GPU for execution.  The
% command buffer may only be used on the thread that acquired it.
%
% RAII: if a command buffer blob is GC'd without being submitted (e.g. an
% exception discarded it mid-frame), the foreign destroy hook calls
% SDL_CancelGPUCommandBuffer to prevent a leak.  After a successful submit
% the blob is marked consumed so the cancel path is not triggered.  The blob
% holds a parent ref to the device, pinning it against GC for the command
% buffer's lifetime (mirrors SDLRendererBlob -> SDLWindowBlob).
%
% Submitting an already-submitted/cancelled command buffer raises
% existence_error(command_buffer, CmdBuf).

sdl_acquiregpucommandbuffer(CmdBuf, Device) :-
   must_be(var, CmdBuf),
   must_be(sdl_gpu_device_blob, Device),
   sdl_acquiregpucommandbuffer_(CmdBuf, Device).

sdl_submitgpucommandbuffer(CmdBuf) :-
   must_be(sdl_gpu_cmdbuf_blob, CmdBuf),
   sdl_submitgpucommandbuffer_(CmdBuf).

% sdl_cancelgpucommandbuffer/1 is the explicit counterpart to the implicit
% cancel that the blob destructor performs on unsubmitted command buffers
% during GC.  Use it to discard a command buffer early (e.g. a frame aborted
% by a logic error) rather than waiting for GC.  After cancel the command
% buffer is invalid; the blob is marked consumed so the destructor does not
% cancel again.  Cancelling an already-submitted/cancelled buffer raises
% existence_error(command_buffer, CmdBuf).

sdl_cancelgpucommandbuffer(CmdBuf) :-
   must_be(sdl_gpu_cmdbuf_blob, CmdBuf),
   sdl_cancelgpucommandbuffer_(CmdBuf).

% --- SDL_gpu: swapchain texture ---------------------------------------------
% A swapchain texture is the render target that will be presented to the
% screen when the command buffer is submitted.  It is acquired each frame
% from a command buffer + claimed window.  The texture is managed by SDL
% (must not be freed), valid only within the command buffer that acquired
% it, and write-only.
%
% The texture may be `null` (e.g. window minimized, or too many frames in
% flight for the non-blocking variant).  This is not an error — skip
% rendering that frame.  After acquiring a swapchain texture it is an error
% to cancel the command buffer; submit it instead (SDL handles presentation).
%
% The blob is a non-owning view (like PtrBlob): destroy() does not free the
% texture.  It holds a parent ref to the command buffer, preventing GC from
% auto-cancelling the command buffer while a swapchain texture view is live.

sdl_acquiregpuswapchaintexture(CmdBuf, Window, Texture, W, H) :-
   must_be(sdl_gpu_cmdbuf_blob, CmdBuf),
   must_be(sdl_window_blob, Window),
   must_be(var, Texture),
   must_be(var, W),
   must_be(var, H),
   sdl_acquiregpuswapchaintexture_(CmdBuf, Window, Texture, W, H).

sdl_waitandacquiregpuswapchaintexture(CmdBuf, Window, Texture, W, H) :-
   must_be(sdl_gpu_cmdbuf_blob, CmdBuf),
   must_be(sdl_window_blob, Window),
   must_be(var, Texture),
   must_be(var, W),
   must_be(var, H),
   sdl_waitandacquiregpuswapchaintexture_(CmdBuf, Window, Texture, W, H).

% --- SDL_gpu: load / store ops ----------------------------------------------
% SDL_GPULoadOp controls what happens to the render target's previous
% contents at the start of a render pass.  SDL_GPUStoreOp controls what
% happens to the render pass results at the end.

sdl_gpu_load_op(load, 0).
sdl_gpu_load_op(clear, 1).
sdl_gpu_load_op(dont_care, 2).

sdl_gpu_store_op(store, 0).
sdl_gpu_store_op(dont_care, 1).
sdl_gpu_store_op(resolve, 2).
sdl_gpu_store_op(resolve_and_store, 3).

% --- SDL_gpu: render pass ---------------------------------------------------
% A render pass targets one or more color textures (typically the swapchain
% texture) and optionally a depth-stencil texture.  All graphics operations
% must take place inside a render pass.  ColorTargets is a list of
% color_target/11 terms.  DepthStencil is `null` (no depth-stencil target)
% or a depth_stencil_target/10 compound.
%
% The color_target/11 compound maps 1-to-1 to SDL_GPUColorTargetInfo:
%   color_target(Texture, MipLevel, LayerOrDepthPlane, ClearColor,
%                LoadOp, StoreOp, ResolveTexture, ResolveMipLevel,
%                ResolveLayer, Cycle, CycleResolveTexture)
% where ClearColor is fcolor(R,G,B,A) and LoadOp/StoreOp are atoms from
% sdl_gpu_load_op/sdl_gpu_store_op.  ResolveTexture is `null` or a GPU
% texture blob (when store_op is resolve/resolve_and_store).
%
% The depth_stencil_target/10 compound maps 1-to-1 to
% SDL_GPUDepthStencilTargetInfo:
%   depth_stencil_target(Texture, ClearDepth, LoadOp, StoreOp,
%                        StencilLoadOp, StencilStoreOp, Cycle,
%                        ClearStencil, MipLevel, Layer)
% where ClearDepth is a float, ClearStencil an integer 0-255, and the
% load/store ops are atoms from sdl_gpu_load_op/sdl_gpu_store_op.
%
% RAII: the render pass blob holds a parent ref to the command buffer.  If
% GC'd without being explicitly ended, destroy() calls SDL_EndGPURenderPass
% as a safety net.  After explicit end the blob is marked consumed.  Ending
% an already-ended render pass raises existence_error(render_pass, Pass).

sdl_begingpurenderpass(RenderPass, CmdBuf, ColorTargets, DepthStencil) :-
   must_be(var, RenderPass),
   must_be(sdl_gpu_cmdbuf_blob, CmdBuf),
   must_be(list(sdl_gpu_color_target), ColorTargets),
   must_be((oneof([null]) ; sdl_gpu_depth_stencil_target), DepthStencil),
   maplist(color_target_int, ColorTargets, IntTargets),
   depth_stencil_int(DepthStencil, IntDepthStencil),
   sdl_begingpurenderpass_(RenderPass, CmdBuf, IntTargets, IntDepthStencil).

sdl_endgpurenderpass(RenderPass) :-
   must_be(sdl_gpu_renderpass_blob, RenderPass),
   sdl_endgpurenderpass_(RenderPass).

% Translate color_target/11 atoms (load_op, store_op) to ints for the
% foreign predicate.  The compound is reconstructed with int values.
color_target_int(
   color_target(Texture, MipLevel, LayerOrDepthPlane, ClearColor,
                LoadOp, StoreOp, ResolveTexture, ResolveMipLevel,
                ResolveLayer, Cycle, CycleResolveTexture),
   color_target(Texture, MipLevel, LayerOrDepthPlane, ClearColor,
                IntLoadOp, IntStoreOp, ResolveTexture, ResolveMipLevel,
                ResolveLayer, Cycle, CycleResolveTexture)) :-
   sdl_gpu_load_op(LoadOp, IntLoadOp),
   sdl_gpu_store_op(StoreOp, IntStoreOp).

% Translate depth_stencil_target/10 atoms (load_op, store_op, stencil_load_op,
% stencil_store_op) to ints for the foreign predicate.  null passes through.
depth_stencil_int(null, null) :- !.
depth_stencil_int(
   depth_stencil_target(Texture, ClearDepth, LoadOp, StoreOp,
                        StencilLoadOp, StencilStoreOp, Cycle,
                        ClearStencil, MipLevel, Layer),
   depth_stencil_target(Texture, ClearDepth, IntLoadOp, IntStoreOp,
                        IntStencilLoadOp, IntStencilStoreOp, Cycle,
                        ClearStencil, MipLevel, Layer)) :-
   sdl_gpu_load_op(LoadOp, IntLoadOp),
   sdl_gpu_store_op(StoreOp, IntStoreOp),
   sdl_gpu_load_op(StencilLoadOp, IntStencilLoadOp),
   sdl_gpu_store_op(StencilStoreOp, IntStencilStoreOp).

% --- SDL_gpu: texture type, format, usage, sample count ---------------------

sdl_gpu_texture_type('2d',         0).
sdl_gpu_texture_type('2d_array',   1).
sdl_gpu_texture_type('3d',         2).
sdl_gpu_texture_type(cube,       3).
sdl_gpu_texture_type(cube_array, 4).

sdl_gpu_texture_usage(sampler,                                 0x00000001).
sdl_gpu_texture_usage(color_target,                            0x00000002).
sdl_gpu_texture_usage(depth_stencil_target,                    0x00000004).
sdl_gpu_texture_usage(graphics_storage_read,                   0x00000008).
sdl_gpu_texture_usage(compute_storage_read,                    0x00000010).
sdl_gpu_texture_usage(compute_storage_write,                   0x00000020).
sdl_gpu_texture_usage(compute_storage_simultaneous_read_write, 0x00000040).

sdl_gpu_sample_count(1, 0).
sdl_gpu_sample_count(2, 1).
sdl_gpu_sample_count(4, 2).
sdl_gpu_sample_count(8, 3).

% sdl_gpu_texture_format/2 — maps SDL_GPUTextureFormat enum values (sequential
% from 0).  Generated from SDL_gpu.h.
sdl_gpu_texture_format(invalid, 0).
sdl_gpu_texture_format(a8_unorm, 1).
sdl_gpu_texture_format(r8_unorm, 2).
sdl_gpu_texture_format(r8g8_unorm, 3).
sdl_gpu_texture_format(r8g8b8a8_unorm, 4).
sdl_gpu_texture_format(r16_unorm, 5).
sdl_gpu_texture_format(r16g16_unorm, 6).
sdl_gpu_texture_format(r16g16b16a16_unorm, 7).
sdl_gpu_texture_format(r10g10b10a2_unorm, 8).
sdl_gpu_texture_format(b5g6r5_unorm, 9).
sdl_gpu_texture_format(b5g5r5a1_unorm, 10).
sdl_gpu_texture_format(b4g4r4a4_unorm, 11).
sdl_gpu_texture_format(b8g8r8a8_unorm, 12).
sdl_gpu_texture_format(bc1_rgba_unorm, 13).
sdl_gpu_texture_format(bc2_rgba_unorm, 14).
sdl_gpu_texture_format(bc3_rgba_unorm, 15).
sdl_gpu_texture_format(bc4_r_unorm, 16).
sdl_gpu_texture_format(bc5_rg_unorm, 17).
sdl_gpu_texture_format(bc7_rgba_unorm, 18).
sdl_gpu_texture_format(bc6h_rgb_float, 19).
sdl_gpu_texture_format(bc6h_rgb_ufloat, 20).
sdl_gpu_texture_format(r8_snorm, 21).
sdl_gpu_texture_format(r8g8_snorm, 22).
sdl_gpu_texture_format(r8g8b8a8_snorm, 23).
sdl_gpu_texture_format(r16_snorm, 24).
sdl_gpu_texture_format(r16g8_snorm, 25).
sdl_gpu_texture_format(r16g16b16a16_snorm, 26).
sdl_gpu_texture_format(r16_float, 27).
sdl_gpu_texture_format(r16g16_float, 28).
sdl_gpu_texture_format(r16g16b16a16_float, 29).
sdl_gpu_texture_format(r32_float, 30).
sdl_gpu_texture_format(r32g32_float, 31).
sdl_gpu_texture_format(r32g32b32a32_float, 32).
sdl_gpu_texture_format(r11g11b10_ufloat, 33).
sdl_gpu_texture_format(r8_uint, 34).
sdl_gpu_texture_format(r8g8_uint, 35).
sdl_gpu_texture_format(r8g8b8a8_uint, 36).
sdl_gpu_texture_format(r16_uint, 37).
sdl_gpu_texture_format(r16g16_uint, 38).
sdl_gpu_texture_format(r16g16b16a16_uint, 39).
sdl_gpu_texture_format(r32_uint, 40).
sdl_gpu_texture_format(r32g32_uint, 41).
sdl_gpu_texture_format(r32g32b32a32_uint, 42).
sdl_gpu_texture_format(r8_int, 43).
sdl_gpu_texture_format(r8g8_int, 44).
sdl_gpu_texture_format(r8g8b8a8_int, 45).
sdl_gpu_texture_format(r16_int, 46).
sdl_gpu_texture_format(r16g16_int, 47).
sdl_gpu_texture_format(r16g16b16a16_int, 48).
sdl_gpu_texture_format(r32_int, 49).
sdl_gpu_texture_format(r32g32_int, 50).
sdl_gpu_texture_format(r32g32b32a32_int, 51).
sdl_gpu_texture_format(r8g8b8a8_unorm_srgb, 52).
sdl_gpu_texture_format(b8g8r8a8_unorm_srgb, 53).
sdl_gpu_texture_format(bc1_rgba_unorm_srgb, 54).
sdl_gpu_texture_format(bc2_rgba_unorm_srgb, 55).
sdl_gpu_texture_format(bc3_rgba_unorm_srgb, 56).
sdl_gpu_texture_format(bc7_rgba_unorm_srgb, 57).
sdl_gpu_texture_format(d16_unorm, 58).
sdl_gpu_texture_format(d24_unorm, 59).
sdl_gpu_texture_format(d32_float, 60).
sdl_gpu_texture_format(d24_unorm_s8_uint, 61).
sdl_gpu_texture_format(d32_float_s8_uint, 62).
sdl_gpu_texture_format(astc_4x4_unorm, 63).
sdl_gpu_texture_format(astc_5x4_unorm, 64).
sdl_gpu_texture_format(astc_5x5_unorm, 65).
sdl_gpu_texture_format(astc_6x5_unorm, 66).
sdl_gpu_texture_format(astc_6x6_unorm, 67).
sdl_gpu_texture_format(astc_8x5_unorm, 68).
sdl_gpu_texture_format(astc_8x6_unorm, 69).
sdl_gpu_texture_format(astc_8x8_unorm, 70).
sdl_gpu_texture_format(astc_10x5_unorm, 71).
sdl_gpu_texture_format(astc_10x6_unorm, 72).
sdl_gpu_texture_format(astc_10x8_unorm, 73).
sdl_gpu_texture_format(astc_10x10_unorm, 74).
sdl_gpu_texture_format(astc_12x10_unorm, 75).
sdl_gpu_texture_format(astc_12x12_unorm, 76).
sdl_gpu_texture_format(astc_4x4_unorm_srgb, 77).
sdl_gpu_texture_format(astc_5x4_unorm_srgb, 78).
sdl_gpu_texture_format(astc_5x5_unorm_srgb, 79).
sdl_gpu_texture_format(astc_6x5_unorm_srgb, 80).
sdl_gpu_texture_format(astc_6x6_unorm_srgb, 81).
sdl_gpu_texture_format(astc_8x5_unorm_srgb, 82).
sdl_gpu_texture_format(astc_8x6_unorm_srgb, 83).
sdl_gpu_texture_format(astc_8x8_unorm_srgb, 84).
sdl_gpu_texture_format(astc_10x5_unorm_srgb, 85).
sdl_gpu_texture_format(astc_10x6_unorm_srgb, 86).
sdl_gpu_texture_format(astc_10x8_unorm_srgb, 87).
sdl_gpu_texture_format(astc_10x10_unorm_srgb, 88).
sdl_gpu_texture_format(astc_12x10_unorm_srgb, 89).
sdl_gpu_texture_format(astc_12x12_unorm_srgb, 90).
sdl_gpu_texture_format(astc_4x4_float, 91).
sdl_gpu_texture_format(astc_5x4_float, 92).
sdl_gpu_texture_format(astc_5x5_float, 93).
sdl_gpu_texture_format(astc_6x5_float, 94).
sdl_gpu_texture_format(astc_6x6_float, 95).
sdl_gpu_texture_format(astc_8x5_float, 96).
sdl_gpu_texture_format(astc_8x6_float, 97).
sdl_gpu_texture_format(astc_8x8_float, 98).
sdl_gpu_texture_format(astc_10x5_float, 99).
sdl_gpu_texture_format(astc_10x6_float, 100).
sdl_gpu_texture_format(astc_10x8_float, 101).
sdl_gpu_texture_format(astc_10x10_float, 102).
sdl_gpu_texture_format(astc_12x10_float, 103).
sdl_gpu_texture_format(astc_12x12_float, 104).

% --- SDL_gpu: create / release texture --------------------------------------
% Creates a GPU texture (render target, sampler source, storage, etc.) or
% releases it.  The gpu_texture_create_info/8 compound maps 1-to-1 to
% SDL_GPUTextureCreateInfo (props is always 0):
%   gpu_texture_create_info(Type, Format, Usage, Width, Height,
%                           LayerCountOrDepth, NumLevels, SampleCount)
% where Type is a sdl_gpu_texture_type atom, Format a sdl_gpu_texture_format
% atom, Usage a list of sdl_gpu_texture_usage atoms (OR-ed), and SampleCount
% a sdl_gpu_sample_count atom.  Width/Height/LayerCountOrDepth/NumLevels are
% non-negative integers.
%
% The blob is owning: destroy() calls SDL_ReleaseGPUTexture.  It holds a
% parent ref to the device, pinning it against GC.  Releasing an
% already-released texture raises existence_error(texture, Texture).

sdl_creategputexture(Texture, Device, CreateInfo) :-
   must_be(var, Texture),
   must_be(sdl_gpu_device_blob, Device),
   must_be(sdl_gpu_texture_create_info, CreateInfo),
   CreateInfo = gpu_texture_create_info(Type, Format, Usage, Width, Height,
                                        LayerCountOrDepth, NumLevels, SampleCount),
   must_be(sdl_gpu_texture_type, Type),
   must_be(sdl_gpu_texture_format, Format),
   must_be(list(sdl_gpu_texture_usage), Usage),
   must_be(nonneg, Width),
   must_be(nonneg, Height),
   must_be(nonneg, LayerCountOrDepth),
   must_be(nonneg, NumLevels),
   must_be(sdl_gpu_sample_count, SampleCount),
   texture_create_info_int(CreateInfo, IntCreateInfo),
   sdl_creategputexture_(Texture, Device, IntCreateInfo).

sdl_releasegputexture(Texture) :-
   must_be(sdl_gpu_texture_blob, Texture),
   sdl_releasegputexture_(Texture).

% Translate gpu_texture_create_info/8 atoms (Type, Format, Usage, SampleCount)
% to ints for the foreign predicate.
texture_create_info_int(
   gpu_texture_create_info(Type, Format, Usage, Width, Height,
                           LayerCountOrDepth, NumLevels, SampleCount),
   gpu_texture_create_info(IntType, IntFormat, IntUsage, Width, Height,
                           LayerCountOrDepth, NumLevels, IntSampleCount)) :-
   sdl_gpu_texture_type(Type, IntType),
   sdl_gpu_texture_format(Format, IntFormat),
   maplist(sdl_gpu_texture_usage, Usage, UsageInts),
   or_list(UsageInts, IntUsage),
   sdl_gpu_sample_count(SampleCount, IntSampleCount).
