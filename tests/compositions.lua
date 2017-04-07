--------------------------------------------------------------------------------
-- zip
--------------------------------------------------------------------------------

dump(zip({"a", "b", "c", "d"}, {"one", "two", "three"}))
--[[test
a one
b two
c three
--test]]

dump(zip())
--[[test
--test]]

dump(zip(range(0)))
--[[test
error: invalid iterator
--test]]

dump(zip(range(0), range(0)))
--[[test
error: invalid iterator
--test]]

print(nth(10, zip(range(1, 100, 3), range(1, 100, 5), range(1, 100, 7))))
--[[test
28 46 64
--test]]

dump(zip(partition(function(x) return x > 7 end, range(1, 15, 1))))
--[[test
8 1
9 2
10 3
11 4
12 5
13 6
14 7
--test]]

--------------------------------------------------------------------------------
-- cycle
--------------------------------------------------------------------------------

dump(take(15, cycle({"a", "b", "c", "d", "e"})))
--[[test
a
b
c
d
e
a
b
c
d
e
a
b
c
d
e
--test]]


dump(take(15, cycle(range(5))))
--[[test
1
2
3
4
5
1
2
3
4
5
1
2
3
4
5
--test]]

dump(take(15, cycle(zip(range(5), {"a", "b", "c", "d", "e"}))))
--[[test
1 a
2 b
3 c
4 d
5 e
1 a
2 b
3 c
4 d
5 e
1 a
2 b
3 c
4 d
5 e
--test]]

--------------------------------------------------------------------------------
-- chain
--------------------------------------------------------------------------------

dump(chain(range(2)))
--[[test
1
2
--test]]

dump(chain(range(2), {"a", "b", "c"}, {"one", "two", "three"}))
--[[test
1
2
a
b
c
one
two
three
--test]]

dump(take(15, cycle(chain(enumerate({"a", "b", "c"}),
    {"one", "two", "three"}))))
--[[test
1 a
2 b
3 c
one
two
three
1 a
2 b
3 c
one
two
three
1 a
2 b
3 c
--test]]

local tab = {}
local keys = {}
for _it, k, v in chain({ a = 11, b = 12, c = 13}, { d = 21, e = 22 }) do
    tab[k] = v
    table.insert(keys, k)
end
table.sort(keys)
for _, key in ipairs(keys) do print(key, tab[key]) end
--[[test
a 11
b 12
c 13
d 21
e 22
--test]]

dump(chain(range(0), range(0), range(0)))
--[[test
error: invalid iterator
--test]]

dump(chain(range(0), range(1), range(0)))
--[[test
error: invalid iterator
--test]]

--------------------------------------------------------------------------------
-- chain_from
--------------------------------------------------------------------------------

dump(chain_from{"abc"})
--[[test
a
b
c
--test]]

dump(chain_from{(range(2)), (range(3))})
--[[test
1
2
1
2
3
--test]]

dump(chain_from(map(range, range(3))))
--[[test
1
1
2
1
2
3
--test]]

dump(take(15, cycle(chain_from{ (enumerate{"a", "b", "c"}),
    {"one", "two", "three"} })))
--[[test
1 a
2 b
3 c
one
two
three
1 a
2 b
3 c
one
two
three
1 a
2 b
3 c
--test]]

local tab = {}
local keys = {}
for _it, k, v in chain_from{ { a = 11, b = 12, c = 13}, { d = 21, e = 22 } } do
    tab[k] = v
    table.insert(keys, k)
end
table.sort(keys)
for _, key in ipairs(keys) do print(key, tab[key]) end
--[[test
a 11
b 12
c 13
d 21
e 22
--test]]

dump(chain_from{range(0), range(0), (range(0))})
--[[test
--test]]

dump(chain_from{range(0), range(1), (range(2))})
--[[test
1
1
2
--test]]

dump(take(5, chain_from(cycle({{"one", "two"}}))))
--[[test
one
two
one
two
one
--test]]
