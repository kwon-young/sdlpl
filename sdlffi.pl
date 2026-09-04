:- use_module(library(ffi)).
:- c_import("#include <SDL2/SDL.h>",
            ['-lSDL2' ],
            [ ]).
