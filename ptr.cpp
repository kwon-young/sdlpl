#include <SWI-cpp2.h>
#include <cstdint>
#include "ptr.h"

// ---------------------------------------------------------------------------
// ptr_store_float32s(+Ptr, +Offset, +List)
// Write a list of numbers as float32 values at byte Offset in the PtrBlob's
// memory region.  Used to fill vertex data into mapped transfer buffers.
// ---------------------------------------------------------------------------
PREDICATE(ptr_store_float32s_, 3) {
  auto ref = PlBlobV<PtrBlob>::cast_ex(A1, *ptr_blob_type());
  size_t offset = A2.as_size_t();
  float *dst = reinterpret_cast<float *>(
      static_cast<char *>(ref->ptr) + offset);
  PlTerm_tail tail(A3);
  PlTerm_var element;
  size_t i = 0;
  while (tail.next(element)) {
    dst[i++] = element.as_float();
  }
  return true;
}

// ---------------------------------------------------------------------------
// ptr_store_uint16s(+Ptr, +Offset, +List)
// Write a list of integers as uint16 values at byte Offset.
// Used to fill 16-bit index data into mapped transfer buffers.
// ---------------------------------------------------------------------------
PREDICATE(ptr_store_uint16s_, 3) {
  auto ref = PlBlobV<PtrBlob>::cast_ex(A1, *ptr_blob_type());
  size_t offset = A2.as_size_t();
  uint16_t *dst = reinterpret_cast<uint16_t *>(
      static_cast<char *>(ref->ptr) + offset);
  PlTerm_tail tail(A3);
  PlTerm_var element;
  size_t i = 0;
  while (tail.next(element)) {
    dst[i++] = static_cast<uint16_t>(element.as_int());
  }
  return true;
}

// ---------------------------------------------------------------------------
// ptr_store_uint32s(+Ptr, +Offset, +List)
// Write a list of integers as uint32 values at byte Offset.
// Used to fill 32-bit index data into mapped transfer buffers.
// ---------------------------------------------------------------------------
PREDICATE(ptr_store_uint32s_, 3) {
  auto ref = PlBlobV<PtrBlob>::cast_ex(A1, *ptr_blob_type());
  size_t offset = A2.as_size_t();
  uint32_t *dst = reinterpret_cast<uint32_t *>(
      static_cast<char *>(ref->ptr) + offset);
  PlTerm_tail tail(A3);
  PlTerm_var element;
  size_t i = 0;
  while (tail.next(element)) {
    dst[i++] = static_cast<uint32_t>(element.as_int());
  }
  return true;
}
