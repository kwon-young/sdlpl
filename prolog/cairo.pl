:- module(cairo, [cairo_image_surface_create/4,
                  cairo_image_surface_create_for_data/6,
                  cairo_surface_destroy/1, cairo_surface_flush/1,
                  cairo_image_surface_get_data/2, cairo_image_surface_get_width/2,
                  cairo_image_surface_get_height/2, cairo_image_surface_get_stride/2,
                  cairo_image_surface_get_format/2,
                  cairo_create/2, cairo_destroy/1,
                  cairo_set_source_rgba/5,
                  cairo_set_antialias/2, cairo_set_line_width/2,
                  cairo_set_line_cap/2, cairo_set_line_join/2,
                  cairo_new_path/1, cairo_new_sub_path/1, cairo_close_path/1,
                  cairo_move_to/3, cairo_line_to/3, cairo_rectangle/5,
                  cairo_arc/6, cairo_arc_negative/6, cairo_curve_to/7,
                  cairo_fill/1, cairo_fill_preserve/1,
                  cairo_stroke/1, cairo_stroke_preserve/1, cairo_paint/1,
                  cairo_format/2, cairo_antialias/2, cairo_line_cap/2,
                  cairo_line_join/2
                  ]).
:- use_foreign_library(foreign(cairo)).

:- multifile error:has_type/2.
error:has_type(cairo_surface_blob, X) :- blob(X, cairo_surface_blob).
error:has_type(cairo_context_blob, X) :- blob(X, cairo_context_blob).
error:has_type(cairo_format,     X) :- cairo_format(X, _).
error:has_type(cairo_antialias,  X) :- cairo_antialias(X, _).
error:has_type(cairo_line_cap,   X) :- cairo_line_cap(X, _).
error:has_type(cairo_line_join,  X) :- cairo_line_join(X, _).

% Rich error messages listing the valid atoms for each enum.
:- multifile prolog:error_message//1.
prolog:error_message(type_error(cairo_format, Culprit)) -->
   { findall(F, cairo_format(F, _), Fs) },
   [ 'cairo_format (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(cairo_antialias, Culprit)) -->
   { findall(F, cairo_antialias(F, _), Fs) },
   [ 'cairo_antialias (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(cairo_line_cap, Culprit)) -->
   { findall(F, cairo_line_cap(F, _), Fs) },
   [ 'cairo_line_cap (one of ~q), found ~q'-[Fs, Culprit] ].
prolog:error_message(type_error(cairo_line_join, Culprit)) -->
   { findall(F, cairo_line_join(F, _), Fs) },
   [ 'cairo_line_join (one of ~q), found ~q'-[Fs, Culprit] ].

user:portray(Surface) :-
   blob(Surface, cairo_surface_blob), !,
   cairo_surface_blob_portray(current_output, Surface).
user:portray(Context) :-
   blob(Context, cairo_context_blob), !,
   cairo_context_blob_portray(current_output, Context).

% --- enum tables ------------------------------------------------------------
% cairo_format_t: see cairo/cairo.h.  argb32 is the natural pairing with
% SDL_PIXELFORMAT_ARGB32 (native-endian 0xAARRGGBB).
cairo_format(invalid, -1).
cairo_format(argb32, 0).
cairo_format(rgb24, 1).
cairo_format(a8, 2).
cairo_format(a1, 3).
cairo_format(rgb16_565, 4).
cairo_format(rgb30, 5).

% cairo_antialias_t
cairo_antialias(default, 0).
cairo_antialias(none, 1).
cairo_antialias(gray, 2).
cairo_antialias(subpixel, 3).
cairo_antialias(fast, 4).
cairo_antialias(good, 5).
cairo_antialias(best, 6).

% cairo_line_cap_t
cairo_line_cap(butt, 0).
cairo_line_cap(round, 1).
cairo_line_cap(square, 2).

% cairo_line_join_t
cairo_line_join(miter, 0).
cairo_line_join(round, 1).
cairo_line_join(bevel, 2).

% --- image surfaces ---------------------------------------------------------

cairo_image_surface_create(Surface, Format, Width, Height) :-
   must_be(var, Surface),
   must_be(cairo_format, Format),
   must_be(positive_integer, Width),
   must_be(positive_integer, Height),
   cairo_format(Format, IntFormat),
   cairo_image_surface_create_(Surface, IntFormat, Width, Height).

% Creates a cairo image surface backed by external pixel data (e.g. an
% SDL locked texture).  The Pixels PtrBlob must stay alive while the
% surface is in use — the surface blob holds a parent ref to it.
cairo_image_surface_create_for_data(Surface, Pixels, Format, Width, Height, Stride) :-
   must_be(var, Surface),
   must_be(ptr_blob, Pixels),
   must_be(cairo_format, Format),
   must_be(positive_integer, Width),
   must_be(positive_integer, Height),
   must_be(integer, Stride),
   cairo_format(Format, IntFormat),
   cairo_image_surface_create_for_data_(Surface, Pixels, IntFormat, Width, Height, Stride).

cairo_surface_destroy(Surface) :-
   must_be(cairo_surface_blob, Surface),
   cairo_surface_destroy_(Surface).

cairo_surface_flush(Surface) :-
   must_be(cairo_surface_blob, Surface),
   cairo_surface_flush_(Surface).

cairo_image_surface_get_data(Surface, Data) :-
   must_be(cairo_surface_blob, Surface),
   must_be(var, Data),
   cairo_image_surface_get_data_(Surface, Data).

cairo_image_surface_get_width(Surface, Width) :-
   must_be(cairo_surface_blob, Surface),
   must_be(var, Width),
   cairo_image_surface_get_width_(Surface, Width).

cairo_image_surface_get_height(Surface, Height) :-
   must_be(cairo_surface_blob, Surface),
   must_be(var, Height),
   cairo_image_surface_get_height_(Surface, Height).

cairo_image_surface_get_stride(Surface, Stride) :-
   must_be(cairo_surface_blob, Surface),
   must_be(var, Stride),
   cairo_image_surface_get_stride_(Surface, Stride).

cairo_image_surface_get_format(Surface, Format) :-
   must_be(cairo_surface_blob, Surface),
   must_be(var, Format),
   cairo_image_surface_get_format_(Surface, IntFormat),
   cairo_format(Format, IntFormat).

% --- context ----------------------------------------------------------------

cairo_create(Context, Surface) :-
   must_be(var, Context),
   must_be(cairo_surface_blob, Surface),
   cairo_create_(Context, Surface).

cairo_destroy(Context) :-
   must_be(cairo_context_blob, Context),
   cairo_destroy_(Context).

% --- source colour ----------------------------------------------------------
% Colour components are doubles in 0.0..1.0 (unlike SDL's 0..255 ints).

cairo_set_source_rgba(Context, R, G, B, A) :-
   must_be(cairo_context_blob, Context),
   maplist(must_be(number), [R, G, B, A]),
   cairo_set_source_rgba_(Context, R, G, B, A).

% --- graphics state ---------------------------------------------------------

cairo_set_antialias(Context, Antialias) :-
   must_be(cairo_context_blob, Context),
   must_be(cairo_antialias, Antialias),
   cairo_antialias(Antialias, Int),
   cairo_set_antialias_(Context, Int).

cairo_set_line_width(Context, Width) :-
   must_be(cairo_context_blob, Context),
   must_be(number, Width),
   cairo_set_line_width_(Context, Width).

cairo_set_line_cap(Context, Cap) :-
   must_be(cairo_context_blob, Context),
   must_be(cairo_line_cap, Cap),
   cairo_line_cap(Cap, Int),
   cairo_set_line_cap_(Context, Int).

cairo_set_line_join(Context, Join) :-
   must_be(cairo_context_blob, Context),
   must_be(cairo_line_join, Join),
   cairo_line_join(Join, Int),
   cairo_set_line_join_(Context, Int).

% --- paths ------------------------------------------------------------------

cairo_new_path(Context) :-
   must_be(cairo_context_blob, Context),
   cairo_new_path_(Context).

cairo_new_sub_path(Context) :-
   must_be(cairo_context_blob, Context),
   cairo_new_sub_path_(Context).

cairo_close_path(Context) :-
   must_be(cairo_context_blob, Context),
   cairo_close_path_(Context).

cairo_move_to(Context, X, Y) :-
   must_be(cairo_context_blob, Context),
   maplist(must_be(number), [X, Y]),
   cairo_move_to_(Context, X, Y).

cairo_line_to(Context, X, Y) :-
   must_be(cairo_context_blob, Context),
   maplist(must_be(number), [X, Y]),
   cairo_line_to_(Context, X, Y).

cairo_rectangle(Context, X, Y, Width, Height) :-
   must_be(cairo_context_blob, Context),
   maplist(must_be(number), [X, Y, Width, Height]),
   cairo_rectangle_(Context, X, Y, Width, Height).

cairo_arc(Context, Xc, Yc, Radius, Angle1, Angle2) :-
   must_be(cairo_context_blob, Context),
   maplist(must_be(number), [Xc, Yc, Radius, Angle1, Angle2]),
   cairo_arc_(Context, Xc, Yc, Radius, Angle1, Angle2).

cairo_arc_negative(Context, Xc, Yc, Radius, Angle1, Angle2) :-
   must_be(cairo_context_blob, Context),
   maplist(must_be(number), [Xc, Yc, Radius, Angle1, Angle2]),
   cairo_arc_negative_(Context, Xc, Yc, Radius, Angle1, Angle2).

cairo_curve_to(Context, X1, Y1, X2, Y2, X3, Y3) :-
   must_be(cairo_context_blob, Context),
   maplist(must_be(number), [X1, Y1, X2, Y2, X3, Y3]),
   cairo_curve_to_(Context, X1, Y1, X2, Y2, X3, Y3).

% --- drawing ----------------------------------------------------------------

cairo_fill(Context) :-
   must_be(cairo_context_blob, Context),
   cairo_fill_(Context).

cairo_fill_preserve(Context) :-
   must_be(cairo_context_blob, Context),
   cairo_fill_preserve_(Context).

cairo_stroke(Context) :-
   must_be(cairo_context_blob, Context),
   cairo_stroke_(Context).

cairo_stroke_preserve(Context) :-
   must_be(cairo_context_blob, Context),
   cairo_stroke_preserve_(Context).

cairo_paint(Context) :-
   must_be(cairo_context_blob, Context),
   cairo_paint_(Context).
