--------------------------------------------------------------------------------
-- index
--------------------------------------------------------------------------------

print(index(2, range(5)))
--[[test
2
--test]]

print(index(10, range(5)))
--[[test
nil
--test]]

print(index(2, range(0)))
--[[test
nil
--test]]

print(index("b", {"a", "b", "c", "d", "e"}))
--[[test
2
--test]]

print(index(1, enumerate({"a", "b", "c", "d", "e"})))
--[[test
1
--test]]

print(index("b", "abcdef"))
--[[test
2
--test]]

print(index_of == index) -- an alias
--[[test
true
--test]]

print(elem_index == index) -- an alias
--[[test
true
--test]]

--------------------------------------------------------------------------------
-- indexes
--------------------------------------------------------------------------------

dump(indexes("a", {"a", "b", "c", "d", "e", "a", "b", "c", "d", "a", "a"}))
--[[test
1
6
10
11
--test]]

dump(indexes("f", {"a", "b", "c", "d", "e", "a", "b", "c", "d", "a", "a"}))
--[[test
--test]]

dump(indexes("f", {}))
--[[test
--test]]

dump(indexes(1, enumerate({"a", "b", "c", "d", "e"})))
--[[test
1
--test]]

print(indices == indexes) -- an alias
--[[test
true
--test]]

print(elem_indexes == indexes) -- an alias
--[[test
true
--test]]

print(elem_indices == indexes) -- an alias
--[[test
true
--test]]
