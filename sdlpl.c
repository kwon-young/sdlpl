#include <stdio.h>
#include <SWI-Prolog.h>
#include <SDL.h>
#include <SDL_image.h>

static foreign_t pl_SDL_Init(term_t flags_t)
{
  uint64_t flags;
  if (!PL_get_uint64(flags_t, &flags)) {
    printf("Failed to get init flags\n");
    PL_fail;
  }
  if (SDL_Init(flags) < 0) {
    printf("Failed to init\n");
    PL_fail;
  }
  printf("SDL_Init %x\n", flags);
  PL_succeed;
}

static foreign_t pl_SDL_Quit()
{
  SDL_Quit();
  printf("SDL_Quit\n");
  PL_succeed;
}

static foreign_t pl_SDL_CreateWindow(
    term_t term, term_t title_t, term_t x_t, term_t y_t,
    term_t w_t, term_t h_t, term_t flags_t)
{
  char* title;
  size_t len;
  if (!PL_get_string_chars(title_t, &title, &len)) {
    printf("failed to get window title\n");
    PL_fail;
  }
  printf("%s\n", title);
  int x;
  if (!PL_get_integer(x_t, &x)) {
    printf("failed to get window x\n");
    PL_fail;
  }
  printf("%x\n", x);
  int y;
  if (!PL_get_integer(y_t, &y)) {
    printf("failed to get window y\n");
    PL_fail;
  }
  printf("%x\n", y);
  int w;
  if (!PL_get_integer(w_t, &w)) {
    printf("failed to get window w\n");
    PL_fail;
  }
  printf("%d\n", w);
  int h;
  if (!PL_get_integer(h_t, &h)) {
    printf("failed to get window h\n");
    PL_fail;
  }
  printf("%d\n", h);
  uint64_t flags;
  if (!PL_get_uint64(flags_t, &flags)) {
    printf("Failed to get init flags\n");
    PL_fail;
  }
  printf("%x\n", flags);
  SDL_Window* window = SDL_CreateWindow(title, x, y, w, h, flags);
  if (window == NULL) {
    printf("Error window creation\n");
    PL_fail;
  }
  if (!PL_unify_pointer(term, window)) {
    printf("Error window term creation\n");
    PL_fail;
  }
  printf("window created\n");
  PL_succeed;
}

static foreign_t pl_SDL_DestroyWindow(term_t term)
{
  SDL_Window* window;
  if (!PL_get_pointer(term, (void**)(&window))) {
    printf("failed to get window pointer\n");
    PL_fail;
  }
  SDL_DestroyWindow(window);
  printf("window destroyed\n");
  PL_succeed;
}

static foreign_t pl_SDL_CreateRenderer(
    term_t renderer_t, term_t window_t, term_t index_t, term_t flags_t)
{
  SDL_Window* window;
  if (!PL_get_pointer(window_t, (void**)(&window))) {
    printf("failed to get window pointer\n");
    PL_fail;
  }
  int index;
  if (!PL_get_integer(index_t, &index)) {
    printf("failed to get renderer index\n");
    PL_fail;
  }
  printf("%d\n", index);
  uint64_t flags;
  if (!PL_get_uint64(flags_t, &flags)) {
    printf("Failed to get renderer flags\n");
    PL_fail;
  }
  printf("%x\n", flags);
  SDL_Renderer* renderer = SDL_CreateRenderer(window, index, flags);
  if (renderer == NULL) {
      printf("Error renderer creation\n");
      PL_fail;
  }
  if (!PL_unify_pointer(renderer_t, renderer)) {
    printf("Error renderer term creation\n");
    PL_fail;
  }
  printf("renderer created\n");
  PL_succeed;
}

static foreign_t pl_SDL_DestroyRenderer(term_t renderer_t)
{
  SDL_Renderer* renderer;
  if (!PL_get_pointer(renderer_t, (void**)(&renderer))) {
    printf("failed to get renderer pointer\n");
    PL_fail;
  }
  SDL_DestroyRenderer(renderer);
  printf("renderer destroyed\n");
  PL_succeed;
}

static foreign_t pl_SDL_RenderClear(term_t renderer_t)
{
  SDL_Renderer* renderer;
  if (!PL_get_pointer(renderer_t, (void**)(&renderer))) {
    printf("failed to get renderer pointer\n");
    PL_fail;
  }
  SDL_RenderClear(renderer);
  printf("renderer cleared\n");
  PL_succeed;
}

foreign_t PL_get_rect(term_t rect_t, SDL_Rect * rect)
{
  term_t x_t = PL_new_term_ref();
  term_t y_t = PL_new_term_ref();
  term_t w_t = PL_new_term_ref();
  term_t h_t = PL_new_term_ref();
  if (!PL_get_arg(1, rect_t, x_t)
      || !PL_get_integer(x_t, &(rect->x))
      || !PL_get_arg(2, rect_t, y_t)
      || !PL_get_integer(y_t, &(rect->y))
      || !PL_get_arg(3, rect_t, w_t)
      || !PL_get_integer(w_t, &(rect->w))
      || !PL_get_arg(4, rect_t, h_t)
      || !PL_get_integer(h_t, &(rect->h)))
  {
    printf("failed to get rect\n");
    PL_fail;
  }
  printf("got rect\n");
}

static foreign_t pl_SDL_RenderCopy(
    term_t renderer_t, term_t texture_t, term_t srrect_t, term_t dstrect_t)
{
  SDL_Renderer* renderer;
  if (!PL_get_pointer(renderer_t, (void**)(&renderer))) {
    printf("failed to get renderer pointer\n");
    PL_fail;
  }
  SDL_Texture* texture;
  if (!PL_get_blob(texture_t, (void**)&texture, NULL, NULL)) {
    printf("failed to get texture pointer\n");
    PL_fail;
  }
  SDL_Rect *srrect_p = NULL;
  if (PL_is_compound(srrect_t)) {
    SDL_Rect srrect;
    srrect_p = &srrect;
    PL_get_rect(srrect_t, srrect_p);
  }
  SDL_Rect *dstrect_p = NULL;
  if (PL_is_compound(dstrect_t)) {
    SDL_Rect dstrect;
    dstrect_p = &dstrect;
    PL_get_rect(dstrect_t, dstrect_p);
  }
  SDL_RenderCopy(renderer, texture, srrect_p, dstrect_p);
  printf("renderer texture copied\n");
  PL_succeed;
}

static foreign_t pl_SDL_RenderPresent(term_t renderer_t)
{
  SDL_Renderer* renderer;
  if (!PL_get_pointer(renderer_t, (void**)(&renderer))) {
    printf("failed to get renderer pointer\n");
    PL_fail;
  }
  SDL_RenderPresent(renderer);
  printf("renderer presented\n");
  PL_succeed;
}

static foreign_t pl_IMG_Init(term_t flags_t)
{
  uint64_t flags;
  if (!PL_get_uint64(flags_t, &flags)) {
    printf("Failed to get IMG init flags\n");
    PL_fail;
  }
  printf("%x\n", flags);
  if (IMG_Init(flags) == 0) {
    printf("Error SDL2_image Initialization\n");
    PL_fail;
  }
  printf("SDL2_image initialized\n");
  PL_succeed;
}

static foreign_t pl_IMG_Quit()
{
  IMG_Quit();
  printf("IMG quit\n");
  PL_succeed;
}

static foreign_t pl_IMG_Load(term_t surface_t, term_t file_t)
{
  // TODO: support filepath with space and accents
  char* file;
  size_t len;
  if (!PL_get_string_chars(file_t, &file, &len)) {
    printf("failed to get window title\n");
    PL_fail;
  }
  printf("%s\n", file);
  SDL_Surface* surface = IMG_Load(file);
  if (surface == NULL) {
    printf("Error loading image: %s\n", SDL_GetError());
    PL_fail;
  }
  if (!PL_unify_pointer(surface_t, surface)) {
    printf("Error surface term creation\n");
    PL_fail;
  }
  printf("surface created\n");
  PL_succeed;
}

static foreign_t pl_SDL_FreeSurface(term_t surface_t)
{
  SDL_Surface* surface;
  if (!PL_get_pointer(surface_t, (void**)(&surface))) {
    printf("failed to get surface pointer\n");
    PL_fail;
  }
  SDL_FreeSurface(surface);
  printf("surface freed\n");
  PL_succeed;
}

typedef struct texture_handle {
  SDL_Texture* handle;
} texture_handle;

int blob_SDL_DestroyTexture(atom_t blob)
{
  size_t len;
  PL_blob_t *type;
  SDL_Texture* texture = NULL;
  texture = PL_blob_data(blob, &len, &type);
  if (texture) {
    SDL_DestroyTexture(texture);
    printf("destroy texture %p\n", texture);
  }
  printf("texture blob freed %p: %s\n", texture, SDL_GetError());
  PL_succeed;
}

static PL_blob_t texture_blob_t = {
  .magic = PL_BLOB_MAGIC,
  .flags = PL_BLOB_UNIQUE | PL_BLOB_NOCOPY,
  .name = "texture",
  .release = blob_SDL_DestroyTexture,
  .compare = NULL,
  .write = NULL,
  .acquire = NULL,
  .save = NULL,
  .load = NULL
};

static foreign_t pl_SDL_CreateTextureFromSurface(term_t texture_t, term_t renderer_t, term_t surface_t)
{
  SDL_Renderer* renderer;
  if (!PL_get_pointer(renderer_t, (void**)(&renderer))) {
    printf("failed to get renderer pointer\n");
    PL_fail;
  }
  SDL_Surface* surface;
  if (!PL_get_pointer(surface_t, (void**)(&surface))) {
    printf("failed to get surface pointer\n");
    PL_fail;
  }
  SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, surface);
  if (texture == NULL) {
    printf("Error creating texture\n");
    PL_fail;
  }
  if (!PL_unify_blob(texture_t, texture, sizeof(int), &texture_blob_t)) {
    printf("Error texture blob creation\n");
    PL_fail;
  }
  printf("texture created %p\n", texture);
  PL_succeed;
}

static foreign_t pl_SDL_DestroyTexture(term_t texture_t)
{
  atom_t atom;
  if (PL_get_atom(texture_t, &atom)) {
    PL_free_blob(atom);
  }
}

static foreign_t pl_SDL_PollEvent(term_t event_t)
{
  SDL_Event event;
  if (SDL_PollEvent(&event)) {
    if (event.type == SDL_QUIT) {
      if (!PL_unify_term(event_t, PL_FUNCTOR_CHARS, "quit", 2,
                         PL_CHARS, "quit",
                         PL_INT, event.quit.timestamp)) {
        printf("Failed to build event term\n");
        PL_fail;
      } else {
        printf("retrieved event\n");
        PL_succeed;
      }
    } else if (event.type == SDL_MOUSEMOTION) {
      if (!PL_unify_term(event_t, PL_FUNCTOR_CHARS, "mousemotion", 9,
                         PL_CHARS, "mousemotion",
                         PL_INT, event.motion.timestamp,
                         PL_INT, event.motion.windowID,
                         PL_INT, event.motion.which,
                         PL_INT, event.motion.state,
                         PL_INT, event.motion.x,
                         PL_INT, event.motion.y,
                         PL_INT, event.motion.xrel,
                         PL_INT, event.motion.yrel)) {
        printf("Failed to build event term\n");
        PL_fail;
      } else {
        printf("retrieved event\n");
        PL_succeed;
      }
    } else if (event.type == SDL_MOUSEBUTTONDOWN || event.type == SDL_MOUSEBUTTONUP) {
      char* button;
      switch (event.button.button) {
        case 1:
          button = "left";
          break;
        case 2:
          button = "middle";
          break;
        case 3:
          button = "right";
          break;
        default:
          button = "unknown";
      }
      if (!PL_unify_term(event_t, PL_FUNCTOR_CHARS, "mousebutton", 9,
                         PL_CHARS, event.type == SDL_MOUSEBUTTONDOWN ? "mousebuttondown": "mousebuttonup",
                         PL_INT, event.button.timestamp,
                         PL_INT, event.button.windowID,
                         PL_INT, event.button.which,
                         PL_CHARS, button,
                         PL_INT, event.button.state,
                         PL_INT, event.button.clicks,
                         PL_INT, event.button.x,
                         PL_INT, event.button.y)) {
        printf("Failed to build event term\n");
        PL_fail;
      } else {
        printf("retrieved event\n");
        PL_succeed;
      }
    } else if (event.type == SDL_KEYDOWN || event.type == SDL_KEYUP) {
      term_t keysym_t = PL_new_term_ref();
      if (!PL_unify_term(keysym_t, PL_FUNCTOR_CHARS, "keysym", 3,
                         PL_INT, event.key.keysym.scancode,
                         PL_INT, event.key.keysym.sym,
                         PL_INT, event.key.keysym.mod)) {
        printf("Failed to build keysym term\n");
        PL_fail;
      }

      if (!PL_unify_term(event_t, PL_FUNCTOR_CHARS, "keyboard", 6,
                         PL_CHARS, event.type == SDL_KEYDOWN ? "keydown": "keyup",
                         PL_INT, event.key.timestamp,
                         PL_INT, event.key.windowID,
                         PL_INT, event.key.state,
                         PL_INT, event.key.repeat,
                         PL_TERM, keysym_t)) {
        printf("Failed to build event term\n");
        PL_fail;
      } else {
        printf("retrieved event\n");
        PL_succeed;
      }
    }
  }
  /* printf("No event\n"); */
  PL_fail;
}

static foreign_t pl_SDL_SetRenderDrawColor(
    term_t renderer_t, term_t r_t, term_t g_t, term_t b_t, term_t a_t)
{
  SDL_Renderer* renderer;
  if (!PL_get_pointer(renderer_t, (void**)(&renderer))) {
    printf("failed to get renderer pointer\n");
    PL_fail;
  }
  int r;
  if (!PL_get_integer(r_t, &r)) {
    printf("failed to get r\n");
    PL_fail;
  }
  int g;
  if (!PL_get_integer(g_t, &g)) {
    printf("failed to get g\n");
    PL_fail;
  }
  int b;
  if (!PL_get_integer(b_t, &b)) {
    printf("failed to get b\n");
    PL_fail;
  }
  int a;
  if (!PL_get_integer(a_t, &a)) {
    printf("failed to get a\n");
    PL_fail;
  }
  if (SDL_SetRenderDrawColor(renderer, r, g, b, a)) {
    printf("failed to set color: %s\n", SDL_GetError());
    PL_fail;
  }
  printf("set color %d %d %d %d\n", r, g, b, a);
  PL_succeed;
}

static foreign_t pl_SDL_RenderDrawRect(term_t renderer_t, term_t rect_t)
{
  SDL_Renderer* renderer;
  if (!PL_get_pointer(renderer_t, (void**)(&renderer))) {
    printf("failed to get renderer pointer\n");
    PL_fail;
  }
  SDL_Rect rect;
  PL_get_rect(rect_t, &rect);
  if (SDL_RenderDrawRect(renderer, &rect)) {
    printf("failed to draw rect: %s\n", SDL_GetError());
    PL_fail;
  }
  printf("drawn rect\n");
  PL_succeed;
}

static foreign_t pl_SDL_RenderFillRect(term_t renderer_t, term_t rect_t)
{
  SDL_Renderer* renderer;
  if (!PL_get_pointer(renderer_t, (void**)(&renderer))) {
    printf("failed to get renderer pointer\n");
    PL_fail;
  }
  SDL_Rect rect;
  PL_get_rect(rect_t, &rect);
  if (SDL_RenderFillRect(renderer, &rect)) {
    printf("failed to draw rect: %s\n", SDL_GetError());
    PL_fail;
  }
  printf("drawn filled rect\n");
  PL_succeed;
}

install_t install_sdl()
{
  PL_register_foreign("sdl_init_", 1, pl_SDL_Init, 0);
  PL_register_foreign("sdl_quit", 0, pl_SDL_Quit, 0);
  PL_register_foreign("sdl_createwindow_", 7, pl_SDL_CreateWindow, 0);
  PL_register_foreign("sdl_destroywindow_", 1, pl_SDL_DestroyWindow, 0);
  PL_register_foreign("sdl_createrenderer_", 4, pl_SDL_CreateRenderer, 0);
  PL_register_foreign("sdl_destroyrenderer_", 1, pl_SDL_DestroyRenderer, 0);
  PL_register_foreign("sdl_renderclear_", 1, pl_SDL_RenderClear, 0);
  PL_register_foreign("sdl_rendercopy_", 4, pl_SDL_RenderCopy, 0);
  PL_register_foreign("sdl_renderpresent_", 1, pl_SDL_RenderPresent, 0);
  PL_register_foreign("img_init_", 1, pl_IMG_Init, 0);
  PL_register_foreign("img_quit", 0, pl_IMG_Quit, 0);
  PL_register_foreign("img_load_", 2, pl_IMG_Load, 0);
  PL_register_foreign("sdl_freesurface_", 1, pl_SDL_FreeSurface, 0);
  PL_register_foreign("sdl_createtexturefromsurface_", 3, pl_SDL_CreateTextureFromSurface, 0);
  PL_register_foreign("sdl_destroytexture_", 1, pl_SDL_DestroyTexture, 0);
  PL_register_foreign("sdl_pollevent_", 1, pl_SDL_PollEvent, 0);
  PL_register_foreign("sdl_setrenderdrawcolor_", 5, pl_SDL_SetRenderDrawColor, 0);
  PL_register_foreign("sdl_renderdrawrect_", 2, pl_SDL_RenderDrawRect, 0);
  PL_register_foreign("sdl_renderfillrect_", 2, pl_SDL_RenderFillRect, 0);
}

install_t uninstall_sdl()
{
  PL_unregister_blob_type(&texture_blob_t);
}
