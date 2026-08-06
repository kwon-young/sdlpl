SWIPL ?= swipl
CC ?= cc
CFLAGS ?=
LDSOFLAGS ?= -shared
SOEXT ?= so
SWIARCH := $(shell $(SWIPL) --arch)
PACKSODIR = lib/$(SWIARCH)

SWI_HOME := $(shell $(SWIPL) -g "current_prolog_flag(home,H),write(H)" -t halt)
SWI_CFLAGS = -I$(SWI_HOME)/include -D__SWI_PROLOG__ -D_REENTRANT -fPIC

SDL_CFLAGS := $(shell pkg-config --cflags sdl2 SDL2_image 2>/dev/null || echo "-I/usr/include/SDL2")
SDL_LIBS := $(shell pkg-config --libs sdl2 SDL2_image 2>/dev/null || echo "-lSDL2 -lSDL2_image")

ALL_CFLAGS = $(SWI_CFLAGS) $(CFLAGS) $(SDL_CFLAGS)

SRC = sdl.cpp
LIB = $(PACKSODIR)/sdl.$(SOEXT)

all: $(LIB)

$(LIB): $(SRC) | $(PACKSODIR)
	$(CC) $(ALL_CFLAGS) -c $(SRC) -o $(PACKSODIR)/sdl.o
	$(CC) $(LDSOFLAGS) $(PACKSODIR)/sdl.o $(SDL_LIBS) -o $(LIB)
	rm -f $(PACKSODIR)/sdl.o

$(PACKSODIR):
	mkdir -p $@

check: all
	$(SWIPL) -p library=prolog -p foreign=$(PACKSODIR) \
	  -g "load_files('tests/sdl.plt',[if(changed),imports([])]), run_tests, halt" -t halt

clean:
	rm -rf lib

indent:
	clang-format -i -style="{ColumnLimit: 85}" $(SRC)

.PHONY: all check clean indent
