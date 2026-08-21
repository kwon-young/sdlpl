/*  Part of the SDL3 pack for SWI-Prolog.

    SDL_video.h — window management.

    @see https://wiki.libsdl.org/SDL3/SDL_video
*/

:- module(sdl_video, [
    sdl_createwindow/5,
    sdl_setwindowposition/3,
    sdl_destroywindow/1,
    sdl_window_flag/2,
    sdl_windowpos/2
]).

:- use_module(library(sdl/foreign), [
    sdl_createwindow_/5,
    sdl_setwindowposition_/3,
    sdl_destroywindow/1,
    sdl_window_blob_portray/2,
    or_list/2
]).
:- reexport(library(sdl/foreign), [sdl_destroywindow/1]).

:- multifile error:has_type/2.
error:has_type(sdl_window_blob,   X) :- blob(X, sdl_window_blob).
error:has_type(sdl_window_flag, X) :- sdl_window_flag(X, _).
error:has_type(sdl_windowpos,   X) :- ( atom(X) -> sdl_windowpos(X, _) ; integer(X) ).

:- multifile prolog:error_message//1.
prolog:error_message(type_error(sdl_window_flag, Culprit)) -->
   { findall(F, sdl_window_flag(F, _), Fs) },
   [ 'sdl_window_flag (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(sdl_windowpos, Culprit)) -->
   { findall(F, sdl_windowpos(F, _), Fs) },
   [ 'sdl_windowpos (one of ~q or an integer pixel offset), found ~q'-[Fs, Culprit] ].

user:portray(Window) :-
   blob(Window, sdl_window_blob), !,
   sdl_window_blob_portray(current_output, Window).

%!  sdl_window_flag(?Flag:atom, ?Value:integer) is nondet.
%
%   Enumerate the window creation flags.  Each flag is a Prolog atom
%   linked to its SDL bit-mask value.
%
%   The user-facing flag atoms are:
%   *  `fullscreen`
%   *  `opengl`
%   *  `occluded`
%   *  `hidden`
%   *  `borderless`
%   *  `resizable`
%   *  `minimized`
%   *  `maximized`
%   *  `mouse_grabbed`
%   *  `input_focus`
%   *  `mouse_focus`
%   *  `external`
%   *  `high_pixel_density`
%   *  `mouse_capture`
%   *  `mouse_relative_mode`
%   *  `always_on_top`
%   *  `utility`
%   *  `keyboard_grabbed`
%   *  `fill_document`
%   *  `vulkan`
%   *  `metal`
%   *  `transparent`
%   *  `not_focusable`
%   *  `input_grabbed` -- synonym for `mouse_grabbed`
%   *  `allow_highdpi` -- synonym for `high_pixel_density`
%
%   Flags requiring a parent window (`modal`, `tooltip`, `popup_menu`) are
%   not exposed.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_CreateWindow

sdl_window_flag(fullscreen, 0x00000001).
sdl_window_flag(opengl, 0x00000002).
sdl_window_flag(occluded, 0x00000004).
sdl_window_flag(hidden, 0x00000008).
sdl_window_flag(borderless, 0x00000010).
sdl_window_flag(resizable, 0x00000020).
sdl_window_flag(minimized, 0x00000040).
sdl_window_flag(maximized, 0x00000080).
sdl_window_flag(mouse_grabbed, 0x00000100).
sdl_window_flag(input_focus, 0x00000200).
sdl_window_flag(mouse_focus, 0x00000400).
sdl_window_flag(external, 0x00000800).
%sdl_window_flag(modal, 0x00001000). requires a parent window
sdl_window_flag(high_pixel_density, 0x00002000).
sdl_window_flag(mouse_capture, 0x00004000).
sdl_window_flag(mouse_relative_mode, 0x00008000).
sdl_window_flag(always_on_top, 0x00010000).
sdl_window_flag(utility, 0x00020000).
%sdl_window_flag(tooltip, 0x00040000). requires a parent window
%sdl_window_flag(popup_menu, 0x00080000). requires a parent window
sdl_window_flag(keyboard_grabbed, 0x00100000).
sdl_window_flag(fill_document, 0x00200000).
sdl_window_flag(vulkan, 0x10000000).
sdl_window_flag(metal, 0x20000000).
sdl_window_flag(transparent, 0x40000000).
sdl_window_flag(not_focusable, 0x80000000).
sdl_window_flag(input_grabbed, Flag) :-
   sdl_window_flag(mouse_grabbed, Flag).
sdl_window_flag(allow_highdpi, Flag) :-
   sdl_window_flag(high_pixel_density, Flag).

%!  sdl_windowpos(?Pos:term, ?Value:integer) is nondet.
%
%   Special window-position constants.  A window position is either one
%   of these atoms or a plain integer pixel offset (validated by the
%   sdl_windowpos type, which accepts both).
%   *  `centered`
%   *  `undefined`
%
%   @see https://wiki.libsdl.org/SDL3/SDL_CreateWindow
%   @see https://wiki.libsdl.org/SDL3/SDL_WINDOWPOS_CENTERED

sdl_windowpos(centered, 0x2fff0000).
sdl_windowpos(undefined, 0x1fff0000).

%!  sdl_createwindow(-Handle:blob, +Title:string, +Width:positive_integer, +Height:positive_integer, +Flags:list(sdl_window_flag)) is det.
%
%   Create a window.  Each element of Flags must be one of the atoms
%   enumerated by sdl_window_flag/2.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_CreateWindow

sdl_createwindow(Handle, Title, Width, Height, Flags) :-
   must_be(var, Handle),
   must_be(string, Title),
   must_be(positive_integer, Width),
   must_be(positive_integer, Height),
   must_be(list(sdl_window_flag), Flags),
   maplist(sdl_window_flag, Flags, IntFlags),
   or_list(IntFlags, IntFlag),
   sdl_createwindow_(Handle, Title, Width, Height, IntFlag).

%!  sdl_setwindowposition(+Window:blob, +X:sdl_windowpos, +Y:sdl_windowpos) is det.
%
%   Move the window.  X and Y are each either an atom enumerated by
%   sdl_windowpos/2 or an integer pixel offset.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_SetWindowPosition

sdl_setwindowposition(Window, X, Y) :-
   must_be(sdl_window_blob, Window),
   must_be(sdl_windowpos, X),
   must_be(sdl_windowpos, Y),
   coord(X, Xp),
   coord(Y, Yp),
   sdl_setwindowposition_(Window, Xp, Yp).

coord(C, Cp) :- ( atom(C) -> sdl_windowpos(C, Cp) ; Cp = C ).

%!  sdl_destroywindow(+Window:blob) is det.
%
%   Destroy a previously created window blob.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_DestroyWindow
