#include <SDL3/SDL.h>
#include <SWI-cpp2.h>
#include <string>

// SDL_events.h — event polling.

static bool get_motion_event(PlTerm term, SDL_MouseMotionEvent motion) {
  bool res;
  PlTermv motion_args(9);
  res = motion_args[0].unify_atom("mousemotion");
  res = res && motion_args[1].unify_integer(motion.timestamp);
  res = res && motion_args[2].unify_integer(motion.windowID);
  res = res && motion_args[3].unify_integer(motion.which);
  res = res && motion_args[4].unify_integer(motion.state);
  res = res && motion_args[5].unify_float(motion.x);
  res = res && motion_args[6].unify_float(motion.y);
  res = res && motion_args[7].unify_float(motion.xrel);
  res = res && motion_args[8].unify_float(motion.yrel);
  res = res && term.unify_term(PlCompound("mousemotion", motion_args));
  return res;
}

static bool get_quit_event(PlTerm term, SDL_QuitEvent quit) {
  PlTermv args(PlTerm_atom("quit"), PlTerm_integer(quit.timestamp));
  return term.unify_term(PlCompound("quit", args));
}

static bool get_mousebutton_event(PlTerm term, SDL_MouseButtonEvent button_event) {
  std::string button;
  switch (button_event.button) {
  case 1:
    button = "left";
    break;
  case 2:
    button = "middle";
    break;
  case 3:
    button = "right";
    break;
  default:
    button = "unknown";
  }
  PlTermv button_args(9);
  bool res;
  std::string button_type =
      button_event.type == SDL_EVENT_MOUSE_BUTTON_DOWN ? "mousebuttondown" : "mousebuttonup";
  res = button_args[0].unify_atom(button_type);
  res = res && button_args[1].unify_integer(button_event.timestamp);
  res = res && button_args[2].unify_integer(button_event.windowID);
  res = res && button_args[3].unify_integer(button_event.which);
  res = res && button_args[4].unify_atom(button);
  res = res && button_args[5].unify_integer(button_event.down ? 1 : 0);
  res = res && button_args[6].unify_integer(button_event.clicks);
  res = res && button_args[7].unify_float(button_event.x);
  res = res && button_args[8].unify_float(button_event.y);
  res = res && term.unify_term(PlCompound("mousebutton", button_args));
  return res;
}

static bool get_key_event(PlTerm term, SDL_KeyboardEvent key) {
  PlTermv keyboard_args(6);
  bool res;
  std::string key_type = key.type == SDL_EVENT_KEY_DOWN ? "keydown" : "keyup";
  res = keyboard_args[0].unify_atom(key_type);
  res = res && keyboard_args[1].unify_integer(key.timestamp);
  res = res && keyboard_args[2].unify_integer(key.windowID);
  res = res && keyboard_args[3].unify_integer(key.down ? 1 : 0);
  res = res && keyboard_args[4].unify_integer(key.repeat ? 1 : 0);
  PlTermv keysym_args(PlTerm_integer(key.scancode),
                      PlTerm_integer(key.key),
                      PlTerm_integer(key.mod));
  PlCompound keysym("keysym", keysym_args);
  res = res && keyboard_args[5].unify_term(PlCompound("keysym", keysym_args));
  res = res && term.unify_term(PlCompound("keyboard", keyboard_args));
  return res;
}

PREDICATE(sdl_pollevent_, 1) {
  SDL_Event event;
  bool res = false;
  if (SDL_PollEvent(&event)) {
    switch (event.type) {
    case SDL_EVENT_QUIT:
      res = get_quit_event(A1, event.quit);
      break;
    case SDL_EVENT_MOUSE_MOTION:
      res = get_motion_event(A1, event.motion);
      break;
    case SDL_EVENT_MOUSE_BUTTON_DOWN:
      [[fallthrough]];
    case SDL_EVENT_MOUSE_BUTTON_UP:
      res = get_mousebutton_event(A1, event.button);
      break;
    case SDL_EVENT_KEY_DOWN:
      [[fallthrough]];
    case SDL_EVENT_KEY_UP:
      res = get_key_event(A1, event.key);
      break;
    }
    return res;
  }
  return false;
}
