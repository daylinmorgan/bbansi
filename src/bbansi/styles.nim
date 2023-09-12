
import std/[strtabs, strutils]

export strtabs

let bbReset* = "\e[0m"

type
  BbStyle = enum
    bold = 1,
    faint,
    italic,
    underline,
    blink,
    reverse=7,
    conceal,
    strike,
    black = 30
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white


proc toAnsiCode*(s: string): string =
  var 
    styles: seq[string]
    bgStyle: string
  if " on " in s:
    let fg_bg_split = s.rsplit(" on ", maxsplit=1)
    styles = fg_bg_split[0].splitWhitespace()
    bgStyle = fg_bg_split[1].strip()
  else:
    styles = s.splitWhitespace()
  for style in styles:
    try:
      var bbStyle: BbStyle
      if style.len == 1:
        bbstyle = parseEnum[BbStyle](
          case style:
          of "b": "bold"
          of "i": "italic"
          of "u": "underline"
          else: "" # this parse enum lookup is unneccesary
        )
      else:
        bbstyle = parseEnum[BbStyle](style)
      # if we fail to parse treat it like a noop..
      result.add "\e[" & $bbStyle.ord() & "m"
    except ValueError: discard
    try:
      let bbStyle = parseEnum[BbStyle](bgStyle)
      result.add "\e[" & $(bbStyle.ord()+10) & "m"
    except ValueError: discard

