:- use_module(library(sdl)).
:- use_module(library(macros)).

#define(window_w, 600).
#define(window_h, 400).
#define(ball_w, 10.0).
#define(ball_h, 10.0).
#define(ball_acc, 1.05).
#define(ball_base_speed, 250.0).
#define(ball_max_speed, 500.0).
#define(paddle_w, 10.0).
#define(paddle_h, 50.0).
#define(paddle_v, 350).
#define(center_w, 4.0).
#define(center_gap, 16.0).
#define(score_bar_h, 8.0).
#define(score_bar_y, 12.0).
#define(score_bar_max, 250.0).
#define(score_bar_scale, 30.0).
#define(max_bounce_angle, 0.7853981633974483).  %% pi/4
#define(max_dt, 0.05).

main :-
   setup_call_cleanup(
      sdl_init([everything]),
      setup_call_cleanup(
         sdl_createwindow(Window, "pong", #window_w, #window_h, [vulkan]),
         setup_call_cleanup(
             (  catch(sdl_setwindowposition(Window, centered, centered),
                     error(_, _), true),
               sdl_createrenderer(Renderer, Window, null)
            ),
            (
               X is #window_w / 2 - #ball_w / 2,
               Y is #window_h / 2 - #ball_h / 2,
               PY is #window_h / 2 - #paddle_h / 2,
               get_time(Start),
               main_loop(state{renderer: Renderer,
                               ball_x: X,
                               ball_y: Y,
                               ball_dx: #ball_base_speed,
                               ball_dy: 0.0,
                               ball_speed: #ball_base_speed,
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
   draw_center_line(Renderer),
   draw_score_bar(Renderer, State),
   ball_color(State, R, G, B),
   sdl_setrenderdrawcolor(Renderer, R, G, B, 255),
   sdl_renderfillrect(Renderer, rect(State.ball_x, State.ball_y, #ball_w, #ball_h)),
   sdl_setrenderdrawcolor(Renderer, 255, 255, 255, 255),
   sdl_renderfillrect(Renderer, rect(0.0, State.p1_y, #paddle_w, #paddle_h)),
   Paddle_X is #window_w - #paddle_w,
   sdl_renderfillrect(Renderer, rect(Paddle_X, State.p2_y, #paddle_w, #paddle_h)),
   sdl_renderpresent(Renderer),
   main_loop(State).

draw_center_line(Renderer) :-
   CX is #window_w / 2 - #center_w / 2,
   draw_center_line(Renderer, CX, 0.0).

draw_center_line(Renderer, CX, Y) :-
   (  Y >= #window_h
   -> true
   ;  sdl_renderfillrect(Renderer, rect(CX, Y, #center_w, #center_w)),
      NextY is Y + #center_w + #center_gap,
      draw_center_line(Renderer, CX, NextY)
   ).

draw_score_bar(Renderer, State) :-
   Diff is State.p1_score - State.p2_score,
   (  Diff =:= 0
   -> true
   ;  Len0 is abs(Diff) * #score_bar_scale,
      (  Len0 > #score_bar_max
      -> Len = #score_bar_max
      ;  Len = Len0
      ),
      CX is #window_w / 2,
      (  Diff > 0
      -> X is CX - Len,
         sdl_setrenderdrawcolor(Renderer, 50, 150, 255, 255)
      ;  X = CX,
         sdl_setrenderdrawcolor(Renderer, 255, 150, 50, 255)
      ),
      sdl_renderfillrect(Renderer, rect(X, #score_bar_y, Len, #score_bar_h))
   ).

ball_color(State, R, G, B) :-
   Speed = State.ball_speed,
   (  Speed =< #ball_base_speed
   -> Ratio = 0.0
   ;  Speed >= #ball_max_speed
   -> Ratio = 1.0
   ;  Ratio is (Speed - #ball_base_speed) / (#ball_max_speed - #ball_base_speed)
   ),
   R is round(80  + Ratio * (255 - 80)),
   G is round(200 + Ratio * (80 - 200)),
   B is round(255 + Ratio * (50 - 255)).

move_p1(StateIn, State) :-
   BallCenter is StateIn.ball_y + #ball_h / 2,
   PaddleCenter is StateIn.p1_y + #paddle_h / 2,
   (  BallCenter < PaddleCenter
   -> Y is StateIn.p1_y - #paddle_v * StateIn.dt
   ;  BallCenter > PaddleCenter
   -> Y is StateIn.p1_y + #paddle_v * StateIn.dt
   ;  Y = StateIn.p1_y
   ),
   State = StateIn.put([p1_y=Y]).

bounce_velocity(Speed, BallY, PaddleY, Dir, DX, DY) :-
   RelY is (BallY + #ball_h / 2 - PaddleY - #paddle_h / 2) / (#paddle_h / 2),
   (  RelY < -1.0 -> RelY1 = -1.0
   ;  RelY > 1.0  -> RelY1 = 1.0
   ;  RelY1 = RelY
   ),
   Angle is RelY1 * #max_bounce_angle,
   DX is Speed * cos(Angle) * Dir,
   DY is Speed * sin(Angle).

reset_ball(StateIn, Direction, State) :-
   X is #window_w / 2 - #ball_w / 2,
   Y is #window_h / 2 - #ball_h / 2,
   DX is #ball_base_speed * Direction,
   State = StateIn.put([
      ball_x: X,
      ball_y: Y,
      ball_dx: DX,
      ball_dy: 0.0,
      ball_speed: #ball_base_speed
   ]).

move_ball(StateIn, State) :-
   Dt is min(StateIn.dt, #max_dt),
   X is StateIn.ball_x + StateIn.ball_dx * Dt,
   Y is StateIn.ball_y + StateIn.ball_dy * Dt,
   (  X < 0
   -> P1Score is StateIn.p1_score,
      P2Score is StateIn.p2_score + 1,
      reset_ball(StateIn.put([p1_score: P1Score, p2_score: P2Score]), 1.0, State)
   ;  X + #ball_w > #window_w
   -> P1Score is StateIn.p1_score + 1,
      P2Score is StateIn.p2_score,
      reset_ball(StateIn.put([p1_score: P1Score, p2_score: P2Score]), -1.0, State)
   ;  Y + #ball_h > StateIn.p1_y,
      Y < StateIn.p1_y + #paddle_h,
      X < #paddle_w,
      StateIn.ball_dx < 0
   -> NewSpeed is min(StateIn.ball_speed * #ball_acc, #ball_max_speed),
      bounce_velocity(NewSpeed, Y, StateIn.p1_y, 1.0, DX, DY),
      clamp_y(Y, Y1, DY, FinalDY),
      State = StateIn.put([
         ball_x: X,
         ball_y: Y1,
         ball_dx: DX,
         ball_dy: FinalDY,
         ball_speed: NewSpeed
      ])
   ;  Y + #ball_h > StateIn.p2_y,
      Y < StateIn.p2_y + #paddle_h,
      X + #ball_w > #window_w - #paddle_w,
      StateIn.ball_dx > 0
   -> NewSpeed is min(StateIn.ball_speed * #ball_acc, #ball_max_speed),
      bounce_velocity(NewSpeed, Y, StateIn.p2_y, -1.0, DX, DY),
      clamp_y(Y, Y1, DY, FinalDY),
      State = StateIn.put([
         ball_x: X,
         ball_y: Y1,
         ball_dx: DX,
         ball_dy: FinalDY,
         ball_speed: NewSpeed
      ])
   ;  clamp_y(Y, Y1, StateIn.ball_dy, FinalDY),
      State = StateIn.put([
         ball_x: X,
         ball_y: Y1,
         ball_dx: StateIn.ball_dx,
         ball_dy: FinalDY
      ])
   ).

clamp_y(Y, Y1, DY, FinalDY) :-
   (  Y < 0
   -> Y1 = 0.0,
      FinalDY is abs(DY)
   ;  Y + #ball_h > #window_h
   -> Y1 is #window_h - #ball_h,
      FinalDY is -abs(DY)
   ;  Y1 = Y,
      FinalDY = DY
   ).
