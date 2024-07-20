sdl.so: sdlpl.c
	swipl-ld -shared -o sdl sdlpl.c -g -I/usr/include/SDL2/ -lSDL2 -lSDL2_image
