:- use_module(library(sdl)).

:- dynamic sample_image/1.
:- prolog_load_context(directory, Dir),
   directory_file_path(Dir, '../examples/DSC03094.JPG', Rel),
   absolute_file_name(Rel, Abs),
   atom_string(Abs, Str),
   assertz(sample_image(Str)).

:- begin_tests(sdl).

test(init, [forall(sdl_init_flag(Flag, _))]) :-
   sdl_init([Flag]),
   sdl_quit.

pos(1).
pos(centered).
pos(undefined).

test(createwindow_pos, [
      setup(sdl_init([everything])), cleanup(sdl_quit),
      forall((pos(X), pos(Y)))]) :-
   setup_call_cleanup(
      sdl_createwindow(Handle, "Title", X, Y, 400, 600, []),
      true,
      sdl_destroywindow(Handle)).

test(createwindow_flag, [
      setup(sdl_init([everything])), cleanup(sdl_quit),
      forall((sdl_window_flag(Flag, _), dif(Flag, metal)))]) :-
   setup_call_cleanup(
      sdl_createwindow(Handle, "Title", 0, 0, 400, 600, [Flag]),
      true,
      sdl_destroywindow(Handle)).

test(createrenderer, [
      setup((sdl_init([everything]),
             sdl_createwindow(Window, "", 0, 0, 400, 600, [opengl]))),
      cleanup((sdl_destroywindow(Window), sdl_quit))]) :-
   setup_call_cleanup(
      sdl_createrenderer(Renderer, Window, -1, [accelerated]),
      true,
      sdl_destroyrenderer(Renderer)).

test(imginit, [forall(img_init_flag(Flag, _))]) :-
   setup_call_cleanup(img_init(_, [Flag]), true, img_quit).

test(imgload, [setup(img_init(_, [jpg])), cleanup(img_quit)]) :-
   sample_image(Img),
   setup_call_cleanup(
      img_load(Surface, Img),
      true,
      sdl_freesurface(Surface)).

test(createtexturefromsurface, [
   setup((
      sdl_init([everything]),
      img_init(_, [jpg]),
      sdl_createwindow(Window, "", 0, 0, 400, 600, [opengl]),
      sdl_createrenderer(Renderer, Window, -1, [accelerated]),
      sample_image(Img),
      img_load(Surface, Img))),
   cleanup((
      sdl_freesurface(Surface),
      sdl_destroyrenderer(Renderer),
      sdl_destroywindow(Window),
      img_quit,
      sdl_quit))]) :-
   setup_call_cleanup(
      sdl_createtexturefromsurface(Texture, Renderer, Surface),
      true,
      sdl_destroytexture(Texture)).

test(renderclearcopypresent, [
   forall((
      member(Srrect, [rect(0, 0, 1000, 1000), null]),
      member(Dstrect, [rect(0, 0, 200, 300), null]))),
   setup((
      sdl_init([everything]),
      img_init(_, [jpg]),
      sdl_createwindow(Window, "", 0, 0, 400, 600, [opengl]),
      sdl_createrenderer(Renderer, Window, -1, [accelerated]),
      sample_image(Img),
      img_load(Surface, Img),
      sdl_createtexturefromsurface(Texture, Renderer, Surface))),
   cleanup((
      sdl_destroytexture(Texture),
      sdl_freesurface(Surface),
      sdl_destroyrenderer(Renderer),
      sdl_destroywindow(Window),
      img_quit,
      sdl_quit))]) :-
   sdl_renderclear(Renderer),
   sdl_rendercopy(Renderer, Texture, Srrect, Dstrect),
   sdl_renderpresent(Renderer).

test(pollevent, [setup(sdl_init([events])), cleanup(sdl_quit), fail]) :-
   sdl_pollevent(_).

test(setrenderdrawcolor, [
   setup((
      sdl_init([everything]),
      sdl_createwindow(Window, "", 0, 0, 400, 600, [opengl]),
      sdl_createrenderer(Renderer, Window, -1, [accelerated]))),
   cleanup((
      sdl_destroyrenderer(Renderer),
      sdl_destroywindow(Window),
      sdl_quit))]) :-
   sdl_setrenderdrawcolor(Renderer, 255, 0, 0, 255).

test(renderdrawrect, [
   setup((
      sdl_init([everything]),
      sdl_createwindow(Window, "", 0, 0, 400, 600, [opengl]),
      sdl_createrenderer(Renderer, Window, -1, [accelerated]))),
   cleanup((
      sdl_destroyrenderer(Renderer),
      sdl_destroywindow(Window),
      sdl_quit))]) :-
   sdl_renderdrawrect(Renderer, rect(0, 0, 100, 100)).

test(renderfillrect, [
   setup((
      sdl_init([everything]),
      sdl_createwindow(Window, "", 0, 0, 400, 600, [opengl]),
      sdl_createrenderer(Renderer, Window, -1, [accelerated]))),
   cleanup((
      sdl_destroyrenderer(Renderer),
      sdl_destroywindow(Window),
      sdl_quit))]) :-
   sdl_renderfillrect(Renderer, rect(0, 0, 100, 100)).

:- end_tests(sdl).

test_sdl :-
   run_tests.
