This is an experimental project to work with elm-in-elm ASTs
to evaluate Elm code on the fly.

All of this is built on top of elm-in-elm, which is in very
early stages, and then mini-elm itself is very beta.

There are two ways we try to evaluate an elm-in-elm AST (if
it even compiles):

- We hand it off to [meta-elm](https://github.com/showell/meta-elm)
  and let it run its eval loop.

- We use [eval.js](https://github.com/showell/mini-elm/blob/master/src/eval.js)
  to directly run an eval loop against the elm-in-elm AST.

In order for `eval.js` to do its thing, we have to hack the
Elm compiler's output.  Instructions:

   elm make src/Make.elm
   python postprocess.py
   < run index2.html in browser >
