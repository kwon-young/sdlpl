/*  Part of the SDL3 pack for SWI-Prolog.

    This module is the sole loader of the sdl.so foreign extension.  It
    owns the raw C++ predicates (with _ suffix) and the bare C++ predicates
    that have no Prolog wrapper (e.g. sdl_quit/0, sdl_destroywindow/1).

    Themed submodules (library(sdl/init), library(sdl/gpu), etc.) import
    the _ suffix predicates from here and define the user-facing wrappers
    that do type checking and data conversion.

    The hub module library(sdl) re-exports all themed submodules, giving
    users a single-entry-point superset of the entire API.
*/

:- module(sdl_foreign, [
    % --- SDL_init.h ---
    sdl_init_/1,
    sdl_quit/0,

    % --- SDL_video.h ---
    sdl_window_blob_portray/2,
    sdl_createwindow_/5,
    sdl_setwindowposition_/3,
    sdl_destroywindow/1,

    % --- SDL_render.h ---
    sdl_renderer_blob_portray/2,
    sdl_texture_blob_portray/2,
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

    % --- SDL_events.h ---
    sdl_pollevent_/1,

    % --- SDL_surface.h ---
    sdl_surface_blob_portray/2,
    sdl_destroysurface/1,
    sdl_createsurfacefrom_/6,

    % --- SDL_image ---
    img_load_/2,

    % --- SDL_gpu.h: blob portray ---
    sdl_gpu_device_blob_portray/2,
    sdl_gpu_cmdbuf_blob_portray/2,
    sdl_gpu_swapchain_texture_blob_portray/2,
    sdl_gpu_renderpass_blob_portray/2,
    sdl_gpu_texture_blob_portray/2,
    sdl_gpu_shader_blob_portray/2,
    sdl_gpu_pipeline_blob_portray/2,
    sdl_gpu_buffer_blob_portray/2,
    sdl_gpu_transfer_buffer_blob_portray/2,
    sdl_gpu_copypass_blob_portray/2,

    % --- SDL_gpu.h: device ---
    sdl_creategpudevice_/4,
    sdl_destroygpudevice_/1,
    sdl_getnumgpudrivers/1,
    sdl_getgpudriver/2,
    sdl_claimwindowforgpudevice_/2,
    sdl_releasewindowfromgpudevice_/2,

    % --- SDL_gpu.h: command buffer ---
    sdl_acquiregpucommandbuffer_/2,
    sdl_submitgpucommandbuffer_/1,
    sdl_cancelgpucommandbuffer_/1,

    % --- SDL_gpu.h: swapchain texture ---
    sdl_acquiregpuswapchaintexture_/5,
    sdl_waitandacquiregpuswapchaintexture_/5,

    % --- SDL_gpu.h: render pass ---
    sdl_begingpurenderpass_/4,
    sdl_endgpurenderpass_/1,

    % --- SDL_gpu.h: texture ---
    sdl_creategputexture_/3,
    sdl_releasegputexture_/1,

    % --- SDL_gpu.h: shader ---
    sdl_creategpushader_/3,
    sdl_releasegpushader_/1,

    % --- SDL_gpu.h: graphics pipeline ---
    sdl_creategpugraphicspipeline_/3,
    sdl_releasegpugraphicspipeline_/1,

    % --- SDL_gpu.h: buffer ---
    sdl_creategpubuffer_/4,
    sdl_releasegpubuffer_/1,

    % --- SDL_gpu.h: transfer buffer ---
    sdl_creategputransferbuffer_/4,
    sdl_releasegputransferbuffer_/1,
    sdl_mapgputransferbuffer_/3,
    sdl_unmapgputransferbuffer_/1,

    % --- SDL_gpu.h: copy pass ---
    sdl_begingpucopypass_/2,
    sdl_endgpucopypass_/1,

    % --- SDL_gpu.h: upload to buffer ---
    sdl_uploadtogpubuffer_/4,

    % --- SDL_gpu.h: draw commands ---
    sdl_bindgpugraphicspipeline_/2,
    sdl_bindgpuvertexbuffers_/3,
    sdl_bindgpuindexbuffer_/3,
    sdl_drawgpuindexedprimitives_/6,
    sdl_drawgpuprimitives_/5,

    % --- shared utility ---
    or_list/2
]).

:- use_foreign_library(foreign(sdl)).

or_list(List, Or) :-
   foldl([B, A, C]>>(C is A \/ B), List, 0, Or).
