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

for _it, a in iter({}) do print(a) end
--[[test
--test]]

for _it, a in iter(iter(iter({}))) do print(a) end
--[[test
--test]]

-- Check that ``iter`` for arrays is equivalent to ``ipairs``
local t = {1, 2, 3}
gen1, param1, state1 = iter(t) 
gen2, param2, state2 = ipairs(t) 
print(gen1 == gen2, param1 == param2, state1 == state2)
--[[test
true true true
--test]]

--
-- Maps
--

for _it, k, v in iter({ a = 1, b = 2, c = 3}) do print(k, v) end
--[[test
b 2
a 1
c 3
--test]]

for _it, k, v in iter(iter(iter({ a = 1, b = 2, c = 3}))) do print(k, v) end
--[[test
b 2
a 1
c 3
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

each(print, { a = 1, b = 2, c = 3})
--[[test
b 2
a 1
c 3
--test]]

each(print, iter({ a = 1, b = 2, c = 3}))
--[[test
b 2
a 1
c 3
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
