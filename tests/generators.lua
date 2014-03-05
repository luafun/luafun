--------------------------------------------------------------------------------
-- range
--------------------------------------------------------------------------------

dump(range(0))
print('--')
for i=1,0 do print(i) end
--[[test
--
--test]]

dump(range(0, 0))
print('--')
for i=0,0 do print(i) end
--[[test
0
--
0
--test]]

dump(range(5))
print('--')
for i=1,5 do print(i) end
--[[test
1
2
3
4
5
--
1
2
3
4
5
--test]]

dump(range(0, 5))
print('--')
for i=0,5 do print(i) end
--[[test
0
1
2
3
4
5
--
0
1
2
3
4
5
--test]]

dump(range(0, 5, 1))
print('--')
for i=0,5,1 do print(i) end
--[[test
0
1
2
3
4
5
--
0
1
2
3
4
5
--test]]

dump(range(0, 10, 2))
print('--')
for i=0,10,2 do print(i) end
--[[test
0
2
4
6
8
10
--
0
2
4
6
8
10
--test]]

dump(range(-5))
print('--')
for i=-1,-5,-1 do print(i) end
--[[test
-1
-2
-3
-4
-5
--
-1
-2
-3
-4
-5
--test]]

dump(range(0, -5, 1))
print('--')
for i=0,-5,1 do print(i) end
--[[test
--
--test]]

dump(range(0, -5, -1))
print('--')
for i=0,-5,-1 do print(i) end
--[[test
0
-1
-2
-3
-4
-5
--
0
-1
-2
-3
-4
-5
--test]]

dump(range(0, -10, -2))
print('--')
for i=0,-10,-2 do print(i) end
--[[test
0
-2
-4
-6
-8
-10
--
0
-2
-4
-6
-8
-10
--test]]

dump(range(1.2, 1.6, 0.1))
--[[test
1.2
1.3
1.4
1.5
--test]]

-- Invalid step
dump(range(0, 5, 0))
--[[test
error: step must not be zero
--test]]

--------------------------------------------------------------------------------
-- duplicate
--------------------------------------------------------------------------------

dump(take(5, duplicate(48)))
--[[test
48
48
48
48
48
--test]]

dump(take(5, duplicate(1,2,3,4,5)))
--[[test
1 2 3 4 5
1 2 3 4 5
1 2 3 4 5
1 2 3 4 5
1 2 3 4 5
--test]]

print(xrepeat == duplicate) -- an alias
--[[test
true
--test]]

print(replicate == duplicate) -- an alias
--[[test
true
--test]]

--------------------------------------------------------------------------------
-- tabulate
--------------------------------------------------------------------------------

dump(take(5, tabulate(function(x) return 2 * x end)))
--[[test
0
2
4
6
8
--test]]

--------------------------------------------------------------------------------
-- zeros
--------------------------------------------------------------------------------

dump(take(5, zeros()))
--[[test
0
0
0
0
0
--test]]

--------------------------------------------------------------------------------
-- ones
--------------------------------------------------------------------------------

dump(take(5, ones()))
--[[test
1
1
1
1
1
--test]]

--------------------------------------------------------------------------------
-- rands
--------------------------------------------------------------------------------

print(all(function(x) return x >= 0 and x < 1 end, take(5, rands())))
--[[test
true
--test]]

dump(take(5, rands(0)))
--[[test
error: empty interval
--test]]

print(all(function(x) return math.floor(x) == x end, take(5, rands(10))))
--[[test
true
--test]]

print(all(function(x) return math.floor(x) == x end, take(5, rands(1024))))
--[[test
true
--test]]

dump(take(5, rands(0, 1)))
--[[test
0
0
0
0
0
--test]]

dump(take(5, rands(5, 6)))
--[[test
5
5
5
5
5
--test]]

print(all(function(x) return x >= 10 and x < 20 end, take(20, rands(10, 20))))
--[[test
true
--test]]
