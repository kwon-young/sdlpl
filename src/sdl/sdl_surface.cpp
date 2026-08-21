#include <SDL3/SDL.h>
#include <SWI-cpp2.h>
#include "sdl_blobs.h"
#include "ptr.h"

// SDL_surface.h — surface creation and management.

PL_blob_t sdl_surface_blob =
    PL_BLOB_DEFINITION(SDLSurfaceBlob, "sdl_surface_blob");

PREDICATE(sdl_surface_blob_portray, 2) {
  auto ref = PlBlobV<SDLSurfaceBlob>::cast_ex(A2, sdl_surface_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

PREDICATE(sdl_destroysurface, 1) {
  auto ref = PlBlobV<SDLSurfaceBlob>::cast_ex(A1, sdl_surface_blob);
  ref->destroy();
  return true;
}

// ---------------------------------------------------------------------------
// Surface from existing pixel data.  The pixels pointer is borrowed from
// a PtrBlob (created by e.g. cairo_image_surface_get_data).  The resulting
// SDLSurfaceBlob holds a parent_ ref to the PtrBlob so the pointer stays
// valid for the surface's lifetime.  SDL does not copy the pixel data.
// ---------------------------------------------------------------------------

PREDICATE(sdl_createsurfacefrom_, 6) {
  int width = A2.as_int();
  int height = A3.as_int();
  SDL_PixelFormat format = (SDL_PixelFormat)A4.as_uint32_t();
  auto ptr_ref = PlBlobV<PtrBlob>::cast_ex(A5, *ptr_blob_type());
  int pitch = A6.as_int();
  SDL_Surface *surface =
      SDL_CreateSurfaceFrom(width, height, format, ptr_ref->ptr, pitch);
  if (surface == NULL) {
    throw PlUnknownError(SDL_GetError());
  }
  auto ref = std::unique_ptr<PlBlob>(
      new SDLSurfaceBlob(surface, ptr_ref->symbol_));
  return A1.unify_blob(&ref);
}
