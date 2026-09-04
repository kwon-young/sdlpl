:- use_foreign_library(foreign('sdlpp.so')).

% sdl_init_flag(timer, 0x00000001).
% sdl_init_flag(audio, 0x00000010).
% sdl_init_flag(video, 0x00000020).
% sdl_init_flag(joystick, 0x00000200).
% sdl_init_flag(haptic, 0x00001000).
% sdl_init_flag(gamecontroller, 0x00002000).
% sdl_init_flag(events, 0x00004000).
% sdl_init_flag(sensor, 0x00008000).
% sdl_init_flag(everything, Flag) :-
%    maplist(sdl_init_flag, [timer, audio, video, events, joystick, haptic,
%                            gamecontroller, sensor], Flags),
%    or_list(Flags, Flag).
%
% or_list(List, Or) :-
%    foldl([B, A, C]>>(C is A \/ B), List, 0, Or).
%
% sdl_init(Flags) :-
%    findall(Flag, sdl_init_flag(Flag, _), AtomFlags),
%    must_be(list(oneof(AtomFlags)), Flags),
%    maplist(sdl_init_flag, Flags, IntFlags),
%    or_list(IntFlags, IntFlag),
%    sdl_init_(IntFlag).
