/*  Part of the SDL3 pack for SWI-Prolog.

    SDL_events.h — event polling.

    @see https://wiki.libsdl.org/SDL3/SDL_events
*/

:- module(sdl_events, [
    sdl_pollevent/1
]).

:- use_module(library(sdl/foreign), [sdl_pollevent_/1]).

%!  sdl_pollevent(-Event:dict) is semidet.
%
%   Poll the next pending event.  Succeeds once with a dict for each
%   pending event, and fails when the queue is empty.
%
%   Event is a dict whose tag is the event type and which always contains
%   the keys `type` and `timestamp`.  Additional type-specific keys are
%   present depending on the tag:
%   *  `quit` -- no extra keys
%   *  `mousemotion` -- `windowID`, `which`, `state`, `x`, `y`, `xrel`, `yrel`
%   *  `mousebutton` -- `windowID`, `which`, `button`, `state`, `clicks`, `x`, `y`
%   *  `keyboard` -- `windowID`, `state`, `repeat`, `keysym`
%
%   Only the event types handled by the binding are produced.
%%
%   @see https://wiki.libsdl.org/SDL3/SDL_PollEvent

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
