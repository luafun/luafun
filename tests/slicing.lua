--------------------------------------------------------------------------------
-- nth
--------------------------------------------------------------------------------

print(nth(2, range(5)))
--[[test
2
--test]]

print(nth(10, range(5)))
--[[test
nil
--test]]

print(nth(2, range(0)))
--[[test
nil
--test]]

print(nth(2, {"a", "b", "c", "d", "e"}))
--[[test
b
--test]]

print(nth(2, enumerate({"a", "b", "c", "d", "e"})))
--[[test
2 b
--test]]

print(nth(1, "abcdef"))
--[[test
a
--test]]

print(nth(2, "abcdef"))
--[[test
b
--test]]

print(nth(6, "abcdef"))
--[[test
f
--test]]

print(nth(0, "abcdef"))
--[[test
error: invalid first argument to nth
--test]]

print(nth(7, "abcdef"))
--[[test
nil
--test]]

--------------------------------------------------------------------------------
-- head
--------------------------------------------------------------------------------

print(head({"a", "b", "c", "d", "e"}))
--[[test
a
--test]]

print(head({}))
--[[test
error: head: iterator is empty
--test]]

print(head(range(0)))
--[[test
error: head: iterator is empty
--test]]

print(head(enumerate({"a", "b"})))
--[[test
1 a
--test]]

print(car == head) -- an alias
--[[test
true
--test]]

--------------------------------------------------------------------------------
-- tail
--------------------------------------------------------------------------------

dump(tail({"a", "b", "c", "d", "e"}))
--[[test
b
c
d
e
--test]]

dump(tail({}))
--[[test
--test]]

dump(tail(range(0)))
--[[test
--test]]

dump(tail(enumerate({"a", "b"})))
--[[test
2 b
--test]]

print(cdr == tail) -- an alias
--[[test
true
--test]]


--------------------------------------------------------------------------------
-- take_n
--------------------------------------------------------------------------------

dump(take_n(0, duplicate(48)))
--[[test
--test]]

dump(take_n(5, range(0)))
--[[test
--test]]

dump(take_n(1, duplicate(48)))
--[[test
48
--test]]

dump(take_n(5, duplicate(48)))
--[[test
48
48
48
48
48
--test]]

dump(take_n(5, enumerate(duplicate('x'))))
--[[test
1 x
2 x
3 x
4 x
5 x
--test]]

--------------------------------------------------------------------------------
-- take_while
--------------------------------------------------------------------------------

dump(take_while(function(x) return x < 5 end, range(10)))
--[[test
1
2
3
4
--test]]

dump(take_while(function(x) return x < 5 end, range(0)))
--[[test
--test]]

dump(take_while(function(x) return x > 100 end, range(10)))
--[[test
--test]]

dump(take_while(function(i, a) return i ~=a end, enumerate({5, 2, 1, 3, 4})))
--[[test
1 5
--test]]

--------------------------------------------------------------------------------
-- take
--------------------------------------------------------------------------------

dump(take(function(x) return x < 5 end, range(10)))
--[[test
1
2
3
4
--test]]

dump(take(5, duplicate(48)))
--[[test
48
48
48
48
48
--test]]

--------------------------------------------------------------------------------
-- drop_n
--------------------------------------------------------------------------------

dump(drop_n(5, range(10)))
--[[test
6
7
8
9
10
--test]]

dump(drop_n(0, range(5)))
--[[test
1
2
3
4
5
--test]]

dump(drop_n(5, range(0)))
--[[test
--test]]

dump(drop_n(2, enumerate({'a', 'b', 'c', 'd', 'e'})))
--[[test
3 c
4 d
5 e
--test]]

--------------------------------------------------------------------------------
-- drop_while
--------------------------------------------------------------------------------

dump(drop_while(function(x) return x < 5 end, range(10)))
--[[test
5
6
7
8
9
10
--test]]

dump(drop_while(function(x) return x < 5 end, range(0)))
--[[test
--test]]

dump(drop_while(function(x) return x > 100 end, range(10)))
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

dump(drop_while(function(i, a) return i ~=a end, enumerate({5, 2, 1, 3, 4})))
--[[test
2 2
3 1
4 3
5 4
--test]]

dump(drop_while(function(i, a) return i ~=a end,
    zip({1, 2, 3, 4, 5}, {5, 4, 3, 2, 1})))
--[[test
3 3
4 2
5 1
--test]]

--------------------------------------------------------------------------------
-- drop
--------------------------------------------------------------------------------

dump(drop(5, range(10)))
--[[test
6
7
8
9
10
--test]]

dump(drop(function(x) return x < 5 end, range(10)))
--[[test
5
6
7
8
9
10
--test]]


--------------------------------------------------------------------------------
-- span
--------------------------------------------------------------------------------

dump(zip(span(function(x) return x < 5 end, range(10))))
--[[test
1 5
2 6
3 7
4 8
--test]]

dump(zip(span(5, range(10))))
--[[test
1 6
2 7
3 8
4 9
5 10
--test]]

dump(zip(span(function(x) return x < 5 end, range(0))))
--[[test
--test]]

dump(zip(span(function(x) return x < 5 end, range(5))))
--[[test
1 5
--test]]

print(split == span) -- an alias
--[[test
true
--test]]

print(split_at == span) -- an alias
--[[test
true
--test]]
