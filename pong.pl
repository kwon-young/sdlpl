:- use_module(sdl).
:- use_module(library(clpBNR)).

main :-
   Ui = window{
      title: "Pong",
      width: 600,
      height: 400,
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
   State = state{
      p1y: P1Y,
      p2y: P2Y,
      x: X,
      y: y,
      dx: DX,
      dy: DY
   },
   DX0 is random_float * 2 - 1,
   DY0 is random_float * 2 - 1,
   State = state{
      p1y: 175,
      p2y: 175,
      x: 295,
      y: 295,
      dx: DX0,
      dy: DY0
   },
