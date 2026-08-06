:- use_module(sdl).
:- use_module(library(macros)).

#define(window_w, 600).
#define(window_h, 400).
#define(ball_w, 10.0).
#define(ball_h, 10.0).
#define(ball_acc, 1.1).
#define(ball_v, 40).
#define(paddle_w, 10.0).
#define(paddle_h, 50.0).
#define(paddle_v, 40).

main :-
   setup_call_cleanup(
      sdl_init([everything]),
      setup_call_cleanup(
         sdl_createwindow(Window, "pong", centered, centered, #window_w, #window_h,
                          [vulkan]),
         setup_call_cleanup(
            sdl_createrenderer(Renderer, Window, -1, [accelerated]),
            (
               X is #window_w / 2 - #ball_w / 2,
               Y is #window_h / 2 - #ball_h / 2,
               PY is #window_h / 2 - #paddle_h / 2,
               get_time(Start),
               main_loop(state{renderer: Renderer,
                               ball_x: X,
                               ball_y: Y,
                               ball_dx: #ball_v,
                               ball_dy: #ball_v,
                               p1_y: PY,
                               p2_y: PY,
                               p1_score: 0,
                               p2_score: 0,
                               t: Start,
                               dt: 0
               })
            ),
            sdl_destroyrenderer(Renderer)),
         sdl_destroywindow(Window)),
      sdl_quit).

main_loop(State) :-
   events(State).

events(StateIn) :-
   (  sdl_pollevent(Event)
   -> (  Event.type == quit
      -> true
      ;  (  Event.type == mousemotion
         -> State = StateIn.put([p2_y=Event.y])
         ;  State = StateIn
         ),
         events(State)
      )
   ;  render(StateIn)
   ).

render(StateIn) :-
   get_time(End),
   Dt is End - StateIn.t,
   State1 = StateIn.put([t=End, dt=Dt]),
   move_p1(State1, State2),
   move_ball(State2, State),
   Renderer = State.renderer,
   sdl_setrenderdrawcolor(Renderer, 0, 0, 0, 255),
   sdl_renderclear(Renderer),
   sdl_setrenderdrawcolor(Renderer, 255, 255, 255, 255),
   sdl_renderfillrectf(Renderer, frect(State.ball_x, State.ball_y, #ball_w, #ball_h)),
   sdl_renderfillrectf(Renderer, frect(0.0, State.p1_y, #paddle_w, #paddle_h)),
   Paddle_X is #window_w - #paddle_w,
   sdl_renderfillrectf(Renderer, frect(Paddle_X, State.p2_y, #paddle_w, #paddle_h)),
   sdl_renderpresent(Renderer),
   main_loop(State).

move_p1(StateIn, State) :-
   (  StateIn.p1_y + #paddle_h / 2 < StateIn.ball_y + #ball_h/2
   -> Y is StateIn.p1_y + #paddle_v * StateIn.dt
   ;  StateIn.p1_y + #paddle_h / 2 > StateIn.ball_y + #ball_h/2
   -> Y is StateIn.p1_y - #paddle_v * StateIn.dt
   ;  Y = StateIn.p1_y
   ),
   State = StateIn.put([p1_y=Y]).

normalize_velocity(DX, DY, DX1, DY1) :-
   Norm is sqrt((DX*DX) + DY*DY),
   DX1 is #ball_v * DX / Norm,
   DY1 is #ball_v * DY / Norm.

move_ball(StateIn, State) :-
   X is StateIn.ball_x + StateIn.ball_dx * StateIn.dt,
   Y is StateIn.ball_y + StateIn.ball_dy * StateIn.dt,
   (  X < 0
   -> normalize_velocity(abs(StateIn.ball_dx), StateIn.ball_dy, DX, DY1),
      P1Score is StateIn.p1_score,
      P2Score is StateIn.p2_score + 1
   ;  X + #ball_w > #window_w
   -> normalize_velocity(-abs(StateIn.ball_dx), StateIn.ball_dy, DX, DY1),
      P1Score is StateIn.p1_score + 1,
      P2Score is StateIn.p2_score
   ;  Y + #ball_h > StateIn.p1_y,
      Y < StateIn.p1_y + #paddle_h,
      X < #paddle_w
   -> DX is abs(StateIn.ball_dx) * #ball_acc,
      V is (Y + #ball_h/2) - (StateIn.p1_y + #paddle_h/2),
      DY1 is StateIn.ball_dy * #ball_acc + V,
      P1Score is StateIn.p1_score,
      P2Score is StateIn.p2_score
   ;  Y + #ball_h > StateIn.p2_y,
      Y < StateIn.p2_y + #paddle_h,
      X + #ball_w > #window_w - #paddle_w
   -> DX is -abs(StateIn.ball_dx) * #ball_acc,
      V is (Y + #ball_h/2) - (StateIn.p1_y + #paddle_h/2),
      DY1 is StateIn.ball_dy * #ball_acc + V,
      P1Score is StateIn.p1_score,
      P2Score is StateIn.p2_score
   ;  DX = StateIn.ball_dx,
      DY1 = StateIn.ball_dy,
      P1Score is StateIn.p1_score,
      P2Score is StateIn.p2_score
   ),
   (  Y < 0
   -> DY is abs(DY1)
   ;  Y + #ball_h > #window_h
   -> DY is -abs(DY1)
   ;  DY = StateIn.ball_dy
   ),
   State = StateIn.put([
      ball_x=X,
      ball_y=Y,
      ball_dx=DX,
      ball_dy=DY,
      p1_score=P1Score,
      p2_score=P2Score
   ]).
