--------------------------------------------------------------------------------
-- range
--------------------------------------------------------------------------------

dump(range(0))
--[[test
--test]]

dump(range(5))
--[[test
0
1
2
3
4
--test]]

dump(range(0, 5))
--[[test
0
1
2
3
4
--test]]

dump(range(0, 5, 1))
--[[test
0
1
2
3
4
--test]]

dump(range(0, 10, 2))
--[[test
0
2
4
6
8
--test]]

dump(range(-5))
--[[test
--test]]

dump(range(0, -5, 1))
--[[test
--test]]

dump(range(0, -5, -1))
--[[test
0
-1
-2
-3
-4
--test]]

dump(range(0, -10, -2))
--[[test
0
-2
-4
-6
-8
--test]]

dump(range(1.2, 2.6, 0.2))
--[[test
1.2
1.4
1.6
1.8
2
2.2
2.4
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

math.randomseed(0)
dump(take(5, rands()))
--[[test
0.79420629243124
0.69885246563716
0.5901037417281
0.7532286166836
0.080971251199854
--test]]

math.randomseed(0)
dump(take(5, rands(0)))
--[[test
error: empty interval
--test]]

math.randomseed(0)
dump(take(5, rands(10)))
--[[test
7
6
5
7
0
--test]]

math.randomseed(0)
dump(take(5, rands(1024)))
--[[test
813
715
604
771
82
--test]]

math.randomseed(0)
dump(take(5, rands(0, 1)))
--[[test
0
0
0
0
0
--test]]

math.randomseed(0)
dump(take(5, rands(5, 6)))
--[[test
5
5
5
5
5
--test]]

math.randomseed(0)
dump(take(20, rands(10, 20)))
--[[test
17
16
15
17
10
16
13
17
14
15
11
10
19
17
11
19
12
13
14
16
--test]]
