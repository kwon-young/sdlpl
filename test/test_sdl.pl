:- use_module(library(sdl)).

:- dynamic sample_image/1.
:- prolog_load_context(directory, Dir),
   directory_file_path(Dir, '../examples/DSC03094.JPG', Rel),
   absolute_file_name(Rel, Abs),
   atom_string(Abs, Str),
   assertz(sample_image(Str)).

:- begin_tests(sdl).

test(init, [forall(sdl_init_flag(Flag, _))]) :-
   sdl_init([Flag]),
   sdl_quit.

test(createwindow, [
      setup(sdl_init([everything])), cleanup(sdl_quit),
      forall((sdl_window_flag(Flag, _), dif(Flag, metal)))]) :-
   setup_call_cleanup(
      sdl_createwindow(Handle, "Title", 400, 600, [Flag]),
      true,
      sdl_destroywindow(Handle)).

test(setwindowposition, [
      setup((sdl_init([everything]),
             sdl_createwindow(Handle, "Title", 400, 600, []))),
      cleanup((sdl_destroywindow(Handle), sdl_quit)),
      forall((pos(X), pos(Y)))]) :-
   catch(sdl_setwindowposition(Handle, X, Y), error(_, _), true).

pos(0).
pos(100).
pos(centered).    % SDL_WINDOWPOS_CENTERED
pos(undefined).   % SDL_WINDOWPOS_UNDEFINED

test(createrenderer, [
      setup((sdl_init([everything]),
             sdl_createwindow(Window, "", 400, 600, [opengl]))),
      cleanup((sdl_destroywindow(Window), sdl_quit))]) :-
   setup_call_cleanup(
      sdl_createrenderer(Renderer, Window, null),
      true,
      sdl_destroyrenderer(Renderer)).

test(setrendervsync, [
      setup((sdl_init([everything]),
             sdl_createwindow(Window, "", 400, 600, [opengl]),
             sdl_createrenderer(Renderer, Window, null))),
      cleanup((sdl_destroyrenderer(Renderer),
               sdl_destroywindow(Window), sdl_quit))]) :-
   sdl_setrendervsync(Renderer, 1).

test(imgload) :-
   sample_image(Img),
   setup_call_cleanup(
      sdl_init([everything]),
      setup_call_cleanup(
         img_load(Surface, Img),
         true,
         sdl_destroysurface(Surface)),
      sdl_quit).

test(createtexturefromsurface, [
   setup((
      sdl_init([everything]),
      sdl_createwindow(Window, "", 400, 600, [opengl]),
      sdl_createrenderer(Renderer, Window, null),
      sample_image(Img),
      img_load(Surface, Img))),
   cleanup((
      sdl_destroysurface(Surface),
      sdl_destroyrenderer(Renderer),
      sdl_destroywindow(Window),
      sdl_quit))]) :-
   setup_call_cleanup(
      sdl_createtexturefromsurface(Texture, Renderer, Surface),
      true,
      sdl_destroytexture(Texture)).

test(rendercleartexturepresent, [
   forall((
      member(Srcrect, [rect(0, 0, 1000, 1000), null]),
      member(Dstrect, [rect(0, 0, 200, 300), null]))),
   setup((
      sdl_init([everything]),
      sdl_createwindow(Window, "", 400, 600, [opengl]),
      sdl_createrenderer(Renderer, Window, null),
      sample_image(Img),
      img_load(Surface, Img),
      sdl_createtexturefromsurface(Texture, Renderer, Surface))),
   cleanup((
      sdl_destroytexture(Texture),
      sdl_destroysurface(Surface),
      sdl_destroyrenderer(Renderer),
      sdl_destroywindow(Window),
      sdl_quit))]) :-
   sdl_renderclear(Renderer),
   sdl_rendertexture(Renderer, Texture, Srcrect, Dstrect),
   sdl_renderpresent(Renderer).

% TODO: this test only checks the empty-queue case (expects fail). It should
% also generate real events and assert on Event.type (atom, not string) to
% catch regressions in the event unification code.
test(pollevent, [setup(sdl_init([events])), cleanup(sdl_quit), fail]) :-
   sdl_pollevent(_).

test(setrenderdrawcolor, [
   setup((
      sdl_init([everything]),
      sdl_createwindow(Window, "", 400, 600, [opengl]),
      sdl_createrenderer(Renderer, Window, null))),
   cleanup((
      sdl_destroyrenderer(Renderer),
      sdl_destroywindow(Window),
      sdl_quit))]) :-
   sdl_setrenderdrawcolor(Renderer, 255, 0, 0, 255).

test(renderrect, [
   setup((
      sdl_init([everything]),
      sdl_createwindow(Window, "", 400, 600, [opengl]),
      sdl_createrenderer(Renderer, Window, null))),
   cleanup((
      sdl_destroyrenderer(Renderer),
      sdl_destroywindow(Window),
      sdl_quit))]) :-
   sdl_renderrect(Renderer, rect(0, 0, 100, 100)).

test(renderfillrect, [
   setup((
      sdl_init([everything]),
      sdl_createwindow(Window, "", 400, 600, [opengl]),
      sdl_createrenderer(Renderer, Window, null))),
   cleanup((
      sdl_destroyrenderer(Renderer),
      sdl_destroywindow(Window),
      sdl_quit))]) :-
   sdl_renderfillrect(Renderer, rect(0, 0, 100, 100)).

% --- SDL_gpu device ---------------------------------------------------------
% SDL_CreateGPUDevice selects a backend that supports at least one of the
% requested shader formats.  A successful creation must round-trip through
% destroy without error.

test(creategpudevice, [
   setup(sdl_init([video])),
   cleanup(sdl_quit),
   forall(member(Formats, [[spirv], [spirv, dxil, msl, metallib]]))]) :-
   setup_call_cleanup(
      sdl_creategpudevice(Device, Formats, false, null),
      true,
      sdl_destroygpudevice(Device)).

test(creategpudevice_name_atom, [
   setup(sdl_init([video])),
   cleanup(sdl_quit)]) :-
   setup_call_cleanup(
      sdl_creategpudevice(Device, [spirv], false, vulkan),
      true,
      sdl_destroygpudevice(Device)).

test(creategpudevice_debug, [
   setup(sdl_init([video])),
   cleanup(sdl_quit)]) :-
   setup_call_cleanup(
      sdl_creategpudevice(Device, [spirv], true, null),
      true,
      sdl_destroygpudevice(Device)).

test(creategpudevice_type_error, [
   setup(sdl_init([video])),
   cleanup(sdl_quit),
   error(type_error(sdl_gpu_shader_format, bogus))]) :-
   sdl_creategpudevice(_, [bogus], false, null).

test(creategpudevice_name_type_error, [
   setup(sdl_init([video])),
   cleanup(sdl_quit),
   error(type_error((oneof([null]);sdl_gpu_driver), bogus))]) :-
   sdl_creategpudevice(_, [spirv], false, bogus).

test(destroygpudevice_type_error, [
   error(type_error(sdl_gpu_device_blob, not_a_blob))]) :-
   sdl_destroygpudevice(not_a_blob).

% --- SDL_gpu: claim / release window ----------------------------------------

test(claimwindowforgpudevice, [
   setup((sdl_init([video]),
          sdl_createwindow(Window, "", 400, 600, [vulkan]),
          sdl_creategpudevice(Device, [spirv], false, null))),
   cleanup((sdl_releasewindowfromgpudevice(Device, Window),
            sdl_destroygpudevice(Device),
            sdl_destroywindow(Window),
            sdl_quit))]) :-
   sdl_claimwindowforgpudevice(Device, Window).

test(releasewindowfromgpudevice, [
   setup((sdl_init([video]),
          sdl_createwindow(Window, "", 400, 600, [vulkan]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_claimwindowforgpudevice(Device, Window))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_destroywindow(Window),
            sdl_quit))]) :-
   sdl_releasewindowfromgpudevice(Device, Window).

test(claimwindowforgpudevice_device_type_error, [
   error(type_error(sdl_gpu_device_blob, not_a_blob))]) :-
   sdl_claimwindowforgpudevice(not_a_blob, _).

test(claimwindowforgpudevice_window_type_error, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit)),
   error(type_error(sdl_window_blob, not_a_blob))]) :-
   sdl_claimwindowforgpudevice(Device, not_a_blob).

% Releasing a window that was never claimed (or already released) raises
% existence_error(claimed_window, Window).
test(releasewindowfromgpudevice_not_claimed, [
   setup((sdl_init([video]),
          sdl_createwindow(Window, "", 400, 600, [vulkan]),
          sdl_creategpudevice(Device, [spirv], false, null))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_destroywindow(Window),
            sdl_quit)),
   error(existence_error(claimed_window, _))]) :-
   sdl_releasewindowfromgpudevice(Device, Window).

% Double release: the second call must raise existence_error.
test(releasewindowfromgpudevice_double_release, [
   setup((sdl_init([video]),
          sdl_createwindow(Window, "", 400, 600, [vulkan]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_claimwindowforgpudevice(Device, Window))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_destroywindow(Window),
            sdl_quit)),
   error(existence_error(claimed_window, _))]) :-
   sdl_releasewindowfromgpudevice(Device, Window),
   sdl_releasewindowfromgpudevice(Device, Window).

% Device destruction auto-releases claimed windows on the SDL side; the
% window may then be destroyed without an explicit release call.
test(destroygpudevice_auto_releases_window, [
   setup((sdl_init([video]),
          sdl_createwindow(Window, "", 400, 600, [vulkan]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_claimwindowforgpudevice(Device, Window))),
   cleanup((sdl_destroywindow(Window),
            sdl_quit))]) :-
   sdl_destroygpudevice(Device).

% --- SDL_gpu: command buffer ------------------------------------------------

test(acquiregpucommandbuffer, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit))]) :-
   setup_call_cleanup(
      sdl_acquiregpucommandbuffer(CmdBuf, Device),
      true,
      sdl_submitgpucommandbuffer(CmdBuf)).

test(submitgpucommandbuffer, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_acquiregpucommandbuffer(CmdBuf, Device))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit))]) :-
   sdl_submitgpucommandbuffer(CmdBuf).

test(acquiregpucommandbuffer_device_type_error, [
   error(type_error(sdl_gpu_device_blob, not_a_blob))]) :-
   sdl_acquiregpucommandbuffer(_, not_a_blob).

test(submitgpucommandbuffer_type_error, [
   error(type_error(sdl_gpu_cmdbuf_blob, not_a_blob))]) :-
   sdl_submitgpucommandbuffer(not_a_blob).

% Submitting an already-submitted command buffer raises existence_error.
test(submitgpucommandbuffer_double_submit, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_acquiregpucommandbuffer(CmdBuf, Device))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit)),
   error(existence_error(command_buffer, _))]) :-
   sdl_submitgpucommandbuffer(CmdBuf),
   sdl_submitgpucommandbuffer(CmdBuf).

test(cancelgpucommandbuffer, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_acquiregpucommandbuffer(CmdBuf, Device))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit))]) :-
   sdl_cancelgpucommandbuffer(CmdBuf).

test(cancelgpucommandbuffer_type_error, [
   error(type_error(sdl_gpu_cmdbuf_blob, not_a_blob))]) :-
   sdl_cancelgpucommandbuffer(not_a_blob).

% Submitting a cancelled command buffer raises existence_error.
test(submitgpucommandbuffer_after_cancel, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_acquiregpucommandbuffer(CmdBuf, Device))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit)),
   error(existence_error(command_buffer, _))]) :-
   sdl_cancelgpucommandbuffer(CmdBuf),
   sdl_submitgpucommandbuffer(CmdBuf).

% Cancelling a submitted command buffer raises existence_error.
test(cancelgpucommandbuffer_after_submit, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_acquiregpucommandbuffer(CmdBuf, Device))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit)),
   error(existence_error(command_buffer, _))]) :-
   sdl_submitgpucommandbuffer(CmdBuf),
   sdl_cancelgpucommandbuffer(CmdBuf).

% --- SDL_gpu: swapchain texture ---------------------------------------------

test(waitandacquiregpuswapchaintexture, [
   setup((sdl_init([video]),
          sdl_createwindow(Window, "", 400, 600, [vulkan]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_claimwindowforgpudevice(Device, Window),
          sdl_acquiregpucommandbuffer(CmdBuf, Device))),
   cleanup((sdl_submitgpucommandbuffer(CmdBuf),
            sdl_releasewindowfromgpudevice(Device, Window),
            sdl_destroygpudevice(Device),
            sdl_destroywindow(Window),
            sdl_quit))]) :-
   sdl_waitandacquiregpuswapchaintexture(CmdBuf, Window, _Texture, _W, _H).

test(acquiregpuswapchaintexture, [
   setup((sdl_init([video]),
          sdl_createwindow(Window, "", 400, 600, [vulkan]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_claimwindowforgpudevice(Device, Window),
          sdl_acquiregpucommandbuffer(CmdBuf, Device))),
   cleanup((sdl_submitgpucommandbuffer(CmdBuf),
            sdl_releasewindowfromgpudevice(Device, Window),
            sdl_destroygpudevice(Device),
            sdl_destroywindow(Window),
            sdl_quit))]) :-
   sdl_acquiregpuswapchaintexture(CmdBuf, Window, _Texture, _W, _H).

test(waitandacquiregpuswapchaintexture_cmdbuf_type_error, [
   error(type_error(sdl_gpu_cmdbuf_blob, not_a_blob))]) :-
   sdl_waitandacquiregpuswapchaintexture(not_a_blob, _, _, _, _).

test(waitandacquiregpuswapchaintexture_window_type_error, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_acquiregpucommandbuffer(CmdBuf, Device))),
   cleanup((sdl_cancelgpucommandbuffer(CmdBuf),
            sdl_destroygpudevice(Device),
            sdl_quit)),
   error(type_error(sdl_window_blob, not_a_blob))]) :-
   sdl_waitandacquiregpuswapchaintexture(CmdBuf, not_a_blob, _, _, _).

% --- SDL_gpu: render pass ---------------------------------------------------

test(begingpurenderpass, [
   setup((sdl_init([video]),
          sdl_createwindow(Window, "", 400, 600, [vulkan]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_claimwindowforgpudevice(Device, Window),
          sdl_acquiregpucommandbuffer(CmdBuf, Device),
          sdl_waitandacquiregpuswapchaintexture(CmdBuf, Window, Texture, W, H))),
   cleanup((sdl_endgpurenderpass(RenderPass),
            sdl_submitgpucommandbuffer(CmdBuf),
            sdl_releasewindowfromgpudevice(Device, Window),
            sdl_destroygpudevice(Device),
            sdl_destroywindow(Window),
            sdl_quit))]) :-
   (  Texture == null
   -> true
   ;  Target = color_target(Texture, 0, 0, fcolor(0.0,0.0,0.0,1.0),
                            clear, store, null, 0, 0, false, false),
      sdl_begingpurenderpass(RenderPass, CmdBuf, [Target], null)
   ).

test(endgpurenderpass, [
   setup((sdl_init([video]),
          sdl_createwindow(Window, "", 400, 600, [vulkan]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_claimwindowforgpudevice(Device, Window),
          sdl_acquiregpucommandbuffer(CmdBuf, Device),
          sdl_waitandacquiregpuswapchaintexture(CmdBuf, Window, Texture, _, _),
          (  Texture == null
          -> RenderPass = null
          ;  Target = color_target(Texture, 0, 0, fcolor(0.0,0.0,0.0,1.0),
                                   clear, store, null, 0, 0, false, false),
             sdl_begingpurenderpass(RenderPass, CmdBuf, [Target], null)
          ))),
   cleanup((sdl_submitgpucommandbuffer(CmdBuf),
            sdl_releasewindowfromgpudevice(Device, Window),
            sdl_destroygpudevice(Device),
            sdl_destroywindow(Window),
            sdl_quit))]) :-
   (  RenderPass == null
   -> true
   ;  sdl_endgpurenderpass(RenderPass)
   ).

test(begingpurenderpass_cmdbuf_type_error, [
   error(type_error(sdl_gpu_cmdbuf_blob, not_a_blob))]) :-
   sdl_begingpurenderpass(_, not_a_blob, [], null).

test(begingpurenderpass_depthstencil_type_error, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_acquiregpucommandbuffer(CmdBuf, Device))),
   cleanup((sdl_cancelgpucommandbuffer(CmdBuf),
            sdl_destroygpudevice(Device),
            sdl_quit)),
   error(type_error((oneof([null]);sdl_gpu_depth_stencil_target), bogus))]) :-
   sdl_begingpurenderpass(_, CmdBuf, [], bogus).

test(begingpurenderpass_depthstencil_bad_arity, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_acquiregpucommandbuffer(CmdBuf, Device))),
   cleanup((sdl_cancelgpucommandbuffer(CmdBuf),
            sdl_destroygpudevice(Device),
            sdl_quit)),
   error(type_error((oneof([null]);sdl_gpu_depth_stencil_target), _))]) :-
   Bad = depth_stencil_target(not_a_blob, 1.0, load, store, load, store, false, 0, 0),
   sdl_begingpurenderpass(_, CmdBuf, [], Bad).

% --- SDL_gpu: create / release texture --------------------------------------

test(creategputexture, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit))]) :-
   setup_call_cleanup(
      sdl_creategputexture(Texture, Device,
         gpu_texture_create_info('2d', d24_unorm, [depth_stencil_target],
                                 400, 600, 1, 1, 1)),
      true,
      sdl_releasegputexture(Texture)).

test(creategputexture_color, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit))]) :-
   setup_call_cleanup(
      sdl_creategputexture(Texture, Device,
         gpu_texture_create_info('2d', b8g8r8a8_unorm, [color_target],
                                 400, 600, 1, 1, 1)),
      true,
      sdl_releasegputexture(Texture)).

test(creategputexture_device_type_error, [
   error(type_error(sdl_gpu_device_blob, not_a_blob))]) :-
   sdl_creategputexture(_, not_a_blob,
      gpu_texture_create_info('2d', d24_unorm, [depth_stencil_target],
                              400, 600, 1, 1, 1)).

test(creategputexture_format_type_error, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit)),
   error(type_error(sdl_gpu_texture_format, bogus))]) :-
   sdl_creategputexture(_, Device,
      gpu_texture_create_info('2d', bogus, [depth_stencil_target],
                              400, 600, 1, 1, 1)).

test(releasegputexture_type_error, [
   error(type_error(sdl_gpu_texture_blob, not_a_blob))]) :-
   sdl_releasegputexture(not_a_blob).

test(releasegputexture_double_release, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_creategputexture(Texture, Device,
             gpu_texture_create_info('2d', d24_unorm, [depth_stencil_target],
                                     400, 600, 1, 1, 1)))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit)),
   error(existence_error(texture, _))]) :-
   sdl_releasegputexture(Texture),
   sdl_releasegputexture(Texture).

% --- SDL_gpu: render pass with depth-stencil texture ------------------------

test(begingpurenderpass_with_depthstencil, [
   setup((sdl_init([video]),
          sdl_createwindow(Window, "", 400, 600, [vulkan]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_claimwindowforgpudevice(Device, Window),
          sdl_creategputexture(DepthTex, Device,
             gpu_texture_create_info('2d', d24_unorm, [depth_stencil_target],
                                     400, 600, 1, 1, 1)),
          sdl_acquiregpucommandbuffer(CmdBuf, Device),
          sdl_waitandacquiregpuswapchaintexture(CmdBuf, Window, Tex, _, _))),
   cleanup((sdl_endgpurenderpass(RenderPass),
            sdl_submitgpucommandbuffer(CmdBuf),
            sdl_releasegputexture(DepthTex),
            sdl_releasewindowfromgpudevice(Device, Window),
            sdl_destroygpudevice(Device),
            sdl_destroywindow(Window),
            sdl_quit))]) :-
   (  Tex == null
   -> true
   ;  ColorTarget = color_target(Tex, 0, 0, fcolor(0.0,0.0,0.0,1.0),
                                 clear, store, null, 0, 0, false, false),
      DS = depth_stencil_target(DepthTex, 1.0, clear, store,
                                dont_care, dont_care, false, 0, 0, 0),
      sdl_begingpurenderpass(RenderPass, CmdBuf, [ColorTarget], DS)
   ).

test(endgpurenderpass_type_error, [
   error(type_error(sdl_gpu_renderpass_blob, not_a_blob))]) :-
   sdl_endgpurenderpass(not_a_blob).

test(endgpurenderpass_double_end, [
   setup((sdl_init([video]),
          sdl_createwindow(Window, "", 400, 600, [vulkan]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_claimwindowforgpudevice(Device, Window),
          sdl_acquiregpucommandbuffer(CmdBuf, Device),
          sdl_waitandacquiregpuswapchaintexture(CmdBuf, Window, Texture, _, _),
          (  Texture == null
          -> true
          ;  Target = color_target(Texture, 0, 0, fcolor(0.0,0.0,0.0,1.0),
                                   clear, store, null, 0, 0, false, false),
             sdl_begingpurenderpass(RenderPass, CmdBuf, [Target], null),
             sdl_endgpurenderpass(RenderPass)
          ))),
   cleanup((sdl_submitgpucommandbuffer(CmdBuf),
            sdl_releasewindowfromgpudevice(Device, Window),
            sdl_destroygpudevice(Device),
            sdl_destroywindow(Window),
            sdl_quit)),
   error(existence_error(render_pass, _))]) :-
   nonvar(RenderPass),
   sdl_endgpurenderpass(RenderPass).

:- end_tests(sdl).

test_sdl :-
   run_tests.
