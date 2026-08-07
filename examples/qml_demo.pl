:- use_module(library(qml)).
:- use_module(library(clpBNR)).

%% A declarative, QML-like UI built on top of the qml module.
%%
%%   - main/0  : a column with two images, a rectangle and a button whose
%%               `pressed` state is maintained reactively by qml_button/1.
%%   - pong/0  : a playable Pong whose per-frame logic is the pong/6
%%               OnFrame phrase.

main :-
   Ui = window{
      title: "Helene",
      w: 400,
      h: 600,
      childs: column{
         x: 0,
         y: 0,
         childs: [
            image{
               source: "DSC03094.JPG",
               x: 0,
               y: Img1Y,
               w: 100,
               h: 100
            },
            image{
               source: "DSC03094.JPG",
               x: 0,
               y: Img2Y,
               w: 100,
               h: 100
            },
            rectangle{
               color: rgba(200, 0, 0, 255),
               x: 0,
               y: RectY,
               fill: true,
               w: 100,
               h: 100
            },
            button{
               color: rgba(0, 200, 0, 255),
               x: 0,
               y: BY,
               w: 100,
               h: 50,
               pressed: Pressed
            }
         ]
      }
   },
   nth1(4, Ui.childs.childs, Button),
   State0 = state{
      x: 0,
      y: 0,
      img1y: Img1Y,
      img2y: Img2Y,
      recty: RectY,
      by: BY,
      pressed: Pressed
   },
   Save0 = state{pressed: false},
   qml_run(Ui, qml_button(Button), State0, Save0).

%%! \section{Pong}
%%
%% pong/6 is the OnFrame phrase: it reads the previous frame's paddle /
%% ball positions from the saved state and binds the new ones, reacting to
%% the mouse (left paddle) and the keyboard (right paddle).

pong(P1Y, P2Y, X, Y, DX, DY) -->
   p1(P1Y),
   p2(P2Y),
   ball(X, Y, DX, DY, P1Y, P2Y).

p1(P1Y) -->
   qml_get_save(p1y, P1Y0),
   qml_get_save(y, Y0),
   {
      (  { P1Y0 + 50 =< Y0 }
      -> { P1Y == P1Y0 + 10 }
      ;  { P1Y0 >= Y0 + 10 }
      -> { P1Y == P1Y0 - 10 }
      ;  P1Y = P1Y0
      )
   }.

p2(P2Y) -->
   qml_get_save(p2y, P2Y0),
   (  qml_event(keyboard, keydown, Event)
   -> {
         keysym(Scancode, _, _) = Event.keysym,
         (  Scancode = 82
         -> { P2Y1 == P2Y0 - 10 }
         ;  Scancode = 81
         -> { P2Y1 == P2Y0 + 10 }
         ;  P2Y1 = P2Y0
         )
      }
   ;  { P2Y1 = P2Y0 }
   ),
   {
      (  { P2Y1 =< 0 }
      -> P2Y = 0
      ;  { P2Y1 + 50 >= 400 }
      -> { P2Y == 350 }
      ;  P2Y = P2Y1
      )
   }.

ball(X, Y, DX, DY, P1Y, P2Y) -->
   qml_get_save(x, X0),
   qml_get_save(y, Y0),
   qml_get_save(dx, DX0),
   qml_get_save(dy, DY0),
   {
      {
         X1 == X0 + DX0,
         Y1 == Y0 + DY0
      },
      (  { P1Y =< Y1 + 10, Y1 =< P1Y + 50, X1 =< 10 }
      -> { X2 == 10 + (10 - X1), DX1 == -DX0 * 1.1,
           Offset == ((Y1 + 5) - (P1Y + 25) / 25), DY1 == DY0 * 1.1 }
      ;  { P2Y =< Y1 + 10, Y1 =< P2Y + 50, X1 + 10 >= 590 }
      -> { X2 == 580 - (X1 + 10 - 590), DX1 == -DX0 * 1.1,
           Offset == ((Y1 + 5) - (P2Y + 25) / 25), DY1 == DY0 * 1.1 }
      ;  X2 = X1, DX1 = DX0, DY1 = DY0
      ),
      (  { X2 =< 0 }
      -> { X3 == -X2, DX2 == -DX1 }
      ;  { X2 + 10 >= 600 }
      -> { X3 == 600 - (X2 + 10 - 600), DX2 == -DX1 }
      ;  { X3 == X2 }, DX2 = DX1
      ),
      (  { Y1 =< 0 }
      -> { Y2 == -Y1, DY2 == -DY1 }
      ;  { Y1 + 10 >= 400 }
      -> { Y2 == 390 - (Y1 + 10 - 400), DY2 == -DY1 }
      ;  { Y2 == Y1 }, DY2 = DY1
      ),
      midpoint(X3, X4),
      midpoint(Y2, Y3),
      midpoint(DX2, DX),
      midpoint(DY2, DY),
      X is round(X4),
      Y is round(Y3)
   }.

pong :-
   Ui = window{
      title: "Pong",
      w: 600,
      h: 400,
      childs: [
         rectangle{
            id: p1,
            color: rgba(255, 255, 255, 255),
            fill: true,
            x: 0,
            y: P1Y,
            w: 10,
            h: 50
         },
         rectangle{
            id: p2,
            color: rgba(255, 255, 255, 255),
            fill: true,
            x: 590,
            y: P2Y,
            w: 10,
            h: 50
         },
         rectangle{
            id: ball,
            color: rgba(255, 255, 255, 255),
            fill: true,
            x: X,
            y: Y,
            w: 10,
            h: 10
         }
      ]
   },
   State0 = state{
      p1y: P1Y,
      p2y: P2Y,
      x: X,
      y: Y,
      dx: DX,
      dy: DY
   },
   DX0 is (random_float * 2 - 1) * 1,
   DY0 is (random_float * 2 - 1) * 1,
   Save0 = state{
      p1y: 150,
      p2y: 150,
      x: 295,
      y: 195,
      dx: DX0,
      dy: DY0
   },
   qml_run(Ui, pong(P1Y, P2Y, X, Y, DX, DY), State0, Save0).
