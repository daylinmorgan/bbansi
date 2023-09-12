import std/[os, sequtils, strutils, sugar]
import bbansi/styles

# TODO: add support for some kind of FORCE_COLOR and detect terminals...
let noColor = os.getEnv("NO_COLOR") != ""

type
  BbSpan = object
    styles: seq[string]
    slice: array[2, int]
  BbString = object
    raw: string
    plain: string
    spans: seq[BbSpan]

proc debug(bbs: BbString): string =
  echo "bbString("
  echo "  raw: ", bbs.raw
  echo "  plain: ", bbs.plain
  echo "  spans: ", bbs.spans
  echo ")"

proc `&`*(x: BbString, y: string): BbString =
  result = x
  result.raw &= y
  result.plain &= y
  result.spans[^1].slice[1] = result.plain.len-1

proc `&`*(x: string, y: BbString): BbString =
  result.raw = x & y.raw
  result.plain = x & y.plain
  result.spans.add BbSpan(styles: @[],slice: [0, x.len-1] )
  for span in y.spans:
    let
      length = x.len
      styles = span.styles
      slice = span.slice
    result.spans.add BbSpan(styles: styles, slice: [slice[0]+length,slice[1]+length])

func len*(bbs: BbString): int = bbs.plain.len

proc `$`*(bbs: BbString): string =
  if noColor: return bbs.plain

  for span in bbs.spans:
    var codes = ""
    if span.styles.len > 0:
      codes = collect(for style in span.styles: style.toAnsiCode).join("")

    result.add codes
    result.add bbs.plain[span.slice[0]..span.slice[1]]

    if codes != "":
      result.add bbReset

proc endSpan(bbs: var BbString) =
  bbs.spans[^1].slice[1] = bbs.plain.len-1

proc newSpan(bbs: var BbString, pattern: string) =
  bbs.spans.add BbSpan(styles: @[pattern], slice: [bbs.plain.len, 0])

proc resetSpan(bbs: var BbString) =
  bbs.endSpan
  bbs.spans.add BbSpan(styles: @[], slice: [bbs.plain.len, 0])

proc closeLastStyle(bbs: var BbString) =
  bbs.endSpan
  let newStyle = bbs.spans[^1].styles[0..^2] # drop the latest style
  bbs.spans.add BbSpan(styles: newStyle, slice: [bbs.plain.len, 0])

proc addToSpan(bbs: var BbString, pattern: string) =
  bbs.endSpan
  let currStyl = bbs.spans[^1].styles
  bbs.spans.add BbSpan(styles: currStyl & @[pattern], slice: [bbs.plain.len, 0])

proc closeStyle(bbs: var BbString, pattern: string) =
  let style = pattern[1..^1].strip()
  if style in bbs.spans[^1].styles:
    bbs.endSpan
    let newStyle = bbs.spans[^1].styles.filterIt(it != style) # use sets instead
    bbs.spans.add BbSpan(styles: newStyle, slice: [bbs.plain.len, 0])

proc closeFinalSpan(bbs: var BbString) =
  if bbs.spans.len >= 1 and bbs.spans[^1].slice[1] == 0:
    bbs.endSpan

proc bb*(s: string): BbString =
  ## convert bbcode markup to ansi escape codes
  var
    pattern: string
    i = 0

  template next = result.plain.add s[i]; inc i
  template incPattern = pattern.add s[i]; inc i
  template resetPattern = pattern = ""; inc i

  result.raw = s
  if not s.startswith('[') or s.startswith("[["):
    result.spans.add BbSpan()

  while i < s.len:
    case s[i]:
      of '\\':
        if i < s.len and s[i+1] == '[':
          inc i
        next
      of '[':
        if i < s.len and s[i+1] == '[':
          inc i; next; continue
        inc i
        while i < s.len and s[i] != ']':
          incPattern
        pattern = pattern.strip()
        if result.spans.len > 0:
          if pattern == "/": result.closeLastStyle
          elif pattern == "reset": result.resetSpan
          elif pattern.startswith('/'): result.closeStyle pattern
          else: result.addToSpan pattern
        else: result.newSpan pattern
        resetPattern
      else:
        next
  result.closeFinalSpan

proc bb*(s: string, style: string): BbString =
  bb("[" & style & "]" & s & "[/" & style & "]")

proc `&`*(x: BbString, y: BbString): Bbstring =
  # there is probably a more efficient way to do this
  bb(x.raw & y.raw)


# ---- cli
when isMainModule:
  import std/[strformat, parseopt]
  const version = staticExec "git describe --tags --always --dirty=-dev"
  let help = &"""
{bb"[bold]bbansi[/] \[[green]args...[/]] [faint][[-h,-v][/]"}

{bb"[italic]usage"}:
  bbansi "[yellow] yellow text!"
    |-> {bb"[yellow] yellow text!"}
  bbansi "[bold red] bold red text[/] plain text..." 
    |-> {bb"[bold red] bold red text[/] plain text..."}

flags:
  """ & $(bb(collect(for (s, l, d) in [
        ("h", "help", "show this help"),
        ("v", "version", "show version")]:
        &"[yellow]-{s}[/]  [green]--{l.alignLeft(8)}[/] {d}").join("\n  ")
        ))
  proc writeHelp() =
    echo help
    quit(QuitSuccess)
  proc writeVersion() =
    echo bb(&"[yellow]bbansi version[/][red] ->[/] [bold]{version}[/]")
    quit(QuitSuccess)
  var strArgs: seq[string]
  var p = initOptParser()
  for kind, key, val in p.getopt():
    case kind:
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
      case key:
        of "help", "h": writeHelp()
        of "version", "v": writeVersion()
        else:
          echo bb"[red]ERROR[/]: unexpected option/value -> ", key, ", ", val
          echo "Option and value: ", key, ", ", val

    of cmdArgument:
      strArgs.add key
  if strArgs.len == 0:
    echo help
    quit(QuitSuccess)
  for arg in strArgs:
    echo arg.bb
