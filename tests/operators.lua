--
-- All these functions are fully covered by Lua tests.
-- This test just checks that all functions were defined correctly.
--

print(op == operator) -- an alias
--[[test
true
--test]]

--------------------------------------------------------------------------------
-- Comparison operators
--------------------------------------------------------------------------------

local comparators = { 'le', 'lt', 'eq', 'ne', 'ge', 'gt' }
for _k, op in iter(comparators) do
    print('op', op)
    print('==')
    print('num:')
    print(operator[op](0, 1))
    print(operator[op](1, 0))
    print(operator[op](0, 0))
    print('str:')
    print(operator[op]("abc", "cde"))
    print(operator[op]("cde", "abc"))
    print(operator[op]("abc", "abc"))
    print('')
end
--[[test
op le
==
num:
true
false
true
str:
true
false
true

op lt
==
num:
true
false
false
str:
true
false
false

op eq
==
num:
false
false
true
str:
false
false
true

op ne
==
num:
true
true
false
str:
true
true
false

op ge
==
num:
false
true
true
str:
false
true
true

op gt
==
num:
false
true
false
str:
false
true
false

--test]]

--------------------------------------------------------------------------------
-- Arithmetic operators
--------------------------------------------------------------------------------

print(operator.add(-1.0, 1.0))
print(operator.add(0, 0))
print(operator.add(12, 2))
--[[test
0
0
14
--test]]

print(operator.div(10, 2))
print(operator.div(10, 3))
print(operator.div(-10, 3))
--[[test
5
3.3333333333333
-3.3333333333333
--test]]

print(operator.floordiv(10, 3))
print(operator.floordiv(11, 3))
print(operator.floordiv(12, 3))
print(operator.floordiv(-10, 3))
print(operator.floordiv(-11, 3))
print(operator.floordiv(-12, 3))
--[[test
3
3
4
-4
-4
-4
--test]]

print(operator.intdiv(10, 3))
print(operator.intdiv(11, 3))
print(operator.intdiv(12, 3))
print(operator.intdiv(-10, 3))
print(operator.intdiv(-11, 3))
print(operator.intdiv(-12, 3))
--[[test
3
3
4
-3
-3
-4
--test]]

print(operator.truediv(10, 3))
print(operator.truediv(11, 3))
print(operator.truediv(12, 3))
print(operator.truediv(-10, 3))
print(operator.truediv(-11, 3))
print(operator.truediv(-12, 3))
--[[test
3.3333333333333
3.6666666666667
4
-3.3333333333333
-3.6666666666667
-4
--test]]

print(operator.mod(10, 2))
print(operator.mod(10, 3))
print(operator.mod(-10, 3))
--[[test
0
1
2
--test]]

print(operator.mul(10, 0.1))
print(operator.mul(0, 0))
print(operator.mul(-1, -1))
--[[test
1
0
1
--test]]

print(operator.neq(1))
print(operator.neq(0) == 0)
print(operator.neq(-0) == 0)
print(operator.neq(-1))
--[[test
-1
true
true
1
--test]]

print(operator.unm(1))
print(operator.unm(0) == 0)
print(operator.unm(-0) == 0)
print(operator.unm(-1))
--[[test
-1
true
true
1
--test]]

print(operator.pow(2, 3))
print(operator.pow(0, 10))
print(operator.pow(2, 0))
--[[test
8
0
1
--test]]

print(operator.sub(2, 3))
print(operator.sub(0, 10))
print(operator.sub(2, 2))
--[[test
-1
-10
0
--test]]

--------------------------------------------------------------------------------
-- String operators
--------------------------------------------------------------------------------

print(operator.concat("aa", "bb"))
print(operator.concat("aa", ""))
print(operator.concat("", "bb"))
--[[test
aabb
aa
bb
--test]]

print(operator.len(""))
print(operator.len("ab"))
print(operator.len("abcd"))
--[[test
0
2
4
--test]]

print(operator.length(""))
print(operator.length("ab"))
print(operator.length("abcd"))
--[[test
0
2
4
--test]]

----------------------------------------------------------------------------
-- Logical operators
----------------------------------------------------------------------------

print(operator.land(true, true))
print(operator.land(true, false))
print(operator.land(false, true))
print(operator.land(false, false))
print(operator.land(1, 0))
print(operator.land(0, 1))
print(operator.land(1, 1))
print(operator.land(0, 0))
--[[test
true
false
false
false
0
1
1
0
--test]]

print(operator.lor(true, true))
print(operator.lor(true, false))
print(operator.lor(false, true))
print(operator.lor(false, false))
print(operator.lor(1, 0))
print(operator.lor(0, 1))
print(operator.lor(1, 1))
print(operator.lor(0, 0))
--[[test
true
true
true
false
1
0
1
0
--test]]

print(operator.lnot(true))
print(operator.lnot(false))
print(operator.lor(1))
print(operator.lor(0))
--[[test
false
true
1
0
--test]]

print(operator.truth(true))
print(operator.truth(false))
print(operator.truth(1))
print(operator.truth(0))
print(operator.truth(nil))
print(operator.truth(""))
print(operator.truth({}))
--[[test
true
false
true
true
false
true
true
--test]]
