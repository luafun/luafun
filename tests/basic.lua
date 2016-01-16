--------------------------------------------------------------------------------
-- iter
--------------------------------------------------------------------------------

--
-- Arrays
--

for _it, a in iter({1, 2, 3}) do print(a) end
--[[test
1
2
3
--test]]

for _it, a in iter(iter(iter({1, 2, 3}))) do print(a) end
--[[test
1
2
3
--test]]

for _it, a in wrap(wrap(iter({1, 2, 3}))) do print(a) end
--[[test
1
2
3
--test]]

for _it, a in wrap(wrap(ipairs({1, 2, 3}))) do print(a) end
--[[test
1
2
3
--test]]

for _it, a in iter({}) do print(a) end
--[[test
--test]]

for _it, a in iter(iter(iter({}))) do print(a) end
--[[test
--test]]

for _it, a in wrap(wrap(iter({}))) do print(a) end
--[[test
--test]]

for _it, a in wrap(wrap(ipairs({}))) do print(a) end
--[[test
--test]]

-- Check that ``iter`` for arrays is equivalent to ``ipairs``
local t = {1, 2, 3}
gen1, param1, state1 = iter(t):unwrap()
gen2, param2, state2 = ipairs(t) 
print(gen1 == gen2, param1 == param2, state1 == state2)
--[[test
true true true
--test]]

-- Test that ``wrap`` do nothing for wrapped iterators
gen1, param1, state1 = iter({1, 2, 3})
gen2, param2, state2 = wrap(gen1, param1, state1):unwrap()
print(gen1 == gen2, param1 == param2, state1 == state2)
--[[test
true true true
--test]]

--
-- Maps
--

local t = {}
for _it, k, v in iter({ a = 1, b = 2, c = 3}) do t[#t + 1] = k end
table.sort(t)
for _it, v in iter(t) do print(v) end
--[[test
a
b
c
--test]]

local t = {}
for _it, k, v in iter(iter(iter({ a = 1, b = 2, c = 3}))) do t[#t + 1] = k end
table.sort(t)
for _it, v in iter(t) do print(v) end
--[[test
a
b
c
--test]]

for _it, k, v in iter({}) do print(k, v) end
--[[test
--test]]

for _it, k, v in iter(iter(iter({}))) do print(k, v) end
--[[test
--test]]

--
-- String
--

for _it, a in iter("abcde") do print(a) end
--[[test
a
b
c
d
e
--test]]

for _it, a in iter(iter(iter("abcde"))) do print(a) end
--[[test
a
b
c
d
e
--test]]

for _it, a in iter("") do print(a) end
--[[test
--test]]

for _it, a in iter(iter(iter(""))) do print(a) end
--[[test
--test]]

--
-- Custom generators
--

local function mypairs_gen(max, state)
    if (state >= max) then
            return nil
        end
        return state + 1, state + 1
end

local function mypairs(max)
    return mypairs_gen, max, 0
end

for _it, a in iter(mypairs(10)) do print(a) end
--[[test
1
2
3
4
5
6
7
8
9
10
--test]]

--
-- Invalid values
--

for _it, a in iter(1) do print(a) end
--[[test
error: object 1 of type "number" is not iterable
--test]]

for _it, a in iter(1, 2, 3, 4, 5, 6, 7) do print(a) end
--[[test
error: object 1 of type "number" is not iterable
--test]]

--------------------------------------------------------------------------------
-- each
--------------------------------------------------------------------------------

each(print, {1, 2, 3})
--[[test
1
2
3
--test]]

each(print, iter({1, 2, 3}))
--[[test
1
2
3
--test]]

each(print, {})
--[[test
--test]]


each(print, iter({}))
--[[test
--test]]

local keys, vals = {}, {}
each(function(k, v)
    keys[#keys + 1] = k
    vals[#vals + 1] = v
end, { a = 1, b = 2, c = 3})
table.sort(keys)
table.sort(vals)
each(print, keys)
each(print, vals)
--[[test
a
b
c
1
2
3
--test]]

each(print, "abc")
--[[test
a
b
c
--test]]

each(print, iter("abc"))
--[[test
a
b
c
--test]]

print(for_each == each) -- an alias
--[[test
true
--test]]

print(foreach == each) -- an alias
--[[test
true
--test]]

--------------------------------------------------------------------------------
-- totable
--------------------------------------------------------------------------------

local tab = totable(range(5))
print(type(tab), #tab)
each(print, tab)
--[[test
table 5
1
2
3
4
5
--test]]

local tab = totable(range(0))
print(type(tab), #tab)
--[[test
table 0
--test]]

local tab = totable("abcdef")
print(type(tab), #tab)
each(print, tab)
--[[test
table 6
a
b
c
d
e
f
--test]]

local unpack = rawget(table, "unpack") or unpack
local tab = totable({ 'a', {'b', 'c'}, {'d', 'e', 'f'}})
print(type(tab), #tab)
each(print, tab[1])
each(print, map(unpack, drop(1, tab)))
--[[test
table 3
a
b c
d e f
--test]]

--------------------------------------------------------------------------------
-- tomap
--------------------------------------------------------------------------------

local tab = tomap(zip(range(1, 7), 'abcdef'))
print(type(tab), #tab)
each(print, iter(tab))
--[[test
table 6
a
b
c
d
e
f
--test]]

local tab = tomap({a = 1, b = 2, c = 3})
print(type(tab), #tab)
local t = {}
for _it, k, v in iter(tab) do t[v] = k end
table.sort(t)
for k, v in ipairs(t) do print(k, v) end
--[[test
table 0
1 a
2 b
3 c
--test]]

local tab = tomap(enumerate("abcdef"))
print(type(tab), #tab)
each(print, tab)
--[[test
table 6
a
b
c
d
e
f
--test]]
