#ifndef SDL_BLOBS_H
#define SDL_BLOBS_H

#include <SDL3/SDL.h>
#include <SWI-cpp2.h>

// ---------------------------------------------------------------------------
// Shared blob types for the SDL3 bindings.
//
// Each PL_blob_t object is defined (via PL_BLOB_DEFINITION) in exactly one
// translation unit and extern-declared here so that every .cpp file linked
// into sdl.so shares the same PL_blob_t* pointer.  This is required for
// PlBlobV<T>::cast_ex, which validates blobs by pointer identity
// (type == ref->blob_t_): if each .cpp had its own static definition the
// pointers would differ and cross-module casts would fail.
//
// The blob types are auto-registered by SWI-Prolog the first time
// PL_unify_blob is called with a PL_blob_t whose magic field is
// PL_BLOB_MAGIC; no explicit PL_register_blob_type call is needed.
// ---------------------------------------------------------------------------

// --- SDL_window (defined in sdl_video.cpp) ---------------------------------
extern PL_blob_t sdl_window_blob;

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

// --- SDL_renderer (defined in sdl_render.cpp) -------------------------------
extern PL_blob_t sdl_renderer_blob;

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

// --- SDL_surface (defined in sdl_surface.cpp) -------------------------------
extern PL_blob_t sdl_surface_blob;

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

// --- SDL_texture (defined in sdl_render.cpp) --------------------------------
extern PL_blob_t sdl_texture_blob;

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

#endif // SDL_BLOBS_H
