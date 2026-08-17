:- module(ptr, [ptr_store_float32s/3,
                ptr_store_uint16s/3,
                ptr_store_uint32s/3
                ]).

:- use_foreign_library(foreign(ptr)).

% PtrBlob is defined entirely in C++ (ptr.h, included by sdl.cpp, cairo.cpp,
% and ptr.cpp).  This module provides the type-check hook, rich error message
% for the `ptr_blob` type, and bulk typed writers for filling mapped memory
% regions (e.g. GPU transfer buffers) with vertex/index data from Prolog
% lists.
%
% The blob type itself is registered at runtime by whichever foreign module
% loads first (via the ptr_blob_type() first-loader-wins mechanism in
% ptr.h); no ptr.so exists for the blob type alone — ptr.so only provides
% the writer predicates.

:- multifile error:has_type/2.
error:has_type(ptr_blob, X) :- blob(X, ptr_blob).

:- multifile prolog:error_message//1.
prolog:error_message(type_error(ptr_blob, Culprit)) -->
   [ 'ptr_blob (a non-owning pointer view blob), found ~q'-[Culprit] ].

% --- typed writers ----------------------------------------------------------
% These predicates write Prolog lists into a PtrBlob's memory region at the
% given byte offset.  They are used to fill GPU transfer buffers (mapped via
% sdl_mapgputransferbuffer/3) with vertex or index data before uploading to
% GPU buffers.  One Prolog→C crossing per call (bulk, not per-element).

ptr_store_float32s(Ptr, Offset, List) :-
   must_be(ptr_blob, Ptr),
   must_be(nonneg, Offset),
   must_be(list(number), List),
   ptr_store_float32s_(Ptr, Offset, List).

ptr_store_uint16s(Ptr, Offset, List) :-
   must_be(ptr_blob, Ptr),
   must_be(nonneg, Offset),
   must_be(list(integer), List),
   ptr_store_uint16s_(Ptr, Offset, List).

ptr_store_uint32s(Ptr, Offset, List) :-
   must_be(ptr_blob, Ptr),
   must_be(nonneg, Offset),
   must_be(list(integer), List),
   ptr_store_uint32s_(Ptr, Offset, List).
