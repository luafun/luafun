--------------------------------------------------------------------------------
-- foldl
--------------------------------------------------------------------------------

print(foldl(function(acc, x) return acc + x end, 0, range(5)))
--[[test
15
--test]]

print(foldl(operator.add, 0, range(5)))
--[[test
15
--test]]

print(foldl(function(acc, x, y) return acc + x * y; end, 0,
    zip(range(1, 5), {4, 3, 2, 1})))
--[[test
20
--test]]

print(reduce == foldl) -- an alias
--[[test
true
--test]]

--------------------------------------------------------------------------------
-- length
--------------------------------------------------------------------------------

print(length({"a", "b", "c", "d", "e"}))
--[[test
5
--test]]

print(length({}))
--[[test
0
--test]]

print(length(range(0)))
--[[test
0
--test]]

--------------------------------------------------------------------------------
-- is_null
--------------------------------------------------------------------------------

print(is_null({"a", "b", "c", "d", "e"}))
--[[test
false
--test]]

print(is_null({}))
--[[test
true
--test]]

print(is_null(range(0)))
--[[test
true
--test]]

local gen, init, state = range(5)
print(is_null(gen, init, state))
dump(gen, init, state)
--[[test
false
1
2
3
4
5
--test]]

--------------------------------------------------------------------------------
-- is_prefix_of
--------------------------------------------------------------------------------

print(is_prefix_of({"a"}, {"a", "b", "c"}))
--[[test
true
--test]]

print(is_prefix_of({}, {"a", "b", "c"}))
--[[test
true
--test]]

print(is_prefix_of({}, {}))
--[[test
true
--test]]

print(is_prefix_of({"a"}, {}))
--[[test
false
--test]]

print(is_prefix_of(range(5), range(6)))
--[[test
true
--test]]

print(is_prefix_of(range(6), range(5)))
--[[test
false
--test]]

--------------------------------------------------------------------------------
-- all
--------------------------------------------------------------------------------

print(all(function(x) return x end, {true, true, true, true}))
--[[test
true
--test]]

print(all(function(x) return x end, {true, true, true, false}))
--[[test
false
--test]]

print(all(function(x) return x end, {}))
--[[test
true
--test]]

print(every == all) -- an alias
--[[test
true
--test]]

--------------------------------------------------------------------------------
-- any
--------------------------------------------------------------------------------

print(any(function(x) return x end, {false, false, false, false}))
--[[test
false
--test]]

print(any(function(x) return x end, {false, false, false, true}))
--[[test
true
--test]]

print(any(function(x) return x end, {}))
--[[test
false
--test]]

print(some == any) -- an alias
--[[test
true
--test]]

--------------------------------------------------------------------------------
-- sum
--------------------------------------------------------------------------------

print(sum(range(1, 5)))
--[[test
15
--test]]

print(sum(range(1, 5, 0.5)))
--[[test
27
--test]]

print(sum(range(0)))
--[[test
0
--test]]

--------------------------------------------------------------------------------
-- product
--------------------------------------------------------------------------------

print(product(range(1, 5)))
--[[test
120
--test]]

print(product(range(1, 5, 0.5)))
--[[test
7087.5
--test]]

print(product(range(0)))
--[[test
1
--test]]


--------------------------------------------------------------------------------
-- min
--------------------------------------------------------------------------------

print(min(range(1, 10, 1)))
--[[test
1
--test]]

print(min({"f", "d", "c", "d", "e"}))
--[[test
c
--test]]

print(min({}))
--[[test
error: min: iterator is empty
--test]]

print(minimum == min) -- an alias
--[[test
true
--test]]

--------------------------------------------------------------------------------
-- min_by
--------------------------------------------------------------------------------

function min_cmp(a, b) if -a < -b then return a else return b end end
--[[test
--test]]

print(min_by(min_cmp, range(1, 10, 1)))
--[[test
10
--test]]

print(min_by(min_cmp, {}))
--[[test
error: min: iterator is empty
--test]]

print(minimum_by == min_by) -- an alias
--[[test
true
--test]]

--------------------------------------------------------------------------------
-- max
--------------------------------------------------------------------------------

print(max(range(1, 10, 1)))
--[[test
10
--test]]

print(max({"f", "d", "c", "d", "e"}))
--[[test
f
--test]]

print(max({}))
--[[test
error: max: iterator is empty
--test]]

print(maximum == max) -- an alias
--[[test
true
--test]]

--------------------------------------------------------------------------------
-- max_by
--------------------------------------------------------------------------------

function max_cmp(a, b) if -a > -b then return a else return b end end
--[[test
--test]]

print(max_by(max_cmp, range(1, 10, 1)))
--[[test
1
--test]]

print(max_by(max_cmp, {}))
--[[test
error: max: iterator is empty
--test]]

print(maximum_by == maximum_by) -- an alias
--[[test
true
--test]]
