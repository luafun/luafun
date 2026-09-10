std = "luajit"
ignore = {
    -- Redefining a local variable.
    "411",
    -- Redefining an argument.
    "412",
    -- Shadowing an upvalue argument.
    "432",
    -- Unused variable with `_` prefix.
    "211/_.*",
    -- Unused loop variable with `_` prefix.
    "213/_.*",
    -- Access to an undefined field of a global variable.
	"113",
}

include_files = {
    "**/*.lua",
}

exclude_files = {
    ".rocks/**/*.lua",
    ".git/**/*.lua",
}

files["tests/*.lua"] = {
    ignore = {
        "111",
    },
}
