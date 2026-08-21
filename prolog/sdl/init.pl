/*  Part of the SDL3 pack for SWI-Prolog.

    SDL_init.h — initialization and shutdown.

    @see https://wiki.libsdl.org/SDL3/SDL_init
*/

:- module(sdl_init, [
    sdl_init/1,
    sdl_init_flag/2,
    sdl_quit/0
]).

:- use_module(library(sdl/foreign), [sdl_init_/1, sdl_quit/0, or_list/2]).
:- reexport(library(sdl/foreign), [sdl_quit/0]).

:- multifile error:has_type/2.
error:has_type(sdl_init_flag, X) :- sdl_init_flag(X, _).

:- multifile prolog:error_message//1.
prolog:error_message(type_error(sdl_init_flag, Culprit)) -->
   { findall(F, sdl_init_flag(F, _), Fs) },
   [ 'sdl_init_flag (one of ~q), found ~q'-[Fs, Culprit] ].

%%  sdl_init_flag(?Flag:atom, ?Value:integer) is nondet.
%
%   Enumerate the SDL subsystem subscription flags.  Each flag is a
%   Prolog atom linked to its SDL bit-mask value.
%
%   The user-facing flag atoms are:
%   *  `audio`
%   *  `video`
%   *  `joystick`
%   *  `haptic`
%   *  `gamepad`
%   *  `events`
%   *  `sensor`
%   *  `camera`
%   *  `everything` -- a convenience flag combining the other flags
%
%   @see https://wiki.libsdl.org/SDL3/SDL_Init

sdl_init_flag(audio, 0x00000010).
sdl_init_flag(video, 0x00000020).
sdl_init_flag(joystick, 0x00000200).
sdl_init_flag(haptic, 0x00001000).
sdl_init_flag(gamepad, 0x00002000).
sdl_init_flag(events, 0x00004000).
sdl_init_flag(sensor, 0x00008000).
sdl_init_flag(camera, 0x00010000).
sdl_init_flag(everything, Flag) :-
   maplist(sdl_init_flag, [audio, video, events, joystick, haptic,
                           gamepad, sensor, camera], Flags),
   or_list(Flags, Flag).

%!  sdl_init(+Flags:list(sdl_init_flag)) is det.
%
%   Initializes the SDL library.  Each element of Flags must be one of
%   the atoms enumerated by sdl_init_flag/2.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_Init

sdl_init(Flags) :-
    must_be(list(sdl_init_flag), Flags),
    maplist(sdl_init_flag, Flags, IntFlags),
    or_list(IntFlags, IntFlag),
    sdl_init_(IntFlag).

%!  sdl_quit is det.
%
%   Shuts down all SDL subsystems initialized by sdl_init/1.
%
%   @see https://wiki.libsdl.org/SDL3/SDL_Quit
