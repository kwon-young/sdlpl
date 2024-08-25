sdl.so: sdl.cpp
	swipl-ld -shared -o sdl sdl.cpp -I/usr/include/SDL2/ -lSDL2 -lSDL2_image

.PHONY: indent clean

indent: sdl.cpp
	clang-format -i -style="{ColumnLimit: 85}" sdl.cpp

clean:
	$(RM) sdl.so
