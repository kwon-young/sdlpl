:- use_module(library(clpBNR)).

point(point{x: _X, y: _Y}).
speed(speed{dx: _, dy: _}).

trajectory(P0, Speed, T, P1) :-
   point(P0),
   speed(Speed),
   point(P1),
   { P1.x == P0.x + T * Speed.dx },
   { P1.y == P0.y + T * Speed.dy }.

box(B1, B2) :-
   box(B2),
   B1 :< B2.
box(Box) :-
   Box = box{x: X, y: Y, w: W, h: H, left: X, top: Y, right: Right, bottom: Bottom},
   { Right == X + W },
   { Bottom == Y + H }.

contour(Box, Point) :-
   box(Box),
   point(Point),
   {  Box.left =< Point.x, Point.x =< Box.right,
      Box.top =< Point.y, Point.y =< Box.bottom
   }.

contour(Box1, Box2, P) :-
   contour(Box1, P),
   contour(Box2, P).

% autour(Box, Point) :-
%    box(Box),
%    point(Point),
%    {  Point.x =< Box.left
%       or Box.right =< Point.x
%       or Point.y =< Box.top
%       or Box.bottom =< Point.y
%    }.

inside(Box1, Box2) :-
   box(Box2),
   contour(Box1, point{x: Box2.left, y: Box2.top}),
   contour(Box1, point{x: Box2.right, y: Box2.top}),
   contour(Box1, point{x: Box2.right, y: Box2.bottom}),
   contour(Box1, point{x: Box2.left, y: Box2.bottom}).

% outside(Box1, Box2) :-
%    box(Box2),
%    autour(Box1, point{x: Box2.left, y: Box2.top}),
%    autour(Box1, point{x: Box2.right, y: Box2.top}),
%    autour(Box1, point{x: Box2.right, y: Box2.bottom}),
%    autour(Box1, point{x: Box2.left, y: Box2.bottom}).

window(Window) :-
   box(box{x: 0, y: 0, w: 600, h: 400}, Window).

ball(Ball) :-
   box(box{w: 10, h: 10}, Box),
   speed(Speed),
   Ball = ball{box: Box, speed: Speed}.

paddle(Window, X, Paddle) :-
   box(box{x: X, w: 10, h: 50}, Paddle),
   inside(Window, Paddle).

state(State) :-
   window(Window),
   ball(Ball),
   paddle(Window, 0, Paddle),
   State = state{
      window: Window,
      ball: Ball,
      paddle: Paddle
   }.

initial_state(State, State0) :-
   copy_term(State, State0),
   box{x: 50, y: 20} :< State0.ball.box,
   speed{dx: -1, dy: 0} :< State0.ball.speed,
   box{y: 0} :< State0.paddle.

main(State0, State1) :-
   state(State),
   initial_state(State, State0),
   trajectories(State, State0, 0, 100, State1).

collide(State, State0, Min, Max, Goal, T-State1) :-
   call(Goal, State, State0, Min, Max, T, State1).

trajectories(State, State0, Min, Max, StateEnd) :-
   convlist(collide(State, State0, Min, Max),
            [ball_paddle, ball_window_left],
            Collisions),
   keysort(Collisions, [T-State1 | _]),
   !,
   trajectories(State, State1, T, Max, StateEnd).
trajectories(State, State0, _Min, Max, State1) :-
   new_state(State, State0, Max, State1).

collision(B1, S1, B2, Min, Max, T) :-
   T::real(Min, Max),
   contour(B1, P0),
   trajectory(P0, S1, T, P1),
   contour(B2, P1),
   range(T, [T, _]).

new_state(State, State0, T, State1) :-
   new_state(State, State0, T, State0.ball.speed, State1).
new_state(State, State0, T, NewSpeed, State1) :-
   P0 = point{x: State0.ball.box.x, y: State0.ball.box.y},
   trajectory(P0, State0.ball.speed, T, P1),
   copy_term(State, State1),
   box{x: P1.x, y: P1.y} :< State1.ball.box,
   NewSpeed :< State1.ball.speed,
   State0.paddle :< State1.paddle.

ball_paddle(State, State0, Min, Max, T, State1) :-
   collision(State0.ball.box, State0.ball.speed, State0.paddle, Min, Max, T),
   debug(collision, "collision with paddle", []),
   DX is -State0.ball.speed.dx,
   new_state(State, State0, T, speed{dx: DX, dy: State0.ball.speed.dy}, State1).

ball_window_left(State, State0, Min, Max, T, State1) :-
   box(box{x: State.window.x, y: State.window.y, w: 0, h: State.window.h}, Window), 
   collision(State0.ball.box, State0.ball.speed, Window, Min, Max, T),
   debug(collision, "collision with window left", []),
   DX is -State0.ball.speed.dx,
   new_state(State, State0, T, speed{dx: DX, dy: State0.ball.speed.dy}, State1).
