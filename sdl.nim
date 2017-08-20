import sdl2/sdl

#Таймеры: из-за многопоточности
#framerate тоже из-за многопточности?
#mixer: не воспроизводит ничего кроме wav
#mixer: setDistance не работает?
#ex105_syswm.nim не работает. getWindowWMInfo не определена
#Код после mainLoop в emscripten не исполняется. но можно руками выходить из цикла

when defined(emscripten):
  import jsbind/emscripten

  template mainLoop*(statement, actions: untyped): untyped =
    proc emscLoop{.cdecl.} =
      if statement:
        emscripten_cancel_main_loop()
        sdl.quit()
        system.quit()
      else:
        actions
      
    emscripten_set_main_loop(emscLoop, 0 ,1)

  when defined(sdl_custom_log):
    proc customLogger (userdata: pointer; category: LogCategory; priority: LogPriority; message: cstring) {.cdecl.} =
      echo priority, ":", message  
    sdl.logSetOutputFunction(customLogger, nil)
    sdl.logSetAllPriority(LOG_PRIORITY_VERBOSE);

else:

  template mainLoop*(statement, actions: untyped): untyped =
    while not statement:
      actions
  
export sdl