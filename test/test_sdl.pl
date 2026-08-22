:- use_module(library(sdl)).

:- dynamic shader_dir/1.
:- prolog_load_context(directory, Dir),
   directory_file_path(Dir, '../shaders', ShaderDir),
   assertz(shader_dir(ShaderDir)).

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
   Img = "../test/images.jpg",
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
      Img = "../test/images.jpg",
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
      Img = "../test/images.jpg",
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
   ;  make_color_target([texture(Texture), load_op(clear), store_op(store)], Target),
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
          ;  make_color_target([texture(Texture), load_op(clear), store_op(store)], Target),
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
      (  make_gpu_texture_create_info([format(d24_unorm),
                                       usage([depth_stencil_target]),
                                       width(400), height(600)], Info),
         sdl_creategputexture(Texture, Device, Info) ),
      true,
      sdl_releasegputexture(Texture)).

test(creategputexture_color, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit))]) :-
   setup_call_cleanup(
      (  make_gpu_texture_create_info([format(b8g8r8a8_unorm),
                                       usage([color_target]),
                                       width(400), height(600)], Info),
         sdl_creategputexture(Texture, Device, Info) ),
      true,
      sdl_releasegputexture(Texture)).

test(creategputexture_device_type_error, [
   error(type_error(sdl_gpu_device_blob, not_a_blob))]) :-
   make_gpu_texture_create_info([format(d24_unorm),
                                 usage([depth_stencil_target]),
                                 width(400), height(600)], Info),
   sdl_creategputexture(_, not_a_blob, Info).

test(creategputexture_format_type_error, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit)),
   error(type_error(sdl_gpu_texture_format, bogus))]) :-
   make_gpu_texture_create_info([format(bogus),
                                 usage([depth_stencil_target]),
                                 width(400), height(600)], Info),
   sdl_creategputexture(_, Device, Info).

test(releasegputexture_type_error, [
   error(type_error(sdl_gpu_texture_blob, not_a_blob))]) :-
   sdl_releasegputexture(not_a_blob).

test(releasegputexture_double_release, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null),
          make_gpu_texture_create_info([format(d24_unorm),
                                        usage([depth_stencil_target]),
                                        width(400), height(600)], Info),
          sdl_creategputexture(Texture, Device, Info))),
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
          make_gpu_texture_create_info([format(d24_unorm),
                                        usage([depth_stencil_target]),
                                        width(400), height(600)], DepthInfo),
          sdl_creategputexture(DepthTex, Device, DepthInfo),
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
   ;  make_color_target([texture(Tex), load_op(clear), store_op(store)], ColorTarget),
      make_depth_stencil_target([texture(DepthTex), load_op(clear), store_op(store)], DS),
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
          ;  make_color_target([texture(Texture), load_op(clear), store_op(store)], Target),
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

% --- SDL_gpu: create / release shader ----------------------------------------

test(creategpushader, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit))]) :-
   shader_dir(Dir),
   directory_file_path(Dir, 'tri.vert.spv', VertSpv),
   read_file_to_string(VertSpv, Code, [type(binary)]),
   make_gpu_shader_create_info([code(Code), format(spirv), stage(vertex)],
                               Info),
   setup_call_cleanup(
      sdl_creategpushader(Shader, Device, Info),
      true,
      sdl_releasegpushader(Shader)).

test(creategpushader_fragment, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit))]) :-
   shader_dir(Dir),
   directory_file_path(Dir, 'tri.frag.spv', FragSpv),
   read_file_to_string(FragSpv, Code, [type(binary)]),
   make_gpu_shader_create_info([code(Code), format(spirv), stage(fragment)],
                               Info),
   setup_call_cleanup(
      sdl_creategpushader(Shader, Device, Info),
      true,
      sdl_releasegpushader(Shader)).

test(creategpushader_device_type_error, [
   error(type_error(sdl_gpu_device_blob, not_a_blob))]) :-
   make_gpu_shader_create_info([code(""), format(spirv), stage(vertex)], Info),
   sdl_creategpushader(_, not_a_blob, Info).

test(creategpushader_stage_type_error, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit)),
   error(type_error(sdl_gpu_shader_stage, bogus))]) :-
   make_gpu_shader_create_info([code(""), format(spirv), stage(bogus)], Info),
   sdl_creategpushader(_, Device, Info).

test(releasegpushader_type_error, [
   error(type_error(sdl_gpu_shader_blob, not_a_blob))]) :-
   sdl_releasegpushader(not_a_blob).

test(releasegpushader_double_release, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null),
          shader_dir(Dir),
          directory_file_path(Dir, 'tri.vert.spv', VertSpv),
          read_file_to_string(VertSpv, Code, [type(binary)]),
          make_gpu_shader_create_info([code(Code), format(spirv), stage(vertex)], Info),
          sdl_creategpushader(Shader, Device, Info))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit)),
   error(existence_error(shader, _))]) :-
   sdl_releasegpushader(Shader),
   sdl_releasegpushader(Shader).

% --- SDL_gpu: create / release graphics pipeline -----------------------------

test(creategpugraphicspipeline, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null),
          shader_dir(Dir),
          directory_file_path(Dir, 'tri.vert.spv', VertSpv),
          directory_file_path(Dir, 'tri.frag.spv', FragSpv),
          read_file_to_string(VertSpv, VertCode, [type(binary)]),
          read_file_to_string(FragSpv, FragCode, [type(binary)]),
          make_gpu_shader_create_info([code(VertCode), format(spirv), stage(vertex)], VertInfo),
          make_gpu_shader_create_info([code(FragCode), format(spirv), stage(fragment)], FragInfo),
          sdl_creategpushader(VertShader, Device, VertInfo),
          sdl_creategpushader(FragShader, Device, FragInfo))),
   cleanup((sdl_releasegpushader(VertShader),
            sdl_releasegpushader(FragShader),
            sdl_destroygpudevice(Device),
            sdl_quit))]) :-
   make_vertex_buffer_description([slot(0), pitch(24)], VBD),
   make_vertex_attribute([location(0), buffer_slot(0), format(float2), offset(0)], PosAttr),
   make_vertex_attribute([location(1), buffer_slot(0), format(float4), offset(8)], ColorAttr),
   make_vertex_input_state([vertex_buffer_descriptions([VBD]), vertex_attributes([PosAttr, ColorAttr])], VIS),
   default_rasterizer_state(RS),
   default_multisample_state(MS),
   default_stencil_op_state(SOS),
   make_depth_stencil_state([back_stencil_state(SOS), front_stencil_state(SOS)], DSS),
   make_color_target_blend_state([], BS),
   make_color_target_description([format(b8g8r8a8_unorm), blend_state(BS)], CTD),
   make_target_info([color_target_descriptions([CTD])], TI),
   make_gpu_graphics_pipeline_create_info([
      vertex_shader(VertShader),
      fragment_shader(FragShader),
      vertex_input_state(VIS),
      rasterizer_state(RS),
      multisample_state(MS),
      depth_stencil_state(DSS),
      target_info(TI)
   ], Info),
   setup_call_cleanup(
      sdl_creategpugraphicspipeline(Pipeline, Device, Info),
      true,
      sdl_releasegpugraphicspipeline(Pipeline)).

test(releasegpugraphicspipeline_type_error, [
   error(type_error(sdl_gpu_pipeline_blob, not_a_blob))]) :-
   sdl_releasegpugraphicspipeline(not_a_blob).

test(creategpugraphicspipeline_device_type_error, [
   error(type_error(sdl_gpu_device_blob, not_a_blob))]) :-
   sdl_creategpugraphicspipeline(_, not_a_blob, not_a_record).

% --- SDL_gpu: create / release buffer ----------------------------------------

test(creategpubuffer, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit))]) :-
   setup_call_cleanup(
      sdl_creategpubuffer(Buffer, Device, [vertex], 1024),
      true,
      sdl_releasegpubuffer(Buffer)).

test(creategpubuffer_index, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit))]) :-
   setup_call_cleanup(
      sdl_creategpubuffer(Buffer, Device, [index], 512),
      true,
      sdl_releasegpubuffer(Buffer)).

test(creategpubuffer_device_type_error, [
   error(type_error(sdl_gpu_device_blob, not_a_blob))]) :-
   sdl_creategpubuffer(_, not_a_blob, [vertex], 1024).

test(creategpubuffer_usage_type_error, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit)),
   error(type_error(sdl_gpu_buffer_usage, bogus))]) :-
   sdl_creategpubuffer(_, Device, [bogus], 1024).

test(releasegpubuffer_type_error, [
   error(type_error(sdl_gpu_buffer_blob, not_a_blob))]) :-
   sdl_releasegpubuffer(not_a_blob).

test(releasegpubuffer_double_release, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_creategpubuffer(Buffer, Device, [vertex], 1024))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit)),
   error(existence_error(buffer, _))]) :-
   sdl_releasegpubuffer(Buffer),
   sdl_releasegpubuffer(Buffer).

% --- SDL_gpu: create / release transfer buffer -------------------------------

test(creategputransferbuffer, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit))]) :-
   setup_call_cleanup(
      sdl_creategputransferbuffer(TB, Device, upload, 1024),
      true,
      sdl_releasegputransferbuffer(TB)).

test(creategputransferbuffer_download, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit))]) :-
   setup_call_cleanup(
      sdl_creategputransferbuffer(TB, Device, download, 512),
      true,
      sdl_releasegputransferbuffer(TB)).

test(creategputransferbuffer_device_type_error, [
   error(type_error(sdl_gpu_device_blob, not_a_blob))]) :-
   sdl_creategputransferbuffer(_, not_a_blob, upload, 1024).

test(creategputransferbuffer_usage_type_error, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit)),
   error(type_error(sdl_gpu_transfer_buffer_usage, bogus))]) :-
   sdl_creategputransferbuffer(_, Device, bogus, 1024).

test(releasegputransferbuffer_type_error, [
   error(type_error(sdl_gpu_transfer_buffer_blob, not_a_blob))]) :-
   sdl_releasegputransferbuffer(not_a_blob).

test(releasegputransferbuffer_double_release, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_creategputransferbuffer(TB, Device, upload, 1024))),
   cleanup((sdl_destroygpudevice(Device),
            sdl_quit)),
   error(existence_error(transfer_buffer, _))]) :-
   sdl_releasegputransferbuffer(TB),
   sdl_releasegputransferbuffer(TB).

% --- SDL_gpu: map / unmap transfer buffer ------------------------------------

test(mapgputransferbuffer, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_creategputransferbuffer(TB, Device, upload, 1024))),
   cleanup((sdl_releasegputransferbuffer(TB),
            sdl_destroygpudevice(Device),
            sdl_quit))]) :-
   setup_call_cleanup(
      sdl_mapgputransferbuffer(Ptr, TB, false),
      true,
      sdl_unmapgputransferbuffer(TB)).

test(mapgputransferbuffer_cycle, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_creategputransferbuffer(TB, Device, upload, 1024))),
   cleanup((sdl_releasegputransferbuffer(TB),
            sdl_destroygpudevice(Device),
            sdl_quit))]) :-
   setup_call_cleanup(
      sdl_mapgputransferbuffer(Ptr, TB, true),
      true,
      sdl_unmapgputransferbuffer(TB)).

test(mapgputransferbuffer_type_error, [
   error(type_error(sdl_gpu_transfer_buffer_blob, not_a_blob))]) :-
   sdl_mapgputransferbuffer(_, not_a_blob, false).

test(unmapgputransferbuffer_type_error, [
   error(type_error(sdl_gpu_transfer_buffer_blob, not_a_blob))]) :-
   sdl_unmapgputransferbuffer(not_a_blob).

% --- SDL_gpu: copy pass ------------------------------------------------------

test(begingpucopypass, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_acquiregpucommandbuffer(CmdBuf, Device))),
   cleanup((sdl_submitgpucommandbuffer(CmdBuf),
            sdl_destroygpudevice(Device),
            sdl_quit))]) :-
   setup_call_cleanup(
      sdl_begingpucopypass(CopyPass, CmdBuf),
      true,
      sdl_endgpucopypass(CopyPass)).

test(begingpucopypass_cmdbuf_type_error, [
   error(type_error(sdl_gpu_cmdbuf_blob, not_a_blob))]) :-
   sdl_begingpucopypass(_, not_a_blob).

test(endgpucopypass_type_error, [
   error(type_error(sdl_gpu_copypass_blob, not_a_blob))]) :-
   sdl_endgpucopypass(not_a_blob).

test(endgpucopypass_double_end, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_acquiregpucommandbuffer(CmdBuf, Device),
          sdl_begingpucopypass(CopyPass, CmdBuf),
          sdl_endgpucopypass(CopyPass))),
   cleanup((sdl_submitgpucommandbuffer(CmdBuf),
            sdl_destroygpudevice(Device),
            sdl_quit)),
   error(existence_error(copy_pass, _))]) :-
   sdl_endgpucopypass(CopyPass).

% --- SDL_gpu: upload to buffer -----------------------------------------------

test(uploadtogpubuffer, [
   setup((sdl_init([video]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_creategputransferbuffer(TB, Device, upload, 1024),
          sdl_creategpubuffer(Buffer, Device, [vertex], 1024),
          sdl_acquiregpucommandbuffer(CmdBuf, Device),
          sdl_begingpucopypass(CopyPass, CmdBuf))),
   cleanup((sdl_endgpucopypass(CopyPass),
            sdl_submitgpucommandbuffer(CmdBuf),
            sdl_releasegpubuffer(Buffer),
            sdl_releasegputransferbuffer(TB),
            sdl_destroygpudevice(Device),
            sdl_quit))]) :-
   Source = transfer_buffer_location(TB, 0),
   Destination = buffer_region(Buffer, 0, 1024),
   sdl_uploadtogpubuffer(CopyPass, Source, Destination, false).

test(uploadtogpubuffer_type_error, [
   error(type_error(sdl_gpu_copypass_blob, not_a_blob))]) :-
   sdl_uploadtogpubuffer(not_a_blob,
      transfer_buffer_location(not_a_blob, 0),
      buffer_region(not_a_blob, 0, 0), false).

% --- SDL_gpu: draw commands --------------------------------------------------

test(bindgpugraphicspipeline, [
   setup((sdl_init([video]),
          sdl_createwindow(Window, "", 400, 600, [vulkan]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_claimwindowforgpudevice(Device, Window),
          shader_dir(Dir),
          directory_file_path(Dir, 'tri.vert.spv', VertSpv),
          directory_file_path(Dir, 'tri.frag.spv', FragSpv),
          read_file_to_string(VertSpv, VertCode, [type(binary)]),
          read_file_to_string(FragSpv, FragCode, [type(binary)]),
          make_gpu_shader_create_info([code(VertCode), format(spirv), stage(vertex)], VertInfo),
          make_gpu_shader_create_info([code(FragCode), format(spirv), stage(fragment)], FragInfo),
          sdl_creategpushader(VertShader, Device, VertInfo),
          sdl_creategpushader(FragShader, Device, FragInfo),
          make_vertex_buffer_description([slot(0), pitch(24)], VBD),
          make_vertex_attribute([location(0), buffer_slot(0), format(float2), offset(0)], PosAttr),
          make_vertex_attribute([location(1), buffer_slot(0), format(float4), offset(8)], ColorAttr),
          make_vertex_input_state([vertex_buffer_descriptions([VBD]), vertex_attributes([PosAttr, ColorAttr])], VIS),
          default_rasterizer_state(RS),
          default_multisample_state(MS),
          default_stencil_op_state(SOS),
          make_depth_stencil_state([back_stencil_state(SOS), front_stencil_state(SOS)], DSS),
          make_color_target_blend_state([], BS),
          make_color_target_description([format(b8g8r8a8_unorm), blend_state(BS)], CTD),
          make_target_info([color_target_descriptions([CTD])], TI),
          make_gpu_graphics_pipeline_create_info([vertex_shader(VertShader), fragment_shader(FragShader), vertex_input_state(VIS), rasterizer_state(RS), multisample_state(MS), depth_stencil_state(DSS), target_info(TI)], PipelineInfo),
          sdl_creategpugraphicspipeline(Pipeline, Device, PipelineInfo),
          sdl_acquiregpucommandbuffer(CmdBuf, Device),
          sdl_waitandacquiregpuswapchaintexture(CmdBuf, Window, Tex, _, _))),
   cleanup((sdl_submitgpucommandbuffer(CmdBuf),
            sdl_releasegpugraphicspipeline(Pipeline),
            sdl_releasegpushader(VertShader),
            sdl_releasegpushader(FragShader),
            sdl_releasewindowfromgpudevice(Device, Window),
            sdl_destroygpudevice(Device),
            sdl_destroywindow(Window),
            sdl_quit))]) :-
   (  Tex == null
   -> true
   ;  make_color_target([texture(Tex), load_op(clear), store_op(store)], CT),
      sdl_begingpurenderpass(RenderPass, CmdBuf, [CT], null),
      sdl_bindgpugraphicspipeline(RenderPass, Pipeline),
      sdl_endgpurenderpass(RenderPass)
   ).

test(drawgpuprimitives, [
   setup((sdl_init([video]),
          sdl_createwindow(Window, "", 400, 600, [vulkan]),
          sdl_creategpudevice(Device, [spirv], false, null),
          sdl_claimwindowforgpudevice(Device, Window),
          shader_dir(Dir),
          directory_file_path(Dir, 'tri.vert.spv', VertSpv),
          directory_file_path(Dir, 'tri.frag.spv', FragSpv),
          read_file_to_string(VertSpv, VertCode, [type(binary)]),
          read_file_to_string(FragSpv, FragCode, [type(binary)]),
          make_gpu_shader_create_info([code(VertCode), format(spirv), stage(vertex)], VertInfo),
          make_gpu_shader_create_info([code(FragCode), format(spirv), stage(fragment)], FragInfo),
          sdl_creategpushader(VertShader, Device, VertInfo),
          sdl_creategpushader(FragShader, Device, FragInfo),
          make_vertex_buffer_description([slot(0), pitch(24)], VBD),
          make_vertex_attribute([location(0), buffer_slot(0), format(float2), offset(0)], PosAttr),
          make_vertex_attribute([location(1), buffer_slot(0), format(float4), offset(8)], ColorAttr),
          make_vertex_input_state([vertex_buffer_descriptions([VBD]), vertex_attributes([PosAttr, ColorAttr])], VIS),
          default_rasterizer_state(RS),
          default_multisample_state(MS),
          default_stencil_op_state(SOS),
          make_depth_stencil_state([back_stencil_state(SOS), front_stencil_state(SOS)], DSS),
          make_color_target_blend_state([], BS),
          make_color_target_description([format(b8g8r8a8_unorm), blend_state(BS)], CTD),
          make_target_info([color_target_descriptions([CTD])], TI),
          make_gpu_graphics_pipeline_create_info([vertex_shader(VertShader), fragment_shader(FragShader), vertex_input_state(VIS), rasterizer_state(RS), multisample_state(MS), depth_stencil_state(DSS), target_info(TI)], PipelineInfo),
          sdl_creategpugraphicspipeline(Pipeline, Device, PipelineInfo),
          sdl_creategpubuffer(VertexBuffer, Device, [vertex], 72),
          sdl_acquiregpucommandbuffer(CmdBuf, Device),
          sdl_waitandacquiregpuswapchaintexture(CmdBuf, Window, Tex, _, _))),
   cleanup((sdl_releasegpubuffer(VertexBuffer),
            sdl_submitgpucommandbuffer(CmdBuf),
            sdl_releasegpugraphicspipeline(Pipeline),
            sdl_releasegpushader(VertShader),
            sdl_releasegpushader(FragShader),
            sdl_releasewindowfromgpudevice(Device, Window),
            sdl_destroygpudevice(Device),
            sdl_destroywindow(Window),
            sdl_quit))]) :-
   (  Tex == null
   -> true
   ;  make_color_target([texture(Tex), load_op(clear), store_op(store)], CT),
      sdl_begingpurenderpass(RenderPass, CmdBuf, [CT], null),
      sdl_bindgpugraphicspipeline(RenderPass, Pipeline),
      sdl_bindgpuvertexbuffers(RenderPass, 0, [buffer_binding(VertexBuffer, 0)]),
      sdl_drawgpuprimitives(RenderPass, 3, 1, 0, 0),
      sdl_endgpurenderpass(RenderPass)
   ).

test(bindgpugraphicspipeline_type_error, [
   error(type_error(sdl_gpu_renderpass_blob, not_a_blob))]) :-
   sdl_bindgpugraphicspipeline(not_a_blob, not_a_blob).

test(drawgpuprimitives_type_error, [
   error(type_error(sdl_gpu_renderpass_blob, not_a_blob))]) :-
   sdl_drawgpuprimitives(not_a_blob, 3, 1, 0, 0).

:- end_tests(sdl).

test_sdl :-
   run_tests.
