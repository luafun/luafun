package = "fun"
version = "scm-1"

source = {
    url = "git://github.com/rtsisyk/luafun.git",
}

description = {
    summary = "A high-performance functional programming library for LuaJIT",
    homepage = "https://rtsisyk.github.io/luafun",
    license = "MIT/X11",
    maintainer = "Roman Tsisyk <roman@tsisyk.com>",
    detailed = [[
Lua Fun is a high-performance functional programming library designed for LuaJIT
tracing just-in-time compiler.

The library provides a set of more than 50 programming primitives typically
found in languages like Standard ML, Haskell, Erlang, JavaScript, Python and
even Lisp. High-order functions such as map(), filter(), reduce(), zip() will
help you to write simple and efficient functional code.

Lua Fun. Simple, Efficient and Functional. In Lua. With JIT.
]]
}

dependencies = {
    "lua" -- actually "luajit >= 2.0"
}

build = {
    type = "builtin",
    modules = {
        fun = "fun.lua",
    },
    copy_directories = { "tests" },
}
