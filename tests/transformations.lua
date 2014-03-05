--------------------------------------------------------------------------------
-- map
--------------------------------------------------------------------------------

fun = function(...) return 'map', ... end

dump(map(fun, range(0)))
--[[test
--test]]


dump(map(fun, range(4)))
--[[test
map 1
map 2
map 3
map 4
--test]]

dump(map(fun, enumerate({"a", "b", "c", "d", "e"})))
--[[test
map 0 a
map 1 b
map 2 c
map 3 d
map 4 e
--test]]

dump(map(function(x) return 2 * x end, range(4)))
--[[test
2
4
6
8
--test]]

fun = nil
--[[test
--test]]

--------------------------------------------------------------------------------
-- enumerate
--------------------------------------------------------------------------------

dump(enumerate({"a", "b", "c", "d", "e"}))
--[[test
0 a
1 b
2 c
3 d
4 e
--test]]

dump(enumerate(enumerate(enumerate({"a", "b", "c", "d", "e"}))))
--[[test
0 0 0 a
1 1 1 b
2 2 2 c
3 3 3 d
4 4 4 e
--test]]

dump(enumerate(zip({"one", "two", "three", "four", "five"},
    {"a", "b", "c", "d", "e"})))
--[[test
0 one a
1 two b
2 three c
3 four d
4 five e
--test]]

--------------------------------------------------------------------------------
-- intersperse
--------------------------------------------------------------------------------

dump(intersperse("x", {}))

dump(intersperse("x", {"a", "b", "c", "d", "e"}))
--[[test
a
x
b
x
c
x
d
x
e
x
--test]]

dump(intersperse("x", {"a", "b", "c", "d", "e", "f"}))
--[[test
a
x
b
x
c
x
d
x
e
x
f
x
--test]]
