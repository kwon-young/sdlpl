#include <SDL3/SDL.h>
#include <SDL3/SDL_gpu.h>
#include <SDL3_image/SDL_image.h>
#include <SWI-cpp2.h>
#include <algorithm>
#include <string>
#include <vector>
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

// ---------------------------------------------------------------------------
// SDL_gpu device
//
// SDL_gpu is SDL3's explicit GPU API (command buffers, render passes,
// graphics pipelines, vertex/index buffers).  It is a parallel API to
// SDL_Renderer: a window is claimed by a GPU device instead of having a
// renderer created for it.  The device is the root handle from which all
// other GPU resources are created; it owns no parent.
// ---------------------------------------------------------------------------

struct SDLGPUDeviceBlob;

static PL_blob_t sdl_gpu_device_blob =
    PL_BLOB_DEFINITION(SDLGPUDeviceBlob, "sdl_gpu_device_blob");

struct SDLGPUDeviceBlob : public PlBlob {
  SDL_GPUDevice *device_;
  // Atoms of windows claimed via SDL_ClaimWindowForGPUDevice.  Each entry
  // is a registered ref, pinning the window blob against Prolog GC for as
  // long as the device holds the claim (mirrors SDLRendererBlob::parent_).
  // SDL_DestroyGPUDevice releases all claimed windows on the SDL side; we
  // unregister the refs here afterwards so the window blobs become
  // collectable again.
  std::vector<PlAtom> claimed_windows_;

  explicit SDLGPUDeviceBlob() : PlBlob(&sdl_gpu_device_blob), device_(NULL) {}

  explicit SDLGPUDeviceBlob(SDL_GPUDevice *device)
      : PlBlob(&sdl_gpu_device_blob), device_(device) {}

  PL_BLOB_SIZE

  void portray(PlStream &strm) const {
    strm.printf("sdl_gpu_device_blob<%p>(%p)", this, device_);
  }

  // Claim bookkeeping: register the window atom so its blob cannot be GC'd
  // while the device holds the claim.  Returns false if the window is
  // already in the list (double-claim), true on success.
  bool claim_window(PlAtom window) {
    if (has_window(window)) {
      return false;
    }
    PlAtom w(window);
    w.register_ref();
    claimed_windows_.push_back(w);
    return true;
  }

  // Release bookkeeping: unregister the window atom.  Returns false if the
  // window is not currently claimed by this device.
  bool release_window(PlAtom window) {
    auto it = std::find_if(claimed_windows_.begin(), claimed_windows_.end(),
                           [&](const PlAtom &a) { return a == window; });
    if (it == claimed_windows_.end()) {
      return false;
    }
    it->unregister_ref();
    claimed_windows_.erase(it);
    return true;
  }

  bool has_window(PlAtom window) const {
    return std::any_of(claimed_windows_.begin(), claimed_windows_.end(),
                       [&](const PlAtom &a) { return a == window; });
  }

  void destroy() noexcept {
    if (device_ != NULL) {
      // SDL_DestroyGPUDevice releases all claimed windows on the SDL side.
      SDL_DestroyGPUDevice(device_);
      device_ = NULL;
    }
    for (PlAtom &a : claimed_windows_) {
      if (a.not_null()) {
        a.unregister_ref();
        a.set_null();
      }
    }
    claimed_windows_.clear();
  }

  virtual ~SDLGPUDeviceBlob() noexcept { destroy(); }
};

PREDICATE(sdl_gpu_device_blob_portray, 2) {
  auto ref = PlBlobV<SDLGPUDeviceBlob>::cast_ex(A2, sdl_gpu_device_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

// sdl_creategpudevice_(-Device, +FormatFlags:int, +Debug:bool, +Name)
// Name is the atom `null` (use the default driver) or a driver atom (vulkan,
// direct3d12, metal) obtained from sdl_getgpudriver/sdl_gpu_driver.  The atom
// is translated to a raw C string here, only at the SDL call boundary.
PREDICATE(sdl_creategpudevice_, 4) {
  SDL_GPUShaderFormat formats = (SDL_GPUShaderFormat)A2.as_uint32_t();
  bool debug = A3.as_bool();
  const char *name = nullptr;
  if (!(A4.is_atom() && A4.as_atom() == PlAtom("null"))) {
    PlAtom a = A4.as_atom();
    name = Plx_atom_nchars(a.unwrap(), nullptr);
  }
  SDL_GPUDevice *device = SDL_CreateGPUDevice(formats, debug, name);
  if (device == NULL) {
    throw PlUnknownError(SDL_GetError());
  }
  auto ref = std::unique_ptr<PlBlob>(new SDLGPUDeviceBlob(device));
  return A1.unify_blob(&ref);
}

PREDICATE(sdl_destroygpudevice_, 1) {
  auto ref = PlBlobV<SDLGPUDeviceBlob>::cast_ex(A1, sdl_gpu_device_blob);
  ref->destroy();
  return true;
}

// sdl_getnumgpudrivers(-Count)
// Returns the number of GPU drivers compiled into this SDL build.  Does
// not require SDL_Init.  On a Linux build this is typically 1 (vulkan);
// on Windows 2 (vulkan, direct3d12); on macOS 2 (vulkan, metal).
PREDICATE(sdl_getnumgpudrivers, 1) {
  return A1.unify_integer(SDL_GetNumGPUDrivers());
}

// sdl_getgpudriver(+Index, -Name)
// Returns the name of the compiled-in GPU driver at the given index, as a
// Prolog atom (e.g. vulkan, direct3d12, metal).  Drivers are ordered as SDL
// checks them during device creation.  Index ranges from 0 to
// sdl_getnumgpudrivers-1.
PREDICATE(sdl_getgpudriver, 2) {
  int index = A1.as_int();
  const char *name = SDL_GetGPUDriver(index);
  if (name == NULL) {
    throw PlUnknownError("SDL_GetGPUDriver: index out of range");
  }
  return A2.unify_atom(name);
}

// sdl_claimwindowforgpudevice_(+Device, +Window)
// Claims a window for GPU rendering, creating its swapchain.  The window
// must have been created with the `vulkan` (or `metal` on macOS) window flag
// matching the device's backend.  On success the window's blob atom is
// registered on the device, pinning it against Prolog GC for the claim's
// lifetime (mirrors SDLRendererBlob::parent_).  No new blob is produced —
// this is a state mutation on the existing window.
PREDICATE(sdl_claimwindowforgpudevice_, 2) {
  auto device_ref = PlBlobV<SDLGPUDeviceBlob>::cast_ex(A1, sdl_gpu_device_blob);
  auto window_ref = PlBlobV<SDLWindowBlob>::cast_ex(A2, sdl_window_blob);
  if (!SDL_ClaimWindowForGPUDevice(device_ref->device_, window_ref->window_)) {
    throw PlUnknownError(SDL_GetError());
  }
  if (!device_ref->claim_window(window_ref->symbol_)) {
    // SDL claimed it but our bookkeeping says we already track it — should
    // not happen.  Roll back the SDL claim to keep state consistent.
    SDL_ReleaseWindowFromGPUDevice(device_ref->device_, window_ref->window_);
    throw PlUnknownError("sdl_claimwindowforgpudevice: window already tracked");
  }
  return true;
}

// sdl_releasewindowfromgpudevice_(+Device, +Window)
// Releases a previously claimed window, destroying its swapchain.  Throws
// existence_error(claimed_window, Window) if the window is not currently
// claimed by this device (double-release or release-without-claim).  On
// success the window's blob atom is unregistered, allowing Prolog GC to
// collect it once no other references remain.  SDL_DestroyGPUDevice also
// releases all claimed windows automatically, so explicit release is only
// required to reclaim a window before device destruction.
PREDICATE(sdl_releasewindowfromgpudevice_, 2) {
  auto device_ref = PlBlobV<SDLGPUDeviceBlob>::cast_ex(A1, sdl_gpu_device_blob);
  auto window_ref = PlBlobV<SDLWindowBlob>::cast_ex(A2, sdl_window_blob);
  if (!device_ref->has_window(window_ref->symbol_)) {
    throw PlExistenceError("claimed_window", A2);
  }
  SDL_ReleaseWindowFromGPUDevice(device_ref->device_, window_ref->window_);
  device_ref->release_window(window_ref->symbol_);
  return true;
}

// ---------------------------------------------------------------------------
// SDL_gpu command buffer
//
// A command buffer is acquired per frame from a device, commands are
// recorded into it (render passes, copy passes, draws), and it is submitted
// to the GPU for execution.  SDL manages the command buffer memory: there is
// no SDL_DestroyGPUCommandBuffer.  The only disposal paths are
// SDL_SubmitGPUCommandBuffer (normal) and SDL_CancelGPUCommandBuffer
// (discard).  After either, the command buffer pointer is invalid to use.
//
// RAII: if a command buffer blob is garbage-collected without being
// submitted (e.g. an exception discarded it mid-frame), destroy() calls
// SDL_CancelGPUCommandBuffer to prevent a leak.  After a successful submit,
// the pointer is set to NULL so destroy() is a no-op (calling cancel on an
// already-submitted buffer would be invalid).
//
// The blob holds a parent ref to the device, preventing the device from
// being GC'd while a command buffer is live (mirrors SDLRendererBlob ->
// SDLWindowBlob).
// ---------------------------------------------------------------------------

struct SDLGPUCommandBufferBlob;

static PL_blob_t sdl_gpu_cmdbuf_blob =
    PL_BLOB_DEFINITION(SDLGPUCommandBufferBlob, "sdl_gpu_cmdbuf_blob");

struct SDLGPUCommandBufferBlob : public PlBlob {
  SDL_GPUCommandBuffer *cmdbuf_;
  PlAtom parent_;

  explicit SDLGPUCommandBufferBlob()
      : PlBlob(&sdl_gpu_cmdbuf_blob), cmdbuf_(NULL), parent_(PlAtom::null) {}

  explicit SDLGPUCommandBufferBlob(SDL_GPUCommandBuffer *cmdbuf, PlAtom device)
      : PlBlob(&sdl_gpu_cmdbuf_blob), cmdbuf_(cmdbuf), parent_(device) {
    parent_.register_ref();
  }

  PL_BLOB_SIZE

  void portray(PlStream &strm) const {
    strm.printf("sdl_gpu_cmdbuf_blob<%p>(%p)", this, cmdbuf_);
  }

  void destroy() noexcept {
    if (cmdbuf_ != NULL) {
      // Safety net: cancel unsubmitted command buffers to prevent leaks.
      // If the user already submitted, cmdbuf_ was set to NULL by
      // sdl_submitgpucommandbuffer_, so this path only fires for the
      // leak case (e.g. an exception discarded the cmdbuf before submit).
      SDL_CancelGPUCommandBuffer(cmdbuf_);
      cmdbuf_ = NULL;
    }
    if (parent_.not_null()) {
      parent_.unregister_ref();
      parent_.set_null();
    }
  }

  virtual ~SDLGPUCommandBufferBlob() noexcept { destroy(); }
};

PREDICATE(sdl_gpu_cmdbuf_blob_portray, 2) {
  auto ref = PlBlobV<SDLGPUCommandBufferBlob>::cast_ex(A2, sdl_gpu_cmdbuf_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

// sdl_acquiregpucommandbuffer_(-CmdBuf, +Device)
// Acquires a command buffer for recording GPU commands.  The command buffer
// may only be used on the thread that acquired it.  The returned blob holds
// a parent ref to the device, pinning it against GC for the command buffer's
// lifetime.
PREDICATE(sdl_acquiregpucommandbuffer_, 2) {
  auto device_ref = PlBlobV<SDLGPUDeviceBlob>::cast_ex(A2, sdl_gpu_device_blob);
  SDL_GPUCommandBuffer *cmdbuf =
      SDL_AcquireGPUCommandBuffer(device_ref->device_);
  if (cmdbuf == NULL) {
    throw PlUnknownError(SDL_GetError());
  }
  auto ref = std::unique_ptr<PlBlob>(
      new SDLGPUCommandBufferBlob(cmdbuf, device_ref->symbol_));
  return A1.unify_blob(&ref);
}

// sdl_submitgpucommandbuffer_(+CmdBuf)
// Submits the command buffer for GPU execution.  After submit the command
// buffer pointer is invalid; the blob's pointer is set to NULL so that
// destroy() (GC or explicit) is a no-op.  Calling submit on an already-
// submitted/cancelled buffer throws an error.
PREDICATE(sdl_submitgpucommandbuffer_, 1) {
  auto ref =
      PlBlobV<SDLGPUCommandBufferBlob>::cast_ex(A1, sdl_gpu_cmdbuf_blob);
  if (ref->cmdbuf_ == NULL) {
    throw PlExistenceError("command_buffer", A1);
  }
  if (!SDL_SubmitGPUCommandBuffer(ref->cmdbuf_)) {
    throw PlUnknownError(SDL_GetError());
  }
  // Mark as consumed: NULL the pointer so destroy() (GC or explicit) does
  // NOT call SDL_CancelGPUCommandBuffer on an already-submitted buffer.
  ref->cmdbuf_ = NULL;
  return true;
}

// sdl_cancelgpucommandbuffer_(+CmdBuf)
// Cancels the command buffer, discarding all recorded commands.  After
// cancel the command buffer pointer is invalid; the blob's pointer is set
// to NULL so that destroy() (GC or explicit) is a no-op.  Calling cancel on
// an already-submitted/cancelled buffer throws an error.  This is the
// explicit counterpart to the implicit cancel that destroy() performs on
// unsubmitted command buffers during GC.
PREDICATE(sdl_cancelgpucommandbuffer_, 1) {
  auto ref =
      PlBlobV<SDLGPUCommandBufferBlob>::cast_ex(A1, sdl_gpu_cmdbuf_blob);
  if (ref->cmdbuf_ == NULL) {
    throw PlExistenceError("command_buffer", A1);
  }
  if (!SDL_CancelGPUCommandBuffer(ref->cmdbuf_)) {
    throw PlUnknownError(SDL_GetError());
  }
  // Mark as consumed: NULL the pointer so destroy() (GC or explicit) does
  // NOT call SDL_CancelGPUCommandBuffer again on an already-cancelled buffer.
  ref->cmdbuf_ = NULL;
  return true;
}

// ---------------------------------------------------------------------------
// SDL_gpu swapchain texture
//
// A swapchain texture is acquired from a command buffer + claimed window
// each frame.  It is the render target that will be presented to the screen
// when the command buffer is submitted.  The texture is managed by SDL: it
// must NOT be freed by the user (no SDL_ReleaseGPUTexture).  It is valid
// only within the command buffer that acquired it, and is write-only.
//
// The texture handle may be NULL (e.g. window minimized, or too many frames
// in flight for the non-blocking variant).  This is not an error; the caller
// should skip rendering that frame.  A NULL texture is represented in Prolog
// as the atom `null`.
//
// RAII: the blob is a non-owning view (like PtrBlob).  destroy() is a no-op
// — SDL reclaims the texture when the command buffer is submitted.  The blob
// holds a parent ref to the command buffer, preventing it from being GC'd
// (or auto-cancelled) while a swapchain texture view is still live.
// ---------------------------------------------------------------------------

struct SDLGPUSwapchainTextureBlob;

static PL_blob_t sdl_gpu_swapchain_texture_blob =
    PL_BLOB_DEFINITION(SDLGPUSwapchainTextureBlob,
                       "sdl_gpu_swapchain_texture_blob");

struct SDLGPUSwapchainTextureBlob : public PlBlob {
  SDL_GPUTexture *texture_;
  PlAtom parent_;

  explicit SDLGPUSwapchainTextureBlob()
      : PlBlob(&sdl_gpu_swapchain_texture_blob), texture_(NULL),
        parent_(PlAtom::null) {}

  explicit SDLGPUSwapchainTextureBlob(SDL_GPUTexture *texture, PlAtom cmdbuf)
      : PlBlob(&sdl_gpu_swapchain_texture_blob), texture_(texture),
        parent_(cmdbuf) {
    parent_.register_ref();
  }

  PL_BLOB_SIZE

  void portray(PlStream &strm) const {
    strm.printf("sdl_gpu_swapchain_texture_blob<%p>(%p)", this, texture_);
  }

  void destroy() noexcept {
    // Non-owning: do NOT free texture_.  SDL reclaims it on command buffer
    // submit.  Just release the parent ref.
    texture_ = NULL;
    if (parent_.not_null()) {
      parent_.unregister_ref();
      parent_.set_null();
    }
  }

  virtual ~SDLGPUSwapchainTextureBlob() noexcept { destroy(); }
};

PREDICATE(sdl_gpu_swapchain_texture_blob_portray, 2) {
  auto ref = PlBlobV<SDLGPUSwapchainTextureBlob>::cast_ex(
      A2, sdl_gpu_swapchain_texture_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

// Helper: acquire swapchain texture (shared logic for both blocking and
// non-blocking variants).  A1 = CmdBuf, A2 = Window, A3 = Texture out,
// A4 = Width out, A5 = Height out.  fn is the SDL acquire function.
static bool acquire_swapchain(PlTermv av,
                              bool (*fn)(SDL_GPUCommandBuffer *,
                                         SDL_Window *, SDL_GPUTexture **,
                                         Uint32 *, Uint32 *)) {
  auto cmdbuf_ref =
      PlBlobV<SDLGPUCommandBufferBlob>::cast_ex(av[0], sdl_gpu_cmdbuf_blob);
  if (cmdbuf_ref->cmdbuf_ == NULL) {
    throw PlExistenceError("command_buffer", av[0]);
  }
  auto window_ref = PlBlobV<SDLWindowBlob>::cast_ex(av[1], sdl_window_blob);
  SDL_GPUTexture *texture = NULL;
  Uint32 width = 0, height = 0;
  if (!fn(cmdbuf_ref->cmdbuf_, window_ref->window_, &texture, &width,
          &height)) {
    throw PlUnknownError(SDL_GetError());
  }
  bool ok;
  if (texture == NULL) {
    // Window minimized or too many frames in flight — not an error.
    ok = av[2].unify_atom("null");
  } else {
    auto ref = std::unique_ptr<PlBlob>(
        new SDLGPUSwapchainTextureBlob(texture, cmdbuf_ref->symbol_));
    ok = av[2].unify_blob(&ref);
  }
  ok = ok && av[3].unify_integer(width);
  ok = ok && av[4].unify_integer(height);
  return ok;
}

// sdl_acquiregpuswapchaintexture_(+CmdBuf, +Window, -Texture, -W, -H)
// Non-blocking: may return `null` for Texture if too many frames are in
// flight.  In that case, skip rendering and submit the empty command buffer
// (or wait and retry next frame).
PREDICATE(sdl_acquiregpuswapchaintexture_, 5) {
  PlTermv av(A1, A2, A3, A4, A5);
  return acquire_swapchain(av, SDL_AcquireGPUSwapchainTexture);
}

// sdl_waitandacquiregpuswapchaintexture_(+CmdBuf, +Window, -Texture, -W, -H)
// Blocking: waits until a swapchain texture is available, then acquires it.
// May still return `null` for Texture if the window is minimized.
PREDICATE(sdl_waitandacquiregpuswapchaintexture_, 5) {
  PlTermv av(A1, A2, A3, A4, A5);
  return acquire_swapchain(av, SDL_WaitAndAcquireGPUSwapchainTexture);
}

// ---------------------------------------------------------------------------
// SDL_gpu render pass
//
// A render pass is begun on a command buffer, targeting one or more color
// textures (typically the swapchain texture).  All drawing commands must
// take place inside a render pass.  The render pass is ended with
// SDL_EndGPURenderPass, after which the handle is invalid.
//
// RAII: the render pass is managed by SDL (no destroy function).  If the
// blob is GC'd without being explicitly ended, destroy() calls
// SDL_EndGPURenderPass as a safety net (same pattern as command buffer's
// auto-cancel).  After explicit end, the pointer is set to NULL so
// destroy() is a no-op.  The blob holds a parent ref to the command buffer.
// ---------------------------------------------------------------------------

struct SDLGPURenderPassBlob;

static PL_blob_t sdl_gpu_renderpass_blob =
    PL_BLOB_DEFINITION(SDLGPURenderPassBlob, "sdl_gpu_renderpass_blob");

struct SDLGPURenderPassBlob : public PlBlob {
  SDL_GPURenderPass *pass_;
  PlAtom parent_;

  explicit SDLGPURenderPassBlob()
      : PlBlob(&sdl_gpu_renderpass_blob), pass_(NULL), parent_(PlAtom::null) {}

  explicit SDLGPURenderPassBlob(SDL_GPURenderPass *pass, PlAtom cmdbuf)
      : PlBlob(&sdl_gpu_renderpass_blob), pass_(pass), parent_(cmdbuf) {
    parent_.register_ref();
  }

  PL_BLOB_SIZE

  void portray(PlStream &strm) const {
    strm.printf("sdl_gpu_renderpass_blob<%p>(%p)", this, pass_);
  }

  void destroy() noexcept {
    if (pass_ != NULL) {
      // Safety net: end unended render passes to keep SDL state consistent.
      SDL_EndGPURenderPass(pass_);
      pass_ = NULL;
    }
    if (parent_.not_null()) {
      parent_.unregister_ref();
      parent_.set_null();
    }
  }

  virtual ~SDLGPURenderPassBlob() noexcept { destroy(); }
};

PREDICATE(sdl_gpu_renderpass_blob_portray, 2) {
  auto ref =
      PlBlobV<SDLGPURenderPassBlob>::cast_ex(A2, sdl_gpu_renderpass_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

// ---------------------------------------------------------------------------
// SDL_gpu texture (user-created)
//
// Created via SDL_CreateGPUTexture with a texture create info struct, and
// released via SDL_ReleaseGPUTexture.  The blob stores both the texture and
// device pointers (release needs both), and holds a parent ref to the device
// for GC safety.  destroy() calls SDL_ReleaseGPUTexture, so the texture is
// automatically freed if the blob is garbage-collected.
// ---------------------------------------------------------------------------

struct SDLGPUTextureBlob;

static PL_blob_t sdl_gpu_texture_blob =
    PL_BLOB_DEFINITION(SDLGPUTextureBlob, "sdl_gpu_texture_blob");

struct SDLGPUTextureBlob : public PlBlob {
  SDL_GPUTexture *texture_;
  SDL_GPUDevice *device_;
  PlAtom parent_;

  explicit SDLGPUTextureBlob()
      : PlBlob(&sdl_gpu_texture_blob), texture_(NULL), device_(NULL),
        parent_(PlAtom::null) {}

  explicit SDLGPUTextureBlob(SDL_GPUTexture *texture, SDL_GPUDevice *device,
                            PlAtom parent)
      : PlBlob(&sdl_gpu_texture_blob), texture_(texture), device_(device),
        parent_(parent) {
    parent_.register_ref();
  }

  PL_BLOB_SIZE

  void portray(PlStream &strm) const {
    strm.printf("sdl_gpu_texture_blob<%p>(%p)", this, texture_);
  }

  void destroy() noexcept {
    if (texture_ != NULL) {
      SDL_ReleaseGPUTexture(device_, texture_);
      texture_ = NULL;
    }
    device_ = NULL;
    if (parent_.not_null()) {
      parent_.unregister_ref();
      parent_.set_null();
    }
  }

  virtual ~SDLGPUTextureBlob() noexcept { destroy(); }
};

PREDICATE(sdl_gpu_texture_blob_portray, 2) {
  auto ref = PlBlobV<SDLGPUTextureBlob>::cast_ex(A2, sdl_gpu_texture_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

// Helper: parse a gpu_texture_create_info/8 compound into
// SDL_GPUTextureCreateInfo.  The compound fields are already translated to
// int values by the Prolog layer (Type, Format, Usage, SampleCount).
static SDL_GPUTextureCreateInfo get_texture_create_info(PlTerm term) {
  SDL_GPUTextureCreateInfo info;
  info.type = (SDL_GPUTextureType)term[1].as_int();
  info.format = (SDL_GPUTextureFormat)term[2].as_uint32_t();
  info.usage = (SDL_GPUTextureUsageFlags)term[3].as_uint32_t();
  info.width = term[4].as_uint32_t();
  info.height = term[5].as_uint32_t();
  info.layer_count_or_depth = term[6].as_uint32_t();
  info.num_levels = term[7].as_uint32_t();
  info.sample_count = (SDL_GPUSampleCount)term[8].as_int();
  info.props = 0;
  return info;
}

// sdl_creategputexture_(-Texture, +Device, +CreateInfo)
// CreateInfo is a gpu_texture_create_info/8 compound with int values for
// enum/flag fields (translated by the Prolog wrapper).  The blob holds a
// parent ref to the device.
PREDICATE(sdl_creategputexture_, 3) {
  auto device_ref = PlBlobV<SDLGPUDeviceBlob>::cast_ex(A2, sdl_gpu_device_blob);
  SDL_GPUTextureCreateInfo info = get_texture_create_info(A3);
  SDL_GPUTexture *texture =
      SDL_CreateGPUTexture(device_ref->device_, &info);
  if (texture == NULL) {
    throw PlUnknownError(SDL_GetError());
  }
  auto ref = std::unique_ptr<PlBlob>(
      new SDLGPUTextureBlob(texture, device_ref->device_,
                            device_ref->symbol_));
  return A1.unify_blob(&ref);
}

// sdl_releasegputexture_(+Texture)
// Releases the GPU texture.  After release the texture pointer is invalid;
// the blob's pointer is set to NULL so destroy() is a no-op.  Calling
// release on an already-released texture throws existence_error.
PREDICATE(sdl_releasegputexture_, 1) {
  auto ref = PlBlobV<SDLGPUTextureBlob>::cast_ex(A1, sdl_gpu_texture_blob);
  if (ref->texture_ == NULL) {
    throw PlExistenceError("texture", A1);
  }
  SDL_ReleaseGPUTexture(ref->device_, ref->texture_);
  ref->texture_ = NULL;
  ref->device_ = NULL;
  return true;
}

// Helper: extract SDL_GPUTexture* from a swapchain texture blob or a regular
// GPU texture blob term.  We check the blob type pointer directly (instead of
// PlBlobV::cast) because cast() calls PL_api_error on size mismatch when the
// blob_t_ member matches but the C++ type doesn't — that aborts rather than
// allowing a fallback to the next type check.
static SDL_GPUTexture *get_gpu_texture(PlTerm term) {
  size_t len;
  PL_blob_t *type;
  void *data = term.as_atom().blob_data(&len, &type);
  if (!data) {
    throw PlTypeError("sdl_gpu_texture", term);
  }
  if (type == &sdl_gpu_swapchain_texture_blob) {
    return static_cast<SDLGPUSwapchainTextureBlob *>(data)->texture_;
  }
  if (type == &sdl_gpu_texture_blob) {
    return static_cast<SDLGPUTextureBlob *>(data)->texture_;
  }
  throw PlTypeError("sdl_gpu_texture", term);
}

// Helper: parse an fcolor(R,G,B,A) compound into SDL_FColor.
static SDL_FColor get_fcolor(PlTerm term) {
  return SDL_FColor{(float)term[1].as_float(), (float)term[2].as_float(),
                    (float)term[3].as_float(), (float)term[4].as_float()};
}

// Helper: parse a color_target/11 compound into SDL_GPUColorTargetInfo.
static SDL_GPUColorTargetInfo get_color_target_info(PlTerm term) {
  SDL_GPUColorTargetInfo info;
  info.texture = get_gpu_texture(term[1]);
  info.mip_level = term[2].as_uint32_t();
  info.layer_or_depth_plane = term[3].as_uint32_t();
  info.clear_color = get_fcolor(term[4]);
  info.load_op = (SDL_GPULoadOp)term[5].as_int();
  info.store_op = (SDL_GPUStoreOp)term[6].as_int();
  // resolve_texture: null or a GPU texture blob
  if (term[7].is_atom() && term[7].as_atom() == PlAtom("null")) {
    info.resolve_texture = NULL;
  } else {
    info.resolve_texture = get_gpu_texture(term[7]);
  }
  info.resolve_mip_level = term[8].as_uint32_t();
  info.resolve_layer = term[9].as_uint32_t();
  info.cycle = term[10].as_bool();
  info.cycle_resolve_texture = term[11].as_bool();
  info.padding1 = 0;
  info.padding2 = 0;
  return info;
}

// Helper: parse a depth_stencil_target/9 compound into
// SDL_GPUDepthStencilTargetInfo.
static SDL_GPUDepthStencilTargetInfo get_depth_stencil_target_info(PlTerm term) {
  SDL_GPUDepthStencilTargetInfo info;
  info.texture = get_gpu_texture(term[1]);
  info.clear_depth = term[2].as_float();
  info.load_op = (SDL_GPULoadOp)term[3].as_int();
  info.store_op = (SDL_GPUStoreOp)term[4].as_int();
  info.stencil_load_op = (SDL_GPULoadOp)term[5].as_int();
  info.stencil_store_op = (SDL_GPUStoreOp)term[6].as_int();
  info.cycle = term[7].as_bool();
  info.clear_stencil = term[8].as_uint();
  info.mip_level = term[9].as_uint();
  info.layer = term[10].as_uint();
  return info;
}

// sdl_begingpurenderpass_(-RenderPass, +CmdBuf, +ColorTargets, +DepthStencil)
// ColorTargets is a Prolog list of color_target/11 terms.  DepthStencil is
// the atom `null` (no depth-stencil target) or a depth_stencil_target/10
// compound.  The render pass blob holds a parent ref to the command buffer.
PREDICATE(sdl_begingpurenderpass_, 4) {
  auto cmdbuf_ref =
      PlBlobV<SDLGPUCommandBufferBlob>::cast_ex(A2, sdl_gpu_cmdbuf_blob);
  if (cmdbuf_ref->cmdbuf_ == NULL) {
    throw PlExistenceError("command_buffer", A2);
  }
  // Parse color target list using PlTerm_tail for idiomatic iteration.
  std::vector<SDL_GPUColorTargetInfo> targets;
  PlTerm_tail tail(A3);
  PlTerm_var element;
  while (tail.next(element)) {
    targets.push_back(get_color_target_info(element));
  }
  // Depth stencil: null or depth_stencil_target/10 compound.
  SDL_GPUDepthStencilTargetInfo depth_info;
  const SDL_GPUDepthStencilTargetInfo *depth = NULL;
  if (A4.is_atom() && A4.as_atom() == PlAtom("null")) {
    depth = NULL;
  } else {
    depth_info = get_depth_stencil_target_info(A4);
    depth = &depth_info;
  }
  SDL_GPURenderPass *pass = SDL_BeginGPURenderPass(
      cmdbuf_ref->cmdbuf_, targets.data(), (Uint32)targets.size(), depth);
  if (pass == NULL) {
    throw PlUnknownError(SDL_GetError());
  }
  auto ref = std::unique_ptr<PlBlob>(
      new SDLGPURenderPassBlob(pass, cmdbuf_ref->symbol_));
  return A1.unify_blob(&ref);
}

// sdl_endgpurenderpass_(+RenderPass)
// Ends the render pass.  After end the handle is invalid; the blob's
// pointer is set to NULL so destroy() is a no-op.  Calling end on an
// already-ended render pass throws existence_error.
PREDICATE(sdl_endgpurenderpass_, 1) {
  auto ref =
      PlBlobV<SDLGPURenderPassBlob>::cast_ex(A1, sdl_gpu_renderpass_blob);
  if (ref->pass_ == NULL) {
    throw PlExistenceError("render_pass", A1);
  }
  SDL_EndGPURenderPass(ref->pass_);
  ref->pass_ = NULL;
  return true;
}

// ---------------------------------------------------------------------------
// SDL_gpu shader
//
// Created via SDL_CreateGPUShader with a shader create info struct, and
// released via SDL_ReleaseGPUShader.  The blob stores both the shader and
// device pointers (release needs both), and holds a parent ref to the device
// for GC safety.  destroy() calls SDL_ReleaseGPUShader, so the shader is
// automatically freed if the blob is garbage-collected.
//
// Shader bytecode (e.g. SPIR-V for Vulkan) is passed as a Prolog string.
// The C++ layer uses PL_get_nchars to extract the raw bytes and length,
// since SPIR-V is binary data that may contain null bytes.
// ---------------------------------------------------------------------------

struct SDLGPUShaderBlob;

static PL_blob_t sdl_gpu_shader_blob =
    PL_BLOB_DEFINITION(SDLGPUShaderBlob, "sdl_gpu_shader_blob");

struct SDLGPUShaderBlob : public PlBlob {
  SDL_GPUShader *shader_;
  SDL_GPUDevice *device_;
  PlAtom parent_;

  explicit SDLGPUShaderBlob()
      : PlBlob(&sdl_gpu_shader_blob), shader_(NULL), device_(NULL),
        parent_(PlAtom::null) {}

  explicit SDLGPUShaderBlob(SDL_GPUShader *shader, SDL_GPUDevice *device,
                            PlAtom parent)
      : PlBlob(&sdl_gpu_shader_blob), shader_(shader), device_(device),
        parent_(parent) {
    parent_.register_ref();
  }

  PL_BLOB_SIZE

  void portray(PlStream &strm) const {
    strm.printf("sdl_gpu_shader_blob<%p>(%p)", this, shader_);
  }

  void destroy() noexcept {
    if (shader_ != NULL) {
      SDL_ReleaseGPUShader(device_, shader_);
      shader_ = NULL;
    }
    device_ = NULL;
    if (parent_.not_null()) {
      parent_.unregister_ref();
      parent_.set_null();
    }
  }

  virtual ~SDLGPUShaderBlob() noexcept { destroy(); }
};

PREDICATE(sdl_gpu_shader_blob_portray, 2) {
  auto ref = PlBlobV<SDLGPUShaderBlob>::cast_ex(A2, sdl_gpu_shader_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

// sdl_creategpushader_(-Shader, +Device, +CreateInfo)
// CreateInfo is a gpu_shader_create_info/8 compound with int values for
// format and stage (translated by the Prolog wrapper).  The code field is
// a Prolog string containing raw shader bytecode (e.g. SPIR-V).
PREDICATE(sdl_creategpushader_, 3) {
  auto device_ref = PlBlobV<SDLGPUDeviceBlob>::cast_ex(A2, sdl_gpu_device_blob);

  SDL_GPUShaderCreateInfo info;
  // code: extract raw bytes + length from the Prolog string.  SPIR-V is
  // binary and may contain null bytes, so we use PL_get_string_chars (C API)
  // which gives both pointer and length without stopping at null bytes.
  size_t code_size;
  char *code_data;
  if (!PL_get_string(A3[1].unwrap(), &code_data, &code_size)) {
    throw PlTypeError("string", A3[1]);
  }
  info.code_size = code_size;
  info.code = (const Uint8 *)code_data;
  // entrypoint: normal text string
  info.entrypoint = A3[2].as_string().c_str();
  // format, stage (already translated to ints by Prolog wrapper)
  info.format = (SDL_GPUShaderFormat)A3[3].as_uint32_t();
  info.stage = (SDL_GPUShaderStage)A3[4].as_int();
  info.num_samplers = A3[5].as_uint32_t();
  info.num_storage_textures = A3[6].as_uint32_t();
  info.num_storage_buffers = A3[7].as_uint32_t();
  info.num_uniform_buffers = A3[8].as_uint32_t();
  info.props = 0;

  SDL_GPUShader *shader = SDL_CreateGPUShader(device_ref->device_, &info);
  if (shader == NULL) {
    throw PlUnknownError(SDL_GetError());
  }
  auto ref = std::unique_ptr<PlBlob>(
      new SDLGPUShaderBlob(shader, device_ref->device_,
                           device_ref->symbol_));
  return A1.unify_blob(&ref);
}

// sdl_releasegpushader_(+Shader)
// Releases the GPU shader.  After release the shader pointer is invalid;
// the blob's pointer is set to NULL so destroy() is a no-op.  Calling
// release on an already-released shader throws existence_error.
PREDICATE(sdl_releasegpushader_, 1) {
  auto ref = PlBlobV<SDLGPUShaderBlob>::cast_ex(A1, sdl_gpu_shader_blob);
  if (ref->shader_ == NULL) {
    throw PlExistenceError("shader", A1);
  }
  SDL_ReleaseGPUShader(ref->device_, ref->shader_);
  ref->shader_ = NULL;
  ref->device_ = NULL;
  return true;
}

// ---------------------------------------------------------------------------
// SDL_gpu graphics pipeline
//
// Created via SDL_CreateGPUGraphicsPipeline with a deeply nested create info
// struct, and released via SDL_ReleaseGPUGraphicsPipeline.  The blob stores
// both the pipeline and device pointers (release needs both), and holds a
// parent ref to the device for GC safety.  destroy() calls
// SDL_ReleaseGPUGraphicsPipeline, so the pipeline is automatically freed if
// the blob is garbage-collected.
// ---------------------------------------------------------------------------

struct SDLGPUGraphicsPipelineBlob;

static PL_blob_t sdl_gpu_pipeline_blob =
    PL_BLOB_DEFINITION(SDLGPUGraphicsPipelineBlob, "sdl_gpu_pipeline_blob");

struct SDLGPUGraphicsPipelineBlob : public PlBlob {
  SDL_GPUGraphicsPipeline *pipeline_;
  SDL_GPUDevice *device_;
  PlAtom parent_;

  explicit SDLGPUGraphicsPipelineBlob()
      : PlBlob(&sdl_gpu_pipeline_blob), pipeline_(NULL), device_(NULL),
        parent_(PlAtom::null) {}

  explicit SDLGPUGraphicsPipelineBlob(SDL_GPUGraphicsPipeline *pipeline,
                                      SDL_GPUDevice *device, PlAtom parent)
      : PlBlob(&sdl_gpu_pipeline_blob), pipeline_(pipeline), device_(device),
        parent_(parent) {
    parent_.register_ref();
  }

  PL_BLOB_SIZE

  void portray(PlStream &strm) const {
    strm.printf("sdl_gpu_pipeline_blob<%p>(%p)", this, pipeline_);
  }

  void destroy() noexcept {
    if (pipeline_ != NULL) {
      SDL_ReleaseGPUGraphicsPipeline(device_, pipeline_);
      pipeline_ = NULL;
    }
    device_ = NULL;
    if (parent_.not_null()) {
      parent_.unregister_ref();
      parent_.set_null();
    }
  }

  virtual ~SDLGPUGraphicsPipelineBlob() noexcept { destroy(); }
};

PREDICATE(sdl_gpu_pipeline_blob_portray, 2) {
  auto ref =
      PlBlobV<SDLGPUGraphicsPipelineBlob>::cast_ex(A2, sdl_gpu_pipeline_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

// Helper: get a shader pointer from a shader blob term.
static SDL_GPUShader *get_gpu_shader(PlTerm term) {
  auto ref = PlBlobV<SDLGPUShaderBlob>::cast_ex(term, sdl_gpu_shader_blob);
  return ref->shader_;
}

// Helper: parse a vertex_buffer_description/4 compound (int values).
static SDL_GPUVertexBufferDescription get_vertex_buffer_desc(PlTerm term) {
  SDL_GPUVertexBufferDescription desc;
  desc.slot = term[1].as_uint32_t();
  desc.pitch = term[2].as_uint32_t();
  desc.input_rate = (SDL_GPUVertexInputRate)term[3].as_int();
  desc.instance_step_rate = term[4].as_uint32_t();
  return desc;
}

// Helper: parse a vertex_attribute/4 compound (int values).
static SDL_GPUVertexAttribute get_vertex_attribute(PlTerm term) {
  SDL_GPUVertexAttribute attr;
  attr.location = term[1].as_uint32_t();
  attr.buffer_slot = term[2].as_uint32_t();
  attr.format = (SDL_GPUVertexElementFormat)term[3].as_uint32_t();
  attr.offset = term[4].as_uint32_t();
  return attr;
}

// Helper: parse a stencil_op_state/4 compound (int values).
static SDL_GPUStencilOpState get_stencil_op_state(PlTerm term) {
  SDL_GPUStencilOpState state;
  state.fail_op = (SDL_GPUStencilOp)term[1].as_int();
  state.pass_op = (SDL_GPUStencilOp)term[2].as_int();
  state.depth_fail_op = (SDL_GPUStencilOp)term[3].as_int();
  state.compare_op = (SDL_GPUCompareOp)term[4].as_int();
  return state;
}

// Helper: parse a color_target_blend_state/9 compound (int values).
static SDL_GPUColorTargetBlendState get_blend_state(PlTerm term) {
  SDL_GPUColorTargetBlendState state;
  state.src_color_blendfactor = (SDL_GPUBlendFactor)term[1].as_int();
  state.dst_color_blendfactor = (SDL_GPUBlendFactor)term[2].as_int();
  state.color_blend_op = (SDL_GPUBlendOp)term[3].as_int();
  state.src_alpha_blendfactor = (SDL_GPUBlendFactor)term[4].as_int();
  state.dst_alpha_blendfactor = (SDL_GPUBlendFactor)term[5].as_int();
  state.alpha_blend_op = (SDL_GPUBlendOp)term[6].as_int();
  state.color_write_mask = (SDL_GPUColorComponentFlags)term[7].as_uint();
  state.enable_blend = term[8].as_bool();
  state.enable_color_write_mask = term[9].as_bool();
  state.padding1 = 0;
  state.padding2 = 0;
  return state;
}

// Helper: parse a color_target_description/2 compound (int values).
// color_target_description(Format:int, BlendState)
static SDL_GPUColorTargetDescription get_color_target_desc(PlTerm term) {
  SDL_GPUColorTargetDescription desc;
  desc.format = (SDL_GPUTextureFormat)term[1].as_uint32_t();
  desc.blend_state = get_blend_state(term[2]);
  return desc;
}

// Helper: parse a list of compounds into a vector via PlTerm_tail.
template <typename T, T (*parser)(PlTerm)>
static std::vector<T> parse_list(PlTerm list_term) {
  std::vector<T> items;
  PlTerm_tail tail(list_term);
  PlTerm_var element;
  while (tail.next(element)) {
    items.push_back(parser(element));
  }
  return items;
}

// sdl_creategpugraphicspipeline_(-Pipeline, +Device, +CreateInfo)
// CreateInfo is a gpu_graphics_pipeline_create_info/8 compound with int
// values (translated by the Prolog wrapper).  The nested sub-structs are:
//   vertex_input_state(VertexBuffers, VertexAttributes)
//   rasterizer_state(FillMode, CullMode, FrontFace, DepthBiasConstantFactor,
//                    DepthBiasClamp, DepthBiasSlopeFactor,
//                    EnableDepthBias, EnableDepthClip)
//   multisample_state(SampleCount, SampleMask, EnableMask,
//                     EnableAlphaToCoverage)
//   depth_stencil_state(CompareOp, BackStencilState, FrontStencilState,
//                       CompareMask, WriteMask, EnableDepthTest,
//                       EnableDepthWrite, EnableStencilTest)
//   target_info(ColorTargetDescriptions, DepthStencilFormat,
//               HasDepthStencilTarget)
// where stencil_op_state(FailOp, PassOp, DepthFailOp, CompareOp) and
// color_target_blend_state(SrcColorBF, DstColorBF, ColorBlendOp,
//   SrcAlphaBF, DstAlphaBF, AlphaBlendOp, ColorWriteMask,
//   EnableBlend, EnableColorWriteMask).
PREDICATE(sdl_creategpugraphicspipeline_, 3) {
  auto device_ref = PlBlobV<SDLGPUDeviceBlob>::cast_ex(A2, sdl_gpu_device_blob);

  SDL_GPUGraphicsPipelineCreateInfo info;
  memset(&info, 0, sizeof(info));
  info.vertex_shader = get_gpu_shader(A3[1]);
  info.fragment_shader = get_gpu_shader(A3[2]);

  // vertex_input_state(VertexBuffers, VertexAttributes)
  PlTerm vi = A3[3];
  auto vbs = parse_list<SDL_GPUVertexBufferDescription, get_vertex_buffer_desc>(
      vi[1]);
  auto vas = parse_list<SDL_GPUVertexAttribute, get_vertex_attribute>(vi[2]);
  info.vertex_input_state.vertex_buffer_descriptions = vbs.data();
  info.vertex_input_state.num_vertex_buffers = (Uint32)vbs.size();
  info.vertex_input_state.vertex_attributes = vas.data();
  info.vertex_input_state.num_vertex_attributes = (Uint32)vas.size();

  info.primitive_type = (SDL_GPUPrimitiveType)A3[4].as_int();

  // rasterizer_state(FillMode, CullMode, FrontFace, DepthBiasConstantFactor,
  //                  DepthBiasClamp, DepthBiasSlopeFactor,
  //                  EnableDepthBias, EnableDepthClip)
  PlTerm rs = A3[5];
  info.rasterizer_state.fill_mode = (SDL_GPUFillMode)rs[1].as_int();
  info.rasterizer_state.cull_mode = (SDL_GPUCullMode)rs[2].as_int();
  info.rasterizer_state.front_face = (SDL_GPUFrontFace)rs[3].as_int();
  info.rasterizer_state.depth_bias_constant_factor = rs[4].as_float();
  info.rasterizer_state.depth_bias_clamp = rs[5].as_float();
  info.rasterizer_state.depth_bias_slope_factor = rs[6].as_float();
  info.rasterizer_state.enable_depth_bias = rs[7].as_bool();
  info.rasterizer_state.enable_depth_clip = rs[8].as_bool();
  info.rasterizer_state.padding1 = 0;
  info.rasterizer_state.padding2 = 0;

  // multisample_state(SampleCount, SampleMask, EnableMask,
  //                   EnableAlphaToCoverage)
  PlTerm ms = A3[6];
  info.multisample_state.sample_count = (SDL_GPUSampleCount)ms[1].as_int();
  info.multisample_state.sample_mask = ms[2].as_uint32_t();
  info.multisample_state.enable_mask = ms[3].as_bool();
  info.multisample_state.enable_alpha_to_coverage = ms[4].as_bool();
  info.multisample_state.padding2 = 0;
  info.multisample_state.padding3 = 0;

  // depth_stencil_state(CompareOp, BackStencilState, FrontStencilState,
  //                     CompareMask, WriteMask, EnableDepthTest,
  //                     EnableDepthWrite, EnableStencilTest)
  PlTerm ds = A3[7];
  info.depth_stencil_state.compare_op = (SDL_GPUCompareOp)ds[1].as_int();
  info.depth_stencil_state.back_stencil_state = get_stencil_op_state(ds[2]);
  info.depth_stencil_state.front_stencil_state = get_stencil_op_state(ds[3]);
  info.depth_stencil_state.compare_mask = ds[4].as_uint();
  info.depth_stencil_state.write_mask = ds[5].as_uint();
  info.depth_stencil_state.enable_depth_test = ds[6].as_bool();
  info.depth_stencil_state.enable_depth_write = ds[7].as_bool();
  info.depth_stencil_state.enable_stencil_test = ds[8].as_bool();
  info.depth_stencil_state.padding1 = 0;
  info.depth_stencil_state.padding2 = 0;
  info.depth_stencil_state.padding3 = 0;

  // target_info(ColorTargetDescriptions, DepthStencilFormat,
  //             HasDepthStencilTarget)
  PlTerm ti = A3[8];
  auto ctds =
      parse_list<SDL_GPUColorTargetDescription, get_color_target_desc>(ti[1]);
  info.target_info.color_target_descriptions = ctds.data();
  info.target_info.num_color_targets = (Uint32)ctds.size();
  info.target_info.depth_stencil_format =
      (SDL_GPUTextureFormat)ti[2].as_uint32_t();
  info.target_info.has_depth_stencil_target = ti[3].as_bool();
  info.target_info.padding1 = 0;
  info.target_info.padding2 = 0;
  info.target_info.padding3 = 0;

  info.props = 0;

  SDL_GPUGraphicsPipeline *pipeline =
      SDL_CreateGPUGraphicsPipeline(device_ref->device_, &info);
  if (pipeline == NULL) {
    throw PlUnknownError(SDL_GetError());
  }
  auto ref = std::unique_ptr<PlBlob>(
      new SDLGPUGraphicsPipelineBlob(pipeline, device_ref->device_,
                                     device_ref->symbol_));
  return A1.unify_blob(&ref);
}

// sdl_releasegpugraphicspipeline_(+Pipeline)
// Releases the graphics pipeline.  After release the pointer is invalid;
// the blob's pointer is set to NULL so destroy() is a no-op.  Calling
// release on an already-released pipeline throws existence_error.
PREDICATE(sdl_releasegpugraphicspipeline_, 1) {
  auto ref =
      PlBlobV<SDLGPUGraphicsPipelineBlob>::cast_ex(A1, sdl_gpu_pipeline_blob);
  if (ref->pipeline_ == NULL) {
    throw PlExistenceError("pipeline", A1);
  }
  SDL_ReleaseGPUGraphicsPipeline(ref->device_, ref->pipeline_);
  ref->pipeline_ = NULL;
  ref->device_ = NULL;
  return true;
}

// ---------------------------------------------------------------------------
// SDL_gpu buffer
//
// Created via SDL_CreateGPUBuffer with a buffer create info struct, and
// released via SDL_ReleaseGPUBuffer.  The blob stores both the buffer and
// device pointers (release needs both), and holds a parent ref to the device
// for GC safety.  destroy() calls SDL_ReleaseGPUBuffer, so the buffer is
// automatically freed if the blob is garbage-collected.
// ---------------------------------------------------------------------------

struct SDLGPUBufferBlob;

static PL_blob_t sdl_gpu_buffer_blob =
    PL_BLOB_DEFINITION(SDLGPUBufferBlob, "sdl_gpu_buffer_blob");

struct SDLGPUBufferBlob : public PlBlob {
  SDL_GPUBuffer *buffer_;
  SDL_GPUDevice *device_;
  PlAtom parent_;

  explicit SDLGPUBufferBlob()
      : PlBlob(&sdl_gpu_buffer_blob), buffer_(NULL), device_(NULL),
        parent_(PlAtom::null) {}

  explicit SDLGPUBufferBlob(SDL_GPUBuffer *buffer, SDL_GPUDevice *device,
                            PlAtom parent)
      : PlBlob(&sdl_gpu_buffer_blob), buffer_(buffer), device_(device),
        parent_(parent) {
    parent_.register_ref();
  }

  PL_BLOB_SIZE

  void portray(PlStream &strm) const {
    strm.printf("sdl_gpu_buffer_blob<%p>(%p)", this, buffer_);
  }

  void destroy() noexcept {
    if (buffer_ != NULL) {
      SDL_ReleaseGPUBuffer(device_, buffer_);
      buffer_ = NULL;
    }
    device_ = NULL;
    if (parent_.not_null()) {
      parent_.unregister_ref();
      parent_.set_null();
    }
  }

  virtual ~SDLGPUBufferBlob() noexcept { destroy(); }
};

PREDICATE(sdl_gpu_buffer_blob_portray, 2) {
  auto ref = PlBlobV<SDLGPUBufferBlob>::cast_ex(A2, sdl_gpu_buffer_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

// sdl_creategpubuffer_(-Buffer, +Device, +Usage:int, +Size:int)
PREDICATE(sdl_creategpubuffer_, 4) {
  auto device_ref = PlBlobV<SDLGPUDeviceBlob>::cast_ex(A2, sdl_gpu_device_blob);
  SDL_GPUBufferCreateInfo info;
  memset(&info, 0, sizeof(info));
  info.usage = (SDL_GPUBufferUsageFlags)A3.as_uint32_t();
  info.size = A4.as_uint32_t();
  SDL_GPUBuffer *buffer =
      SDL_CreateGPUBuffer(device_ref->device_, &info);
  if (buffer == NULL) {
    throw PlUnknownError(SDL_GetError());
  }
  auto ref = std::unique_ptr<PlBlob>(
      new SDLGPUBufferBlob(buffer, device_ref->device_,
                           device_ref->symbol_));
  return A1.unify_blob(&ref);
}

// sdl_releasegpubuffer_(+Buffer)
PREDICATE(sdl_releasegpubuffer_, 1) {
  auto ref = PlBlobV<SDLGPUBufferBlob>::cast_ex(A1, sdl_gpu_buffer_blob);
  if (ref->buffer_ == NULL) {
    throw PlExistenceError("buffer", A1);
  }
  SDL_ReleaseGPUBuffer(ref->device_, ref->buffer_);
  ref->buffer_ = NULL;
  ref->device_ = NULL;
  return true;
}

// ---------------------------------------------------------------------------
// SDL_gpu transfer buffer
//
// Created via SDL_CreateGPUTransferBuffer, released via
// SDL_ReleaseGPUTransferBuffer.  Transfer buffers are the staging area for
// uploading data to GPU buffers/textures (upload) or downloading from them
// (download).  The blob stores both the transfer buffer and device pointers
// (release needs both), and holds a parent ref to the device for GC safety.
// ---------------------------------------------------------------------------

struct SDLGPUTransferBufferBlob;

static PL_blob_t sdl_gpu_transfer_buffer_blob =
    PL_BLOB_DEFINITION(SDLGPUTransferBufferBlob,
                       "sdl_gpu_transfer_buffer_blob");

struct SDLGPUTransferBufferBlob : public PlBlob {
  SDL_GPUTransferBuffer *transfer_buffer_;
  SDL_GPUDevice *device_;
  PlAtom parent_;

  explicit SDLGPUTransferBufferBlob()
      : PlBlob(&sdl_gpu_transfer_buffer_blob), transfer_buffer_(NULL),
        device_(NULL), parent_(PlAtom::null) {}

  explicit SDLGPUTransferBufferBlob(SDL_GPUTransferBuffer *tb,
                                    SDL_GPUDevice *device, PlAtom parent)
      : PlBlob(&sdl_gpu_transfer_buffer_blob), transfer_buffer_(tb),
        device_(device), parent_(parent) {
    parent_.register_ref();
  }

  PL_BLOB_SIZE

  void portray(PlStream &strm) const {
    strm.printf("sdl_gpu_transfer_buffer_blob<%p>(%p)", this,
                transfer_buffer_);
  }

  void destroy() noexcept {
    if (transfer_buffer_ != NULL) {
      SDL_ReleaseGPUTransferBuffer(device_, transfer_buffer_);
      transfer_buffer_ = NULL;
    }
    device_ = NULL;
    if (parent_.not_null()) {
      parent_.unregister_ref();
      parent_.set_null();
    }
  }

  virtual ~SDLGPUTransferBufferBlob() noexcept { destroy(); }
};

PREDICATE(sdl_gpu_transfer_buffer_blob_portray, 2) {
  auto ref = PlBlobV<SDLGPUTransferBufferBlob>::cast_ex(
      A2, sdl_gpu_transfer_buffer_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

// sdl_creategputransferbuffer_(-TransferBuffer, +Device, +Usage:int, +Size:int)
PREDICATE(sdl_creategputransferbuffer_, 4) {
  auto device_ref = PlBlobV<SDLGPUDeviceBlob>::cast_ex(A2, sdl_gpu_device_blob);
  SDL_GPUTransferBufferCreateInfo info;
  memset(&info, 0, sizeof(info));
  info.usage = (SDL_GPUTransferBufferUsage)A3.as_int();
  info.size = A4.as_uint32_t();
  SDL_GPUTransferBuffer *tb =
      SDL_CreateGPUTransferBuffer(device_ref->device_, &info);
  if (tb == NULL) {
    throw PlUnknownError(SDL_GetError());
  }
  auto ref = std::unique_ptr<PlBlob>(
      new SDLGPUTransferBufferBlob(tb, device_ref->device_,
                                   device_ref->symbol_));
  return A1.unify_blob(&ref);
}

// sdl_releasegputransferbuffer_(+TransferBuffer)
PREDICATE(sdl_releasegputransferbuffer_, 1) {
  auto ref = PlBlobV<SDLGPUTransferBufferBlob>::cast_ex(
      A1, sdl_gpu_transfer_buffer_blob);
  if (ref->transfer_buffer_ == NULL) {
    throw PlExistenceError("transfer_buffer", A1);
  }
  SDL_ReleaseGPUTransferBuffer(ref->device_, ref->transfer_buffer_);
  ref->transfer_buffer_ = NULL;
  ref->device_ = NULL;
  return true;
}

// ---------------------------------------------------------------------------
// SDL_gpu transfer buffer map / unmap
//
// Maps a transfer buffer into application address space so vertex/index data
// can be written, then unmaps it.  The mapped pointer is returned as a
// PtrBlob (non-owning view, like sdl_locktexture).  The PtrBlob's parent is
// the transfer buffer blob, preventing GC from releasing the transfer buffer
// while the mapping is live.  The memory is owned by the driver — do NOT
// free it.  Must unmap before encoding upload commands.
// ---------------------------------------------------------------------------

// sdl_mapgputransferbuffer_(-Ptr, +TransferBuffer, +Cycle:bool)
PREDICATE(sdl_mapgputransferbuffer_, 3) {
  auto ref = PlBlobV<SDLGPUTransferBufferBlob>::cast_ex(
      A2, sdl_gpu_transfer_buffer_blob);
  if (ref->transfer_buffer_ == NULL) {
    throw PlExistenceError("transfer_buffer", A2);
  }
  bool cycle = A3.as_bool();
  void *ptr =
      SDL_MapGPUTransferBuffer(ref->device_, ref->transfer_buffer_, cycle);
  if (ptr == NULL) {
    throw PlUnknownError(SDL_GetError());
  }
  auto blob = std::unique_ptr<PlBlob>(
      new PtrBlob(ptr, ref->symbol_));
  return A1.unify_blob(&blob);
}

// sdl_unmapgputransferbuffer_(+TransferBuffer)
PREDICATE(sdl_unmapgputransferbuffer_, 1) {
  auto ref = PlBlobV<SDLGPUTransferBufferBlob>::cast_ex(
      A1, sdl_gpu_transfer_buffer_blob);
  if (ref->transfer_buffer_ == NULL) {
    throw PlExistenceError("transfer_buffer", A1);
  }
  SDL_UnmapGPUTransferBuffer(ref->device_, ref->transfer_buffer_);
  return true;
}

// ---------------------------------------------------------------------------
// SDL_gpu copy pass
//
// A copy pass is begun on a command buffer and is used for upload/download
// operations (SDL_UploadToGPUBuffer, SDL_UploadToGPUTexture, etc.).  The
// copy pass is ended with SDL_EndGPUCopyPass, after which the handle is
// invalid.
//
// RAII: the copy pass is managed by SDL (no destroy function).  If the blob
// is GC'd without being explicitly ended, destroy() calls SDL_EndGPUCopyPass
// as a safety net (same pattern as render pass).  After explicit end, the
// pointer is set to NULL so destroy() is a no-op.  The blob holds a parent
// ref to the command buffer.
// ---------------------------------------------------------------------------

struct SDLGPUCopyPassBlob;

static PL_blob_t sdl_gpu_copypass_blob =
    PL_BLOB_DEFINITION(SDLGPUCopyPassBlob, "sdl_gpu_copypass_blob");

struct SDLGPUCopyPassBlob : public PlBlob {
  SDL_GPUCopyPass *pass_;
  PlAtom parent_;

  explicit SDLGPUCopyPassBlob()
      : PlBlob(&sdl_gpu_copypass_blob), pass_(NULL), parent_(PlAtom::null) {}

  explicit SDLGPUCopyPassBlob(SDL_GPUCopyPass *pass, PlAtom cmdbuf)
      : PlBlob(&sdl_gpu_copypass_blob), pass_(pass), parent_(cmdbuf) {
    parent_.register_ref();
  }

  PL_BLOB_SIZE

  void portray(PlStream &strm) const {
    strm.printf("sdl_gpu_copypass_blob<%p>(%p)", this, pass_);
  }

  void destroy() noexcept {
    if (pass_ != NULL) {
      SDL_EndGPUCopyPass(pass_);
      pass_ = NULL;
    }
    if (parent_.not_null()) {
      parent_.unregister_ref();
      parent_.set_null();
    }
  }

  virtual ~SDLGPUCopyPassBlob() noexcept { destroy(); }
};

PREDICATE(sdl_gpu_copypass_blob_portray, 2) {
  auto ref = PlBlobV<SDLGPUCopyPassBlob>::cast_ex(A2, sdl_gpu_copypass_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

// sdl_begingpucopypass_(-CopyPass, +CmdBuf)
PREDICATE(sdl_begingpucopypass_, 2) {
  auto cmdbuf_ref =
      PlBlobV<SDLGPUCommandBufferBlob>::cast_ex(A2, sdl_gpu_cmdbuf_blob);
  if (cmdbuf_ref->cmdbuf_ == NULL) {
    throw PlExistenceError("command_buffer", A2);
  }
  SDL_GPUCopyPass *pass = SDL_BeginGPUCopyPass(cmdbuf_ref->cmdbuf_);
  if (pass == NULL) {
    throw PlUnknownError(SDL_GetError());
  }
  auto ref = std::unique_ptr<PlBlob>(
      new SDLGPUCopyPassBlob(pass, cmdbuf_ref->symbol_));
  return A1.unify_blob(&ref);
}

// sdl_endgpucopypass_(+CopyPass)
PREDICATE(sdl_endgpucopypass_, 1) {
  auto ref = PlBlobV<SDLGPUCopyPassBlob>::cast_ex(A1, sdl_gpu_copypass_blob);
  if (ref->pass_ == NULL) {
    throw PlExistenceError("copy_pass", A1);
  }
  SDL_EndGPUCopyPass(ref->pass_);
  ref->pass_ = NULL;
  return true;
}

// ---------------------------------------------------------------------------
// SDL_gpu upload to buffer
//
// Uploads data from a transfer buffer to a GPU buffer.  Must be called inside
// a copy pass.  The source is a transfer_buffer_location(TransferBuffer,
// Offset) compound and the destination is a buffer_region(Buffer, Offset,
// Size) compound.  No new blob is created — this is a command recorded into
// the copy pass.
// ---------------------------------------------------------------------------

// Helper: parse a transfer_buffer_location/2 compound.
static SDL_GPUTransferBufferLocation get_transfer_buffer_location(PlTerm term) {
  SDL_GPUTransferBufferLocation loc;
  auto ref = PlBlobV<SDLGPUTransferBufferBlob>::cast_ex(
      term[1], sdl_gpu_transfer_buffer_blob);
  loc.transfer_buffer = ref->transfer_buffer_;
  loc.offset = term[2].as_uint32_t();
  return loc;
}

// Helper: parse a buffer_region/3 compound.
static SDL_GPUBufferRegion get_buffer_region(PlTerm term) {
  SDL_GPUBufferRegion region;
  auto ref = PlBlobV<SDLGPUBufferBlob>::cast_ex(term[1], sdl_gpu_buffer_blob);
  region.buffer = ref->buffer_;
  region.offset = term[2].as_uint32_t();
  region.size = term[3].as_uint32_t();
  return region;
}

// sdl_uploadtogpubuffer_(+CopyPass, +Source, +Destination, +Cycle:bool)
PREDICATE(sdl_uploadtogpubuffer_, 4) {
  auto copypass_ref =
      PlBlobV<SDLGPUCopyPassBlob>::cast_ex(A1, sdl_gpu_copypass_blob);
  if (copypass_ref->pass_ == NULL) {
    throw PlExistenceError("copy_pass", A1);
  }
  SDL_GPUTransferBufferLocation source =
      get_transfer_buffer_location(A2);
  SDL_GPUBufferRegion destination = get_buffer_region(A3);
  bool cycle = A4.as_bool();
  SDL_UploadToGPUBuffer(copypass_ref->pass_, &source, &destination, cycle);
  return true;
}


