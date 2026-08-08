#include <SDL3/SDL.h>
#include <SDL3_image/SDL_image.h>
#include <SWI-cpp2.h>
#include <string>
#include "ptr.h"

struct SDLWindowBlob;

static PL_blob_t sdl_window_blob =
    PL_BLOB_DEFINITION(SDLWindowBlob, "sdl_window_blob");

struct SDLWindowBlob : public PlBlob {
  SDL_Window *window_;

  explicit SDLWindowBlob() : PlBlob(&sdl_window_blob) {}

  explicit SDLWindowBlob(SDL_Window *window)
      : PlBlob(&sdl_window_blob), window_(window) {}

  PL_BLOB_SIZE

  void portray(PlStream &strm) const {
    strm.printf("sdl_window_blob<%p>(%p)", this, window_);
  }

  void destroy() noexcept {
    if (window_ != NULL) {
      SDL_DestroyWindow(window_);
      window_ = NULL;
    }
  }

  virtual ~SDLWindowBlob() noexcept { destroy(); }
};

PREDICATE(sdl_window_blob_portray, 2) {
  auto ref = PlBlobV<SDLWindowBlob>::cast_ex(A2, sdl_window_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

struct SDLRendererBlob;

static PL_blob_t sdl_renderer_blob =
    PL_BLOB_DEFINITION(SDLRendererBlob, "sdl_renderer_blob");

struct SDLRendererBlob : public PlBlob {
  SDL_Renderer *renderer_;
  PlAtom parent_;

  explicit SDLRendererBlob() : PlBlob(&sdl_renderer_blob), parent_(PlAtom::null) {}

  explicit SDLRendererBlob(SDL_Renderer *renderer, PlAtom window)
      : PlBlob(&sdl_renderer_blob), renderer_(renderer), parent_(window) {
    parent_.register_ref();
  }

  PL_BLOB_SIZE

  void portray(PlStream &strm) const {
    strm.printf("sdl_renderer_blob<%p>(%p)", this, renderer_);
  }

  void destroy() noexcept {
    if (renderer_ != NULL) {
      SDL_DestroyRenderer(renderer_);
      renderer_ = NULL;
    }
    if (parent_.not_null()) {
      parent_.unregister_ref();
      parent_.set_null();
    }
  }

  virtual ~SDLRendererBlob() noexcept { destroy(); }
};

PREDICATE(sdl_renderer_blob_portray, 2) {
  auto ref = PlBlobV<SDLRendererBlob>::cast_ex(A2, sdl_renderer_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

struct SDLSurfaceBlob;

static PL_blob_t sdl_surface_blob =
    PL_BLOB_DEFINITION(SDLSurfaceBlob, "sdl_surface_blob");

struct SDLSurfaceBlob : public PlBlob {
  SDL_Surface *surface_;
  PlAtom parent_;

  explicit SDLSurfaceBlob()
      : PlBlob(&sdl_surface_blob), surface_(NULL), parent_(PlAtom::null) {}

  explicit SDLSurfaceBlob(SDL_Surface *surface)
      : PlBlob(&sdl_surface_blob), surface_(surface), parent_(PlAtom::null) {}

  explicit SDLSurfaceBlob(SDL_Surface *surface, PlAtom parent)
      : PlBlob(&sdl_surface_blob), surface_(surface), parent_(parent) {
    parent_.register_ref();
  }

  PL_BLOB_SIZE

  void portray(PlStream &strm) const {
    strm.printf("sdl_surface_blob<%p>(%p)", this, surface_);
  }

  void destroy() noexcept {
    if (surface_ != NULL) {
      SDL_DestroySurface(surface_);
      surface_ = NULL;
    }
    if (parent_.not_null()) {
      parent_.unregister_ref();
      parent_.set_null();
    }
  }

  virtual ~SDLSurfaceBlob() noexcept { destroy(); }
};

PREDICATE(sdl_surface_blob_portray, 2) {
  auto ref = PlBlobV<SDLSurfaceBlob>::cast_ex(A2, sdl_surface_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

struct SDLTextureBlob;

static PL_blob_t sdl_texture_blob =
    PL_BLOB_DEFINITION(SDLTextureBlob, "sdl_texture_blob");

struct SDLTextureBlob : public PlBlob {
  SDL_Texture *texture_;
  PlAtom parent_;

  explicit SDLTextureBlob() : PlBlob(&sdl_texture_blob), parent_(PlAtom::null) {}

  explicit SDLTextureBlob(SDL_Texture *texture, PlAtom renderer)
      : PlBlob(&sdl_texture_blob), texture_(texture), parent_(renderer) {
    parent_.register_ref();
  }

  PL_BLOB_SIZE

  void portray(PlStream &strm) const {
    strm.printf("sdl_texture_blob<%p>(%p)", this, texture_);
  }

  void destroy() noexcept {
    if (texture_ != NULL) {
      SDL_DestroyTexture(texture_);
      texture_ = NULL;
    }
    if (parent_.not_null()) {
      parent_.unregister_ref();
      parent_.set_null();
    }
  }

  virtual ~SDLTextureBlob() noexcept { destroy(); }
};

PREDICATE(sdl_texture_blob_portray, 2) {
  auto ref = PlBlobV<SDLTextureBlob>::cast_ex(A2, sdl_texture_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

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

const SDL_FRect get_frect(PlTerm term) {
  const SDL_FRect rect = {term[1].as_float(), term[2].as_float(),
                          term[3].as_float(), term[4].as_float()};
  return rect;
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

PREDICATE(img_load_, 2) {
  SDL_Surface *surface = IMG_Load(A2.as_string().c_str());
  if (surface == NULL) {
    throw PlUnknownError(SDL_GetError());
  }
  auto ref = std::unique_ptr<PlBlob>(new SDLSurfaceBlob(surface));
  return A1.unify_blob(&ref);
}

PREDICATE(sdl_destroysurface, 1) {
  auto ref = PlBlobV<SDLSurfaceBlob>::cast_ex(A1, sdl_surface_blob);
  ref->destroy();
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

bool get_motion_event(PlTerm term, SDL_MouseMotionEvent motion) {
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

bool get_quit_event(PlTerm term, SDL_QuitEvent quit) {
  PlTermv args(PlTerm_atom("quit"), PlTerm_integer(quit.timestamp));
  return term.unify_term(PlCompound("quit", args));
}

bool get_mousebutton_event(PlTerm term, SDL_MouseButtonEvent button_event) {
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

bool get_key_event(PlTerm term, SDL_KeyboardEvent key) {
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


