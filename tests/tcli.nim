import std/[
  compilesettings,
  os,
  osproc,
  strutils,
  unittest
]

const pathToSrc = querySetting(SingleValueSetting.projectPath)

proc cliRun(cmd: string): string =
  let (output, _) = execCmdEx(pathToSrc / "bbansi.out " & cmd)
  return output.strip()

suite "cli":
  setup:
    let cmd = "nim c -o:" & pathToSrc / "bbansi.out " & (pathToSrc / ".." /
        "src" / "bbansi.nim")
    check execCmdEx(cmd).exitCode == 0
  test "simple":
    check "\e[31mRed\e[0m" == cliRun "[red]Red[/]"
    check "\e[1;31mRed\e[0m\e[1m Not Red but Bold\e[0m" ==
        cliRun "'[red]Red[/] Not Red but Bold' " & "--style:bold"
