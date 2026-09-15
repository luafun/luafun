#!/usr/bin/env python3
"""Split the flat generated `fun` module page into per-category pages.

`emmylua_doc_cli` documents all exported functions on a single
`modules/fun.md` page.  The desired documentation groups the functions
the same way the library does (Basic Functions, Generators, Slicing, ...),
which is expressed by `---@category` tags in `fun.lua`.

Usage: split_api.py <sphinx_src> <fun.lua>
"""

import os
import re
import sys

# slug -> page title, in the order in which the pages should appear
CATEGORIES = [
    ("basic", "Basic Functions"),
    ("generators", "Generators"),
    ("slicing", "Slicing"),
    ("indexing", "Indexing"),
    ("filtering", "Filtering"),
    ("reducing", "Reducing"),
    ("transformations", "Transformations"),
    ("compositions", "Compositions"),
    ("operators", "Operators"),
    ("internal", "Internal"),
]
TITLES = {title for _, title in CATEGORIES}

# slug -> introductory text inserted right after the page title
INTROS = {
    "basic": (
        "The section contains functions to create iterators from Lua objects."
    ),
    "generators": (
        "This section contains a number of useful generators modeled after\n"
        "Standard ML, Haskell, Python, Ruby, JavaScript and other languages."
    ),
    "slicing": (
        "This section contains functions to make subsequences from iterators."
    ),
    "indexing": (
        "This section contains functions to find elements by its values."
    ),
    "filtering": (
        "This section contains functions to filter values during iteration."
    ),
    "reducing": (
        "The section contains functions to analyze iteration values and\n"
        "recombine through use of a given combining operation the results of\n"
        "recursively processing its constituent parts, building up a return\n"
        "value\n"
        "\n"
        "```{note}\n"
        "An attempt to use infinity iterators with the most function from the\n"
        "module causes an infinite loop.\n"
        "```"
    ),
    "operators": (
        "This auxiliary module exports a set of Lua operators as intrinsic\n"
        "functions to use with the library high-order primitives."
    ),
}

# slug -> ordered (sub-heading, [function names]) groups.  A sub-heading is
# written before the first function of its group and the function headings
# are demoted to level 3 so that they nest under it.
SECTIONS = {
    "generators": [
        ("Finite Generators", ["range"]),
        ("Infinity Generators",
         ["duplicate", "replicate", "xrepeat", "tabulate", "zeros", "ones"]),
        ("Random sampling", ["rands"]),
    ],
    "slicing": [
        ("Basic", ["nth", "head", "car", "tail", "cdr"]),
        ("Subsequences",
         ["take_n", "take_while", "take", "drop_n", "drop_while", "drop",
          "span", "split", "split_at"]),
    ],
    "reducing": [
        ("Folds", ["foldl", "reduce", "length", "totable", "tomap"]),
        ("Predicates",
         ["is_prefix_of", "is_null", "all", "every", "any", "some"]),
        ("Special folds",
         ["sum", "product", "min", "minimum", "min_by", "minimum_by",
          "max", "maximum", "max_by", "maximum_by"]),
    ],
}


def add_subheadings(slug, sections):
    """Insert the sub-headings of a page and demote its function headings."""
    groups = SECTIONS.get(slug)
    if not groups:
        return sections
    heading_of = {}
    for heading, names in groups:
        for name in names:
            heading_of[name] = heading
    out = []
    seen = set()
    for section in sections:
        m = re.match(r"## fun\.([A-Za-z_]\w*)", section)
        name = m.group(1) if m else None
        heading = heading_of.get(name)
        if heading and heading not in seen:
            seen.add(heading)
            out.append("## %s" % heading)
        # demote "## fun.x" to "### fun.x" so that it nests under the heading
        out.append("#" + section)
    return out


def parse_categories(path):
    """Return a function name -> category resolver built from `fun.lua`."""
    name_cat = {}
    alias = {}
    pending = None
    decl = re.compile(
        r"^local\s+([A-Za-z_]\w*)\s*=\s*(?:function|\{)"
        r"|^local\s+function\s+([A-Za-z_]\w*)\("
    )
    exports = re.compile(r"^exports\.([A-Za-z_]\w*)\s*=\s*(?:exports\.)?([A-Za-z_]\w*)\s*$")
    methods = re.compile(r"^methods\.([A-Za-z_]\w*)\s*=\s*(?:methods\.)?([A-Za-z_]\w*)\s*$")

    for line in open(path).read().split("\n"):
        m = re.match(r"^\s*---@category\s+(.+?)\s*$", line)
        if m:
            pending = m.group(1)
            continue
        m = decl.match(line)
        if m:
            if pending:
                name_cat[m.group(1) or m.group(2)] = pending
                pending = None
            continue
        m = exports.match(line)
        if m:
            alias[m.group(1)] = m.group(2)
            pending = None
            continue
        m = methods.match(line)
        if m:
            alias.setdefault(m.group(1), m.group(2))

    def resolve(name, seen=None):
        seen = seen or set()
        if name in name_cat:
            return name_cat[name]
        if name in alias and name not in seen:
            seen.add(name)
            return resolve(alias[name], seen)
        return None

    return resolve


def main():
    sphinx_src, fun_lua = sys.argv[1], sys.argv[2]
    resolve = parse_categories(fun_lua)

    modules_dir = os.path.join(sphinx_src, "modules")
    page = os.path.join(modules_dir, "fun.md")
    text = open(page).read()

    sections = [s.rstrip("\n") for s in re.split(r"(?m)^(?=### )", text) if s.startswith("### ")]

    groups = {title: [] for _, title in CATEGORIES}
    other = []
    for section in sections:
        m = re.match(r"###\s+fun\.([A-Za-z_]\w*)", section)
        if not m:
            continue
        # drop tag lines rendered by the markdown templates
        section = "\n".join(
            line for line in section.split("\n") if not re.match(r"^\s*@category\s", line)
        )
        # a trailing "## fields" block (operator/op) belongs to the next
        # section; cut it off here
        lines = section.split("\n")
        kept = [lines[0]]
        for line in lines[1:]:
            if line.startswith("## "):
                break
            kept.append(line)
        section = "\n".join(kept).rstrip("\n")
        # demote "### fun.x" to "## fun.x" so that the page title (H1) is
        # followed by H2 headings (avoid MyST "non-consecutive header")
        section = re.sub(r"^### ", "## ", section, count=1)
        title = resolve(m.group(1))
        if title in TITLES:
            groups[title].append(section)
        else:
            other.append(section)

    # the pages live next to the other chapters (index.md, intro.md, ...),
    # so that their URLs match the old documentation (e.g. /filtering.html)
    for slug, title in CATEGORIES:
        if not groups[title]:
            continue
        with open(os.path.join(sphinx_src, slug + ".md"), "w") as f:
            f.write("# %s\n\n" % title)
            if slug in INTROS:
                f.write(INTROS[slug] + "\n\n")
            f.write("\n\n".join(add_subheadings(slug, groups[title])))
            f.write("\n")
    if other:
        with open(os.path.join(sphinx_src, "other.md"), "w") as f:
            f.write("# Other\n\n")
            f.write("\n\n".join(other))
            f.write("\n")
        print("warning: %d function(s) without a category -> other.md" % len(other))

    # remove tag lines rendered on the remaining type pages
    types_dir = os.path.join(sphinx_src, "types")
    for root, _dirs, files in os.walk(types_dir):
        for name in files:
            if not name.endswith(".md"):
                continue
            path = os.path.join(root, name)
            with open(path) as f:
                content = f.read()
            cleaned = "\n".join(
                line
                for line in content.split("\n")
                if not re.match(r"^\s*@category\s", line)
            )
            if cleaned != content:
                with open(path, "w") as f:
                    f.write(cleaned)

    # the flat pages are replaced by the per-category ones
    for flat in (page, os.path.join(sphinx_src, "types", "fun.md")):
        if os.path.exists(flat):
            os.remove(flat)


if __name__ == "__main__":
    main()
