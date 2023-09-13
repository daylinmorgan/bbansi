import std/[strtabs, strutils]

let bbReset* = "\e[0m"

let
  bbStyles* = {
   "bold": "1",
   "b": "1",
   "faint": "2",
   "italic": "3",
   "i": "3",
   "underline": "4",
   "u": "4",
   "blink": "5",
   "reverse": "7",
   "conceal": "8",
   "strike": "9",

    }.newStringTable(modeCaseInsensitive)

  bbColors* = {
    "black": "0",
    "red": "1",
    "green": "2",
    "yellow": "3",
    "blue": "4",
    "magenta": "5",
    "cyan": "6",
    "white": "7",
    }.newStringTable(modeCaseInsensitive)

proc toAnsiCode*(s: string): string =
  var
    styles: seq[string]
    bgStyle: string
  if " on " in s or s.startswith("on"):
    let fgBgSplit = s.rsplit("on", maxsplit = 1)
    styles = fgBgSplit[0].splitWhitespace()
    bgStyle = fgBgSplit[1].strip()
  else:
    styles = s.splitWhitespace()
  for style in styles:
    if style in bbStyles:
      result.add "\e[" & bbStyles[style] & "m"
    elif style in bbColors:
      result.add "\e[3" & bbColors[style] & "m"

  let style = bgStyle
  if style in bbColors:
    result.add "\e[4" & bbColors[style] & "m"

