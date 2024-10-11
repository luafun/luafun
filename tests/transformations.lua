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
map 1 a
map 2 b
map 3 c
map 4 d
map 5 e
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
-- pick
--------------------------------------------------------------------------------
local t = {}
for _, x in pick(3, zip({ 1, 2, 3 }, { 4, 5, 6 }, { 7, 8, 9 }, { 10, 11, 12 })) do
    t[#t + 1] = x
end
table.sort(t)
for _, x in ipairs(t) do
    print(x)
end
--[[test
7
8
9
--test]]

--------------------------------------------------------------------------------
-- keys
--------------------------------------------------------------------------------
local t = {}
for _, k in keys({a = 1, b = 2, c = 3}) do
    t[#t+1] = k
end
table.sort(t)
for _, k in ipairs(t) do
    print(k)
end
--[[test
a
b
c
--test]]

--------------------------------------------------------------------------------
-- values
--------------------------------------------------------------------------------
local t = {}
for _, k in values({ a = 1, b = 2, c = 3 }) do
    t[#t + 1] = k
end
table.sort(t)
for _, k in ipairs(t) do
    print(k)
end
--[[test
1
2
3
--test]]

print(sum(values({ a = 1, b = 2, c = 3})))
--[[test
6
--test]]

--------------------------------------------------------------------------------
-- enumerate
--------------------------------------------------------------------------------

dump(enumerate({"a", "b", "c", "d", "e"}))
--[[test
1 a
2 b
3 c
4 d
5 e
--test]]

dump(enumerate(enumerate(enumerate({"a", "b", "c", "d", "e"}))))
--[[test
1 1 1 a
2 2 2 b
3 3 3 c
4 4 4 d
5 5 5 e
--test]]

dump(enumerate(zip({"one", "two", "three", "four", "five"},
    {"a", "b", "c", "d", "e"})))
--[[test
1 one a
2 two b
3 three c
4 four d
5 five e
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
