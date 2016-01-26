package = "fun"
version = "0.1.3-1"
source = {
   url = "git://github.com/rtsisyk/luafun.git",
   tag = "0.1.3"
}
description = {
   summary = "High-performance functional programming library for Lua",
   detailed = [[
Lua Fun is a high-performance functional programming library for Lua
designed with LuaJIT's trace compiler in mind.

Lua Fun provides a set of more than 50 programming primitives typically
found in languages like Standard ML, Haskell, Erlang, JavaScript, Python and
even Lisp. High-order functions such as map, filter, reduce, zip, etc.,
make it easy to write simple and efficient functional code.
]],
   homepage = "https://rtsisyk.github.io/luafun",
   license = "MIT/X11",
   maintainer = "Roman Tsisyk <roman@tarantool.org>"
}
dependencies = {
   "lua"
}
build = {
   type = "builtin",
   modules = {
      fun = "fun.lua"
   },
   copy_directories = {
      "tests"
   }
}
