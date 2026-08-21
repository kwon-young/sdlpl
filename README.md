# sdl — SWI-Prolog bindings for SDL3

Handwritten bindings that let SWI-Prolog programs use
[SDL3](https://www.libsdl.org/) (windowing, 2D rendering, input events) and
[SDL3_image](https://github.com/libsdl/SDL_image) (image loading).

The foreign extension is written in C++ using SWI-Prolog's C++ foreign
interface (`SWI-cpp2.h`). SDL handles are wrapped in Prolog *blobs* with
RAII semantics, so they are freed automatically on backtracking or garbage
collection.

Each predicate maps 1-to-1 to a single SDL3 function call.

## Features

- Open and manage windows (`sdl_createwindow/5`, `sdl_setwindowposition/3`,
  `sdl_destroywindow/1`)
- Hardware-accelerated 2D rendering (`sdl_createrenderer/3`,
  `sdl_setrendervsync/2`, `sdl_renderclear/1`, `sdl_rendertexture/4`,
  `sdl_renderpresent/1`)
- Draw outlined / filled rectangles (`sdl_renderrect/2`,
  `sdl_renderfillrect/2`, `sdl_setrenderdrawcolor/5`)
- Load images via SDL3_image (`img_load/2`, `sdl_createtexturefromsurface/3`,
  `sdl_destroysurface/1`)
- Poll mouse, keyboard and quit events as dicts (`sdl_pollevent/1`)
- Symbolic flag enums with type checking (`sdl_init_flag/2`,
  `sdl_window_flag/2`)

## Installation

### Requirements

- SWI-Prolog (>= 9.2) with development headers
- SDL3 and SDL3_image development libraries
- A C++17 compiler and CMake (>= 3.16)

### As a pack

```
swipl pack install https://github.com/kwon-young/sdlpl.git
```

The pack manager detects `CMakeLists.txt`, configures and builds the
foreign extension via CMake, and installs `sdl.so` into `lib/<arch>/`.

### From source (local checkout)

```
cmake -B build
cmake --build build
ctest --test-dir build --output-on-failure   # run the plunit suite
```

The library is then usable with `:- use_module(library(sdl)).`

## Usage

```prolog
:- use_module(library(sdl)).
```

This loads the entire API. The library is also modularized internally. You can load specific subsystems if you prefer a tighter namespace:

- `:- use_module(library(sdl/init)).` (initialization)
- `:- use_module(library(sdl/video)).` (windows)
- `:- use_module(library(sdl/render)).` (2D renderer)
- `:- use_module(library(sdl/events)).` (event polling)
- `:- use_module(library(sdl/surface)).` (software surfaces)
- `:- use_module(library(sdl/gpu)).` (SDL3 explicit GPU API)
- `:- use_module(library(sdl/image)).` (SDL3_image)

```prolog
demo :-
    setup_call_cleanup(
        sdl_init([everything]),
        setup_call_cleanup(
            sdl_createwindow(W, "demo", 640, 480, []),
            setup_call_cleanup(
                (   sdl_setwindowposition(W, centered, centered),
                    sdl_createrenderer(R, W, null)
                ),
                (   sdl_setrenderdrawcolor(R, 255, 0, 0, 255),
                    sdl_renderclear(R),
                    sdl_setrenderdrawcolor(R, 255, 255, 255, 255),
                    sdl_renderfillrect(R, rect(100, 100, 200, 200)),
                    sdl_renderpresent(R),
                    wait_for_quit
                ),
                sdl_destroyrenderer(R)),
            sdl_destroywindow(W)),
        sdl_quit).

% loop until a quit event is received
wait_for_quit :-
    (   sdl_pollevent(E), E.type == quit
    ->  true
    ;   wait_for_quit
    ).
```

## Examples

The `examples/` directory contains small programs demonstrating the API:

- `pong2.pl` — a playable Pong game using `library(macros)`.
- `test.pl` — a declarative reactive-UI experiment (DCG based).
- `box.pl` — a pure `clpBNR` collision/geometry model (no SDL).

Run an example from the pack root, e.g.:

```
swipl -p library=prolog -p foreign=lib/$(swipl --arch) -g main examples/pong2.pl
```

## Testing

```
ctest --test-dir build --output-on-failure
```

Tests live in `test/test_sdl.pl` and are integration tests that open real SDL
windows. They use the sample image `examples/DSC03094.JPG`.

## License

GNU General Public License v3.0 — see [LICENSE](LICENSE).
