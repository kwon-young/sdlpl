#include <string>
#include <SDL.h>
#include <SDL_image.h>
#include <SWI-cpp2.h>

PREDICATE(sdl_init_, 1)
{
  if (SDL_Init(A1.as_uint32_t()) < 0)
  {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}

PREDICATE(sdl_quit, 0)
{
  SDL_Quit();
  return true;
}

PREDICATE(sdl_createwindow_, 7)
{
  SDL_Window *window = SDL_CreateWindow(A2.as_string().c_str(),
                                        A3.as_int(), A4.as_int(),
                                        A5.as_int(), A6.as_int(),
                                        A7.as_uint32_t());
  if (window == NULL)
  {
    throw PlUnknownError(SDL_GetError());
  }
  return A1.unify_pointer(window);
}

PREDICATE(sdl_destroywindow, 1)
{
  SDL_DestroyWindow((SDL_Window *) A1.as_pointer());
  return true;
}

PREDICATE(sdl_createrenderer_, 4)
{
  SDL_Renderer *renderer = SDL_CreateRenderer((SDL_Window *) A2.as_pointer(),
                                              A3.as_int(),
                                              A4.as_uint32_t());
  if (renderer == NULL)
  {
    throw PlUnknownError(SDL_GetError());
  }
  return A1.unify_pointer(renderer);
}

PREDICATE(sdl_destroyrenderer, 1)
{
  SDL_DestroyRenderer((SDL_Renderer *) A1.as_pointer());
  return true;
}

PREDICATE(sdl_renderclear, 1)
{
  if (SDL_RenderClear((SDL_Renderer *) A1.as_pointer()) < 0)
  {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}

const SDL_Rect
get_rect(PlTerm term)
{
  const SDL_Rect rect = {
    term[1].as_int(), term[2].as_int(), term[3].as_int(),
    term[4].as_int()
  };
  return rect;
}

PREDICATE(sdl_rendercopy_, 4)
{
  SDL_Rect *srcrect_p = NULL;
  SDL_Rect srcrect;
  if (A3.is_compound())
  {
    srcrect = get_rect(A3);
    srcrect_p = &srcrect;
  }
  SDL_Rect *dstrect_p = NULL;
  SDL_Rect dstrect;
  if (A4.is_compound())
  {
    dstrect = get_rect(A4);
    dstrect_p = &dstrect;
  }
  if (SDL_RenderCopy((SDL_Renderer *) A1.as_pointer(),
                     (SDL_Texture *) A2.as_pointer(),
                     srcrect_p, dstrect_p) < 0)
  {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}

PREDICATE(sdl_renderpresent, 1)
{
  SDL_RenderPresent((SDL_Renderer *) A1.as_pointer());
  return true;
}

PREDICATE(img_init_, 2)
{
  int result = IMG_Init(A2.as_uint32_t());
  return A1.unify_integer(result);
}

PREDICATE(img_quit, 0)
{
  IMG_Quit();
  return true;
}

PREDICATE(img_load_, 2)
{
  SDL_Surface *surface = IMG_Load(A2.as_string().c_str());
  if (surface == NULL)
  {
    throw PlUnknownError(SDL_GetError());
  }
  return A1.unify_pointer(surface);
}

PREDICATE(sdl_freesurface, 1)
{
  SDL_FreeSurface((SDL_Surface *) A1.as_pointer());
  return true;
}

PREDICATE(sdl_createtexturefromsurface_, 3)
{
  SDL_Texture *texture =
    SDL_CreateTextureFromSurface((SDL_Renderer *) A2.as_pointer(),
                                 (SDL_Surface *) A3.as_pointer());
  if (texture == NULL)
  {
    throw PlUnknownError(SDL_GetError());
  }
  return A1.unify_pointer(texture);
}

PREDICATE(sdl_destroytexture, 1)
{
  SDL_DestroyTexture((SDL_Texture *) A1.as_pointer());
  return true;
}

bool
get_motion_event(PlTerm term, SDL_MouseMotionEvent motion)
{
  bool res;
  PlTermv motion_args(9);
  res = motion_args[0].unify_string("mousemotion");
  res = res && motion_args[1].unify_integer(motion.timestamp);
  res = res && motion_args[2].unify_integer(motion.windowID);
  res = res && motion_args[3].unify_integer(motion.which);
  res = res && motion_args[4].unify_integer(motion.state);
  res = res && motion_args[5].unify_integer(motion.x);
  res = res && motion_args[6].unify_integer(motion.y);
  res = res && motion_args[7].unify_integer(motion.xrel);
  res = res && motion_args[8].unify_integer(motion.yrel);
  res = res && term.unify_term(PlCompound("mousemotion", motion_args));
  return res;
}

bool
get_quit_event(PlTerm term, SDL_QuitEvent quit)
{
  PlTermv args(PlTerm_string("quit"), PlTerm_integer(quit.timestamp));
  return term.unify_term(PlCompound("quit", args));
}

bool
get_mousebutton_event(PlTerm term, SDL_MouseButtonEvent button_event)
{
  std::string button;
  switch (button_event.button)
  {
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
    button_event.type ==
    SDL_MOUSEBUTTONDOWN ? "mousebuttondown" : "mousebuttonup";
  res = button_args[0].unify_string(button_type);
  res = res && button_args[1].unify_integer(button_event.timestamp);
  res = res && button_args[2].unify_integer(button_event.windowID);
  res = res && button_args[3].unify_integer(button_event.which);
  res = res && button_args[4].unify_string(button);
  res = res && button_args[5].unify_integer(button_event.state);
  res = res && button_args[6].unify_integer(button_event.clicks);
  res = res && button_args[7].unify_integer(button_event.x);
  res = res && button_args[8].unify_integer(button_event.y);
  res = res && term.unify_term(PlCompound("mousebutton", button_args));
  return res;
}

bool
get_key_event(PlTerm term, SDL_KeyboardEvent key)
{
  PlTermv keyboard_args(6);
  bool res;
  std::string key_type = key.type == SDL_KEYDOWN ? "keydown" : "keyup";
  res = keyboard_args[0].unify_string(key_type);
  res = res && keyboard_args[1].unify_integer(key.timestamp);
  res = res && keyboard_args[2].unify_integer(key.windowID);
  res = res && keyboard_args[3].unify_integer(key.state);
  res = res && keyboard_args[4].unify_integer(key.repeat);
  PlTermv keysym_args(PlTerm_integer(key.keysym.scancode),
                      PlTerm_integer(key.keysym.sym),
                      PlTerm_integer(key.keysym.mod));
  PlCompound keysym("keysym", keysym_args);
  res = res && keyboard_args[5].unify_term(PlCompound("keysym", keysym_args));
  res = res && term.unify_term(PlCompound("keyboard", keyboard_args));
  return res;
}

PREDICATE(sdl_pollevent_, 1)
{
  SDL_Event event;
  bool res;
  if (SDL_PollEvent(&event))
  {
    switch (event.type)
    {
    case SDL_QUIT:
      res = get_quit_event(A1, event.quit);
      break;
    case SDL_MOUSEMOTION:
      res = get_motion_event(A1, event.motion);
      break;
    case SDL_MOUSEBUTTONDOWN:
      [[fallthrough]];
    case SDL_MOUSEBUTTONUP:
      res = get_mousebutton_event(A1, event.button);
      break;
    case SDL_KEYDOWN:
      [[fallthrough]];
    case SDL_KEYUP:
      res = get_key_event(A1, event.key);
      break;
    }
    return res;
  }
  return false;
}

PREDICATE(sdl_setrenderdrawcolor_, 5)
{
  if (SDL_SetRenderDrawColor((SDL_Renderer *) A1.as_pointer(),
                             A2.as_uint(),
                             A3.as_uint(), A4.as_uint(), A5.as_uint()) < 0)
  {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}

PREDICATE(sdl_renderdrawrect_, 2)
{
  const SDL_Rect rect = get_rect(A2);
  if (SDL_RenderDrawRect((SDL_Renderer *) A1.as_pointer(), &rect) < 0)
  {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}

PREDICATE(sdl_renderfillrect_, 2)
{
  const SDL_Rect rect = get_rect(A2);
  if (SDL_RenderFillRect((SDL_Renderer *) A1.as_pointer(), &rect) < 0)
  {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}
