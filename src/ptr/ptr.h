#ifndef PTR_H
#define PTR_H

#include <SWI-cpp2.h>

// ---------------------------------------------------------------------------
// PtrBlob — a non-owning view of a memory region owned by another blob.
//
// It holds:
//   ptr    — the borrowed memory address (e.g. a cairo pixel buffer)
//   parent — a registered PlAtom reference to the owning blob, preventing
//            Prolog GC from collecting the owner (and freeing the buffer)
//            while this view is live.
//
// ptr is NEVER freed by the blob — the parent owns it.  The blob's sole
// purpose is lifetime safety + carrying the address across the Prolog/C
// boundary without exposing it as a raw integer.
//
// This header is included by the sdl extension (src/sdl/sdl_gpu.cpp,
// src/sdl/sdl_render.cpp, src/sdl/sdl_surface.cpp) and the cairo extension
// (src/cairo/cairo.cpp).  The blob type is shared at runtime via
// PL_find_blob_type("ptr_blob"): whichever .so loads first registers the
// type, the other finds it by name.  Both modules then see the same
// PL_blob_t* pointer, so cast_ex (which compares by pointer identity)
// succeeds across modules.
// ---------------------------------------------------------------------------

struct PtrBlob;

// Resolve the canonical PL_blob_t* for "ptr_blob".  First-loader-wins:
// whichever .so calls this first finds NULL from PL_find_blob_type and
// registers the type; subsequent calls (from either .so) find it already
// registered.  The static `t` caches the result per-.so; the static `def`
// only fires in the first .so and is never touched by the second.
inline PL_blob_t *ptr_blob_type() {
  static PL_blob_t *t = PL_find_blob_type("ptr_blob");
  if (!t) {
    static PL_blob_t def = PL_BLOB_DEFINITION(PtrBlob, "ptr_blob");
    PL_register_blob_type(&def);
    t = &def;
  }
  return t;
}

struct PtrBlob : public PlBlob {
  void *ptr;
  PlAtom parent;

  explicit PtrBlob()
      : PlBlob(ptr_blob_type()), ptr(nullptr), parent(PlAtom::null) {}

  explicit PtrBlob(void *p, PlAtom par)
      : PlBlob(ptr_blob_type()), ptr(p), parent(par) {
    parent.register_ref();
  }

  PL_BLOB_SIZE

  void destroy() noexcept {
    // Do NOT free ptr — owned by the parent blob.
    ptr = nullptr;
    if (parent.not_null()) {
      parent.unregister_ref();
      parent.set_null();
    }
  }

  virtual ~PtrBlob() noexcept { destroy(); }
};

#endif // PTR_H
