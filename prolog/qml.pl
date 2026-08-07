:- module(qml,
          [ qml_run/1,            % qml_run(+Ui)
            qml_run/2,            % qml_run(+Ui, :OnFrame)
            qml_run/4,            % qml_run(+Ui, :OnFrame, +State0, +Save0)
            qml_get/4,           % qml_get(+Key, -Value) //
            qml_get/5,           % qml_get(+Key, -Value, +Default) //
            qml_get_save/4,      % qml_get_save(+Key, -Value) //
            qml_event/5,         % qml_event(+Tag, +Type, -Event) //
            qml_button/3,        % qml_button(?Button) //
            qml_contour/2        % qml_contour(+Box, +Point)
            ]).

:- use_module(library(sdl)).
:- use_module(library(clpBNR)).

:- meta_predicate qml_run(+, 0).
:- meta_predicate qml_run(+, 0, +, +).

%%! \section{Entry points}
%%
%% A UI is a dict tree whose tags name element types (window, column,
%% rectangle, image, button, ...). Each frame:
%%
%%   1. events are polled into the current state,
%%   2. the user-supplied `OnFrame` phrase runs (it may read the previous
%%      frame's saved values via qml_get_save/2 and the current events via
%%      qml_event/3, binding the reactive variables shared with the UI),
%%   3. the render command list is replayed unless it is unchanged.
%
% qml_run(+Ui) runs a static UI (no per-frame logic).
qml_run(Ui) :-
   qml_run(Ui, qml_noop, state{}, state{render: []-[]}).

% qml_run(+Ui, :OnFrame) runs a UI with per-frame logic but no persistent
% state beyond what OnFrame threads itself.
qml_run(Ui, OnFrame) :-
   qml_run(Ui, OnFrame, state{}, state{render: []-[]}).

% qml_run(+Ui, :OnFrame, +State0, +Save0) is the full entry point.
%
% State0 holds the reactive variables (shared with Ui and OnFrame); it is
% the "current frame" container. Save0 holds their concrete initial values
% (plus render: []-[]); it is the "previous frame" container that OnFrame
% reads through qml_get_save/2. The framework injects onFrame, render,
% events and next keys into State0 before running.
qml_run(Ui, OnFrame, State0, Save0) :-
   put_dict([onFrame: OnFrame, render: R-R, events: [], next: []], State0, State),
   put_dict([render: []-[]], Save0, Save),
   phrase(setup(Ui), [State, Save], _).

%%! \section{State access for OnFrame handlers}
%%
%% These let an OnFrame phrase read the previous frame's saved values and
%% the current frame's events / state without depending on framework
%% internals.

qml_get(Key, Value) -->
   get(Key, Value).
qml_get(Key, Value, Default) -->
   get(Key, Value, Default).
qml_get_save(Key, Value) -->
   get_save(Key, Value).
qml_event(Tag, Type, Event) -->
   get_event(Tag, Type, Event).

%%! \section{Built-in button behavior}
%%
%% qml_button(?Button) is an OnFrame phrase that maintains the `pressed`
%% property of a button dict: a left-click inside the button's rectangle
%% sets pressed = true, a left-button release sets it back to false.

qml_button(Button) -->
   get_save(pressed, SavePressed),
   qml_button_(SavePressed, Button).
qml_button_(true, Button) -->
   (  get_event(mousebutton, mousebuttonup, Event),
      { Event.button = left }
   -> { Button.pressed = false }
   ;  { Button.pressed = true }
   ).
qml_button_(false, Button) -->
   (  get_event(mousebutton, mousebuttondown, Event),
      { Event.button = left }
   -> {  when(
             (ground(Button.x),
              ground(Button.y),
              ground(Button.w),
              ground(Button.h)), (
             (  qml_contour(Button, Event)
             -> Button.pressed = true
             ;  Button.pressed = false
             )
          )) }
   ;  { Button.pressed = false }
   ).

% qml_contour(+Box, +Point) holds when Point lies inside Box (a dict with
% x, y, w, h) — the point-in-rectangle test used by qml_button/1.
qml_contour(Box, Point) :-
   {
      Box.x =< Point.x,
      Point.x =< Box.x + Box.w,
      Box.y =< Point.y,
      Point.y =< Box.y + Box.h
   }.

%%! \section{Framework internals}
%
% The predicates below implement the DCG state threading, the element
% dispatch, the render loop and the built-in elements. They are not part
% of the public API but are needed by qml_run/1,2,4.

qml_noop --> [].

% DCG state primitives. The threaded list is, during setup, a single
% state dict [State]; during render it expands to three positions
% [Copy, State, Save] (see copy_state//0 / save_state//0).

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

copy_state, [Copy, X] -->
   [X],
   { copy_term(X, Copy) }.
save_state, [X, Save] -->
   [Save, X, _].

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

% call_tag(+Method, +Dict) dispatches on the dict tag: a dict tagged
% `rectangle` is handled by rectangle(Method, Dict). This is the QML
% "element type resolves to its implementation" step.
call_tag(Method, Dict) -->
   { is_dict(Dict, Tag) },
   call(Tag, Method, Dict).

%%! \subsection{Setup traversal}

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

setup_next -->
   get(next, Nexts),
   setup_next(Nexts).

setup_next([]) -->
   render.
setup_next([Next | Nexts]) -->
   put(next, Nexts),
   call_tag(setup, Next).

%%! \subsection{Render command list and events}

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

%%! \subsection{Built-in elements}

% window(setup, _) creates the SDL window/renderer, stores the renderer
% in the state, then sets up its children.
window(setup, Ui) -->
   setup_call_cleanup(
      sdl_createwindow(Window, Ui.title, Ui.w, Ui.h, [vulkan, resizable]),
      setup_call_cleanup(
         sdl_createrenderer(Renderer, Window, null),
         (  put(renderer, Renderer),
            setup_childs(Ui.get(childs, []))
         ),
         sdl_destroyrenderer(Renderer)),
      sdl_destroywindow(Window)).

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

% column(setup, _) is the QML Column layout: children are stacked
% vertically, each child's y is reactively bound to the running height.
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

% button(setup, _) renders a button; it is filled when pressed.
button(setup, Button) -->
   get(renderer, Renderer),
   {
      RectC = rect(Button.x, Button.y, Button.w, Button.h),
      Color = Button.color,
      Fill = Button.pressed
   },
   add_render(rectangle(render, Color, RectC, Fill, Renderer)),
   setup_childs(Button.get(childs, [])).

%%! \subsection{Render loop}

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
