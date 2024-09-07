#include <SDL.h>
#include <SDL_image.h>
#include <SWI-cpp2.h>
#include <string>

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

  explicit SDLRendererBlob() : PlBlob(&sdl_renderer_blob) {}

  explicit SDLRendererBlob(SDL_Renderer *renderer)
      : PlBlob(&sdl_renderer_blob), renderer_(renderer) {}

  PL_BLOB_SIZE

  void portray(PlStream &strm) const {
    strm.printf("sdl_renderer_blob<%p>(%p)", this, renderer_);
  }

  void destroy() noexcept {
    if (renderer_ != NULL) {
      SDL_DestroyRenderer(renderer_);
      renderer_ = NULL;
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

  explicit SDLSurfaceBlob() : PlBlob(&sdl_surface_blob) {}

  explicit SDLSurfaceBlob(SDL_Surface *surface)
      : PlBlob(&sdl_surface_blob), surface_(surface) {}

  PL_BLOB_SIZE

  void portray(PlStream &strm) const {
    strm.printf("sdl_surface_blob<%p>(%p)", this, surface_);
  }

  void destroy() noexcept {
    if (surface_ != NULL) {
      SDL_FreeSurface(surface_);
      surface_ = NULL;
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

  explicit SDLTextureBlob() : PlBlob(&sdl_texture_blob) {}

  explicit SDLTextureBlob(SDL_Texture *texture)
      : PlBlob(&sdl_texture_blob), texture_(texture) {}

  PL_BLOB_SIZE

  void portray(PlStream &strm) const {
    strm.printf("sdl_texture_blob<%p>(%p)", this, texture_);
  }

  void destroy() noexcept {
    if (texture_ != NULL) {
      SDL_DestroyTexture(texture_);
      texture_ = NULL;
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
  if (SDL_Init(A1.as_uint32_t()) < 0) {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}

PREDICATE(sdl_quit, 0) {
  SDL_Quit();
  return true;
}

PREDICATE(sdl_createwindow_, 7) {
  SDL_Window *window =
      SDL_CreateWindow(A2.as_string().c_str(), A3.as_int(), A4.as_int(), A5.as_int(),
                       A6.as_int(), A7.as_uint32_t());
  if (window == NULL) {
    throw PlUnknownError(SDL_GetError());
  }
  auto ref = std::unique_ptr<PlBlob>(new SDLWindowBlob(window));
  return A1.unify_blob(&ref);
}

PREDICATE(sdl_destroywindow, 1) {
  auto ref = PlBlobV<SDLWindowBlob>::cast_ex(A1, sdl_window_blob);
  ref->destroy();
  return true;
}

PREDICATE(sdl_createrenderer_, 4) {
  auto window_ref = PlBlobV<SDLWindowBlob>::cast_ex(A2, sdl_window_blob);
  SDL_Renderer *renderer =
      SDL_CreateRenderer(window_ref->window_, A3.as_int(), A4.as_uint32_t());
  if (renderer == NULL) {
    throw PlUnknownError(SDL_GetError());
  }
  auto ref = std::unique_ptr<PlBlob>(new SDLRendererBlob(renderer));
  return A1.unify_blob(&ref);
}

PREDICATE(sdl_destroyrenderer, 1) {
  auto ref = PlBlobV<SDLRendererBlob>::cast_ex(A1, sdl_renderer_blob);
  ref->destroy();
  return true;
}

PREDICATE(sdl_renderclear, 1) {
  auto ref = PlBlobV<SDLRendererBlob>::cast_ex(A1, sdl_renderer_blob);
  if (SDL_RenderClear(ref->renderer_) < 0) {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}

const SDL_Rect get_rect(PlTerm term) {
  const SDL_Rect rect = {term[1].as_int(), term[2].as_int(), term[3].as_int(),
                         term[4].as_int()};
  return rect;
}

PREDICATE(sdl_rendercopy_, 4) {
  SDL_Rect *srcrect_p = NULL;
  SDL_Rect srcrect;
  if (A3.is_compound()) {
    srcrect = get_rect(A3);
    srcrect_p = &srcrect;
  }
  SDL_Rect *dstrect_p = NULL;
  SDL_Rect dstrect;
  if (A4.is_compound()) {
    dstrect = get_rect(A4);
    dstrect_p = &dstrect;
  }
  auto texture_ref = PlBlobV<SDLTextureBlob>::cast_ex(A2, sdl_texture_blob);
  auto renderer_ref = PlBlobV<SDLRendererBlob>::cast_ex(A1, sdl_renderer_blob);
  if (SDL_RenderCopy(renderer_ref->renderer_, texture_ref->texture_, srcrect_p,
                     dstrect_p) < 0) {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}

PREDICATE(sdl_renderpresent, 1) {
  auto ref = PlBlobV<SDLRendererBlob>::cast_ex(A1, sdl_renderer_blob);
  SDL_RenderPresent(ref->renderer_);
  return true;
}

PREDICATE(img_init_, 2) {
  int result = IMG_Init(A2.as_uint32_t());
  return A1.unify_integer(result);
}

PREDICATE(img_quit, 0) {
  IMG_Quit();
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

PREDICATE(sdl_freesurface, 1) {
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
  auto ref = std::unique_ptr<PlBlob>(new SDLTextureBlob(texture));
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

bool get_quit_event(PlTerm term, SDL_QuitEvent quit) {
  PlTermv args(PlTerm_string("quit"), PlTerm_integer(quit.timestamp));
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
      button_event.type == SDL_MOUSEBUTTONDOWN ? "mousebuttondown" : "mousebuttonup";
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

bool get_key_event(PlTerm term, SDL_KeyboardEvent key) {
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

PREDICATE(sdl_pollevent_, 1) {
  SDL_Event event;
  bool res;
  if (SDL_PollEvent(&event)) {
    switch (event.type) {
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

PREDICATE(sdl_setrenderdrawcolor_, 5) {
  auto ref = PlBlobV<SDLRendererBlob>::cast_ex(A1, sdl_renderer_blob);
  if (SDL_SetRenderDrawColor(ref->renderer_, A2.as_uint(), A3.as_uint(),
                             A4.as_uint(), A5.as_uint()) < 0) {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}

PREDICATE(sdl_renderdrawrect_, 2) {
  const SDL_Rect rect = get_rect(A2);
  auto ref = PlBlobV<SDLRendererBlob>::cast_ex(A1, sdl_renderer_blob);
  if (SDL_RenderDrawRect(ref->renderer_, &rect) < 0) {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}

PREDICATE(sdl_renderfillrect_, 2) {
  const SDL_Rect rect = get_rect(A2);
  auto ref = PlBlobV<SDLRendererBlob>::cast_ex(A1, sdl_renderer_blob);
  if (SDL_RenderFillRect(ref->renderer_, &rect) < 0) {
    throw PlUnknownError(SDL_GetError());
  }
  return true;
}
