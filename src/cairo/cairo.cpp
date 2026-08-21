#include <cairo/cairo.h>
#include <SWI-cpp2.h>
#include <string>
#include "ptr.h"

// ---------------------------------------------------------------------------
// Cairo has two main handle types exposed here:
//
//   cairo_surface_t  -- a drawing target (here always an image surface, i.e.
//                       a CPU-side pixel buffer).
//   cairo_t          -- a drawing context.  It holds all graphics state
//                       (source colour, line width, antialias mode, the
//                       current path, ...) and is bound to a target surface
//                       at creation time.  cairo_create() takes its own
//                       reference on the surface, but we additionally keep a
//                       registered PlAtom reference to the surface blob so
//                       that Prolog GC can never collect the surface blob
//                       out from under a live context blob (Prolog GC order
//                       is not guaranteed).  This mirrors the
//                       SDLRendererBlob->window and SDLTextureBlob->renderer
//                       parent links in sdl.cpp.
//
// Each handle is wrapped in a PlBlob subclass with RAII semantics: the
// destructor / destroy() calls the matching cairo_*_destroy() and releases
// the parent reference.  Foreign predicates are named with a trailing
// underscore (e.g. cairo_create_/2); the Prolog side in prolog/cairo.pl
// provides the public name without the underscore after type-checking.
// ---------------------------------------------------------------------------

struct CairoSurfaceBlob;

static PL_blob_t cairo_surface_blob =
    PL_BLOB_DEFINITION(CairoSurfaceBlob, "cairo_surface_blob");

struct CairoSurfaceBlob : public PlBlob {
  cairo_surface_t *surface_;
  PlAtom parent_; // keeps a PtrBlob alive (for for_data surfaces)

  explicit CairoSurfaceBlob() : PlBlob(&cairo_surface_blob), parent_(PlAtom::null) {}

  explicit CairoSurfaceBlob(cairo_surface_t *surface)
      : PlBlob(&cairo_surface_blob), surface_(surface), parent_(PlAtom::null) {}

  explicit CairoSurfaceBlob(cairo_surface_t *surface, PlAtom parent)
      : PlBlob(&cairo_surface_blob), surface_(surface), parent_(parent) {
    parent_.register_ref();
  }

  PL_BLOB_SIZE

  void portray(PlStream &strm) const {
    strm.printf("cairo_surface_blob<%p>(%p)", this, surface_);
  }

  void destroy() noexcept {
    if (surface_ != NULL) {
      cairo_surface_destroy(surface_);
      surface_ = NULL;
    }
    if (parent_.not_null()) {
      parent_.unregister_ref();
      parent_.set_null();
    }
  }

  virtual ~CairoSurfaceBlob() noexcept { destroy(); }
};

PREDICATE(cairo_surface_blob_portray, 2) {
  auto ref = PlBlobV<CairoSurfaceBlob>::cast_ex(A2, cairo_surface_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

struct CairoContextBlob;

static PL_blob_t cairo_context_blob =
    PL_BLOB_DEFINITION(CairoContextBlob, "cairo_context_blob");

struct CairoContextBlob : public PlBlob {
  cairo_t *cr_;
  PlAtom parent_; // keeps the owning surface alive while the ctx lives

  explicit CairoContextBlob()
      : PlBlob(&cairo_context_blob), cr_(NULL), parent_(PlAtom::null) {}

  explicit CairoContextBlob(cairo_t *cr, PlAtom surface)
      : PlBlob(&cairo_context_blob), cr_(cr), parent_(surface) {
    parent_.register_ref();
  }

  PL_BLOB_SIZE

  void portray(PlStream &strm) const {
    strm.printf("cairo_context_blob<%p>(%p)", this, cr_);
  }

  void destroy() noexcept {
    if (cr_ != NULL) {
      cairo_destroy(cr_);
      cr_ = NULL;
    }
    if (parent_.not_null()) {
      parent_.unregister_ref();
      parent_.set_null();
    }
  }

  virtual ~CairoContextBlob() noexcept { destroy(); }
};

PREDICATE(cairo_context_blob_portray, 2) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A2, cairo_context_blob);
  PlStream strm(A1, 0);
  ref->portray(strm);
  return true;
}

// ---------------------------------------------------------------------------
// Image surfaces: rendering to memory buffers.
// ---------------------------------------------------------------------------

PREDICATE(cairo_image_surface_create_, 4) {
  cairo_format_t format = (cairo_format_t)A2.as_int();
  cairo_surface_t *surface =
      cairo_image_surface_create(format, A3.as_int(), A4.as_int());
  if (cairo_surface_status(surface) != CAIRO_STATUS_SUCCESS) {
    cairo_surface_destroy(surface);
    throw PlUnknownError(cairo_status_to_string(
        cairo_surface_status(surface)));
  }
  auto ref =
      std::unique_ptr<PlBlob>(new CairoSurfaceBlob(surface));
  return A1.unify_blob(&ref);
}

PREDICATE(cairo_image_surface_create_for_data_, 6) {
  auto ptr_ref = PlBlobV<PtrBlob>::cast_ex(A2, *ptr_blob_type());
  cairo_format_t format = (cairo_format_t)A3.as_int();
  cairo_surface_t *surface = cairo_image_surface_create_for_data(
      (unsigned char *)ptr_ref->ptr, format, A4.as_int(), A5.as_int(), A6.as_int());
  if (cairo_surface_status(surface) != CAIRO_STATUS_SUCCESS) {
    cairo_surface_destroy(surface);
    throw PlUnknownError(cairo_status_to_string(
        cairo_surface_status(surface)));
  }
  // Parent = PtrBlob → keeps the pixel buffer alive (owned by SDL texture).
  // cairo does NOT free the pixel data on surface_destroy.
  auto ref = std::unique_ptr<PlBlob>(
      new CairoSurfaceBlob(surface, ptr_ref->symbol_));
  return A1.unify_blob(&ref);
}

PREDICATE(cairo_surface_destroy_, 1) {
  auto ref = PlBlobV<CairoSurfaceBlob>::cast_ex(A1, cairo_surface_blob);
  ref->destroy();
  return true;
}

PREDICATE(cairo_surface_flush_, 1) {
  auto ref = PlBlobV<CairoSurfaceBlob>::cast_ex(A1, cairo_surface_blob);
  cairo_surface_flush(ref->surface_);
  return true;
}

PREDICATE(cairo_image_surface_get_data_, 2) {
  auto surface_ref = PlBlobV<CairoSurfaceBlob>::cast_ex(A1, cairo_surface_blob);
  unsigned char *data = cairo_image_surface_get_data(surface_ref->surface_);
  // Return a PtrBlob that holds a parent_ ref to the surface, keeping
  // the pixel buffer alive while the pointer view is referenced.  The
  // pointer itself never escapes to Prolog as a raw integer.
  auto ptr = std::unique_ptr<PlBlob>(
      new PtrBlob(data, surface_ref->symbol_));
  return A2.unify_blob(&ptr);
}

PREDICATE(cairo_image_surface_get_width_, 2) {
  auto ref = PlBlobV<CairoSurfaceBlob>::cast_ex(A1, cairo_surface_blob);
  return A2.unify_integer(cairo_image_surface_get_width(ref->surface_));
}

PREDICATE(cairo_image_surface_get_height_, 2) {
  auto ref = PlBlobV<CairoSurfaceBlob>::cast_ex(A1, cairo_surface_blob);
  return A2.unify_integer(cairo_image_surface_get_height(ref->surface_));
}

PREDICATE(cairo_image_surface_get_stride_, 2) {
  auto ref = PlBlobV<CairoSurfaceBlob>::cast_ex(A1, cairo_surface_blob);
  return A2.unify_integer(cairo_image_surface_get_stride(ref->surface_));
}

PREDICATE(cairo_image_surface_get_format_, 2) {
  auto ref = PlBlobV<CairoSurfaceBlob>::cast_ex(A1, cairo_surface_blob);
  return A2.unify_integer(
      (int)cairo_image_surface_get_format(ref->surface_));
}

// ---------------------------------------------------------------------------
// Context: create / destroy / status.
// ---------------------------------------------------------------------------

PREDICATE(cairo_create_, 2) {
  auto surface_ref = PlBlobV<CairoSurfaceBlob>::cast_ex(A2, cairo_surface_blob);
  cairo_t *cr = cairo_create(surface_ref->surface_);
  if (cairo_status(cr) != CAIRO_STATUS_SUCCESS) {
    cairo_destroy(cr);
    throw PlUnknownError(cairo_status_to_string(cairo_status(cr)));
  }
  auto ref = std::unique_ptr<PlBlob>(
      new CairoContextBlob(cr, surface_ref->symbol_));
  return A1.unify_blob(&ref);
}

PREDICATE(cairo_destroy_, 1) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  ref->destroy();
  return true;
}

// ---------------------------------------------------------------------------
// Source colour.
// ---------------------------------------------------------------------------

PREDICATE(cairo_set_source_rgba_, 5) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  cairo_set_source_rgba(ref->cr_, A2.as_double(), A3.as_double(),
                        A4.as_double(), A5.as_double());
  return true;
}

// ---------------------------------------------------------------------------
// Graphics state.
// ---------------------------------------------------------------------------

PREDICATE(cairo_set_antialias_, 2) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  cairo_set_antialias(ref->cr_, (cairo_antialias_t)A2.as_int());
  return true;
}

PREDICATE(cairo_set_line_width_, 2) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  cairo_set_line_width(ref->cr_, A2.as_double());
  return true;
}

PREDICATE(cairo_set_line_cap_, 2) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  cairo_set_line_cap(ref->cr_, (cairo_line_cap_t)A2.as_int());
  return true;
}

PREDICATE(cairo_set_line_join_, 2) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  cairo_set_line_join(ref->cr_, (cairo_line_join_t)A2.as_int());
  return true;
}

// ---------------------------------------------------------------------------
// Paths.
// ---------------------------------------------------------------------------

PREDICATE(cairo_new_path_, 1) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  cairo_new_path(ref->cr_);
  return true;
}

PREDICATE(cairo_new_sub_path_, 1) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  cairo_new_sub_path(ref->cr_);
  return true;
}

PREDICATE(cairo_close_path_, 1) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  cairo_close_path(ref->cr_);
  return true;
}

PREDICATE(cairo_move_to_, 3) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  cairo_move_to(ref->cr_, A2.as_double(), A3.as_double());
  return true;
}

PREDICATE(cairo_line_to_, 3) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  cairo_line_to(ref->cr_, A2.as_double(), A3.as_double());
  return true;
}

PREDICATE(cairo_rectangle_, 5) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  cairo_rectangle(ref->cr_, A2.as_double(), A3.as_double(),
                  A4.as_double(), A5.as_double());
  return true;
}

PREDICATE(cairo_arc_, 6) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  cairo_arc(ref->cr_, A2.as_double(), A3.as_double(), A4.as_double(),
            A5.as_double(), A6.as_double());
  return true;
}

PREDICATE(cairo_arc_negative_, 6) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  cairo_arc_negative(ref->cr_, A2.as_double(), A3.as_double(),
                     A4.as_double(), A5.as_double(), A6.as_double());
  return true;
}

PREDICATE(cairo_curve_to_, 7) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  cairo_curve_to(ref->cr_, A2.as_double(), A3.as_double(), A4.as_double(),
                 A5.as_double(), A6.as_double(), A7.as_double());
  return true;
}

// ---------------------------------------------------------------------------
// Drawing: fill / stroke / paint.  These consume the current path (except
// the *_preserve variants).
// ---------------------------------------------------------------------------

PREDICATE(cairo_fill_, 1) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  cairo_fill(ref->cr_);
  return true;
}

PREDICATE(cairo_fill_preserve_, 1) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  cairo_fill_preserve(ref->cr_);
  return true;
}

PREDICATE(cairo_stroke_, 1) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  cairo_stroke(ref->cr_);
  return true;
}

PREDICATE(cairo_stroke_preserve_, 1) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  cairo_stroke_preserve(ref->cr_);
  return true;
}

PREDICATE(cairo_paint_, 1) {
  auto ref = PlBlobV<CairoContextBlob>::cast_ex(A1, cairo_context_blob);
  cairo_paint(ref->cr_);
  return true;
}
