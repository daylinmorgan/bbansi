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
    codes: seq[string]
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
      codes.add bbStyles[style]
    elif style in bbColors:
      codes.add "3" & bbColors[style]
  if bgStyle in bbColors:
    codes.add "4" & bbColors[bgStyle]

  if codes.len > 0:
    result.add "\e["
    result.add codes.join ";"
    result.add "m"

