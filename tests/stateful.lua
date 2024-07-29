-- compatibility with Lua 5.1/5.2
local unpack = rawget(table, "unpack") or unpack

function gen_stateful_iter(values)
    local i = 1
    local gen = function(_param, values)
        if i > #values then
            return nil
        end
        local t = values[i]
        i = i + 1
        if type(t) == 'table' then
            return values, unpack(t, 1, table.maxn(t))
        else
            return values, t
        end
    end
    return iter(gen, nil, values)
end

--------------------------------------------------------------------------------
-- drop_while
--------------------------------------------------------------------------------

-- Simple test
dump(gen_stateful_iter({1, 2, 3, 4, 5, 6, 5, 4, 3}):drop_while(function(x) return x < 5 end))
--[[test
5
6
5
4
3
--test]]

-- Multireturn
dump(gen_stateful_iter({{1, 10}, {3, 30}, {5, 50}, {6, 60}, {3, 20}}):drop_while(function(x) return x < 5 end))
--[[test
5 50
6 60
3 20
--test]]

-- Multireturn with nil
dump(gen_stateful_iter({{1, nil, 10}, {3, nil, 30}, {5, nil, 50}, {6, nil, 60}, {3, nil, 20}}):drop_while(function(x) return x < 5 end))
--[[test
5 nil 50
6 nil 60
3 nil 20
--test]]

-- Multireturn with condition on second returned value
dump(gen_stateful_iter({{0, 1}, {0, 3}, {0, 5}, {0, 4}}):drop_while(function(x, y) return y < 5 end))
--[[test
0 5
0 4
--test]]

-- Empty iterator
dump(gen_stateful_iter({}):drop_while(function(x) return x < 5 end))
--[[test
--test]]

-- Always false
dump(gen_stateful_iter({1, 2, 3, 4, 5}):drop_while(function(x) return x > 100 end))
--[[test
1
2
3
4
5
--test]]
