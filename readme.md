I spent some time studying the work of SDL2 with Emscripten. Although in the end it turned out to be a bad idea(look at the end), I decided to post information that could help me in my time. 

## How to make working SDL2 app for web?
All you need:
1) nimble install sl2_nim jsbind
2) make a working native application
3) get sdl.nim and nim.cfg from this repo
4) replace *import sdl2/sdl* to *import sdl*
5) Change the main loop of your application using sdl.mainLoop.

for example:

```while done:```

to

```sdl.mainLoop done:```

6) ```nim c -d:emscripten -d:release main.nim```

That's all. (Your code still has be compilable for the native)

## How it works?
Nothing complicated. Look at the code for the [sdl.nim](https://github.com/Jipok/Nim-SDL2-and-Emscripten/blob/master/sdl.nim) and [nim.cfg](https://github.com/Jipok/Nim-SDL2-and-Emscripten/blob/master/nim.cfg). It all boils down to applying the necessary compilation settings and replacing the main application loop with the procedure that will be called by Emscrypton. 
```nim
template mainLoop*(statement, actions: untyped): untyped =
  proc emscLoop{.cdecl.} =
    if statement:
      emscripten_cancel_main_loop()
      sdl.quit()
      system.quit()
    else:
      actions
```
```passL %= "-s USE_SDL=2"```


## Any live demo?
I took examples from Vladar 4/sdl2_net. Not everything was made working.
- [x] ex101_init - everything is working. Nothing interesting to see there
- [x] ex102_logs - same as the previous one
- [ ] ex104_timers - it seems the timer is triggered once. Perhaps this is because of the single-threadedness of js
- [ ] ex105_syswm - getWindowWMInfo are not defined. But this can easily be fixed
- [x] [ex201_textures](https://jipok.github.io/Nim-SDL2-and-Emscripten/ex201_textures/) - works. But look below how to use external files and sdl2-image
- [x] [ex202_transformations](https://jipok.github.io/Nim-SDL2-and-Emscripten/ex202_transformations/)
- [x] [ex203_blending](https://jipok.github.io/Nim-SDL2-and-Emscripten/ex203_blending/)
- [x] [ex204_drawing](https://jipok.github.io/Nim-SDL2-and-Emscripten/ex204_drawing/)
- [x] [ex205_sdl_gfx_primitives](https://jipok.github.io/Nim-SDL2-and-Emscripten/ex205_sdl_gfx_primitives/) - for better performance, I moved the code of the drawing from the main loop. Also look below about gfx primitives
- [x] [ex206_bitmap_fonts](https://jipok.github.io/Nim-SDL2-and-Emscripten/ex206_bitmap_fonts/) - works. But look below how to use sdl2_ttf
- [x] [ex207_ttf_fonts](https://jipok.github.io/Nim-SDL2-and-Emscripten/ex207_ttf_fonts/) 
- [x] [ex208_framerate](https://jipok.github.io/Nim-SDL2-and-Emscripten/ex208_framerate/) 
- [x] [ex209_viewports_and_scaling](https://jipok.github.io/Nim-SDL2-and-Emscripten/ex209_viewports_and_scaling/) 
- [x] [ex210_pixels](https://jipok.github.io/Nim-SDL2-and-Emscripten/ex210_pixels/) 
- [ ] ex211_opengl - Emscripten does not support OpenGL. Only OpenGL ES and WebGL
- [x] [ex301_keyboard](https://jipok.github.io/Nim-SDL2-and-Emscripten/ex301_keyboard/) 
- [x] [ex302_mouse](https://jipok.github.io/Nim-SDL2-and-Emscripten/ex302_mouse/)
- [ ] ex303_joystick - I don't have a joystick to test this, but looks working
- [x] [ex401_mixer](https://jipok.github.io/Nim-SDL2-and-Emscripten/ex401_mixer/)  - no music.  See below about sdl-mixer
- [x] [ex402_panning](https://jipok.github.io/Nim-SDL2-and-Emscripten/ex402_panning/) - works, but without SetDistance

## Other examples? SDL-net?
I was not interested in sdl-net. But below you can find information about it. See "Ports"

## What about WebAssembly?
Although WebAssembly(wasm) is more efficient, but not supported by many browsers. Therefore by default (see nim.cfg) it compiles into asmjs. Just add -d:wasm to compiler for wasm.

**ex:** ```nim c -d:emscripten -d:release -d:wasm ex208_framerate.nim```

Live demo: [wasm_ex208_framerate](https://jipok.github.io/Nim-SDL2-and-Emscripten/wasm_ex208_framerate/) 

If you're interested, the forum has a post with the benchmarks: [Nim in the browser: some benchmarks](https://forum.nim-lang.org/t/2991)

### ex205_sdl_gfx_primitives
The module gfxPrimitives is not included in sdl2. Also it does not exist in other ports. I had to compile it myself. Just download the libSDL2_gfx.o and add the linker option:

```passL %= "./libSDL2_gfx.o"```

## [Ports](https://kripken.github.io/emscripten-site/docs/compiling/Building-Projects.html#emscripten-ports)
All available ports are located here: https://github.com/emscripten-ports

Also in *$EMSCRIPTEN/tools/ports/* you can find scripts that download and build ports.

All ports are downloaded and unpacked in: *$HOME/.emscripten_ports/*

In *$HOME/.emscripten_cache/asmjs/* the cache and compiled ports are stored.

You can easily connect the desired port by specifying a flag for the linker.

**ex:** ```passL %= "-s USE_TTF=2"```

### sdl-image
This port requires additionally indicate for linker which formats need to be included:

**ex:** ```passL %= "-s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS=\'[\"png\"]\'"```

Also you can already use the version compiled by me(supports png and bmp). Download and add:

```passL %= "./libSDL2_image-png.o"```

## How to build port yourself?
You can see the script code from Emscripten, but they are not always effective. Also some information can be found in the wiki or on the [github](https://github.com/emscripten-ports/SDL2/blob/master/docs/README-emscripten.md).

Example of how to build SDL2:
```bash
git clone https://github.com/emscripten-ports/SDL2
cd SDL2-master
mkdir build
cd build
emconfigure ../configure --host=asmjs-unknown-emscripten --disable-assembly --disable-threads --disable-mmx --disable-sdltest --disable-shared --enable-cpuinfo=false CFLAGS="-O3"
emmake make
```
Similarly, a ttf and a mixer can be built with:
```bash
EMCONFIGURE_JS=1 emconfigure ../configure --disable-shared --disable-sdltest --disable-mmx
emmake make
```
Then you can collect the necessary *name.o* files using emcc.

**ex:** ```emcc ./freetype.bc ./*.o -o libSDL2_ttf.bc```

**tip**: ```llvm-nm file.o``` Will show what names the file exports
So you can build a library with only the required functionality.

### sdl-mixer
There is no separate port for the mixer. The built-in functions of sdl seem to play only wav. There also lacks some functions. For example: SetDistance

I didn't build the mixer with the support of mp3. 

Some tips and scripts you can find here: [link](https://github.com/kripken/emscripten/issues/3985#issuecomment-176910968)


## Why you shouldn't use SDL2 with Emscripten?
Because it has a large size and terrible architecture(port, not sdl).

At first I thought about dynamic linking. But this is an experimental feature([article](https://github.com/kripken/emscripten/wiki/Linking)) and I was not able to use SDL2 as side module.

In general, I spent a lot of time trying to reduce the size. But neither a myself builds with the necessary functionality, nor dynamic linking will not help.
Just take a look at how the SDL-image works:

It uses native functions to load the file and the libpng library. This adds about 1 megabyte and a loss in performance.
The correct way would be to use ready-made browser functions for working with images. The functions of SDL2 should have been just stubs that caused the corresponding functions on the js.

And a quick review of the code, shows that this is used everywhere. It's horrible. My perfectionism did not allow me to continue to use this option for cross-platform applications.

You can use sdl1. For emscripten there is a simple library that uses the correct method. Just take a look at her code. Just take a look at her code: [library_sdl.js](https://github.com/kripken/emscripten/blob/1.37.18/src/library_sdl.js)
