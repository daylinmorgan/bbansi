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
  import std/[strformat, parseopt]
  const version = staticExec "git describe --tags --always --dirty=-dev"
  let help = &"""
{bb"[bold]bbansi[/] [green]<args>[/] [black]<-h|-v>[/]"}

usage:
  bbansi "[yellow] yellow text!"
    |-> {bb"[yellow] yellow text!"}
  bbansi "[bold red] bold red[/] plain text..." 
    |-> {bb"[bold red] bold red text[/] plain text..."}
"""
  proc writeHelp() =
    echo help
    quit(QuitSuccess)
  proc writeVersion() =
    echo "bbansi version -> ", version
    quit(QuitSuccess)
  var strArgs: seq[string]
  var p = initOptParser()
  for kind, key, val in p.getopt():
    case kind:
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
      case key:
        of "help", "h": writeHelp()
        of "version","v": writeVersion()
        else:
          echo bb"[red]ERROR[/]: unexpected option/value -> ", key, ", ", val
          echo "Option and value: ", key, ", ", val

    of cmdArgument:
      strArgs.add key

  if strArgs.len != 0:
    for arg in strArgs:
      echo arg.bb
  else:
    echo "[bold]---------------------".bb
    echo bb"[bold]bold"
    echo bb"[red]red"
    echo bb"[bold red]bold red"
    echo bb"[bold red]bold red[reset] no more red" 
    echo bb"[unknown]this text is red no?"
    echo bb"\[red] <- not a pattern "
