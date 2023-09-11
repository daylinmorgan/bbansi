# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.
import std/[os, strutils]
import bbansi/styles

# TODO: add support for some kind of FORCE_COLOR
let noColor = os.getEnv("NO_COLOR") != ""


proc bb*(s: string): string =
  ## convert bbcode markup to ansi escape codes
  var
    i = 0
    addReset = false
    pattern = ""
    preChar = ' '

  while i < s.len:
    # start extracting pattern when you see '[' but not '[['
    if s[i] == '\\':
      inc i
      if s[i] == '[':
        result.add s[i]
        inc i
        continue

    if s[i] == '[' and preChar != '\\':
      inc i
      while i < s.len and s[i] != ']':
        preChar = s[i]
        pattern.add s[i]
        inc i

      if noColor:
        inc i
        continue
      if pattern in ["reset","/"]:
        result.add bbReset
        addReset = false
      else:
        for style in pattern.splitWhitespace():
          if style in codeMap:
            addReset = true
            result.add "\e[" & codeMap[style] & "m"
      pattern = ""
      inc i
    else:
      preChar = s[i]
      result.add s[i]
      inc i

  if addReset:
    result.add "\e[0m"

when isMainModule:
  echo bb"[bold]bold"
  echo bb"[red]red"
  echo bb"[bold red]bold red"
  echo bb"[bold red]bold red[reset] no more red" 
  echo bb"[unknown]this text is red no?"
  echo bb"\[red] <- not a pattern "
