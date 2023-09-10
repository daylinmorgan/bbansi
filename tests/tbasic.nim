# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import bbansi
test "basic":
  check "\e[31mRed Text\e[0m" == bb"[red]Red Text"
  check "No Style" == bb"No Style"
  check "Unknown Style" == bb"[unknown]Unknown Style"
  check "\e[1m\e[31mBold Red Text\e[0m" == bb"[bold red]Bold Red Text"
  check "\e[1m\e[31mBold Red Text\e[0mPlain Text" == bb"[bold red]Bold Red Text[reset]Plain Text"
  # not sure how rich handles this
  check "[red] ignored pattern" == bb"[[red] ignored pattern"
