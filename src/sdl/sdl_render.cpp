#include <SDL3/SDL.h>
#include <SWI-cpp2.h>
#include <string>
#include "sdl_blobs.h"
#include "ptr.h"

// SDL_render.h — 2D hardware-accelerated renderer, textures, drawing.

PL_blob_t sdl_renderer_blob =
    PL_BLOB_DEFINITION(SDLRendererBlob, "sdl_renderer_blob");

PL_blob_t sdl_texture_blob =
    PL_BLOB_DEFINITION(SDLTextureBlob, "sdl_texture_blob");

static const SDL_FRect get_frect(PlTerm term) {
  const SDL_FRect rect = {term[1].as_float(), term[2].as_float(),
                          term[3].as_float(), term[4].as_float()};
  return rect;
}

PREDICATE(sdl_renderer_blob_portray, 2) {
  auto ref = PlBlobV<SDLRendererBlob>::cast_ex(A2, sdl_renderer_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

PREDICATE(sdl_texture_blob_portray, 2) {
  auto ref = PlBlobV<SDLTextureBlob>::cast_ex(A2, sdl_texture_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

PREDICATE(sdl_createrenderer_, 3) {
  auto window_ref = PlBlobV<SDLWindowBlob>::cast_ex(A2, sdl_window_blob);
  const char *name = nullptr;
  std::string name_str;
  if (!(A3.is_atom() && A3.as_atom() == PlAtom("null"))) {
    name_str = A3.as_string();
    name = name_str.c_str();
  }
  SDL_Renderer *renderer = SDL_CreateRenderer(window_ref->window_, name);
  if (renderer == NULL) {
    throw PlUnknownError(SDL_GetError());
  }
  auto ref =
      std::unique_ptr<PlBlob>(new SDLRendererBlob(renderer, window_ref->symbol_));
  return A1.unify_blob(&ref);
}

PREDICATE(sdl_setrendervsync_, 2) {
  auto ref = PlBlobV<SDLRendererBlob>::cast_ex(A1, sdl_renderer_blob);
  if (!SDL_SetRenderVSync(ref->renderer_, A2.as_int())) {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}

PREDICATE(sdl_destroyrenderer, 1) {
  auto ref = PlBlobV<SDLRendererBlob>::cast_ex(A1, sdl_renderer_blob);
  ref->destroy();
  return true;
}

PREDICATE(sdl_renderclear, 1) {
  auto ref = PlBlobV<SDLRendererBlob>::cast_ex(A1, sdl_renderer_blob);
  if (!SDL_RenderClear(ref->renderer_)) {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}

PREDICATE(sdl_rendertexture_, 4) {
  SDL_FRect *srcrect_p = NULL;
  SDL_FRect srcrect;
  if (A3.is_compound()) {
    srcrect = get_frect(A3);
    srcrect_p = &srcrect;
  }
  SDL_FRect *dstrect_p = NULL;
  SDL_FRect dstrect;
  if (A4.is_compound()) {
    dstrect = get_frect(A4);
    dstrect_p = &dstrect;
  }
  auto texture_ref = PlBlobV<SDLTextureBlob>::cast_ex(A2, sdl_texture_blob);
  auto renderer_ref = PlBlobV<SDLRendererBlob>::cast_ex(A1, sdl_renderer_blob);
  if (!SDL_RenderTexture(renderer_ref->renderer_, texture_ref->texture_,
                         srcrect_p, dstrect_p)) {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}

PREDICATE(sdl_renderpresent, 1) {
  auto ref = PlBlobV<SDLRendererBlob>::cast_ex(A1, sdl_renderer_blob);
  SDL_RenderPresent(ref->renderer_);
  return true;
}

PREDICATE(sdl_createtexturefromsurface_, 3) {
  auto renderer_ref = PlBlobV<SDLRendererBlob>::cast_ex(A2, sdl_renderer_blob);
  auto surface_ref = PlBlobV<SDLSurfaceBlob>::cast_ex(A3, sdl_surface_blob);
  SDL_Texture *texture =
      SDL_CreateTextureFromSurface(renderer_ref->renderer_, surface_ref->surface_);
  if (texture == NULL) {
    throw PlUnknownError(SDL_GetError());
  }
  auto ref =
      std::unique_ptr<PlBlob>(new SDLTextureBlob(texture, renderer_ref->symbol_));
  return A1.unify_blob(&ref);
}

PREDICATE(sdl_createtexture_, 6) {
  auto renderer_ref = PlBlobV<SDLRendererBlob>::cast_ex(A2, sdl_renderer_blob);
  SDL_PixelFormat format = (SDL_PixelFormat)A3.as_uint32_t();
  SDL_TextureAccess access = (SDL_TextureAccess)A4.as_int();
  SDL_Texture *texture =
      SDL_CreateTexture(renderer_ref->renderer_, format, access,
                        A5.as_int(), A6.as_int());
  if (texture == NULL) {
    throw PlUnknownError(SDL_GetError());
  }
  auto ref =
      std::unique_ptr<PlBlob>(new SDLTextureBlob(texture, renderer_ref->symbol_));
  return A1.unify_blob(&ref);
}

PREDICATE(sdl_destroytexture, 1) {
  auto ref = PlBlobV<SDLTextureBlob>::cast_ex(A1, sdl_texture_blob);
  ref->destroy();
  return true;
}

PREDICATE(sdl_setrenderdrawcolor_, 5) {
  auto ref = PlBlobV<SDLRendererBlob>::cast_ex(A1, sdl_renderer_blob);
  if (!SDL_SetRenderDrawColor(ref->renderer_, A2.as_uint(), A3.as_uint(),
                              A4.as_uint(), A5.as_uint())) {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}

PREDICATE(sdl_renderrect_, 2) {
  const SDL_FRect rect = get_frect(A2);
  auto ref = PlBlobV<SDLRendererBlob>::cast_ex(A1, sdl_renderer_blob);
  if (!SDL_RenderRect(ref->renderer_, &rect)) {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}

PREDICATE(sdl_renderfillrect_, 2) {
  const SDL_FRect rect = get_frect(A2);
  auto ref = PlBlobV<SDLRendererBlob>::cast_ex(A1, sdl_renderer_blob);
  if (!SDL_RenderFillRect(ref->renderer_, &rect)) {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}

// ---------------------------------------------------------------------------
// Update a texture with new pixel data.  The pixels pointer is borrowed
// from a PtrBlob.  This avoids creating/destroying a texture every frame
// when streaming dynamically-rendered content (e.g. cairo).
// ---------------------------------------------------------------------------

PREDICATE(sdl_updatetexture_, 4) {
  auto texture_ref = PlBlobV<SDLTextureBlob>::cast_ex(A1, sdl_texture_blob);
  SDL_Rect rect;
  SDL_Rect *rect_p = NULL;
  if (A2.is_compound()) {
    rect.x = (int)A2[1].as_float();
    rect.y = (int)A2[2].as_float();
    rect.w = (int)A2[3].as_float();
    rect.h = (int)A2[4].as_float();
    rect_p = &rect;
  }
  auto ptr_ref = PlBlobV<PtrBlob>::cast_ex(A3, *ptr_blob_type());
  int pitch = A4.as_int();
  if (!SDL_UpdateTexture(texture_ref->texture_, rect_p, ptr_ref->ptr, pitch)) {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}

// ---------------------------------------------------------------------------
// Lock a streaming texture for write-only pixel access.  Returns a PtrBlob
// wrapping the locked pixel pointer (parent = texture blob) and the pitch.
// The pointer is valid until sdl_unlocktexture is called.  This enables
// zero-copy rendering: cairo writes directly into the GPU texture's memory.
// ---------------------------------------------------------------------------

PREDICATE(sdl_locktexture_, 4) {
  auto texture_ref = PlBlobV<SDLTextureBlob>::cast_ex(A1, sdl_texture_blob);
  SDL_Rect rect;
  SDL_Rect *rect_p = NULL;
  if (A2.is_compound()) {
    rect.x = (int)A2[1].as_float();
    rect.y = (int)A2[2].as_float();
    rect.w = (int)A2[3].as_float();
    rect.h = (int)A2[4].as_float();
    rect_p = &rect;
  }
  void *pixels;
  int pitch;
  if (!SDL_LockTexture(texture_ref->texture_, rect_p, &pixels, &pitch)) {
    throw PlUnknownError(SDL_GetError());
  }
  auto ref = std::unique_ptr<PlBlob>(
      new PtrBlob(pixels, texture_ref->symbol_));
  return (A3.unify_blob(&ref) && A4.unify_integer(pitch));
}

PREDICATE(sdl_unlocktexture_, 1) {
  auto texture_ref = PlBlobV<SDLTextureBlob>::cast_ex(A1, sdl_texture_blob);
  SDL_UnlockTexture(texture_ref->texture_);
  return true;
}
