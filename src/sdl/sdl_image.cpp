#include <SDL3/SDL.h>
#include <SDL3_image/SDL_image.h>
#include <SWI-cpp2.h>
#include "sdl_blobs.h"

// SDL_image — image loading via SDL3_image.

PREDICATE(img_load_, 2) {
  SDL_Surface *surface = IMG_Load(A2.as_string().c_str());
  if (surface == NULL) {
    throw PlUnknownError(SDL_GetError());
  }
  auto ref = std::unique_ptr<PlBlob>(new SDLSurfaceBlob(surface));
  return A1.unify_blob(&ref);
}
