# Build scripts

This contains the template engine which builds the site.

## Template language

Syntax:

- `{expr}` becomes the contents of `expr`, an **expression**. Expressions are
  - Numbers, strings, `true`, `false`
  - Binding paths, e.g. `foo`, `foo.bar`, `foo.5`, `foo:bar`, `foo.bar:baz.qux:abc` (note that the symbol after the `:` must be an identifier, not anything more complex)
  - Local binding and then an expression, e.g. `foo=bar;baz` evaluates to `baz` where `foo` is bound to `bar`. The bound value (`bar`) can be anything except another local binding
  - **Path**: `/foo.txt`, `/foo/bar.html`, `/foo/bar/baz.json?query=param`. This expands to the actual file contents, where the query keys (if provided) are bound to their respective values.
    - If the file is `json` it will be an object.
    - If the file is `txt` or `html` it will be a string
    - If the file is `md` it will be a string with markdown converted to HTML using [luamd](https://github.com/bakpakin/luamd)
    - Any other files aren't supported
- `<!--for key,value in expr -->...<!--end -->` repeats `...` binding `key` and `value` to each entry in `expr`. If an array, `key` is optional and will be the index.
- `<!--if expr -->...if<!--else -->...else<!--end -->` becomes `...if` if `expr` is `true`, `...else` if `false`. The `else` block is optional. `expr` must evaluate to `true` or `false`.

Other stuff:

- `root` is always bound to `root.json`, so `root.field` resolves to `field` located within `root.json`
- For security, implementors may want to represent HTML code as a separate datatype from strings, and make raw strings HTML-escape. This implementation doesn't do that

## Why?

Why did I make my own template engine when there are so many others? It was interesting and it only took a few hours.
