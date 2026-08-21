#include <SDL3/SDL.h>
#include <SWI-cpp2.h>

// SDL_init.h — initialization and shutdown.

PREDICATE(sdl_init_, 1) {
  if (!SDL_Init(A1.as_uint32_t())) {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}

PREDICATE(sdl_quit, 0) {
  SDL_Quit();
  return true;
}
