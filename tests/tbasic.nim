# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import bbansi

suite "basic":
  test "simple":
    check "\e[31mRed Text\e[0m" == $bb"[red]Red Text"
    check "\e[33mYellow Text\e[0m" == $bb"[yellow]Yellow Text"
    check "\e[1m\e[31mBold Red Text\e[0m" == $bb"[bold red]Bold Red Text"

  test "closing":
    check "\e[1mBold\e[0m\e[1m\e[31m Bold Red\e[0m\e[1m Bold Only\e[0m" ==
      $bb"[bold]Bold[red] Bold Red[/red] Bold Only"

  test "abbreviated":
    check "\e[1mBold\e[0m Not Bold" == $bb"[b]Bold[/] Not Bold"

  test "noop":
    check "No Style" == $bb"No Style"
    check "Unknown Style" == $bb"[unknown]Unknown Style"

  test "escaped":
    check "[red] ignored pattern" == $"[[red] ignored pattern".bb

  test "newlines":
    # Proc Strings: raw strings,
    # but the method name that prefixes the string is called
    # so that foo"12\" -> foo(r"12\")
    check "\e[31mRed Text\e[0m\nNext Line" == $"[red]Red Text[/]\nNext Line".bb

  test "concat-ops":
    check "[red]RED[/]".bb & " plain string" == "[red]RED[/] plain string".bb
    check "[red]RED[/]".bb.len == 3
    check bb("[blue]Blue[/]") & " " & bb("[red]Red[/]") == "[blue]Blue[/] [red]Red[/]".bb
    check "a plain string" & "[blue] a blue string".bb == "a plain string[blue] a blue string".bb
