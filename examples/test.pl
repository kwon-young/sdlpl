:- use_module(sdl).
:- use_module(library(clpBNR)).

onFrame(X, Y) -->
   (  get_event(mousemotion, mousemotion, Event)
   -> {_{x: X, y: Y} :< Event }
   ;  get_save(x, X),
      get_save(y, Y)
   ).

contour(Box, Point) :-
   {
      Box.x =< Point.x,
      Point.x =< Box.x + Box.w,
      Box.y =< Point.y,
      Point.y =< Box.y + Box.h
   }.

button(Button) -->
   get_save(pressed, SavePressed),
   button_(SavePressed, Button).
button_(true, Button) -->
   (  get_event(mousebutton, mousebuttonup, Event),
      { Event.button = left }
   -> { Button.pressed = false }
   ;  { Button.pressed = true }
   ).
button_(false, Button) -->
   (  get_event(mousebutton, mousebuttondown, Event),
      { Event.button = left }
   -> {  when(
            (ground(Button.x),
             ground(Button.y),
             ground(Button.w),
             ground(Button.h)), (
            (  contour(Button, Event)
            -> Button.pressed = true
            ;  Button.pressed = false
            )
         )) }
   ;  { Button.pressed = false }
   ).

pong(P1Y, P2Y, X, Y, DX, DY) -->
   p1(P1Y),
   p2(P2Y),
   ball(X, Y, DX, DY, P1Y, P2Y).

p1(P1Y) -->
   get_save(p1y, P1Y0),
   get_save(y, Y0),
   {
      (  { P1Y0 + 50 =< Y0 }
      -> { P1Y == P1Y0 + 10 }
      ;  { P1Y0 >= Y0 + 10 }
      -> { P1Y == P1Y0 - 10 }
      ;  P1Y = P1Y0
      )
   }.

p2(P2Y) -->
   get_save(p2y, P2Y0),
   (  get_event(keyboard, keydown, Event)
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
   get_save(x, X0),
   get_save(y, Y0),
   get_save(dx, DX0),
   get_save(dy, DY0),
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


main :-
   X = 0,
   Y = 0,
   Ui = window{
      title: "Helene",
      w: 400,
      h: 600,
      childs: column{
         x: X,
         y: Y,
         childs: [
            image{
               source: "DSC03094.JPG",
               x: X,
               y: Img1Y,
               w: 100,
               h: 100
            },
            image{
               source: "DSC03094.JPG",
               x: X,
               y: Img2Y,
               w: 100,
               h: 100
            },
            rectangle{
               color: rgba(200, 0, 0, 255),
               x: X,
               y: RectY,
               fill: true,
               w: 100,
               h: 100
            },
            button{
               color: rgba(0, 200, 0, 255),
               x: X,
               y: BY,
               w: 100,
               h: 50,
               pressed: Pressed
            }
         ]
      }
   },
   nth1(4, Ui.childs.childs, Button),
   State = state{
      x: X,
      y: Y,
      img1y: Img1Y,
      img2y: Img2Y,
      recty: RectY,
      by: BY,
      pressed: Pressed,
      onFrame: button(Button),
      render: R-R,
      events: []
   },
   Save =  state{pressed: false, render: []-[]},
   phrase(setup(Ui), [State, Save], _).

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
   State = state{
      p1y: P1Y,
      p2y: P2Y,
      x: X,
      y: Y,
      dx: DX,
      dy: DY,
      onFrame: pong(P1Y, P2Y, X, Y, DX, DY),
      render: R-R,
      events: []
   },
   DX0 is (random_float * 2 - 1) * 1,
   DY0 is (random_float * 2 - 1) * 1,
   Save = state{
      p1y: 150,
      p2y: 150,
      x: 295,
      y: 195,
      dx: DX0,
      dy: DY0,
      render: []-[]
   },
   phrase(setup(Ui), [State, Save], _).

setup_call_cleanup(Setup, Goal, Cleanup, In, Out) :-
   setup_call_cleanup(
      Setup,
      phrase(Goal, In, Out),
      Cleanup).

setup(Ui) -->
   setup_call_cleanup(
      sdl_init([everything]),
      call_tag(setup, Ui),
      sdl_quit).

put(Key, Value), [Out] -->
   [In],
   { put_dict(Key, In, Value, Out) }.
get(Key, Value), [In] -->
   [In],
   { get_dict(Key, In, Value) }.
get_save(Key, Value), [Copy, X, Save] -->
   [Copy, X, Save],
   { get_dict(Key, Save, Value) }.
get(Key, Value, Default), [In] -->
   [In],
   { Value = In.get(Key, Default) }.
update(Key, Value, NewValue), [Out] -->
   [In],
   { get_dict(Key, In, Value, Out, NewValue) }.

window(setup, Ui) -->
   setup_call_cleanup(
      sdl_createwindow(Window, Ui.title, Ui.w, Ui.h, [vulkan, resizable]),
      setup_call_cleanup(
         (  sdl_setwindowposition(Window, 0x2fff0000, 0x2fff0000),
            sdl_createrenderer(Renderer, Window, null)
         ),
         (  put(renderer, Renderer),
            setup_childs(Ui.get(childs, []))
         ),
         sdl_destroyrenderer(Renderer)),
      sdl_destroywindow(Window)).

setup_childs(Childs) -->
   get(next, Next, []),
   {
      (  is_dict(Childs)
      -> append([Childs], Next, ChildsNext)
      ;  append(Childs, Next, ChildsNext)
      )
   },
   put(next, ChildsNext),
   setup_next.

call_tag(Method, Dict) -->
   { is_dict(Dict, Tag) },
   call(Tag, Method, Dict).

setup_next -->
   get(next, Nexts),
   setup_next(Nexts).

setup_next([]) -->
   render.
setup_next([Next | Nexts]) -->
   put(next, Nexts),
   call_tag(setup, Next).

add_render(Goal) -->
   update(render, R-[Goal | Rs], R-Rs).
add_event(Event) -->
   update(events, In, [Event | In]).
get_event(Tag, Type, Event) -->
   get(events, Events),
   {  member(Event, Events),
      is_dict(Event, Tag),
      get_dict(type, Event, Type),
      !
   }.

image(setup, Image) -->
   get(renderer, Renderer),
   setup_call_cleanup(
      setup_call_cleanup(
         img_load(Surface, Image.source),
         sdl_createtexturefromsurface(Texture, Renderer, Surface),
         sdl_destroysurface(Surface)
      ),
      (  { Rect = rect(Image.x, Image.y, Image.w, Image.h) },
         add_render(sdl_rendertexture(Renderer, Texture, null, Rect)),
         setup_childs(Image.get(childs, []))
      ),
      sdl_destroytexture(Texture)
   ).

rectangle(render, rgba(R, G, B, A), Rect, Fill, Renderer) :-
   sdl_setrenderdrawcolor(Renderer, R, G, B, A),
   (  Fill
   -> sdl_renderfillrect(Renderer, Rect)
   ;  sdl_renderrect(Renderer, Rect)
   ).

rectangle(setup, Rect) -->
   get(renderer, Renderer),
   {
      RectC = rect(Rect.x, Rect.y, Rect.w, Rect.h),
      Color = Rect.color,
      Fill = Rect.get(fill, false)
   },
   add_render(rectangle(render, Color, RectC, Fill, Renderer)),
   setup_childs(Rect.get(childs, [])).

column(setup, Column) -->
   {
      Y = Column.y,
      Childs = Column.childs,
      foldl([Child, TopY, BottomY]>>(
         get_dict(y, Child, TopY),
         get_dict(h, Child, H),
         { BottomY == TopY + H }), Childs, Y, _)
   },
   setup_childs(Childs).
button(setup, Button) -->
   get(renderer, Renderer),
   {
      RectC = rect(Button.x, Button.y, Button.w, Button.h),
      Color = Button.color,
      Fill = Button.pressed
   },
   add_render(rectangle(render, Color, RectC, Fill, Renderer)),
   setup_childs(Button.get(childs, [])).

copy_state, [Copy, X] -->
   [X],
   { copy_term(X, Copy) }.
save_state, [X, Save] -->
   [Save, X, _].

render -->
   { get_time(Start) },
   copy_state,
   events,
   get(onFrame, MakeFrame),
   MakeFrame,
   get(renderer, Renderer),
   get(render, R-[]),
   get_save(render, RSave-[]),
   {
      (  R == RSave
      -> true
      ;  sdl_setrenderdrawcolor(Renderer, 0, 0, 0, 255),
         sdl_renderclear(Renderer),
         maplist(call, R),
         sdl_renderpresent(Renderer)
      )
   },
   (  get_event(quit, _, _)
   -> []
   ;  {  get_time(End),
         Sleep is 1/60 - (End - Start),
         sleep(Sleep)
      },
      save_state,
      render
   ).
events -->
   (  { sdl_pollevent(Event) }
   -> add_event(Event),
      events
   ;  []
   ).
