:- module(sdl, [sdl_init/1, sdl_quit/0,
                sdl_createwindow/7, sdl_destroywindow/1,
                sdl_createrenderer/4, sdl_destroyrenderer/1,
                sdl_renderclear/1, sdl_rendercopy/4, sdl_renderpresent/1,
                img_init/2, img_quit/0, img_load/2,
                sdl_freesurface/1,
                sdl_createtexturefromsurface/3, sdl_destroytexture/1,
                sdl_pollevent/1,
                sdl_setrenderdrawcolor/5, sdl_renderdrawrect/2, sdl_renderfillrect/2
                ]).
:- use_foreign_library(foreign('sdl.so')).

must_be_blob(Type, Term) :-
   (  blob(Term, Type)
   -> true
   ;  type_error(Type, Term)
   ).

user:portray(Window) :-
   blob(Window, sdl_window_blob), !,
   sdl_window_blob_portray(current_output, Window).
user:portray(Renderer) :-
   blob(Renderer, sdl_renderer_blob), !,
   sdl_renderer_blob_portray(current_output, Renderer).
user:portray(Surface) :-
   blob(Surface, sdl_surface_blob), !,
   sdl_surface_blob_portray(current_output, Surface).
user:portray(Texture) :-
   blob(Texture, sdl_texture_blob), !,
   sdl_texture_blob_portray(current_output, Texture).

sdl_init_flag(timer, 0x00000001).
sdl_init_flag(audio, 0x00000010).
sdl_init_flag(video, 0x00000020).
sdl_init_flag(joystick, 0x00000200).
sdl_init_flag(haptic, 0x00001000).
sdl_init_flag(gamecontroller, 0x00002000).
sdl_init_flag(events, 0x00004000).
sdl_init_flag(sensor, 0x00008000).
sdl_init_flag(everything, Flag) :-
   maplist(sdl_init_flag, [timer, audio, video, events, joystick, haptic,
                           gamecontroller, sensor], Flags),
   or_list(Flags, Flag).

or_list(List, Or) :-
   foldl([B, A, C]>>(C is A \/ B), List, 0, Or).

sdl_init(Flags) :-
   findall(Flag, sdl_init_flag(Flag, _), AtomFlags),
   must_be(list(oneof(AtomFlags)), Flags),
   maplist(sdl_init_flag, Flags, IntFlags),
   or_list(IntFlags, IntFlag),
   sdl_init_(IntFlag).

sdl_windowpos_(centered, 0x2fff0000).
sdl_windowpos_(undefined, 0x1fff0000).

sdl_windowpos(XAtom, X) :-
   must_be((oneof([centered, undefined]) ; integer), XAtom),
   (  sdl_windowpos_(XAtom, X)
   -> true
   ;  XAtom = X
   ).

sdl_window_flag(fullscreen, 0x00000001).
sdl_window_flag(opengl, 0x00000002).
sdl_window_flag(shown, 0x00000004).
sdl_window_flag(hidden, 0x00000008).
sdl_window_flag(borderless, 0x00000010).
sdl_window_flag(resizable, 0x00000020).
sdl_window_flag(minimized, 0x00000040).
sdl_window_flag(maximized, 0x00000080).
sdl_window_flag(mouse_grabbed, 0x00000100).
sdl_window_flag(input_focus, 0x00000200).
sdl_window_flag(mouse_focus, 0x00000400).
sdl_window_flag(fullscreen_desktop, Flag) :-
   sdl_window_flag(fullscreen, FullscreenFlag),
   Flag is FullscreenFlag \/ 0x00001000.
sdl_window_flag(foreign, 0x00000800).
sdl_window_flag(allow_highdpi, 0x00002000).
sdl_window_flag(mouse_capture, 0x00004000).
sdl_window_flag(always_on_top, 0x00008000).
sdl_window_flag(skip_taskbar, 0x00010000).
sdl_window_flag(utility, 0x00020000).
%sdl_window_flag(tooltip, 0x00040000). sdl crash
%sdl_window_flag(popup_menu, 0x00080000). sdl crash
sdl_window_flag(keyboard_grabbed, 0x00100000).
sdl_window_flag(vulkan, 0x10000000).
sdl_window_flag(metal, 0x20000000).
sdl_window_flag(input_grabbed, Flag) :-
   sdl_window_flag(mouse_grabbed, Flag).

sdl_createwindow(Handle, Title, XAtom, YAtom, Width, Height, Flags) :-
   must_be(var, Handle),
   must_be(string, Title),
   sdl_windowpos(XAtom, X),
   sdl_windowpos(YAtom, Y),
   must_be(positive_integer, Width),
   must_be(positive_integer, Height),
   findall(AtomFlag, sdl_window_flag(AtomFlag, _), AtomFlags),
   must_be(list(oneof(AtomFlags)), Flags),
   maplist(sdl_window_flag, Flags, IntFlags),
   or_list(IntFlags, IntFlag),
   sdl_createwindow_(Handle, Title, X, Y, Width, Height, IntFlag).

sdl_renderer_flag(software, 0x00000001).
sdl_renderer_flag(accelerated, 0x00000002).
sdl_renderer_flag(presentvsync, 0x00000004).
sdl_renderer_flag(targettexture, 0x00000008).

sdl_createrenderer(Renderer, Window, Index, Flags) :-
   must_be(var, Renderer),
   must_be_blob(sdl_window_blob, Window),
   must_be(integer, Index),
   must_be(list(oneof([software, accelerated, presentvsync, targettexture])), Flags),
   maplist(sdl_renderer_flag, Flags, IntFlags),
   or_list(IntFlags, IntFlag),
   sdl_createrenderer_(Renderer, Window, Index, IntFlag).

img_init_flag(jpg, 0x00000001).
img_init_flag(png, 0x00000002).
img_init_flag(tif, 0x00000004).
img_init_flag(webp, 0x00000008).
img_init_flag(jxl, 0x00000010).
img_init_flag(avif, 0x00000020).

img_init(Result, Flags) :-
   findall(Flag, img_init_flag(Flag, _), AtomFlags),
   must_be(list(oneof(AtomFlags)), Flags),
   maplist(img_init_flag, Flags, IntFlags),
   or_list(IntFlags, IntFlag),
   img_init_(Result, IntFlag).

img_load(Surface, File) :-
   must_be(string, File),
   must_be(var, Surface),
   img_load_(Surface, File).

sdl_createtexturefromsurface(Texture, Renderer, Surface) :-
   must_be(var, Texture),
   must_be_blob(sdl_renderer_blob, Renderer),
   must_be_blob(sdl_surface_blob, Surface),
   sdl_createtexturefromsurface_(Texture, Renderer, Surface).

sdl_rendercopy(Renderer, Texture, Srrect, Dstrect) :-
   must_be_blob(sdl_renderer_blob, Renderer),
   must_be_blob(sdl_texture_blob, Texture),
   maplist(
      must_be((compound(rect(integer, integer, integer, integer)) ; oneof([null]))),
      [Srrect, Dstrect]),
   sdl_rendercopy_(Renderer, Texture, Srrect, Dstrect).

event_struct(quit, []).
event_struct(mousemotion, [windowID, which, state, x, y, xrel, yrel]).
event_struct(mousebutton, [windowID, which, button, state, clicks, x, y]).
event_struct(keyboard, [windowID, state, repeat, keysym]).

sdl_pollevent(Event) :-
   sdl_pollevent_(SDL_Event),
   compound_name_arguments(SDL_Event, Tag, Args),
   event_struct(Tag, Names),
   AllNames = [type, timestamp | Names],
   pairs_keys_values(Pairs, AllNames, Args),
   dict_create(Event, Tag, Pairs).

sdl_setrenderdrawcolor(Renderer, R, G, B, A) :-
   must_be_blob(sdl_renderer_blob, Renderer),
   must_be(between(0, 255), R),
   must_be(between(0, 255), G),
   must_be(between(0, 255), B),
   must_be(between(0, 255), A),
   sdl_setrenderdrawcolor_(Renderer, R, G, B, A).

sdl_renderdrawrect(Renderer, Rect) :-
   must_be_blob(sdl_renderer_blob, Renderer),
   must_be(compound(rect(integer, integer, integer, integer)), Rect),
   sdl_renderdrawrect_(Renderer, Rect).

sdl_renderfillrect(Renderer, Rect) :-
   must_be_blob(sdl_renderer_blob, Renderer),
   must_be(compound(rect(integer, integer, integer, integer)), Rect),
   sdl_renderfillrect_(Renderer, Rect).

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
   setup_call_cleanup(
      img_load(Surface, "DSC03094.JPG"),
      true,
      sdl_freesurface(Surface)).

test(createtexturefromsurface, [
   setup((
      sdl_init([everything]),
      img_init(_, [jpg]),
      sdl_createwindow(Window, "", 0, 0, 400, 600, [opengl]),
      sdl_createrenderer(Renderer, Window, -1, [accelerated]),
      img_load(Surface, "DSC03094.JPG"))),
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
      img_load(Surface, "DSC03094.JPG"),
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
