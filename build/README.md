# Build scripts

This contains the template engine which builds the site.

Syntax:

- `$expr` becomes the contents of `expr`, an expression.
- `@/path` becomes the contents of the `path` from the URL root.
- `<!--input foo,bar -->` denotes that `foo` and `bar` should be bound when this content is loaded. `@/path?foo="abc",bar="xyz"` binds variables `foo` and `bar` in the contents to `path`. Any bound variables in `@path` *must* be in `<!--input -->`.
- `<!--for key,value in expr -->...<!--end -->` repeats `...` binding `key` and `value` to each entry in `expr`. If an array, `key` is optional and will be the index.
- `<!--if expr -->...if<!--else -->...else<!--end -->` becomes `...if` if `expr` is `true`, `...else` if `false`. The `else` block is optional. `expr` must evaluate to `true` or `false`.

Other stuff:

- Expressions are `foo`, `foo.bar`, `foo[3].bar`, `foo[bar].baz`, etc. strings, numbers, `true`, and `false`. There are no functions
- `root` is always bound to `root.json`, so `root.field` resolves to `field` located within `root.json`
- Data loaded from `@path` must be HTML, Markdown, or text. Markdown gets converted to HTML (text also does but it's just text).

Edge cases:

- There must be no spaces in expressions or paths. Spaces denote the end of expressions or paths
- You must put the `/` after the `@` to denote a path.
- If you need to denote the end of an expression or path without a space or newline or other non-expression/path character, use `$` for expressions and `@` for paths (`$expr$` or `@/path@`)
- Use `$$` to escape `$` and `@/@/` to escape `@/`

Why did I make my own template engine when there are so many others? It was interesting and it only took a few hours.
