:- use_module(library(sdl)).
:- use_module(library(ptr)).

% Minimal GPU "hello world": a colored triangle rendered via SDL_gpu.
%
% Run from the pack root:
%   swipl -p library=prolog -p foreign=lib/$(swipl --arch) -g main examples/triangle_gpu.pl
%
% The triangle uses precompiled SPIR-V shaders (shaders/tri.vert.spv,
% shaders/tri.frag.spv) with vertex layout:
%   location 0: float2 pos   (offset 0,  8 bytes)
%   location 1: float4 color (offset 8, 16 bytes)
%   stride: 24 bytes per vertex, 3 vertices = 72 bytes total

win_w(640).
win_h(480).

% Resolve the shaders directory relative to this file at load time.
:- prolog_load_context(directory, ExamplesDir),
   directory_file_path(ExamplesDir, '../shaders', ShaderDir),
   assertz(shader_dir(ShaderDir)).

main :-
    setup_call_cleanup(
        sdl_init([everything]),
        run,
        sdl_quit).

run :-
    win_w(W), win_h(H),
    setup_call_cleanup(
        sdl_createwindow(Window, "GPU Triangle", W, H, [vulkan]),
        setup_call_cleanup(
            (   sdl_creategpudevice(Device, [spirv], false, null),
                sdl_claimwindowforgpudevice(Device, Window)
            ),
            setup_call_cleanup(
                create_resources(Device, Pipeline, VertexBuffer, TransferBuffer),
                main_loop(Device, Window, Pipeline, VertexBuffer),
                cleanup_resources(Device, Pipeline, VertexBuffer, TransferBuffer)),
            (   sdl_releasewindowfromgpudevice(Device, Window),
                sdl_destroygpudevice(Device)
            )),
        sdl_destroywindow(Window)).

% --- resource creation ------------------------------------------------------

create_resources(Device, Pipeline, VertexBuffer, TransferBuffer) :-
    shader_dir(ShaderDir),
    load_shader(Device, vertex, ShaderDir, VertShader),
    load_shader(Device, fragment, ShaderDir, FragShader),
    create_pipeline(Device, VertShader, FragShader, Pipeline),
    create_vertex_data(Device, VertexBuffer, TransferBuffer),
    sdl_releasegpushader(VertShader),
    sdl_releasegpushader(FragShader).

cleanup_resources(_Device, Pipeline, VertexBuffer, TransferBuffer) :-
    sdl_releasegpugraphicspipeline(Pipeline),
    sdl_releasegpubuffer(VertexBuffer),
    sdl_releasegputransferbuffer(TransferBuffer).

load_shader(Device, Stage, ShaderDir, Shader) :-
    (   Stage = vertex -> File = 'tri.vert.spv'
    ;   Stage = fragment -> File = 'tri.frag.spv'
    ),
    directory_file_path(ShaderDir, File, Path),
    read_file_to_string(Path, Code, [type(binary)]),
    make_gpu_shader_create_info([code(Code), format(spirv), stage(Stage)], Info),
    sdl_creategpushader(Shader, Device, Info).

create_pipeline(Device, VertShader, FragShader, Pipeline) :-
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
    sdl_creategpugraphicspipeline(Pipeline, Device, Info).

% Vertex data: 3 vertices, each with pos(float2) + color(float4) = 24 bytes.
%   vertex 0: pos(-0.5,-0.5)  color(1,0,0,1)  red
%   vertex 1: pos( 0.5,-0.5)  color(0,1,0,1)  green
%   vertex 2: pos( 0.0, 0.5)  color(0,0,1,1)  blue
create_vertex_data(Device, VertexBuffer, TransferBuffer) :-
    Vertices = [
       -0.5, -0.5,  1.0, 0.0, 0.0, 1.0,
        0.5, -0.5,  0.0, 1.0, 0.0, 1.0,
        0.0,  0.5,  0.0, 0.0, 1.0, 1.0
    ],
    length(Vertices, Count),
    ByteSize is Count * 4,  % float32 = 4 bytes
    sdl_creategpubuffer(VertexBuffer, Device, [vertex], ByteSize),
    sdl_creategputransferbuffer(TransferBuffer, Device, upload, ByteSize),
    sdl_mapgputransferbuffer(Ptr, TransferBuffer, false),
    ptr_store_float32s(Ptr, 0, Vertices),
    sdl_unmapgputransferbuffer(TransferBuffer),
    sdl_acquiregpucommandbuffer(CmdBuf, Device),
    sdl_begingpucopypass(CopyPass, CmdBuf),
    Source = transfer_buffer_location(TransferBuffer, 0),
    Dest = buffer_region(VertexBuffer, 0, ByteSize),
    sdl_uploadtogpubuffer(CopyPass, Source, Dest, false),
    sdl_endgpucopypass(CopyPass),
    sdl_submitgpucommandbuffer(CmdBuf).

% --- main loop --------------------------------------------------------------

main_loop(Device, Window, Pipeline, VertexBuffer) :-
    (   sdl_pollevent(Event),
        Event.type == quit
    ->  true
    ;   render_frame(Device, Window, Pipeline, VertexBuffer),
        main_loop(Device, Window, Pipeline, VertexBuffer)
    ).

render_frame(Device, Window, Pipeline, VertexBuffer) :-
    sdl_acquiregpucommandbuffer(CmdBuf, Device),
    (   sdl_waitandacquiregpuswapchaintexture(CmdBuf, Window, Texture, _, _),
        Texture \== null
    ->  make_color_target([texture(Texture), load_op(clear), store_op(store)], CT),
        sdl_begingpurenderpass(RenderPass, CmdBuf, [CT], null),
        sdl_bindgpugraphicspipeline(RenderPass, Pipeline),
        sdl_bindgpuvertexbuffers(RenderPass, 0, [buffer_binding(VertexBuffer, 0)]),
        sdl_drawgpuprimitives(RenderPass, 3, 1, 0, 0),
        sdl_endgpurenderpass(RenderPass)
    ;   true
    ),
    sdl_submitgpucommandbuffer(CmdBuf).
