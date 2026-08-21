#include <SDL3/SDL.h>
#include <SWI-cpp2.h>
#include <string>
#include "sdl_blobs.h"

// SDL_video.h — window management.

PL_blob_t sdl_window_blob =
    PL_BLOB_DEFINITION(SDLWindowBlob, "sdl_window_blob");

PREDICATE(sdl_window_blob_portray, 2) {
  auto ref = PlBlobV<SDLWindowBlob>::cast_ex(A2, sdl_window_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

PREDICATE(sdl_createwindow_, 5) {
  SDL_Window *window =
      SDL_CreateWindow(A2.as_string().c_str(), A3.as_int(), A4.as_int(),
                       A5.as_uint64_t());
  if (window == NULL) {
    throw PlUnknownError(SDL_GetError());
  }
  auto ref = std::unique_ptr<PlBlob>(new SDLWindowBlob(window));
  return A1.unify_blob(&ref);
}

PREDICATE(sdl_setwindowposition_, 3) {
  auto ref = PlBlobV<SDLWindowBlob>::cast_ex(A1, sdl_window_blob);
  if (!SDL_SetWindowPosition(ref->window_, A2.as_int(), A3.as_int())) {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}

PREDICATE(sdl_destroywindow, 1) {
  auto ref = PlBlobV<SDLWindowBlob>::cast_ex(A1, sdl_window_blob);
  ref->destroy();
  return true;
}
