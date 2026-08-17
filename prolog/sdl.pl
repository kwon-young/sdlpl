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
                sdl_creategpushader/3,
                sdl_releasegpushader/1,
                sdl_creategpugraphicspipeline/3,
                sdl_releasegpugraphicspipeline/1,
                sdl_creategpubuffer/4,
                sdl_releasegpubuffer/1,
                sdl_creategputransferbuffer/4,
                sdl_releasegputransferbuffer/1,
                sdl_mapgputransferbuffer/3,
                sdl_unmapgputransferbuffer/1,
                sdl_begingpucopypass/2,
                sdl_endgpucopypass/1,
                sdl_uploadtogpubuffer/4,
                sdl_gpu_buffer_usage/2,
                sdl_gpu_transfer_buffer_usage/2,
                sdl_gpu_load_op/2,
                sdl_gpu_store_op/2,
                sdl_gpu_texture_type/2,
                sdl_gpu_texture_format/2,
                sdl_gpu_texture_usage/2,
                sdl_gpu_sample_count/2,
                sdl_gpu_shader_format/2,
                sdl_gpu_shader_stage/2,
                sdl_gpu_primitive_type/2,
                sdl_gpu_fill_mode/2,
                sdl_gpu_cull_mode/2,
                sdl_gpu_front_face/2,
                sdl_gpu_compare_op/2,
                sdl_gpu_stencil_op/2,
                sdl_gpu_blend_op/2,
                sdl_gpu_blend_factor/2,
                sdl_gpu_vertex_input_rate/2,
                sdl_gpu_vertex_element_format/2,
                sdl_gpu_color_component/2,
                sdl_getnumgpudrivers/1, sdl_getgpudriver/2,
                make_color_target/2, default_color_target/1, is_color_target/1,
                make_depth_stencil_target/2, default_depth_stencil_target/1, is_depth_stencil_target/1,
                make_gpu_texture_create_info/2, default_gpu_texture_create_info/1, is_gpu_texture_create_info/1,
                make_gpu_shader_create_info/2, default_gpu_shader_create_info/1, is_gpu_shader_create_info/1,
                make_vertex_buffer_description/2, default_vertex_buffer_description/1, is_vertex_buffer_description/1,
                make_vertex_attribute/2, default_vertex_attribute/1, is_vertex_attribute/1,
                make_stencil_op_state/2, default_stencil_op_state/1, is_stencil_op_state/1,
                make_color_target_blend_state/2, default_color_target_blend_state/1, is_color_target_blend_state/1,
                make_color_target_description/2, default_color_target_description/1, is_color_target_description/1,
                make_vertex_input_state/2, default_vertex_input_state/1, is_vertex_input_state/1,
                make_rasterizer_state/2, default_rasterizer_state/1, is_rasterizer_state/1,
                make_multisample_state/2, default_multisample_state/1, is_multisample_state/1,
                make_depth_stencil_state/2, default_depth_stencil_state/1, is_depth_stencil_state/1,
                make_target_info/2, default_target_info/1, is_target_info/1,
                make_gpu_graphics_pipeline_create_info/2, default_gpu_graphics_pipeline_create_info/1, is_gpu_graphics_pipeline_create_info/1
                ]).
:- use_foreign_library(foreign(sdl)).
:- use_module(library(ptr)).
:- use_module(library(record)).

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
error:has_type(sdl_gpu_shader_blob, X) :- blob(X, sdl_gpu_shader_blob).
error:has_type(sdl_gpu_pipeline_blob, X) :- blob(X, sdl_gpu_pipeline_blob).
error:has_type(sdl_gpu_buffer_blob, X) :- blob(X, sdl_gpu_buffer_blob).
error:has_type(sdl_gpu_transfer_buffer_blob, X) :- blob(X, sdl_gpu_transfer_buffer_blob).
error:has_type(sdl_gpu_copypass_blob, X) :- blob(X, sdl_gpu_copypass_blob).
error:has_type(transfer_buffer_location, X) :-
   compound(X),
   compound_name_arity(X, transfer_buffer_location, 2).
error:has_type(buffer_region, X) :-
   compound(X),
   compound_name_arity(X, buffer_region, 3).
% sdl_gpu_texture accepts either a swapchain texture blob or a regular GPU
% texture blob.  Used as a field type in color_target and depth_stencil_target
% records.
error:has_type(sdl_gpu_texture, X) :-
   (  blob(X, sdl_gpu_swapchain_texture_blob)
   ;  blob(X, sdl_gpu_texture_blob)
   ).
% fcolor(R,G,B,A) — maps to SDL_FColor.  Fields are numbers (int or float);
% the C++ layer converts via as_float().
error:has_type(fcolor, X) :-
   nonvar(X),
   compound_name_arity(X, fcolor, 4),
   arg(1, X, R), is_of_type(number, R),
   arg(2, X, G), is_of_type(number, G),
   arg(3, X, B), is_of_type(number, B),
   arg(4, X, A), is_of_type(number, A).
error:has_type(sdl_gpu_load_op, X) :- sdl_gpu_load_op(X, _).
error:has_type(sdl_gpu_store_op, X) :- sdl_gpu_store_op(X, _).
error:has_type(sdl_gpu_texture_type, X) :- sdl_gpu_texture_type(X, _).
error:has_type(sdl_gpu_texture_format, X) :- sdl_gpu_texture_format(X, _).
error:has_type(sdl_gpu_texture_usage, X) :- sdl_gpu_texture_usage(X, _).
error:has_type(sdl_gpu_sample_count, X) :- sdl_gpu_sample_count(X, _).
error:has_type(sdl_gpu_shader_stage, X) :- sdl_gpu_shader_stage(X, _).
error:has_type(sdl_gpu_primitive_type, X) :- sdl_gpu_primitive_type(X, _).
error:has_type(sdl_gpu_fill_mode, X) :- sdl_gpu_fill_mode(X, _).
error:has_type(sdl_gpu_cull_mode, X) :- sdl_gpu_cull_mode(X, _).
error:has_type(sdl_gpu_front_face, X) :- sdl_gpu_front_face(X, _).
error:has_type(sdl_gpu_compare_op, X) :- sdl_gpu_compare_op(X, _).
error:has_type(sdl_gpu_stencil_op, X) :- sdl_gpu_stencil_op(X, _).
error:has_type(sdl_gpu_blend_op, X) :- sdl_gpu_blend_op(X, _).
error:has_type(sdl_gpu_blend_factor, X) :- sdl_gpu_blend_factor(X, _).
error:has_type(sdl_gpu_vertex_input_rate, X) :- sdl_gpu_vertex_input_rate(X, _).
error:has_type(sdl_gpu_vertex_element_format, X) :- sdl_gpu_vertex_element_format(X, _).
error:has_type(sdl_gpu_color_component, X) :- sdl_gpu_color_component(X, _).
error:has_type(sdl_gpu_buffer_usage, X) :- sdl_gpu_buffer_usage(X, _).
error:has_type(sdl_gpu_transfer_buffer_usage, X) :- sdl_gpu_transfer_buffer_usage(X, _).
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
prolog:error_message(type_error(sdl_gpu_shader_blob, Culprit)) -->
   [ 'sdl_gpu_shader_blob, found ~q'-[Culprit] ].
prolog:error_message(type_error(sdl_gpu_pipeline_blob, Culprit)) -->
   [ 'sdl_gpu_pipeline_blob, found ~q'-[Culprit] ].
prolog:error_message(type_error(sdl_gpu_buffer_blob, Culprit)) -->
   [ 'sdl_gpu_buffer_blob, found ~q'-[Culprit] ].
prolog:error_message(type_error(sdl_gpu_transfer_buffer_blob, Culprit)) -->
   [ 'sdl_gpu_transfer_buffer_blob, found ~q'-[Culprit] ].
prolog:error_message(type_error(sdl_gpu_copypass_blob, Culprit)) -->
   [ 'sdl_gpu_copypass_blob, found ~q'-[Culprit] ].
prolog:error_message(type_error(transfer_buffer_location, Culprit)) -->
   [ 'transfer_buffer_location (transfer_buffer_location/2 compound), found ~q'-[Culprit] ].
prolog:error_message(type_error(buffer_region, Culprit)) -->
   [ 'buffer_region (buffer_region/3 compound), found ~q'-[Culprit] ].
prolog:error_message(type_error(sdl_gpu_texture, Culprit)) -->
   [ 'sdl_gpu_texture (swapchain or regular texture blob), found ~q'-[Culprit] ].
prolog:error_message(type_error(fcolor, Culprit)) -->
   [ 'fcolor (fcolor(R,G,B,A) with numeric fields), found ~q'-[Culprit] ].
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
   [ 'sdl_gpu_texture_format (one of 105 format atoms), found ~q'-[Culprit] ].
prolog:error_message(type_error(sdl_gpu_texture_usage, Culprit)) -->
   { findall(F, sdl_gpu_texture_usage(F, _), Fs) },
   [ 'sdl_gpu_texture_usage (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_sample_count, Culprit)) -->
   { findall(F, sdl_gpu_sample_count(F, _), Fs) },
   [ 'sdl_gpu_sample_count (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_shader_stage, Culprit)) -->
   { findall(F, sdl_gpu_shader_stage(F, _), Fs) },
   [ 'sdl_gpu_shader_stage (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_primitive_type, Culprit)) -->
   { findall(F, sdl_gpu_primitive_type(F, _), Fs) },
   [ 'sdl_gpu_primitive_type (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_fill_mode, Culprit)) -->
   { findall(F, sdl_gpu_fill_mode(F, _), Fs) },
   [ 'sdl_gpu_fill_mode (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_cull_mode, Culprit)) -->
   { findall(F, sdl_gpu_cull_mode(F, _), Fs) },
   [ 'sdl_gpu_cull_mode (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_front_face, Culprit)) -->
   { findall(F, sdl_gpu_front_face(F, _), Fs) },
   [ 'sdl_gpu_front_face (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_compare_op, Culprit)) -->
   { findall(F, sdl_gpu_compare_op(F, _), Fs) },
   [ 'sdl_gpu_compare_op (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_stencil_op, Culprit)) -->
   { findall(F, sdl_gpu_stencil_op(F, _), Fs) },
   [ 'sdl_gpu_stencil_op (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_blend_op, Culprit)) -->
   { findall(F, sdl_gpu_blend_op(F, _), Fs) },
   [ 'sdl_gpu_blend_op (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_blend_factor, Culprit)) -->
   { findall(F, sdl_gpu_blend_factor(F, _), Fs) },
   [ 'sdl_gpu_blend_factor (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_vertex_input_rate, Culprit)) -->
   { findall(F, sdl_gpu_vertex_input_rate(F, _), Fs) },
   [ 'sdl_gpu_vertex_input_rate (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_vertex_element_format, Culprit)) -->
   { findall(F, sdl_gpu_vertex_element_format(F, _), Fs) },
   [ 'sdl_gpu_vertex_element_format (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_color_component, Culprit)) -->
   { findall(F, sdl_gpu_color_component(F, _), Fs) },
   [ 'sdl_gpu_color_component (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_buffer_usage, Culprit)) -->
   { findall(F, sdl_gpu_buffer_usage(F, _), Fs) },
   [ 'sdl_gpu_buffer_usage (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_transfer_buffer_usage, Culprit)) -->
   { findall(F, sdl_gpu_transfer_buffer_usage(F, _), Fs) },
   [ 'sdl_gpu_transfer_buffer_usage (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_gpu_color_target, Culprit)) -->
   [ 'sdl_gpu_color_target (record color_target/11), found ~q'-[Culprit] ].
prolog:error_message(type_error(sdl_gpu_depth_stencil_target, Culprit)) -->
   [ 'sdl_gpu_depth_stencil_target (record depth_stencil_target/10), found ~q'-[Culprit] ].
prolog:error_message(type_error(sdl_gpu_texture_create_info, Culprit)) -->
   [ 'sdl_gpu_texture_create_info (record gpu_texture_create_info/8), found ~q'-[Culprit] ].
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
user:portray(Shader) :-
   blob(Shader, sdl_gpu_shader_blob), !,
   sdl_gpu_shader_blob_portray(current_output, Shader).
user:portray(Pipeline) :-
   blob(Pipeline, sdl_gpu_pipeline_blob), !,
   sdl_gpu_pipeline_blob_portray(current_output, Pipeline).
user:portray(Buffer) :-
   blob(Buffer, sdl_gpu_buffer_blob), !,
   sdl_gpu_buffer_blob_portray(current_output, Buffer).
user:portray(TransferBuffer) :-
   blob(TransferBuffer, sdl_gpu_transfer_buffer_blob), !,
   sdl_gpu_transfer_buffer_blob_portray(current_output, TransferBuffer).
user:portray(CopyPass) :-
   blob(CopyPass, sdl_gpu_copypass_blob), !,
   sdl_gpu_copypass_blob_portray(current_output, CopyPass).

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

% --- SDL_gpu: enum/flag tables ----------------------------------------------
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

sdl_gpu_shader_stage(vertex, 0).
sdl_gpu_shader_stage(fragment, 1).

sdl_gpu_primitive_type(trianglelist, 0).
sdl_gpu_primitive_type(trianglestrip, 1).
sdl_gpu_primitive_type(linelist, 2).
sdl_gpu_primitive_type(linestrip, 3).
sdl_gpu_primitive_type(pointlist, 4).

sdl_gpu_fill_mode(fill, 0).
sdl_gpu_fill_mode(line, 1).

sdl_gpu_cull_mode(none, 0).
sdl_gpu_cull_mode(front, 1).
sdl_gpu_cull_mode(back, 2).

sdl_gpu_front_face(counter_clockwise, 0).
sdl_gpu_front_face(clockwise, 1).

sdl_gpu_compare_op(invalid, 0).
sdl_gpu_compare_op(never, 1).
sdl_gpu_compare_op(less, 2).
sdl_gpu_compare_op(equal, 3).
sdl_gpu_compare_op(less_or_equal, 4).
sdl_gpu_compare_op(greater, 5).
sdl_gpu_compare_op(not_equal, 6).
sdl_gpu_compare_op(greater_or_equal, 7).
sdl_gpu_compare_op(always, 8).

sdl_gpu_stencil_op(invalid, 0).
sdl_gpu_stencil_op(keep, 1).
sdl_gpu_stencil_op(zero, 2).
sdl_gpu_stencil_op(replace, 3).
sdl_gpu_stencil_op(increment_and_clamp, 4).
sdl_gpu_stencil_op(decrement_and_clamp, 5).
sdl_gpu_stencil_op(invert, 6).
sdl_gpu_stencil_op(increment_and_wrap, 7).
sdl_gpu_stencil_op(decrement_and_wrap, 8).

sdl_gpu_blend_op(invalid, 0).
sdl_gpu_blend_op(add, 1).
sdl_gpu_blend_op(subtract, 2).
sdl_gpu_blend_op(reverse_subtract, 3).
sdl_gpu_blend_op(min, 4).
sdl_gpu_blend_op(max, 5).

sdl_gpu_blend_factor(invalid, 0).
sdl_gpu_blend_factor(zero, 1).
sdl_gpu_blend_factor(one, 2).
sdl_gpu_blend_factor(src_color, 3).
sdl_gpu_blend_factor(one_minus_src_color, 4).
sdl_gpu_blend_factor(dst_color, 5).
sdl_gpu_blend_factor(one_minus_dst_color, 6).
sdl_gpu_blend_factor(src_alpha, 7).
sdl_gpu_blend_factor(one_minus_src_alpha, 8).
sdl_gpu_blend_factor(dst_alpha, 9).
sdl_gpu_blend_factor(one_minus_dst_alpha, 10).
sdl_gpu_blend_factor(constant_color, 11).
sdl_gpu_blend_factor(one_minus_constant_color, 12).
sdl_gpu_blend_factor(src_alpha_saturate, 13).

sdl_gpu_vertex_input_rate(vertex, 0).
sdl_gpu_vertex_input_rate(instance, 1).

sdl_gpu_vertex_element_format(invalid, 0).
sdl_gpu_vertex_element_format(int, 1).
sdl_gpu_vertex_element_format(int2, 2).
sdl_gpu_vertex_element_format(int3, 3).
sdl_gpu_vertex_element_format(int4, 4).
sdl_gpu_vertex_element_format(uint, 5).
sdl_gpu_vertex_element_format(uint2, 6).
sdl_gpu_vertex_element_format(uint3, 7).
sdl_gpu_vertex_element_format(uint4, 8).
sdl_gpu_vertex_element_format(float, 9).
sdl_gpu_vertex_element_format(float2, 10).
sdl_gpu_vertex_element_format(float3, 11).
sdl_gpu_vertex_element_format(float4, 12).
sdl_gpu_vertex_element_format(byte2, 13).
sdl_gpu_vertex_element_format(byte4, 14).
sdl_gpu_vertex_element_format(ubyte2, 15).
sdl_gpu_vertex_element_format(ubyte4, 16).
sdl_gpu_vertex_element_format(byte2_norm, 17).
sdl_gpu_vertex_element_format(byte4_norm, 18).
sdl_gpu_vertex_element_format(ubyte2_norm, 19).
sdl_gpu_vertex_element_format(ubyte4_norm, 20).
sdl_gpu_vertex_element_format(short2, 21).
sdl_gpu_vertex_element_format(short4, 22).
sdl_gpu_vertex_element_format(ushort2, 23).
sdl_gpu_vertex_element_format(ushort4, 24).
sdl_gpu_vertex_element_format(short2_norm, 25).
sdl_gpu_vertex_element_format(short4_norm, 26).
sdl_gpu_vertex_element_format(ushort2_norm, 27).
sdl_gpu_vertex_element_format(ushort4_norm, 28).
sdl_gpu_vertex_element_format(half2, 29).
sdl_gpu_vertex_element_format(half4, 30).

sdl_gpu_color_component(r, 0x01).
sdl_gpu_color_component(g, 0x02).
sdl_gpu_color_component(b, 0x04).
sdl_gpu_color_component(a, 0x08).

% --- SDL_gpu: struct records ------------------------------------------------
% The following records map 1-to-1 to SDL_gpu structs.  Field order matches
% the C struct (the foreign layer reads by position).  Field types are
% checked automatically by is_<record>/1 (generated by library(record)).
% Use make_<record>([field(Value), ...], Record) for partial construction
% with defaults; unspecified fields get their default values.

% SDL_GPUColorTargetInfo
:- record color_target(
   texture:sdl_gpu_texture,                                       % required
   mip_level:nonneg=0,
   layer_or_depth_plane:nonneg=0,
   clear_color:fcolor=fcolor(0.0,0.0,0.0,1.0),
   load_op:sdl_gpu_load_op,                                       % required
   store_op:sdl_gpu_store_op,                                     % required
   resolve_texture:(oneof([null]);sdl_gpu_texture)=null,
   resolve_mip_level:nonneg=0,
   resolve_layer:nonneg=0,
   cycle:boolean=false,
   cycle_resolve_texture:boolean=false
).

% SDL_GPUDepthStencilTargetInfo
:- record depth_stencil_target(
   texture:sdl_gpu_texture,                                       % required
   clear_depth:number=1.0,
   load_op:sdl_gpu_load_op,                                       % required
   store_op:sdl_gpu_store_op,                                     % required
   stencil_load_op:sdl_gpu_load_op=dont_care,
   stencil_store_op:sdl_gpu_store_op=dont_care,
   cycle:boolean=false,
   clear_stencil:between(0,255)=0,
   mip_level:between(0,255)=0,
   layer:between(0,255)=0
).

% SDL_GPUTextureCreateInfo (props is always 0, omitted)
:- record gpu_texture_create_info(
   type:sdl_gpu_texture_type='2d',
   format:sdl_gpu_texture_format,                                 % required
   usage:list(sdl_gpu_texture_usage),                             % required
   width:nonneg,                                                  % required
   height:nonneg,                                                 % required
   layer_count_or_depth:nonneg=1,
   num_levels:nonneg=1,
   sample_count:sdl_gpu_sample_count=1
).

% SDL_GPUShaderCreateInfo (props is always 0, omitted).  Code is a Prolog
% string containing raw shader bytecode (e.g. SPIR-V for Vulkan).  Read it
% from a .spv file with read_file_to_string(File, Code, [type(binary)]).
:- record gpu_shader_create_info(
   code:string,                                                   % required
   entrypoint:string="main",
   format:sdl_gpu_shader_format,                                  % required
   stage:sdl_gpu_shader_stage,                                    % required
   num_samplers:nonneg=0,
   num_storage_textures:nonneg=0,
   num_storage_buffers:nonneg=0,
   num_uniform_buffers:nonneg=0
).

% --- Graphics pipeline nested structs ---

% SDL_GPUVertexBufferDescription
:- record vertex_buffer_description(
   slot:nonneg=0,
   pitch:nonneg,
   input_rate:sdl_gpu_vertex_input_rate=vertex,
   instance_step_rate:nonneg=0
).

% SDL_GPUVertexAttribute
:- record vertex_attribute(
   location:nonneg,
   buffer_slot:nonneg=0,
   format:sdl_gpu_vertex_element_format,
   offset:nonneg=0
).

% SDL_GPUStencilOpState.  Defaults match SDL's zero-initialization (invalid=0).
% When enable_stencil_test is false these values are ignored.
:- record stencil_op_state(
   fail_op:sdl_gpu_stencil_op=invalid,
   pass_op:sdl_gpu_stencil_op=invalid,
   depth_fail_op:sdl_gpu_stencil_op=invalid,
   compare_op:sdl_gpu_compare_op=invalid
).

% SDL_GPUColorTargetBlendState
:- record color_target_blend_state(
   src_color_blendfactor:sdl_gpu_blend_factor=one,
   dst_color_blendfactor:sdl_gpu_blend_factor=zero,
   color_blend_op:sdl_gpu_blend_op=add,
   src_alpha_blendfactor:sdl_gpu_blend_factor=one,
   dst_alpha_blendfactor:sdl_gpu_blend_factor=zero,
   alpha_blend_op:sdl_gpu_blend_op=add,
   color_write_mask:list(sdl_gpu_color_component)=[r,g,b,a],
   enable_blend:boolean=false,
   enable_color_write_mask:boolean=false
).

% SDL_GPUColorTargetDescription
:- record color_target_description(
   format:sdl_gpu_texture_format,
   blend_state:color_target_blend_state
).

% SDL_GPUVertexInputState (no pointer fields; lists are inlined)
:- record vertex_input_state(
   vertex_buffer_descriptions:list(vertex_buffer_description)=[],
   vertex_attributes:list(vertex_attribute)=[]
).

% SDL_GPURasterizerState
:- record rasterizer_state(
   fill_mode:sdl_gpu_fill_mode=fill,
   cull_mode:sdl_gpu_cull_mode=none,
   front_face:sdl_gpu_front_face=counter_clockwise,
   depth_bias_constant_factor:number=0.0,
   depth_bias_clamp:number=0.0,
   depth_bias_slope_factor:number=0.0,
   enable_depth_bias:boolean=false,
   enable_depth_clip:boolean=true
).

% SDL_GPUMultisampleState
:- record multisample_state(
   sample_count:sdl_gpu_sample_count=1,
   sample_mask:nonneg=0,
   enable_mask:boolean=false,
   enable_alpha_to_coverage:boolean=false
).

% SDL_GPUDepthStencilState
:- record depth_stencil_state(
   compare_op:sdl_gpu_compare_op=less,
   back_stencil_state:stencil_op_state,
   front_stencil_state:stencil_op_state,
   compare_mask:between(0,255)=255,
   write_mask:between(0,255)=255,
   enable_depth_test:boolean=false,
   enable_depth_write:boolean=true,
   enable_stencil_test:boolean=false
).

% SDL_GPUGraphicsPipelineTargetInfo.  depth_stencil_format defaults to
% invalid (0) — it is ignored when has_depth_stencil_target is false.
:- record target_info(
   color_target_descriptions:list(color_target_description)=[],
   depth_stencil_format:sdl_gpu_texture_format=invalid,
   has_depth_stencil_target:boolean=false
).

% SDL_GPUGraphicsPipelineCreateInfo (props is always 0, omitted)
:- record gpu_graphics_pipeline_create_info(
   vertex_shader:sdl_gpu_shader_blob,
   fragment_shader:sdl_gpu_shader_blob,
   vertex_input_state:vertex_input_state,
   primitive_type:sdl_gpu_primitive_type=trianglelist,
   rasterizer_state:rasterizer_state,
   multisample_state:multisample_state,
   depth_stencil_state:depth_stencil_state,
   target_info:target_info
).

% Type aliases backed by the generated is_*/1 predicates.
error:has_type(sdl_gpu_color_target, X) :- is_color_target(X).
error:has_type(sdl_gpu_depth_stencil_target, X) :- is_depth_stencil_target(X).
error:has_type(sdl_gpu_texture_create_info, X) :- is_gpu_texture_create_info(X).
error:has_type(sdl_gpu_shader_create_info, X) :- is_gpu_shader_create_info(X).
error:has_type(vertex_buffer_description, X) :- is_vertex_buffer_description(X).
error:has_type(vertex_attribute, X) :- is_vertex_attribute(X).
error:has_type(stencil_op_state, X) :- is_stencil_op_state(X).
error:has_type(color_target_blend_state, X) :- is_color_target_blend_state(X).
error:has_type(color_target_description, X) :- is_color_target_description(X).
error:has_type(vertex_input_state, X) :- is_vertex_input_state(X).
error:has_type(rasterizer_state, X) :- is_rasterizer_state(X).
error:has_type(multisample_state, X) :- is_multisample_state(X).
error:has_type(depth_stencil_state, X) :- is_depth_stencil_state(X).
error:has_type(target_info, X) :- is_target_info(X).
error:has_type(sdl_gpu_graphics_pipeline_create_info, X) :- is_gpu_graphics_pipeline_create_info(X).

% --- SDL_gpu: render pass ---------------------------------------------------
% A render pass targets one or more color textures (typically the swapchain
% texture) and optionally a depth-stencil texture.  All graphics operations
% must take place inside a render pass.  ColorTargets is a list of
% color_target records.  DepthStencil is `null` (no depth-stencil target)
% or a depth_stencil_target record.
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

% Translate color_target load_op/store_op atoms to ints for the foreign
% predicate.  The compound is reconstructed with int values.
color_target_int(
   color_target(Texture, MipLevel, LayerOrDepthPlane, ClearColor,
                LoadOp, StoreOp, ResolveTexture, ResolveMipLevel,
                ResolveLayer, Cycle, CycleResolveTexture),
   IntTarget) =>
   sdl_gpu_load_op(LoadOp, IntLoadOp),
   sdl_gpu_store_op(StoreOp, IntStoreOp),
   IntTarget = color_target(Texture, MipLevel, LayerOrDepthPlane, ClearColor,
                            IntLoadOp, IntStoreOp, ResolveTexture, ResolveMipLevel,
                            ResolveLayer, Cycle, CycleResolveTexture).

% Translate depth_stencil_target load/store op atoms to ints.  null passes
% through unchanged.
depth_stencil_int(null, IntTarget) => IntTarget = null.
depth_stencil_int(
   depth_stencil_target(Texture, ClearDepth, LoadOp, StoreOp,
                        StencilLoadOp, StencilStoreOp, Cycle,
                        ClearStencil, MipLevel, Layer),
   IntTarget) =>
   sdl_gpu_load_op(LoadOp, IntLoadOp),
   sdl_gpu_store_op(StoreOp, IntStoreOp),
   sdl_gpu_load_op(StencilLoadOp, IntStencilLoadOp),
   sdl_gpu_store_op(StencilStoreOp, IntStencilStoreOp),
   IntTarget = depth_stencil_target(Texture, ClearDepth, IntLoadOp, IntStoreOp,
                                    IntStencilLoadOp, IntStencilStoreOp, Cycle,
                                    ClearStencil, MipLevel, Layer).

% --- SDL_gpu: create / release texture --------------------------------------
% Creates a GPU texture (render target, sampler source, storage, etc.) or
% releases it.  The gpu_texture_create_info record maps 1-to-1 to
% SDL_GPUTextureCreateInfo (props is always 0).
%
% The blob is owning: destroy() calls SDL_ReleaseGPUTexture.  It holds a
% parent ref to the device, pinning it against GC.  Releasing an
% already-released texture raises existence_error(texture, Texture).

sdl_creategputexture(Texture, Device, CreateInfo) :-
   must_be(var, Texture),
   must_be(sdl_gpu_device_blob, Device),
   must_be(sdl_gpu_texture_create_info, CreateInfo),
   texture_create_info_int(CreateInfo, IntCreateInfo),
   sdl_creategputexture_(Texture, Device, IntCreateInfo).

sdl_releasegputexture(Texture) :-
   must_be(sdl_gpu_texture_blob, Texture),
   sdl_releasegputexture_(Texture).

% Translate gpu_texture_create_info atoms (Type, Format, Usage, SampleCount)
% to ints for the foreign predicate.  The compound is reconstructed with int
% values.
texture_create_info_int(
   gpu_texture_create_info(Type, Format, Usage, Width, Height,
                           LayerCountOrDepth, NumLevels, SampleCount),
   IntInfo) =>
   sdl_gpu_texture_type(Type, IntType),
   sdl_gpu_texture_format(Format, IntFormat),
   maplist(sdl_gpu_texture_usage, Usage, UsageInts),
   or_list(UsageInts, IntUsage),
   sdl_gpu_sample_count(SampleCount, IntSampleCount),
   IntInfo = gpu_texture_create_info(IntType, IntFormat, IntUsage, Width, Height,
                                     LayerCountOrDepth, NumLevels, IntSampleCount).

% --- SDL_gpu: create / release shader ---------------------------------------
% Creates a GPU shader from precompiled bytecode (e.g. SPIR-V for Vulkan)
% and releases it.  The gpu_shader_create_info record maps 1-to-1 to
% SDL_GPUShaderCreateInfo (props is always 0).  Code is a Prolog string
% containing raw bytecode — read it from a .spv file with
% read_file_to_string(File, Code, [type(binary)]).
%
% The blob is owning: destroy() calls SDL_ReleaseGPUShader.  It holds a
% parent ref to the device, pinning it against GC.  Releasing an
% already-released shader raises existence_error(shader, Shader).

sdl_creategpushader(Shader, Device, CreateInfo) :-
   must_be(var, Shader),
   must_be(sdl_gpu_device_blob, Device),
   must_be(sdl_gpu_shader_create_info, CreateInfo),
   shader_create_info_int(CreateInfo, IntCreateInfo),
   sdl_creategpushader_(Shader, Device, IntCreateInfo).

sdl_releasegpushader(Shader) :-
   must_be(sdl_gpu_shader_blob, Shader),
   sdl_releasegpushader_(Shader).

% Translate gpu_shader_create_info atoms (Format, Stage) to ints for the
% foreign predicate.  Code and Entrypoint are strings, passed through
% unchanged.
shader_create_info_int(
   gpu_shader_create_info(Code, Entrypoint, Format, Stage,
                          NumSamplers, NumStorageTextures,
                          NumStorageBuffers, NumUniformBuffers),
   IntInfo) =>
   sdl_gpu_shader_format(Format, IntFormat),
   sdl_gpu_shader_stage(Stage, IntStage),
   IntInfo = gpu_shader_create_info(Code, Entrypoint, IntFormat, IntStage,
                                    NumSamplers, NumStorageTextures,
                                    NumStorageBuffers, NumUniformBuffers).

% --- SDL_gpu: create / release graphics pipeline ----------------------------
% Creates a graphics pipeline from a gpu_graphics_pipeline_create_info record
% and releases it.  The record maps 1-to-1 to SDL_GPUGraphicsPipelineCreateInfo
% (props is always 0), with nested records for each sub-struct.
%
% The blob is owning: destroy() calls SDL_ReleaseGPUGraphicsPipeline.  It
% holds a parent ref to the device.  Releasing an already-released pipeline
% raises existence_error(pipeline, Pipeline).

sdl_creategpugraphicspipeline(Pipeline, Device, CreateInfo) :-
   must_be(var, Pipeline),
   must_be(sdl_gpu_device_blob, Device),
   must_be(sdl_gpu_graphics_pipeline_create_info, CreateInfo),
   graphics_pipeline_create_info_int(CreateInfo, IntCreateInfo),
   sdl_creategpugraphicspipeline_(Pipeline, Device, IntCreateInfo).

sdl_releasegpugraphicspipeline(Pipeline) :-
   must_be(sdl_gpu_pipeline_blob, Pipeline),
   sdl_releasegpugraphicspipeline_(Pipeline).

% Translate all enum/flag atoms in the pipeline create info to ints.
% Each sub-record is destructured and reconstructed with int values.
graphics_pipeline_create_info_int(
   gpu_graphics_pipeline_create_info(VertShader, FragShader,
                                     VertexInputState, PrimitiveType,
                                     RasterizerState, MultisampleState,
                                     DepthStencilState, TargetInfo),
   IntInfo) =>
   sdl_gpu_primitive_type(PrimitiveType, IntPrimitiveType),
   vertex_input_state_int(VertexInputState, IntVIS),
   rasterizer_state_int(RasterizerState, IntRS),
   multisample_state_int(MultisampleState, IntMS),
   depth_stencil_state_int(DepthStencilState, IntDSS),
   target_info_int(TargetInfo, IntTI),
   IntInfo = gpu_graphics_pipeline_create_info(
      VertShader, FragShader, IntVIS, IntPrimitiveType,
      IntRS, IntMS, IntDSS, IntTI).

vertex_input_state_int(
   vertex_input_state(VBDescs, VAttrs),
   IntVIS) =>
   maplist(vertex_buffer_description_int, VBDescs, IntVBDescs),
   maplist(vertex_attribute_int, VAttrs, IntVAttrs),
   IntVIS = vertex_input_state(IntVBDescs, IntVAttrs).

vertex_buffer_description_int(
   vertex_buffer_description(Slot, Pitch, InputRate, InstanceStepRate),
   IntVBD) =>
   sdl_gpu_vertex_input_rate(InputRate, IntInputRate),
   IntVBD = vertex_buffer_description(Slot, Pitch, IntInputRate, InstanceStepRate).

vertex_attribute_int(
   vertex_attribute(Location, BufferSlot, Format, Offset),
   IntVA) =>
   sdl_gpu_vertex_element_format(Format, IntFormat),
   IntVA = vertex_attribute(Location, BufferSlot, IntFormat, Offset).

rasterizer_state_int(
   rasterizer_state(FillMode, CullMode, FrontFace, DBCF, DBC, DBSF,
                    EnableDepthBias, EnableDepthClip),
   IntRS) =>
   sdl_gpu_fill_mode(FillMode, IntFillMode),
   sdl_gpu_cull_mode(CullMode, IntCullMode),
   sdl_gpu_front_face(FrontFace, IntFrontFace),
   IntRS = rasterizer_state(IntFillMode, IntCullMode, IntFrontFace,
                            DBCF, DBC, DBSF, EnableDepthBias, EnableDepthClip).

multisample_state_int(
   multisample_state(SampleCount, SampleMask, EnableMask, EnableAlphaToCoverage),
   IntMS) =>
   sdl_gpu_sample_count(SampleCount, IntSampleCount),
   IntMS = multisample_state(IntSampleCount, SampleMask, EnableMask,
                             EnableAlphaToCoverage).

stencil_op_state_int(
   stencil_op_state(FailOp, PassOp, DepthFailOp, CompareOp),
   IntSOS) =>
   sdl_gpu_stencil_op(FailOp, IntFailOp),
   sdl_gpu_stencil_op(PassOp, IntPassOp),
   sdl_gpu_stencil_op(DepthFailOp, IntDepthFailOp),
   sdl_gpu_compare_op(CompareOp, IntCompareOp),
   IntSOS = stencil_op_state(IntFailOp, IntPassOp, IntDepthFailOp, IntCompareOp).

depth_stencil_state_int(
   depth_stencil_state(CompareOp, BackStencilState, FrontStencilState,
                       CompareMask, WriteMask, EnableDepthTest,
                       EnableDepthWrite, EnableStencilTest),
   IntDSS) =>
   sdl_gpu_compare_op(CompareOp, IntCompareOp),
   stencil_op_state_int(BackStencilState, IntBSS),
   stencil_op_state_int(FrontStencilState, IntFSS),
   IntDSS = depth_stencil_state(IntCompareOp, IntBSS, IntFSS,
                                CompareMask, WriteMask, EnableDepthTest,
                                EnableDepthWrite, EnableStencilTest).

color_target_blend_state_int(
   color_target_blend_state(SrcColorBF, DstColorBF, ColorBlendOp,
                            SrcAlphaBF, DstAlphaBF, AlphaBlendOp,
                            ColorWriteMask, EnableBlend, EnableColorWriteMask),
   IntCTBS) =>
   sdl_gpu_blend_factor(SrcColorBF, IntSrcColorBF),
   sdl_gpu_blend_factor(DstColorBF, IntDstColorBF),
   sdl_gpu_blend_op(ColorBlendOp, IntColorBlendOp),
   sdl_gpu_blend_factor(SrcAlphaBF, IntSrcAlphaBF),
   sdl_gpu_blend_factor(DstAlphaBF, IntDstAlphaBF),
   sdl_gpu_blend_op(AlphaBlendOp, IntAlphaBlendOp),
   maplist(sdl_gpu_color_component, ColorWriteMask, CWMInts),
   or_list(CWMInts, IntColorWriteMask),
   IntCTBS = color_target_blend_state(
      IntSrcColorBF, IntDstColorBF, IntColorBlendOp,
      IntSrcAlphaBF, IntDstAlphaBF, IntAlphaBlendOp,
      IntColorWriteMask, EnableBlend, EnableColorWriteMask).

color_target_description_int(
   color_target_description(Format, BlendState),
   IntCTD) =>
   sdl_gpu_texture_format(Format, IntFormat),
   color_target_blend_state_int(BlendState, IntBlendState),
   IntCTD = color_target_description(IntFormat, IntBlendState).

target_info_int(
   target_info(ColorTargetDescriptions, DepthStencilFormat, HasDepthStencilTarget),
   IntTI) =>
   maplist(color_target_description_int, ColorTargetDescriptions, IntCTDs),
   sdl_gpu_texture_format(DepthStencilFormat, IntDSFormat),
   IntTI = target_info(IntCTDs, IntDSFormat, HasDepthStencilTarget).

% --- SDL_gpu: create / release buffer ---------------------------------------
% Creates a GPU buffer (vertex, index, indirect, or storage) and releases it.
% Usage is a list of sdl_gpu_buffer_usage atoms (OR-ed together).  Size is the
% buffer size in bytes.  The blob is owning: destroy() calls
% SDL_ReleaseGPUBuffer.  Releasing an already-released buffer raises
% existence_error(buffer, Buffer).

sdl_gpu_buffer_usage(vertex,                0x00000001).
sdl_gpu_buffer_usage(index,                 0x00000002).
sdl_gpu_buffer_usage(indirect,              0x00000004).
sdl_gpu_buffer_usage(graphics_storage_read, 0x00000008).
sdl_gpu_buffer_usage(compute_storage_read,  0x00000010).
sdl_gpu_buffer_usage(compute_storage_write, 0x00000020).

sdl_creategpubuffer(Buffer, Device, Usage, Size) :-
   must_be(var, Buffer),
   must_be(sdl_gpu_device_blob, Device),
   must_be(list(sdl_gpu_buffer_usage), Usage),
   must_be(nonneg, Size),
   maplist(sdl_gpu_buffer_usage, Usage, UsageInts),
   or_list(UsageInts, IntUsage),
   sdl_creategpubuffer_(Buffer, Device, IntUsage, Size).

sdl_releasegpubuffer(Buffer) :-
   must_be(sdl_gpu_buffer_blob, Buffer),
   sdl_releasegpubuffer_(Buffer).

% --- SDL_gpu: create / release transfer buffer ------------------------------
% Creates a transfer buffer (staging area for uploading/downloading GPU data)
% and releases it.  Usage is a sdl_gpu_transfer_buffer_usage atom (upload or
% download).  Size is the buffer size in bytes.  The blob is owning:
% destroy() calls SDL_ReleaseGPUTransferBuffer.  Releasing an already-released
% transfer buffer raises existence_error(transfer_buffer, TransferBuffer).

sdl_gpu_transfer_buffer_usage(upload, 0).
sdl_gpu_transfer_buffer_usage(download, 1).

sdl_creategputransferbuffer(TransferBuffer, Device, Usage, Size) :-
   must_be(var, TransferBuffer),
   must_be(sdl_gpu_device_blob, Device),
   must_be(sdl_gpu_transfer_buffer_usage, Usage),
   must_be(nonneg, Size),
   sdl_gpu_transfer_buffer_usage(Usage, IntUsage),
   sdl_creategputransferbuffer_(TransferBuffer, Device, IntUsage, Size).

sdl_releasegputransferbuffer(TransferBuffer) :-
   must_be(sdl_gpu_transfer_buffer_blob, TransferBuffer),
   sdl_releasegputransferbuffer_(TransferBuffer).

% --- SDL_gpu: map / unmap transfer buffer -----------------------------------
% Maps a transfer buffer into application address space (returns a PtrBlob)
% and unmaps it.  The PtrBlob is a non-owning view — the memory is owned by
% the driver and must NOT be freed.  The PtrBlob's parent is the transfer
% buffer blob, preventing GC from releasing it while mapped.  Must unmap
% before encoding upload commands (SDL_UploadToGPUBuffer).
%
% This is the GPU equivalent of sdl_locktexture / sdl_unlocktexture: the
% caller writes vertex/index data into the PtrBlob (via library(ptr) writers
% or cairo), then unmaps and uploads.

sdl_mapgputransferbuffer(Ptr, TransferBuffer, Cycle) :-
   must_be(var, Ptr),
   must_be(sdl_gpu_transfer_buffer_blob, TransferBuffer),
   must_be(boolean, Cycle),
   sdl_mapgputransferbuffer_(Ptr, TransferBuffer, Cycle).

sdl_unmapgputransferbuffer(TransferBuffer) :-
   must_be(sdl_gpu_transfer_buffer_blob, TransferBuffer),
   sdl_unmapgputransferbuffer_(TransferBuffer).

% --- SDL_gpu: copy pass -----------------------------------------------------
% A copy pass is begun on a command buffer and is used for upload/download
% operations (SDL_UploadToGPUBuffer, etc.).  All copy operations must take
% place inside a copy pass.  You must not begin another copy pass, render
% pass, or compute pass before ending the current copy pass.
%
% RAII: the copy pass blob holds a parent ref to the command buffer.  If
% GC'd without being explicitly ended, destroy() calls SDL_EndGPUCopyPass
% as a safety net.  After explicit end the blob is marked consumed.  Ending
% an already-ended copy pass raises existence_error(copy_pass, CopyPass).

sdl_begingpucopypass(CopyPass, CmdBuf) :-
   must_be(var, CopyPass),
   must_be(sdl_gpu_cmdbuf_blob, CmdBuf),
   sdl_begingpucopypass_(CopyPass, CmdBuf).

sdl_endgpucopypass(CopyPass) :-
   must_be(sdl_gpu_copypass_blob, CopyPass),
   sdl_endgpucopypass_(CopyPass).

% --- SDL_gpu: upload to buffer ----------------------------------------------
% Uploads data from a transfer buffer to a GPU buffer.  Must be called inside
% a copy pass.  Source is a transfer_buffer_location/2 compound:
%   transfer_buffer_location(TransferBuffer, Offset)
% Destination is a buffer_region/3 compound:
%   buffer_region(Buffer, Offset, Size)
% Cycle is a boolean: true cycles the buffer if already bound, false
% overwrites.  No new blob is created — this is a command recorded into the
% copy pass.

sdl_uploadtogpubuffer(CopyPass, Source, Destination, Cycle) :-
   must_be(sdl_gpu_copypass_blob, CopyPass),
   must_be(transfer_buffer_location, Source),
   must_be(buffer_region, Destination),
   must_be(boolean, Cycle),
   Source = transfer_buffer_location(TB, _),
   must_be(sdl_gpu_transfer_buffer_blob, TB),
   Destination = buffer_region(Buf, _, _),
   must_be(sdl_gpu_buffer_blob, Buf),
   sdl_uploadtogpubuffer_(CopyPass, Source, Destination, Cycle).
