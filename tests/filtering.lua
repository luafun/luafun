--------------------------------------------------------------------------------
-- filter
--------------------------------------------------------------------------------

dump(filter(function(x) return x % 3 == 0 end, range(10)))
--[[test
3
6
9
--test]]

dump(filter(function(x) return x % 3 == 0 end, range(0)))
--[[test
--test]]


dump(take(5, filter(function(i, x) return i % 3 == 0 end,
    enumerate(duplicate('x')))))
--[[test
3 x
6 x
9 x
12 x
15 x
--test]]

function filter_fun(a, b, c)
    if a % 16 == 0 then
        return true
    else
        return false
    end
end

function test3(a, b, c)
    return a, c, b
end

n = 50
dump(filter(filter_fun, map(test3, zip(range(0, n, 1),
     range(0, n, 2), range(0, n, 3)))))
--[[test
0 0 0
16 48 32
--test]]

print(remove_if == filter) -- an alias
--[[test
true
--test]]

--------------------------------------------------------------------------------
-- grep
--------------------------------------------------------------------------------

lines_to_grep = {
    [[Lorem ipsum dolor sit amet, consectetur adipisicing elit, ]],
    [[sed do eiusmod tempor incididunt ut labore et dolore magna ]],
    [[aliqua. Ut enim ad minim veniam, quis nostrud exercitation ]],
    [[ullamco laboris nisi ut aliquip ex ea commodo consequat.]],
    [[Duis aute irure dolor in reprehenderit in voluptate velit ]],
    [[esse cillum dolore eu fugiat nulla pariatur. Excepteur sint ]],
    [[occaecat cupidatat non proident, sunt in culpa qui officia ]],
    [[deserunt mollit anim id est laborum.]]
}

dump(grep("lab", lines_to_grep))
--[[test
sed do eiusmod tempor incididunt ut labore et dolore magna 
ullamco laboris nisi ut aliquip ex ea commodo consequat.
deserunt mollit anim id est laborum.
--test]]

lines_to_grep = {
    [[Emily]],
    [[Chloe]],
    [[Megan]],
    [[Jessica]],
    [[Emma]],
    [[Sarah]],
    [[Elizabeth]],
    [[Sophie]],
    [[Olivia]],
    [[Lauren]]
}

dump(grep("^Em", lines_to_grep))
--[[test
Emily
Emma
--test]]

--------------------------------------------------------------------------------
-- partition
--------------------------------------------------------------------------------

dump(zip(partition(function(i, x) return i % 3 == 0 end, range(10))))
--[[test
3 1
6 2
9 4
--test]]
