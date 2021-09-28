# mirror - compile and run time reflection for D

[![Actions Status](https://github.com/atilaneves/mirror/workflows/CI/badge.svg)](https://github.com/atilaneves/mirror/actions)
[![Coverage](https://codecov.io/gh/atilaneves/mirror/branch/master/graph/badge.svg)](https://codecov.io/gh/atilaneves/mirror)

## A unified API for compile and runtime reflection in D

D is known for its unparalled compile-time reflection, but the API to
do so is distributed among the built-in `__traits` and the
`std.traits` package in the standard library.  There was no one single
place with a unified API for doing reflection in D. This package
solves that problem.

Furthermore, it attempts to, at the same time, extend the compile-time
reflection capabilities of D into the runtime realm *and* allow users
to write "regular" code with mixins and CTFE instead of template
metaprogramming. This is done by transforming types and symbols into
strings. See the tests and the `mirror.ctfe` package for more.
