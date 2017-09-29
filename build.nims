#!/usr/bin/env nim
mode = ScriptMode.Silent

import strutils

let cmd = "nim c -p:.. --nimcache:../nimcache --hints:off --verbosity:0 -d:release"

for dir in listDirs("."):
  if dir.contains("ex"):
    withDir dir:

      var name = ""
      for file in listFiles("."):
        if file.endsWith(".nim"):
          name = file

      if name == "":
        echo "nothing to compile in ", dir
        continue

      echo dir, '/', name
      if dir.contains("wasm"):
        exec(cmd & " -d:wasm  " & name)
      else:
        exec(cmd & " -d:asmjs " & name)

rmDir "nimcache"