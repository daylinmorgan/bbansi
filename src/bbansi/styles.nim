
import strtabs

export strtabs

let bbReset* ="\e[0m"

let
  codeMap* = {
    "reset":"0",
    "bold": "1",
    "faint": "2",
    "italic":"3",
    "underline":"4",
    "blink":"5",
    "reverse":"7",
    "conceal":"8",
    "strike":"9",
    "black":"30",
    "red": "31",
    "green":"32",
    "yellow":"33",
    "blue":"34",
    "magenta":"35",
    "cyan":"36",
    "white":"37",
  }.newStringTable(modeCaseInsensitive)
