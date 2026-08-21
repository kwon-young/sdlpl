:- use_module(library(sdl)).
:- use_module(library(ptr)).

% Pong rendered through a pure SDL_gpu pipeline.
%
% Game logic (motion, collision, scoring) lives entirely in Prolog.  The
% geometry (two paddle rectangles and a ball quad) is tessellated into
% triangles in Prolog and uploaded each frame to a GPU vertex buffer.  The
% round ball is drawn as a quad and shaped in the fragment shader via a
% signed-distance field with fwidth-based anti-aliasing.
%
% Run from the pack root:
%   swipl -p library=prolog -p foreign=lib/$(swipl --arch) -g main examples/pong_gpu.pl
%
% Controls:
%   W / S       left paddle up / down
%   Up / Down   left paddle up / down
%   Esc         quit
%
% Vertex layout (stride 36 bytes):
%   location 0: float2 pos    (offset 0)
%   location 1: float2 uv     (offset 8)   ball: -1..1 across the quad
%   location 2: float4 color  (offset 16)
%   location 3: float   shape (offset 32)  0.0 = solid rect, 1.0 = ball SDF

win_w(800).
win_h(600).

paddle_w(14.0).
paddle_h(100.0).
paddle_margin(24.0).
paddle_speed(380.0).

ball_r(8.0).
ball_d(D) :- ball_r(R), D is R * 2.0.
ball_pad(10).
ball_base_speed(300.0).
ball_max_speed(560.0).
ball_accel(1.06).
max_bounce_angle(0.7853981633974483).  % pi / 4
max_dt(0.05).

ai_speed(320.0).

% Geometry is fixed: 3 shapes * 2 triangles * 3 vertices = 18 vertices.
verts_per_shape(6).
num_shapes(3).
floats_per_vertex(9).
vertex_bytes(N) :-
    verts_per_shape(V), num_shapes(S), floats_per_vertex(F),
    N is V * S * F * 4.

% Resolve the shaders directory relative to this file at load time.
:- prolog_load_context(directory, ExamplesDir),
   directory_file_path(ExamplesDir, '../shaders', ShaderDir),
   assertz(shader_dir(ShaderDir)).

% --- entry point ------------------------------------------------------------

main :-
    setup_call_cleanup(
        sdl_init([everything]),
        run,
        sdl_quit).

run :-
    win_w(W), win_h(H),
    setup_call_cleanup(
        sdl_createwindow(Window, "GPU Pong", W, H, [vulkan]),
        setup_call_cleanup(
            (   sdl_creategpudevice(Device, [spirv], false, null),
                sdl_claimwindowforgpudevice(Device, Window)
            ),
            setup_call_cleanup(
                create_resources(Device, Pipeline, VertexBuffer, TransferBuffer),
                (   initial_state(State0),
                    main_loop(Device, Window, Pipeline,
                              VertexBuffer, TransferBuffer, State0)
                ),
                cleanup_resources(Device, Pipeline, VertexBuffer, TransferBuffer)),
            (   sdl_releasewindowfromgpudevice(Device, Window),
                sdl_destroygpudevice(Device)
            )),
        sdl_destroywindow(Window)).

% --- resource creation / cleanup --------------------------------------------

create_resources(Device, Pipeline, VertexBuffer, TransferBuffer) :-
    shader_dir(ShaderDir),
    load_shader(Device, vertex, ShaderDir, VertShader),
    load_shader(Device, fragment, ShaderDir, FragShader),
    create_pipeline(Device, VertShader, FragShader, Pipeline),
    vertex_bytes(ByteSize),
    sdl_creategpubuffer(VertexBuffer, Device, [vertex], ByteSize),
    sdl_creategputransferbuffer(TransferBuffer, Device, upload, ByteSize),
    sdl_releasegpushader(VertShader),
    sdl_releasegpushader(FragShader).

cleanup_resources(_Device, Pipeline, VertexBuffer, TransferBuffer) :-
    sdl_releasegpugraphicspipeline(Pipeline),
    sdl_releasegpubuffer(VertexBuffer),
    sdl_releasegputransferbuffer(TransferBuffer).

load_shader(Device, Stage, ShaderDir, Shader) :-
    (   Stage = vertex -> File = 'pong.vert.spv'
    ;   Stage = fragment -> File = 'pong.frag.spv'
    ),
    directory_file_path(ShaderDir, File, Path),
    read_file_to_string(Path, Code, [type(binary)]),
    make_gpu_shader_create_info([code(Code), format(spirv), stage(Stage)], Info),
    sdl_creategpushader(Shader, Device, Info).

create_pipeline(Device, VertShader, FragShader, Pipeline) :-
    floats_per_vertex(F),
    Pitch is F * 4,
    make_vertex_buffer_description([slot(0), pitch(Pitch)], VBD),
    make_vertex_attribute([location(0), buffer_slot(0), format(float2), offset(0)], PosAttr),
    make_vertex_attribute([location(1), buffer_slot(0), format(float2), offset(8)], UvAttr),
    make_vertex_attribute([location(2), buffer_slot(0), format(float4), offset(16)], ColorAttr),
    make_vertex_attribute([location(3), buffer_slot(0), format(float), offset(32)], ShapeAttr),
    make_vertex_input_state(
        [vertex_buffer_descriptions([VBD]),
         vertex_attributes([PosAttr, UvAttr, ColorAttr, ShapeAttr])], VIS),
    make_rasterizer_state([fill_mode(fill), cull_mode(none)], RS),
    default_multisample_state(MS),
    default_stencil_op_state(SOS),
    make_depth_stencil_state([back_stencil_state(SOS), front_stencil_state(SOS)], DSS),
    make_color_target_blend_state([
        src_color_blendfactor(src_alpha),
        dst_color_blendfactor(one_minus_src_alpha),
        src_alpha_blendfactor(one),
        dst_alpha_blendfactor(one_minus_src_alpha),
        enable_blend(true)
    ], BS),
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

% --- game state --------------------------------------------------------------

initial_state(State) :-
    win_w(W), win_h(H),
    ball_d(D),
    paddle_h(PH),
    CX is W / 2 - D / 2,
    CY is H / 2 - D / 2,
    PY is H / 2 - PH / 2,
    ball_base_speed(Speed),
    get_time(Now),
    State = state{
        p1_y: PY,
        p2_y: PY,
        ball_x: CX,
        ball_y: CY,
        ball_dx: Speed,
        ball_dy: 0.0,
        ball_speed: Speed,
        ball_phase: 0.0,
        p1_score: 0,
        p2_score: 0,
        keys: keys{w:0, s:0, up:0, down:0},
        t: Now,
        dt: 0.0,
        fps_count: 0,
        fps_t: Now
    }.

% --- main loop --------------------------------------------------------------
%
% Mirrors the event loop in examples/pong2.pl: poll one event per iteration,
% dispatch it (updating the state dict via the functional .put notation,
% which the SWI reader expands to put_dict/3 at compile time), and when the
% queue is empty run a simulation step + render frame.  The loop terminates
% on a quit event or an Esc keydown.

main_loop(Device, Window, Pipeline, VertexBuffer, TransferBuffer, State0) :-
    (   sdl_pollevent(Event)
    ->  (   Event.type == quit
        ->  true
        ;   handle_event(Event, State0, State1, Quit),
            (   Quit == true
            ->  true
            ;   main_loop(Device, Window, Pipeline,
                          VertexBuffer, TransferBuffer, State1)
            )
        )
    ;   render_frame(Device, Window, Pipeline,
                     VertexBuffer, TransferBuffer, State0, State),
        main_loop(Device, Window, Pipeline,
                  VertexBuffer, TransferBuffer, State)
    ).

% Keyboard events arrive as dicts tagged `keyboard` whose `type` field is
% the atom `keydown` or `keyup` (the first SDL event argument).  The `state`
% field is 1 on press, 0 on release.  keysym is the compound
% keysym(Scancode, Key, Mod) — NOT a dict — so we destructure it with (=)/2.
handle_event(Event, State0, State, Quit) :-
    (   Event.type == keydown
    ;   Event.type == keyup
    ),
    !,
    Event.keysym = keysym(Scancode, _, _),
    Down = Event.state,
    (   Scancode =:= 41, Down =:= 1            % Esc pressed -> quit
    ->  State = State0, Quit = true
    ;   Keys0 = State0.keys,
        update_key(Scancode, Down, Keys0, Keys),
        State = State0.put(keys, Keys),
        Quit = false
    ).
handle_event(_Event, State, State, false).

% SDL scancodes: W=26, S=22, Up=82, Down=81.  Esc (41) is handled above.
update_key(26, Down, Keys0, Keys) :- !, Keys = Keys0.put(w, Down).
update_key(22, Down, Keys0, Keys) :- !, Keys = Keys0.put(s, Down).
update_key(82, Down, Keys0, Keys) :- !, Keys = Keys0.put(up, Down).
update_key(81, Down, Keys0, Keys) :- !, Keys = Keys0.put(down, Down).
update_key(_, _, Keys, Keys) :- !.

% --- physics ----------------------------------------------------------------

step(State0, State) :-
    get_time(Now),
    Dt0 is Now - State0.t,
    max_dt(MaxDt),
    (   Dt0 > MaxDt -> Dt = MaxDt ; Dt = Dt0 ),
    S1 = State0.put([t=Now, dt=Dt]),
    move_left_paddle(S1, S2),
    move_right_paddle(S2, S3),
    move_ball(S3, S4),
    advance_phase(S4, State).

% Pulse phase advances proportionally to ball speed: faster ball breathes
% faster.  360 px/s maps to one cycle per second.
advance_phase(State0, State) :-
    Phase0 is State0.ball_phase,
    Inc is State0.ball_speed * State0.dt / 360.0,
    P is Phase0 + Inc,
    Phase is P - floor(P),
    State = State0.put(ball_phase, Phase).

move_left_paddle(State0, State) :-
    Keys = State0.keys,
    paddle_speed(V),
    Step is V * State0.dt,
    Dir is -Keys.w + Keys.s - Keys.up + Keys.down,  % net (-1, 0, +1)
    Dy is Dir * Step,
    Y0 is State0.p1_y + Dy,
    clamp_paddle(Y0, Y),
    State = State0.put(p1_y, Y).

move_right_paddle(State0, State) :-
    paddle_h(PH),
    ball_d(BD),
    Target is State0.ball_y + BD / 2 - PH / 2,
    Diff is Target - State0.p2_y,
    ai_speed(V),
    Step is V * State0.dt,
    (   abs(Diff) =< Step -> Y0 is State0.p2_y + Diff
    ;   Diff < 0 -> Y0 is State0.p2_y - Step
    ;   Y0 is State0.p2_y + Step
    ),
    clamp_paddle(Y0, Y),
    State = State0.put(p2_y, Y).

clamp_paddle(Y0, Y) :-
    win_h(H), paddle_h(PH),
    MaxY is H - PH,
    (   Y0 < 0.0 -> Y = 0.0
    ;   Y0 > MaxY -> Y = MaxY
    ;   Y = Y0
    ).

move_ball(State0, State) :-
    Dt = State0.dt,
    X is State0.ball_x + State0.ball_dx * Dt,
    Y0 is State0.ball_y + State0.ball_dy * Dt,
    win_w(W), win_h(H),
    ball_d(BD), paddle_w(PW), paddle_h(PH),
    paddle_margin(M),
    % Vertical wall bounce (top / bottom).
    (   Y0 < 0.0
    ->  Y1 = 0.0, DY is abs(State0.ball_dy)
    ;   Y0 + BD > H
    ->  Y1 is H - BD, DY is -abs(State0.ball_dy)
    ;   Y1 = Y0, DY = State0.ball_dy
    ),
    LeftX = M,
    RightX is W - M - PW,
    (   % Left paddle collision.
        State0.ball_dx < 0.0,
        X < LeftX + PW,
        X + BD > LeftX,
        Y1 + BD > State0.p1_y,
        Y1 < State0.p1_y + PH
    ->  bounce_velocity(State0.ball_speed, Y1, State0.p1_y, 1.0,
                        NewSpeed, NDX, NDY),
        NX is LeftX + PW,
        State = State0.put([ball_x=NX, ball_y=Y1,
                            ball_dx=NDX, ball_dy=NDY, ball_speed=NewSpeed])
    ;   % Right paddle collision.
        State0.ball_dx > 0.0,
        X + BD > RightX,
        X < RightX + PW,
        Y1 + BD > State0.p2_y,
        Y1 < State0.p2_y + PH
    ->  bounce_velocity(State0.ball_speed, Y1, State0.p2_y, -1.0,
                        NewSpeed2, NDX2, NDY2),
        NX2 is RightX - BD,
        State = State0.put([ball_x=NX2, ball_y=Y1,
                            ball_dx=NDX2, ball_dy=NDY2, ball_speed=NewSpeed2])
    ;   % Scoring: ball exited past a paddle.
        X + BD < 0.0
    ->  S1 = State0.put(p2_score, State0.p2_score + 1),
        reset_ball(S1, -1.0, State)
    ;   X > W
    ->  S2 = State0.put(p1_score, State0.p1_score + 1),
        reset_ball(S2, 1.0, State)
    ;   State = State0.put([ball_x=X, ball_y=Y1, ball_dy=DY])
    ).

bounce_velocity(Speed0, BallY, PaddleY, Dir, Speed, DX, DY) :-
    ball_d(BD), paddle_h(PH),
    ball_accel(Acc), ball_max_speed(Max),
    max_bounce_angle(MBA),
    Speed is min(Speed0 * Acc, Max),
    Center is BallY + BD / 2 - PaddleY - PH / 2,
    Half is PH / 2,
    (   Center < -Half -> Rel = -1.0
    ;   Center >  Half -> Rel = 1.0
    ;   Rel is Center / Half
    ),
    Angle is Rel * MBA,
    DX is Speed * cos(Angle) * Dir,
    DY is Speed * sin(Angle).

reset_ball(State0, Dir, State) :-
    win_w(W), win_h(H), ball_d(BD),
    ball_base_speed(Speed),
    CX is W / 2 - BD / 2,
    CY is H / 2 - BD / 2,
    State = State0.put([ball_x=CX, ball_y=CY,
                        ball_dx=Speed * Dir, ball_dy=0.0, ball_speed=Speed,
                        ball_phase=0.0]).

% --- geometry (Prolog-side tessellation) -------------------------------------
%
% Each shape produces 6 vertices (2 triangles).  Coordinates are converted
% from screen pixels to normalized device space in the [-1, 1] range, with Y
% flipped so that screen-down maps to NDC-down.  The flat list interleaves
% pos(2), uv(2), color(4), shape(1) = 9 floats per vertex.

build_vertices(State, Verts) :-
    win_w(W),
    paddle_w(PW), paddle_h(PH), paddle_margin(M),
    ball_d(BD),
    LeftX = M,
    RightX is W - M - PW,
    rect_vertices(LeftX, State.p1_y, PW, PH,
                  0.85, 0.85, 0.95, 1.0, 0.0, V1),
    rect_vertices(RightX, State.p2_y, PW, PH,
                  0.85, 0.85, 0.95, 1.0, 0.0, V2),
    ball_phase(State, Phase),
    ball_speed_norm(State, SpeedN),
    ball_vertices(State.ball_x, State.ball_y, BD,
                  0.30, 0.85, 1.0, SpeedN, Phase, V3),
    append([V1, V2, V3], Verts).

rect_vertices(Rx, Ry, Rw, Rh, R, G, B, A, Shape, Verts) :-
    win_w(W), win_h(H),
    X0 is (Rx / W) * 2.0 - 1.0,
    X1 is ((Rx + Rw) / W) * 2.0 - 1.0,
    Y0 is 1.0 - (Ry / H) * 2.0,
    Y1 is 1.0 - ((Ry + Rh) / H) * 2.0,
    Verts = [
        X0, Y0, 0.0, 0.0, R, G, B, A, Shape,
        X1, Y0, 0.0, 0.0, R, G, B, A, Shape,
        X1, Y1, 0.0, 0.0, R, G, B, A, Shape,
        X0, Y0, 0.0, 0.0, R, G, B, A, Shape,
        X1, Y1, 0.0, 0.0, R, G, B, A, Shape,
        X0, Y1, 0.0, 0.0, R, G, B, A, Shape
    ].

% Accumulated [0,1) pulse phase, advanced by advance_phase/2 each step.
ball_phase(State, Phase) :-
    Phase is State.ball_phase.

% Normalized ball speed in [0,1]: 0 at base speed, 1 at max speed.
ball_speed_norm(State, SpeedN) :-
    ball_base_speed(Base), ball_max_speed(Max),
    Raw is (State.ball_speed - Base) / (Max - Base),
    (   Raw < 0.0 -> SpeedN = 0.0
    ;   Raw > 1.0 -> SpeedN = 1.0
    ;   SpeedN = Raw
    ).

ball_vertices(Bx, By, D, R, G, B, A, Phase, Verts) :-
    win_w(W), win_h(H),
    ball_r(Radius),
    ball_pad(Pad),
    Px0 is Bx - Pad,
    Px1 is Bx + D + Pad,
    Py0 is By - Pad,
    Py1 is By + D + Pad,
    X0 is (Px0 / W) * 2.0 - 1.0,
    X1 is (Px1 / W) * 2.0 - 1.0,
    Y0 is 1.0 - (Py0 / H) * 2.0,
    Y1 is 1.0 - (Py1 / H) * 2.0,
    U0 is -(Pad / Radius) - 1.0,
    U1 is  (Pad / Radius) + 1.0,
    Shape is 1.0 + Phase,
    Verts = [
        X0, Y0, U0, U0, R, G, B, A, Shape,
        X1, Y0, U1, U0, R, G, B, A, Shape,
        X1, Y1, U1, U1, R, G, B, A, Shape,
        X0, Y0, U0, U0, R, G, B, A, Shape,
        X1, Y1, U1, U1, R, G, B, A, Shape,
        X0, Y1, U0, U1, R, G, B, A, Shape
    ].

% --- frame rendering --------------------------------------------------------

render_frame(Device, Window, Pipeline, VertexBuffer, TransferBuffer,
             State0, State) :-
    step(State0, State1),
    build_vertices(State1, Verts),    length(Verts, FloatCount),
    floats_per_vertex(FPV),
    NumVerts is FloatCount // FPV,
    ByteSize is FloatCount * 4,
    sdl_acquiregpucommandbuffer(CmdBuf, Device),
    % Upload the freshly tessellated geometry to the vertex buffer.
    sdl_mapgputransferbuffer(Ptr, TransferBuffer, false),
    ptr_store_float32s(Ptr, 0, Verts),
    sdl_unmapgputransferbuffer(TransferBuffer),
    sdl_begingpucopypass(CopyPass, CmdBuf),
    Source = transfer_buffer_location(TransferBuffer, 0),
    Dest = buffer_region(VertexBuffer, 0, ByteSize),
    sdl_uploadtogpubuffer(CopyPass, Source, Dest, false),
    sdl_endgpucopypass(CopyPass),
    % Acquire the swapchain target and draw.
    (   sdl_waitandacquiregpuswapchaintexture(CmdBuf, Window, Texture, _, _),
        Texture \== null
    ->  make_color_target([texture(Texture), load_op(clear), store_op(store)], CT),
        sdl_begingpurenderpass(RenderPass, CmdBuf, [CT], null),
        sdl_bindgpugraphicspipeline(RenderPass, Pipeline),
        sdl_bindgpuvertexbuffers(RenderPass, 0, [buffer_binding(VertexBuffer, 0)]),
        sdl_drawgpuprimitives(RenderPass, NumVerts, 1, 0, 0),
        sdl_endgpurenderpass(RenderPass)
    ;   true
    ),
    sdl_submitgpucommandbuffer(CmdBuf),
    count_fps(State1, State).

count_fps(State0, State) :-
    get_time(Now),
    Count0 is State0.fps_count + 1,
    Elapsed is Now - State0.fps_t,
    (   Elapsed >= 1.0
    ->  FPS is Count0 / Elapsed,
        format("FPS: ~2f~n", [FPS]),
        State = State0.put([fps_count=0, fps_t=Now])
    ;   State = State0.put(fps_count, Count0)
    ).
