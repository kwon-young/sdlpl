:- module(ptr, []).

% PtrBlob is defined entirely in C++ (ptr.h, included by sdl.cpp and
% cairo.cpp).  This pure-Prolog module provides only the type-check
% hook and rich error message for the `ptr_blob` type.  The blob type
% itself is registered at runtime by whichever foreign module loads
% first; no ptr.so exists.

:- multifile error:has_type/2.
error:has_type(ptr_blob, X) :- blob(X, ptr_blob).

:- multifile prolog:error_message//1.
prolog:error_message(type_error(ptr_blob, Culprit)) -->
   [ 'ptr_blob (a non-owning pointer view blob), found ~q'-[Culprit] ].
