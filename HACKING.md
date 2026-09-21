# Hacking

## Build documentation

The documentation is generated from the EmmyLua annotations in `fun.lua`
with [emmylua_doc_cli](https://github.com/EmmyLuaLs/emmylua-analyzer-rust)
and built into a static site with [Sphinx](https://www.sphinx-doc.org/);
the generated Markdown is parsed with
[MyST](https://myst-parser.readthedocs.io/). The general documentation
chapters live in reStructuredText under `doc/`.

Prerequisites:

* `emmylua_doc_cli` (cargo install emmylua_doc_cli --version 0.25.1)
* `sphinx` and `myst-parser`

Install the Python dependencies:

```sh
$ make deps
```

Build the documentation site into `site/`:

```sh
$ make docs
$ xdg-open site/index.html
```

Serve the documentation locally for preview (hot reload):

```sh
$ make serve
```

Export only the API reference markdown from `fun.lua` into `build/docs/`
(without building the site):

```sh
$ make api-docs
```

The Sphinx source tree is assembled in `build/sphinx/` from `doc/` and the
generated markdown; adjust `doc/conf.py` and `doc/reference.rst` to change
the theme or the table of contents.

Cleanup generated artifacts (`build/` and `site/`):

```sh
$ make clean
```

## Run static analysis

```sh
$ make check
```

## Run tests

```sh
$ make test
```
