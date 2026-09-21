---
--- Lua Fun - a high-performance functional programming library for LuaJIT
---
--- Copyright (c) 2013-2017 Roman Tsisyk <roman@tsisyk.com>
---
--- Distributed under the MIT/X11 License. See COPYING.md for more details.
---

---@alias fun.Generator fun(param: any, state: any): any, any
---@alias fun.Iterable fun.Iterator|table|string|fun.Generator
---@alias fun.Predicate fun(...): boolean
---@alias fun.Comparator fun(a: any, b: any): any
---@alias fun.Reducer fun(acc: any, ...): any

---@class fun
local exports = {}

--- An iterator over a sequence of values.
---
--- An iterator is a `gen, param, state` triplet: a generating function, a
--- permanent parameter and a transient state.
---
--- Iterators returned by the library also support the object-oriented style
--- and expose the following methods: unwrap, each (for_each, foreach), nth,
--- head (car), tail (cdr), take_n, take_while, take, drop_n, drop_while,
--- drop, split (span, split_at), index (index_of, elem_index), indexes
--- (elem_indexes, indices, elem_indices), filter (remove_if), grep,
--- partition, foldl (reduce), length, is_null, is_prefix_of, all (every),
--- any (some), sum, product, min (minimum), min_by (minimum_by), max
--- (maximum), max_by (maximum_by), totable, tomap, map, enumerate,
--- intersperse, zip, cycle, chain, operator (op).
---
---@class fun.Iterator
---@field gen fun.Generator @The underlying generator function
---@field param any @The generator parameter (usually a constant)
---@field state any @The current generator state
---@field unwrap fun(self: fun.Iterator): fun.Generator, any, any @Get the underlying gen, param, state triplet
---@type table<string, any>
local methods = {}

-- compatibility with Lua 5.1/5.2
local unpack = rawget(table, "unpack") or unpack

-- table.maxn was removed in Lua 5.3+
local maxn = table.maxn or function(t)
    local maxn = 0.0
    for k in pairs(t) do
        if type(k) == "number" and k > maxn then
            maxn = k
        end
    end
    return maxn
end

--------------------------------------------------------------------------------
-- Internal
--------------------------------------------------------------------------------

local return_if_not_empty = function(state_x, ...)
    if state_x == nil then
        return nil
    end
    return ...
end

local call_if_not_empty = function(fun, state_x, ...)
    if state_x == nil then
        return nil
    end
    return state_x, fun(...)
end

local function deepcopy(orig) -- used by cycle()
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
    else
        copy = orig
    end
    return copy
end

local iterator_mt = {
    -- usually called by for-in loop
    __call = function(self, param, state)
        return self.gen(param, state)
    end;
    __tostring = function(_self)
        return '<generator>'
    end;
    -- add all exported methods
    __index = methods;
}

---@category Internal
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter (usually a constant)
---@param state any @the initial generator state
---@return fun.Iterator, any, any @a wrapped iterator and the param, state triplet
---@overload fun(gen: fun.Generator, param: any, state: any): fun.Iterator, any, any
local wrap = function(gen, param, state)
    return setmetatable({
        gen = gen,
        param = param,
        state = state
    }, iterator_mt), param, state
end
--- Wrap the gen, param, state triplet into an iterator object
exports.wrap = wrap

---@param self fun.Iterator @the iterator to unwrap
---@return fun.Generator, any, any @the underlying gen, param, state triplet
local unwrap = function(self)
    return self.gen, self.param, self.state
end
methods.unwrap = unwrap

--------------------------------------------------------------------------------
-- Basic Functions
--------------------------------------------------------------------------------

---@type fun.Generator
local nil_gen = function(_param, _state)
    return nil
end

local string_gen = function(param, state)
    local state = state + 1
    if state > #param then
        return nil
    end
    local r = string.sub(param, state, state)
    return state, r
end

local ipairs_gen = ipairs({}) -- get the generating function from ipairs

local pairs_gen = pairs({ a = 0 }) -- get the generating function from pairs
local map_gen = function(tab, key)
    local key, value = pairs_gen(tab, key)
    return key, key, value
end

---@param obj fun.Iterable @an iterable object: table, string, function or iterator
---@param param any @a generator parameter
---@param state any @a generator state
---@return fun.Generator, any, any @the raw gen, param, state triplet
local rawiter = function(obj, param, state)
    assert(obj ~= nil, "invalid iterator")
    if type(obj) == "table" then
        local mt = getmetatable(obj);
        if mt ~= nil then
            if mt == iterator_mt then
                return obj.gen, obj.param, obj.state
            elseif mt.__ipairs ~= nil then
                return mt.__ipairs(obj)
            elseif mt.__pairs ~= nil then
                return mt.__pairs(obj)
            end
        end
        if #obj > 0 then
            -- array
            return ipairs(obj)
        else
            -- hash
            return map_gen, obj, nil
        end
    elseif (type(obj) == "function") then
        return obj, param, state
    elseif (type(obj) == "string") then
        if #obj == 0 then
            return nil_gen, nil, nil
        end
        return string_gen, obj, 0
    end
    error(string.format('object %s of type "%s" is not iterable',
          obj, type(obj)))
end

---@category Basic Functions
---@param obj fun.Iterable @an iterable object: table, string, function or iterator
---@param param any @a generator parameter
---@param state any @a generator state
---@return fun.Iterator, any, any @a wrapped iterator and the param, state triplet
---@overload fun(obj: fun.Iterable, param?: any, state?: any): fun.Iterator
local iter = function(obj, param, state)
    return wrap(rawiter(obj, param, state))
end
---
--- Make `gen, param, state` iterator from the iterable object.
--- The function is a generalized version of `pairs` and `ipairs`.
---
--- The function distinguishes between arrays and maps using the `#arg == 0`
--- check to detect maps. For arrays `ipairs` is used. For maps a modified
--- version of `pairs` is used that also returns keys. Userdata objects are
--- handled in the same way as tables.
---
--- If `LUAJIT_ENABLE_LUA52COMPAT`[^luajit_lua52compat] mode is enabled and the
--- argument has the `__pairs` (for maps) or `__ipairs` (for arrays)
--- metamethods, call it with the table or userdata as argument and return the
--- first three results from the call[^lua52_ipairs].
---
--- All library iterators are suitable to use with Lua's `for .. in` loop.
---
---
--- Example:
--- ```lua
--- for _it, a in iter({1, 2, 3}) do print(a) end
--- -- 1
--- -- 2
--- -- 3
---
--- for _it, k, v in iter({ a = 1, b = 2, c = 3}) do print(k, v) end
--- -- b 2
--- -- a 1
--- -- c 3
---
--- for _it, a in iter("abcde") do print(a) end
--- -- a
--- -- b
--- -- c
--- -- d
--- -- e
--- ```
---
--- The first loop variable `_it` stores an internal state of the iterator and
--- must be always ignored in loops:
---
--- ```lua
--- for _it, a, b in iter({ a = 1, b = 2, c = 3}) do print(a, b) end
--- -- _it is some internal iterator state - always ignore it
--- -- a, b are values returned from the iterator
--- ```
---
--- Simple iterators like `iter({1, 2, 3})` have simple states, whereas other
--- iterators like [zip](compositions.md#funzip) or
--- [chain](compositions.md#funchain) have complicated internal states whose
--- values are senseless for the end user.
---
--- Check out the {doc}`Under the Hood <under_the_hood>` section for more
--- details.
---
--- There is also the possibility to supply custom iterators to the function:
---
--- ```lua
--- local function mypairs_gen(max, state)
---     if (state >= max) then
---         return nil
---     end
---     return state + 1, state + 1
--- end
---
--- local function mypairs(max)
---     return mypairs_gen, max, 0
--- end
---
--- for _it, a in iter(mypairs(10)) do print(a) end
--- -- 1
--- -- 2
--- -- 3
--- -- ...
--- -- 10
--- ```
---
--- Iterators can return multiple values.
---
--- Check out the {doc}`Under the Hood <under_the_hood>` section for more
--- details.
---
--- [^luajit_lua52compat]: http://luajit.org/extensions.html
--- [^lua52_ipairs]: http://www.lua.org/manual/5.2/manual.html#pdf-ipairs
exports.iter = iter

local method0 = function(fun)
    return function(self)
        return fun(self.gen, self.param, self.state)
    end
end

local method1 = function(fun)
    return function(self, arg1)
        return fun(arg1, self.gen, self.param, self.state)
    end
end

local method2 = function(fun)
    return function(self, arg1, arg2)
        return fun(arg1, arg2, self.gen, self.param, self.state)
    end
end

---@generic T: function
---@param fun T
---@return T
local export0 = function(fun)
    return function(gen, param, state)
        return fun(rawiter(gen, param, state))
    end
end

---@generic T: function
---@param fun T
---@return T
local export1 = function(fun)
    return function(arg1, gen, param, state)
        return fun(arg1, rawiter(gen, param, state))
    end
end

---@generic T: function
---@param fun T
---@return T
local export2 = function(fun)
    return function(arg1, arg2, gen, param, state)
        return fun(arg1, arg2, rawiter(gen, param, state))
    end
end

---@category Basic Functions
---@param fun fun(...): any @a function executed for each iteration value
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return nil
---@overload fun(fn: fun(...): any, obj: fun.Iterable): nil
local each = function(fun, gen, param, state)
    repeat
        state = call_if_not_empty(fun, gen(param, state))
    until state == nil
end
methods.each = method1(each)
---
--- Execute the *fun* for each iteration value. The function is equivalent to
--- the code below:
---
--- ```lua
--- for _it, ... in iter(gen, param, state) do
---     fun(...)
--- end
--- ```
---
--- The function is used for its side effects. The implementation directly
--- applies *fun* to all iteration values without returning a new iterator, in
--- contrast to functions like [map](transformations.md#funmap).
---
---
--- Example:
--- ```lua
--- each(print, { a = 1, b = 2, c = 3})
--- -- b 2
--- -- a 1
--- -- c 3
---
--- each(print, {1, 2, 3})
--- -- 1
--- -- 2
--- -- 3
--- ```
---
--- See also: [map](transformations.md#funmap), [reduce](reducing.md#funreduce).
exports.each = export1(each)
methods.for_each = methods.each
--- An alias for [each](basic.md#funeach).
exports.for_each = exports.each
methods.foreach = methods.each
--- An alias for [each](basic.md#funeach).
exports.foreach = exports.each

--------------------------------------------------------------------------------
-- Generators
--------------------------------------------------------------------------------

local range_gen = function(param, state)
    local stop, step = param[1], param[2]
    local state = state + step
    if state > stop then
        return nil
    end
    return state, state
end

local range_rev_gen = function(param, state)
    local stop, step = param[1], param[2]
    local state = state + step
    if state < stop then
        return nil
    end
    return state, state
end

---@category Generators
---@param start? number @an endpoint of the interval (see below)
---@param stop? number @an endpoint of the interval (see below)
---@param step? number @a step
---@return fun.Iterator|fun.Generator, any, any @an iterator over the arithmetic progression
---@overload fun(start?: number, stop?: number, step?: number): fun.Iterator
local range = function(start, stop, step)
    if step == nil then
        if stop == nil then
            if start == 0 then
                return nil_gen, nil, nil
            end
            stop = start
            start = stop > 0 and 1 or -1
        end
        step = start <= stop and 1 or -1
    end

    assert(type(start) == "number", "start must be a number")
    assert(type(stop) == "number", "stop must be a number")
    assert(type(step) == "number", "step must be a number")
    assert(step ~= 0, "step must not be zero")

    if (step > 0) then
        return wrap(range_gen, {stop, step}, start - step)
    end
    return wrap(range_rev_gen, {stop, step}, start - step)
end
---
--- The iterator to create arithmetic progressions. Iteration values are
--- generated within the closed interval `[start, stop]` (i.e. *stop* is
--- included). If the *start* argument is omitted, it defaults to `1`
--- (*stop* > 0) or to `-1` (*stop* < 0). If the *step* argument is omitted,
--- it defaults to `1` (*start* <= *stop*) or to `-1` (*start* > *stop*). If
--- *step* is positive, the last element is the largest `start + i * step`
--- less than or equal to *stop*; if *step* is negative, the last element is
--- the smallest `start + i * step` greater than or equal to *stop*. *step*
--- must not be zero (or else an error is raised). `range(0)` returns an empty
--- iterator.
---
---
--- Example:
--- ```lua
--- for _it, v in range(5) do print(v) end
--- -- 1
--- -- 2
--- -- 3
--- -- 4
--- -- 5
---
--- for _it, v in range(-5) do print(v) end
--- -- -1
--- -- -2
--- -- -3
--- -- -4
--- -- -5
---
--- for _it, v in range(1, 6) do print(v) end
--- -- 1
--- -- 2
--- -- 3
--- -- 4
--- -- 5
--- -- 6
---
--- for _it, v in range(0, 20, 5) do print(v) end
--- -- 0
--- -- 5
--- -- 10
--- -- 15
--- -- 20
---
--- for _it, v in range(0, 10, 3) do print(v) end
--- -- 0
--- -- 3
--- -- 6
--- -- 9
---
--- for _it, v in range(0, 1.5, 0.2) do print(v) end
--- -- 0
--- -- 0.2
--- -- 0.4
--- -- 0.6
--- -- 0.8
--- -- 1
--- -- 1.2
--- -- 1.4
---
--- for _it, v in range(0) do print(v) end
---
--- for _it, v in range(1) do print(v) end
--- -- 1
---
--- for _it, v in range(1, 0) do print(v) end
--- -- 1
--- -- 0
---
--- for _it, v in range(0, 10, 0) do print(v) end
--- -- error: step must not be zero
--- ```
exports.range = range

local duplicate_table_gen = function(param_x, state_x)
    return state_x + 1, unpack(param_x)
end

local duplicate_fun_gen = function(param_x, state_x)
    return state_x + 1, param_x(state_x)
end

local duplicate_gen = function(param_x, state_x)
    return state_x + 1, param_x
end

---@category Generators
---@vararg any @objects to duplicate
---@return fun.Iterator, any, any @an iterator that returns the values indefinitely
---@overload fun(...): fun.Iterator
local duplicate = function(...)
    if select('#', ...) <= 1 then
        return wrap(duplicate_gen, select(1, ...), 0)
    else
        return wrap(duplicate_table_gen, {...}, 0)
    end
end
---
--- The iterator returns values over and over again indefinitely. All values
--- that passed to the iterator are returned as-is during the iteration.
---
---
--- Example:
--- ```lua
--- each(print, take(3, duplicate('a', 'b', 'c')))
--- -- a       b       c
--- -- a       b       c
---
--- each(print, take(3, duplicate('x')))
--- -- x
--- -- x
--- -- x
---
--- for _it, a, b, c, d, e in take(3, duplicate(1, 2, 'a', 3, 'b')) do
---     print(a, b, c, d, e)
--- end
--- -- 1       2       a       3       b
--- -- 1       2       a       3       b
--- -- 1       2       a       3       b
--- ```
exports.duplicate = duplicate
--- An alias for [duplicate](generators.md#funduplicate).
exports.replicate = duplicate
--- An alias for [duplicate](generators.md#funduplicate).
exports.xrepeat = duplicate

---@category Generators
---@param fun fun(index: number): any @an unary generating function
---@return fun.Iterator, any, any @an iterator that returns fun(0), fun(1), fun(2), ... indefinitely
---@overload fun(fn: fun(index: number): any): fun.Iterator
local tabulate = function(fun)
    assert(type(fun) == "function")
    return wrap(duplicate_fun_gen, fun, 0)
end
---
--- The iterator that returns `fun(0)`, `fun(1)`, `fun(2)`, `...` values
--- indefinitely.
---
---
--- Example:
--- ```lua
--- each(print, take(5, tabulate(function(x) return 'a', 'b', 2*x end)))
--- -- a       b       0
--- -- a       b       2
--- -- a       b       4
--- -- a       b       6
--- -- a       b       8
---
--- each(print, take(5, tabulate(function(x) return x^2 end)))
--- -- 0
--- -- 1
--- -- 4
--- -- 9
--- -- 16
--- ```
exports.tabulate = tabulate

---@category Generators
---@return fun.Iterator, any, any @an iterator that returns 0 indefinitely
---@overload fun(): fun.Iterator
local zeros = function()
    return wrap(duplicate_gen, 0, 0)
end
---
--- The iterator returns `0` indefinitely.
---
---
--- Example:
--- ```lua
--- each(print, take(5, zeros()))
--- -- 0
--- -- 0
--- -- 0
--- -- 0
--- -- 0
--- ```
exports.zeros = zeros

---@category Generators
---@return fun.Iterator, any, any @an iterator that returns 1 indefinitely
---@overload fun(): fun.Iterator
local ones = function()
    return wrap(duplicate_gen, 1, 0)
end
---
--- The iterator that returns `1` indefinitely.
---
---
--- Example:
--- ```lua
--- each(print, take(5, ones()))
--- -- 1
--- -- 1
--- -- 1
--- -- 1
--- -- 1
--- ```
exports.ones = ones

local rands_gen = function(param_x, _state_x)
    return 0, math.random(param_x[1], param_x[2])
end

local rands_nil_gen = function(_param_x, _state_x)
    return 0, math.random()
end

---@category Generators
---@param n? number @an endpoint of the interval (see below)
---@param m? number @an endpoint of the interval (see below)
---@return fun.Iterator, any, any @an iterator over pseudo-random values
---@overload fun(n?: number, m?: number): fun.Iterator
local rands = function(n, m)
    if n == nil and m == nil then
        return wrap(rands_nil_gen, 0, 0)
    end
    assert(type(n) == "number", "invalid first arg to rands")
    if m == nil then
        m = n
        n = 0
    else
        assert(type(m) == "number", "invalid second arg to rands")
    end
    assert(n < m, "empty interval")
    return wrap(rands_gen, {n, m - 1}, 0)
end
---
--- The iterator returns random values using `math.random`. If the **n** and
--- **m** are set then the iterator returns pseudo-random integers in the
--- `[n, m)` interval (i.e. **m** is not included). If the **m** is not set
--- then the iterator generates pseudo-random integers in the `[0, n)`
--- interval. When called without arguments it returns pseudo-random real
--- numbers with uniform distribution in the interval `[0, 1)`.
---
--- ```{warning}
--- This iterator is not pure-functional and may not work as expected with
--- some library functions.
--- ```
---
---
--- Example:
--- ```lua
--- each(print, take(10, rands(10, 20)))
--- -- 19
--- -- 17
--- -- 11
--- -- 19
--- -- 12
--- -- 13
--- -- 14
--- -- 16
--- -- 10
--- -- 11
---
--- each(print, take(5, rands(10)))
--- -- 7
--- -- 6
--- -- 5
--- -- 9
--- -- 0
---
--- each(print, take(5, rands()))
--- -- 0.79420629243124
--- -- 0.69885246563716
--- -- 0.5901037417281
--- -- 0.7532286166836
--- -- 0.080971251199854
--- ```
exports.rands = rands

--------------------------------------------------------------------------------
-- Slicing
--------------------------------------------------------------------------------

---@category Slicing
---@param n integer @a sequential number (indexed starting from `1`, like Lua tables)
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return any @the n-th element, or nil if there are less than n items
---@overload fun(n: number, obj: fun.Iterable): any
local nth = function(n, gen_x, param_x, state_x)
    assert(n > 0, "invalid first argument to nth")
    -- An optimization for arrays and strings
    if gen_x == ipairs_gen then
        return param_x[state_x + n]
    elseif gen_x == string_gen then
        if state_x + n <= #param_x then
            return string.sub(param_x, state_x + n, state_x + n)
        else
            return nil
        end
    end
    for _=1,n-1,1 do
        state_x = gen_x(param_x, state_x)
        if state_x == nil then
            return nil
        end
    end
    return return_if_not_empty(gen_x(param_x, state_x))
end
methods.nth = method1(nth)
---
--- This function returns the **n**-th element of the `gen, param, state`
--- iterator. If the iterator does not have **n** items then `nil` is returned.
---
--- This function is optimized for basic array and string iterators and has
--- `O(1)` complexity for these cases.
---
---
--- Example:
--- ```lua
--- print(nth(2, range(5)))
--- -- 2
---
--- print(nth(10, range(5)))
--- -- nil
---
--- print(nth(2, {"a", "b", "c", "d", "e"}))
--- -- b
---
--- print(nth(2, drop_n(3, {"a", "b", "c", "d", "e"})))
--- -- e
---
--- print(nth(2, enumerate({"a", "b", "c", "d", "e"})))
--- -- 2 b
--- ```
exports.nth = export1(nth)

local head_call = function(state, ...)
    if state == nil then
        error("head: iterator is empty")
    end
    return ...
end

---@category Slicing
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return any @the first element; an error is raised if the iterator is empty
---@overload fun(obj: fun.Iterable): any
local head = function(gen, param, state)
    return head_call(gen(param, state))
end
methods.head = method0(head)
---
--- Extract the first element of the `gen, param, state` iterator.
--- If the iterator is empty then an error is raised.
---
---
--- Example:
--- ```lua
--- print(head({"a", "b", "c", "d", "e"}))
--- -- a
---
--- print(head({}))
--- -- error: head: iterator is empty
---
--- print(head(range(0)))
--- -- error: head: iterator is empty
---
--- print(head(enumerate({"a", "b"})))
--- -- 1 a
--- ```
exports.head = export0(head)
--- An alias for [head](slicing.md#funhead).
exports.car = exports.head
methods.car = methods.head

---@category Slicing
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return fun.Iterator, any, any @the iterator without its first element
---@overload fun(obj: fun.Iterable): fun.Iterator
local tail = function(gen, param, state)
    state = gen(param, state)
    if state == nil then
        return wrap(nil_gen, nil, nil)
    end
    return wrap(gen, param, state)
end
methods.tail = method0(tail)
---
--- Return a copy of the `gen, param, state` iterator without its first
--- element. If the iterator is empty then an empty iterator is returned.
---
---
--- Example:
--- ```lua
--- each(print, tail({"a", "b", "c", "d", "e"}))
--- -- b
--- -- c
--- -- d
--- -- e
---
--- each(print, tail({}))
---
--- each(print, tail(range(0)))
---
--- each(print, tail(enumerate({"a", "b", "c"})))
--- -- 2 b
--- -- 3 c
--- ```
exports.tail = export0(tail)
--- An alias for [tail](slicing.md#funtail).
exports.cdr = exports.tail
methods.cdr = methods.tail

local take_n_gen_x = function(i, state_x, ...)
    if state_x == nil then
        return nil
    end
    return {i, state_x}, ...
end

local take_n_gen = function(param, state)
    local n, gen_x, param_x = param[1], param[2], param[3]
    local i, state_x = state[1], state[2]
    if i >= n then
        return nil
    end
    return take_n_gen_x(i + 1, gen_x(param_x, state_x))
end

---@category Slicing
---@param n number @a number of elements to take
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return fun.Iterator, any, any @an iterator on the subsequence of the first n elements
---@overload fun(n: number, obj: fun.Iterable): fun.Iterator
local take_n = function(n, gen, param, state)
    assert(n >= 0, "invalid first argument to take_n")
    return wrap(take_n_gen, {n, gen, param}, {0, state})
end
methods.take_n = method1(take_n)
---
---
--- Example:
--- ```lua
--- each(print, take_n(5, range(10)))
--- -- 1
--- -- 2
--- -- 3
--- -- 4
--- -- 5
---
--- each(print, take_n(5, enumerate(duplicate('x'))))
--- -- 1 x
--- -- 2 x
--- -- 3 x
--- -- 4 x
--- -- 5 x
--- ```
exports.take_n = export1(take_n)

local take_while_gen_x = function(fun, state_x, ...)
    if state_x == nil or not fun(...) then
        return nil
    end
    return state_x, ...
end

local take_while_gen = function(param, state_x)
    local fun, gen_x, param_x = param[1], param[2], param[3]
    return take_while_gen_x(fun, gen_x(param_x, state_x))
end

---@category Slicing
---@param fun fun.Predicate @a predicate over iteration values
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return fun.Iterator, any, any @the longest prefix of elements that satisfy the predicate
---@overload fun(fn: fun.Predicate, obj: fun.Iterable): fun.Iterator
local take_while = function(fun, gen, param, state)
    assert(type(fun) == "function", "invalid first argument to take_while")
    return wrap(take_while_gen, {fun, gen, param}, state)
end
methods.take_while = method1(take_while)
--- elements that satisfy **predicate**.
---
---
--- Example:
--- ```lua
--- each(print, take_while(function(x) return x < 5 end, range(10)))
--- -- 1
--- -- 2
--- -- 3
--- -- 4
---
--- each(print, take_while(function(i, a) return i ~= a end,
---     enumerate({5, 3, 4, 4, 2})))
--- -- 1       5
--- -- 2       3
--- -- 3       4
--- ```
---
--- See also: [filter](filtering.md#funfilter).
exports.take_while = export1(take_while)

---@category Slicing
---@param n_or_fun number|fun.Predicate @a number of elements or a predicate (take_n or take_while)
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return fun.Iterator, any, any @an iterator on the subsequence of the first elements
---@overload fun(n_or_fun: number|fun.Predicate, obj: fun.Iterable): fun.Iterator
local take = function(n_or_fun, gen, param, state)
    if type(n_or_fun) == "number" then
        return take_n(n_or_fun, gen, param, state)
    else
        return take_while(n_or_fun, gen, param, state)
    end
end
methods.take = method1(take)
--- An alias for [take_n](slicing.md#funtake_n) and
--- [take_while](slicing.md#funtake_while) that autodetects the required function
--- based on the n_or_fun type.
exports.take = export1(take)

---@category Slicing
---@param n number @the number of elements to drop
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return fun.Iterator, any, any @the iterator after skipping the first n elements
---@overload fun(n: number, obj: fun.Iterable): fun.Iterator
local drop_n = function(n, gen, param, state)
    assert(n >= 0, "invalid first argument to drop_n")
    for _=1,n,1 do
        state = gen(param, state)
        if state == nil then
            return wrap(nil_gen, nil, nil)
        end
    end
    return wrap(gen, param, state)
end
methods.drop_n = method1(drop_n)
--- elements
---
---
--- Example:
--- ```lua
--- each(print, drop_n(2, range(5)))
--- -- 3
--- -- 4
--- -- 5
---
--- each(print, drop_n(2, enumerate({'a', 'b', 'c', 'd', 'e'})))
--- -- 3       c
--- -- 4       d
--- -- 5       e
--- ```
exports.drop_n = export1(drop_n)

-- Unpack values from param[3] on the first iteration, then return
-- values from the provided iterator.
--
-- A generator function for drop_while().
local drop_while_gen = function(param, state)
    local results = param[3]
    if not results then
        return param[1](param[2], state)
    else
        param[3] = nil
        return state, unpack(results, 1, maxn(results))
    end
end

-- Checks if drop_while should continue skipping. If iterator is not exhausted
-- and skipping is over, elements returned by iterator are wrapped into a table
-- and returned as the second return value. Note that a table is created only
-- once, on the last iteration, for the sake of performance.
local drop_while_x = function(fun, state_x, ...)
    if state_x ~= nil and not fun(...) then
        return state_x, {...}
    end
    return state_x
end

---@category Slicing
---@param fun fun.Predicate @a predicate over iteration values
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return fun.Iterator, any, any @the iterator after skipping the longest prefix that satisfies the predicate
---@overload fun(fn: fun.Predicate, obj: fun.Iterable): fun.Iterator
local drop_while = function(fun, gen_x, param_x, state_x)
    assert(type(fun) == "function", "invalid first argument to drop_while")
    local pivot = nil
    while state_x ~= nil and pivot == nil do
        state_x, pivot = drop_while_x(fun, gen_x(param_x, state_x))
    end
    if state_x == nil then
        return wrap(nil_gen, nil, nil)
    end
    return wrap(drop_while_gen, {gen_x, param_x, pivot}, state_x)
end
methods.drop_while = method1(drop_while)
--- elements that satisfy **predicate**.
---
---
--- Example:
--- ```lua
--- each(print, drop_while(function(x) return x < 5 end, range(10)))
--- -- 5
--- -- 6
--- -- 7
--- -- 8
--- -- 9
--- -- 10
--- ```
---
--- See also: [filter](filtering.md#funfilter).
exports.drop_while = export1(drop_while)

---@category Slicing
---@param n_or_fun number|fun.Predicate @a number of elements or a predicate (drop_n or drop_while)
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return fun.Iterator, any, any @the iterator after skipping the elements
---@overload fun(n_or_fun: number|fun.Predicate, obj: fun.Iterable): fun.Iterator
local drop = function(n_or_fun, gen_x, param_x, state_x)
    if type(n_or_fun) == "number" then
        return drop_n(n_or_fun, gen_x, param_x, state_x)
    else
        return drop_while(n_or_fun, gen_x, param_x, state_x)
    end
end
methods.drop = method1(drop)
--- An alias for [drop_n](slicing.md#fundrop_n) and
--- [drop_while](slicing.md#fundrop_while) that autodetects the required function
--- based on the n_or_fun type.
exports.drop = export1(drop)

---@category Slicing
---@param n_or_fun number|fun.Predicate @a number of elements or a predicate (span)
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return fun.Iterator, fun.Iterator, any, any @the prefix and the remainder of the iterator
---@overload fun(n_or_fun: number|fun.Predicate, obj: fun.Iterable): fun.Iterator, fun.Iterator
local split = function(n_or_fun, gen_x, param_x, state_x)
    return take(n_or_fun, gen_x, param_x, state_x),
           drop(n_or_fun, gen_x, param_x, state_x)
end
methods.split = method1(split)
--- An alias for [span](slicing.md#funspan).
exports.split = export1(split)
methods.split_at = methods.split
--- An alias for [span](slicing.md#funspan).
exports.split_at = exports.split
methods.span = methods.split
---
--- Return an iterator pair where the first operates on the longest prefix
--- (possibly empty) of the `gen, param, state` iterator of elements that
--- satisfy **predicate** and second operates the remainder of the
--- `gen, param, state` iterator. Equivalent to:
---
--- ```lua
--- return take(n_or_fun, gen_x, param_x, state_x),
---        drop(n_or_fun, gen_x, param_x, state_x)
--- ```
---
--- ```{note}
--- `{gen, param, state}` must be pure functional to work properly with the
--- function.
--- ```
---
--- [split](slicing.md#funsplit) and [split_at](slicing.md#funsplit_at) are aliases of span.
---
---
--- Example:
--- ```lua
--- each(print, zip(span(function(x) return x < 5 end, range(10))))
--- -- 1       5
--- -- 2       6
--- -- 3       7
--- -- 4       8
---
--- each(print, zip(span(5, range(10))))
--- -- 1       6
--- -- 2       7
--- -- 3       8
--- -- 4       9
--- -- 5       10
--- ```
---
--- See also: [partition](filtering.md#funpartition).
exports.span = exports.split

--------------------------------------------------------------------------------
-- Indexing
--------------------------------------------------------------------------------

---@category Indexing
---@param x any @a value to find
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return number|nil @the position of the first element that equals x, or nil
---@overload fun(x: any, obj: fun.Iterable): number|nil
local index = function(x, gen, param, state)
    local i = 1
    for _k, r in gen, param, state do
        if r == x then
            return i
        end
        i = i + 1
    end
    return nil
end
methods.index = method1(index)
---
--- Return the position of the first element that equals `x`.
---
--- The position is 1-based. The function returns the position of the first
--- element in the given iterator which is equal (using `==`) to the query
--- element, or `nil` if there is no such element.
---
--- [index_of](indexing.md#funindex_of) and [elem_index](indexing.md#funelem_index) are aliases of index.
---
---
--- Example:
--- ```lua
--- print(index(2, range(0)))
--- -- nil
---
--- print(index("b", {"a", "b", "c", "d", "e"}))
--- -- 2
--- ```
exports.index = export1(index)
methods.index_of = methods.index
--- An alias for [index](indexing.md#funindex).
exports.index_of = exports.index
methods.elem_index = methods.index
--- An alias for [index](indexing.md#funindex).
exports.elem_index = exports.index

local indexes_gen = function(param, state)
    local x, gen_x, param_x = param[1], param[2], param[3]
    local i, state_x = state[1], state[2]
    local r
    while true do
        state_x, r = gen_x(param_x, state_x)
        if state_x == nil then
            return nil
        end
        i = i + 1
        if r == x then
            return {i, state_x}, i
        end
    end
end

---@category Indexing
---@param x any @a value to find
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return fun.Iterator, any, any @an iterator over the positions of elements that equal x
---@overload fun(x: any, obj: fun.Iterable): fun.Iterator
local indexes = function(x, gen, param, state)
    return wrap(indexes_gen, {x, gen, param}, {0, state})
end
methods.indexes = method1(indexes)
---
--- Return an iterator over the positions of elements that equal `x`.
---
--- [indices](indexing.md#funindices),
--- [elem_indexes](indexing.md#funelem_indexes) and
--- [elem_indices](indexing.md#funelem_indices) are aliases of indexes.
---
---
--- Example:
--- ```lua
--- each(print, indexes("a", {"a", "b", "c", "d", "e", "a", "b", "a", "a"}))
--- -- 1
--- -- 6
--- -- 9
--- -- 10
--- ```
---
--- See also: [filter](filtering.md#funfilter).
exports.indexes = export1(indexes)
methods.elem_indexes = methods.indexes
--- An alias for [indexes](indexing.md#funindexes).
exports.elem_indexes = exports.indexes
methods.indices = methods.indexes
--- An alias for [indexes](indexing.md#funindexes).
exports.indices = exports.indexes
methods.elem_indices = methods.indexes
--- An alias for [indexes](indexing.md#funindexes).
exports.elem_indices = exports.indexes

--------------------------------------------------------------------------------
-- Filtering
--------------------------------------------------------------------------------

local filter1_gen = function(fun, gen_x, param_x, state_x, a)
    while true do
        if state_x == nil or fun(a) then break; end
        state_x, a = gen_x(param_x, state_x)
    end
    return state_x, a
end

-- call each other
local filterm_gen
local filterm_gen_shrink = function(fun, gen_x, param_x, state_x)
    ---@diagnostic disable-next-line: need-check-nil
    return filterm_gen(fun, gen_x, param_x, gen_x(param_x, state_x))
end

filterm_gen = function(fun, gen_x, param_x, state_x, ...)
    if state_x == nil then
        return nil
    end
    if fun(...) then
        return state_x, ...
    end
    return filterm_gen_shrink(fun, gen_x, param_x, state_x)
end

local filter_detect = function(fun, gen_x, param_x, state_x, ...)
    if select('#', ...) < 2 then
        return filter1_gen(fun, gen_x, param_x, state_x, ...)
    else
        return filterm_gen(fun, gen_x, param_x, state_x, ...)
    end
end

local filter_gen = function(param, state_x)
    local fun, gen_x, param_x = param[1], param[2], param[3]
    return filter_detect(fun, gen_x, param_x, gen_x(param_x, state_x))
end

---@category Filtering
---@param fun fun.Predicate @an predicate to filter the iterator
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return fun.Iterator, any, any @a new iterator of elements that satisfy the predicate
---@overload fun(fn: fun.Predicate, obj: fun.Iterable): fun.Iterator
local filter = function(fun, gen, param, state)
    return wrap(filter_gen, {fun, gen, param}, state)
end
methods.filter = method1(filter)
--- Return a new iterator of those elements that satisfy the **predicate**.
---
--- ```{note}
--- Multireturn iterators are supported but can cause performance regressions.
--- ```
---
--- [remove_if](filtering.md#funremove_if) is an alias of filter.
---
---
--- Example:
--- ```lua
--- each(print, filter(function(x) return x % 3 == 0 end, range(10)))
--- -- 3
--- -- 6
--- -- 9
---
--- each(print, take(5, filter(function(i, x) return i % 3 == 0 end,
---     enumerate(duplicate('x')))))
--- -- 3       x
--- -- 6       x
--- -- 9       x
--- -- 12      x
--- -- 15      x
--- ```
---
--- See also: [take_while](slicing.md#funtake_while) and [drop_while](slicing.md#fundrop_while).
exports.filter = export1(filter)
methods.remove_if = methods.filter
--- An alias for [filter](filtering.md#funfilter).
exports.remove_if = exports.filter

---@category Filtering
---@param fun_or_regexp fun.Predicate|string @a predicate or a Lua regular expression string
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return fun.Iterator, any, any @a new iterator of matching elements
---@overload fun(pattern: fun.Predicate|string, obj: fun.Iterable): fun.Iterator
local grep = function(fun_or_regexp, gen, param, state)
    local fun = fun_or_regexp
    if type(fun_or_regexp) == "string" then
        fun = function(x) return string.find(x, fun_or_regexp) ~= nil end
    end
    ---@cast fun fun.Predicate
    return filter(fun, gen, param, state)
end
methods.grep = method1(grep)
--- Filter the iterator by a regular expression or a predicate.
---
--- If **regexp_or_predicate** is a string then the parameter is used as a
--- regular expression to build a filtering predicate. Otherwise the function is
--- just an alias for [filter](filtering.md#funfilter). Equivalent to:
---
--- ```lua
--- local fun = fun_or_regexp
--- if type(fun_or_regexp) == "string" then
---     fun = function(x) return string.find(x, fun_or_regexp) ~= nil end
--- end
--- return filter(fun, gen, param, state)
--- ```
---
---
--- Example:
--- ```lua
--- lines_to_grep = {
---     [[Emily]],
---     [[Chloe]],
---     [[Megan]],
---     [[Jessica]],
---     [[Emma]],
---     [[Sarah]],
---     [[Elizabeth]],
---     [[Sophie]],
---     [[Olivia]],
---     [[Lauren]]
--- }
---
--- each(print, grep("^Em", lines_to_grep))
--- -- Emily
--- -- Emma
---
--- each(print, grep(function(x) return x % 3 == 0 end, range(10)))
--- -- 3
--- -- 6
--- -- 9
--- ```
exports.grep = export1(grep)

---@category Filtering
---@param fun fun.Predicate @a value to find
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return fun.Iterator, fun.Iterator, any, any @iterators of elements that do and do not satisfy the predicate
---@overload fun(fn: fun.Predicate, obj: fun.Iterable): fun.Iterator, fun.Iterator
local partition = function(fun, gen, param, state)
    local neg_fun = function(...)
        return not fun(...)
    end
    return filter(fun, gen, param, state),
           filter(neg_fun, gen, param, state)
end
methods.partition = method1(partition)
---
--- Return two iterators where elements do and do not satisfy the predicate.
---
--- Equivalent to:
---
--- ```lua
--- return filter(fun, gen, param, state),
---        filter(function(...) return not fun(...) end, gen, param, state)
--- ```
---
--- The function makes a clone of the source iterator. Iterators especially
--- returned in tables to work with [zip](compositions.md#funzip) and other
--- functions.
---
--- ```{note}
--- `{gen, param, state}` must be pure functional to work properly with the
--- function.
--- ```
---
---
--- Example:
--- ```lua
--- each(print, zip(partition(function(i, x) return i % 3 == 0 end, range(10))))
--- -- 3       1
--- -- 6       2
--- -- 9       4
--- ```
---
--- See also: [span](slicing.md#funspan).
exports.partition = export1(partition)

--------------------------------------------------------------------------------
-- Reducing
--------------------------------------------------------------------------------

local foldl_call = function(fun, start, state, ...)
    if state == nil then
        return nil, start
    end
    return state, fun(start, ...)
end

---@category Reducing
---@param fun fun.Reducer @an accumulating function
---@param start any @an initial value that passed to **accfun** on the first iteration
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return any @the accumulated value
---@overload fun(fn: fun.Reducer, start: any, obj: fun.Iterable): any
local foldl = function(fun, start, gen_x, param_x, state_x)
    while true do
        state_x, start = foldl_call(fun, start, gen_x(param_x, state_x))
        if state_x == nil then
            break;
        end
    end
    return start
end
methods.foldl = method2(foldl)
---   first iteration
---
--- The function reduces the iterator from left to right using the binary
--- operator **accfun** and the initial value **initval**. Equivalent to:
---
--- ```lua
--- local val = start
--- for _k, ... in gen_x, param_x, state_x do
---     val = fun(val, ...)
--- end
--- return val
--- ```
---
--- [reduce](reducing.md#funreduce) is an alias of foldl.
---
---
--- Example:
--- ```lua
--- print(foldl(function(acc, x) return acc + x end, 0, range(5)))
--- -- 15
---
--- print(foldl(operator.add, 0, range(5)))
--- -- 15
---
--- print(foldl(function(acc, x, y) return acc + x * y end, 0,
---     zip(range(1, 5), {4, 3, 2, 1})))
--- -- 20
--- ```
exports.foldl = export2(foldl)
methods.reduce = methods.foldl
--- An alias for [foldl](reducing.md#funfoldl).
exports.reduce = exports.foldl

---@category Reducing
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return number @the number of elements in the iterator
---@overload fun(a: string|table): number @# **a** (an alias for [len](#operatortablelen))
local length = function(gen, param, state)
    if gen == ipairs_gen or gen == string_gen then
        return #param - state
    end
    local len = 0
    repeat
        state = gen(param, state)
        len = len + 1
    until state == nil
    return len - 1
end
methods.length = method0(length)
--- Return a number of elements in the iterator.
---
--- The function is equivalent to #obj for basic array and string iterators.
---
--- ```{note}
--- This function has `O(n)` complexity for all iterators except basic array
--- and string iterators, where it has `O(1)` complexity.
--- ```
---
--- ```{warning}
--- An attempt to call this function on an infinite iterator will result in an
--- infinite loop.
--- ```
---
---
--- Example:
--- ```lua
--- print(length({"a", "b", "c", "d", "e"}))
--- -- 5
---
--- print(length(drop_n(3, {"a", "b", "c", "d", "e"})))
--- -- 2
---
--- print(length({}))
--- -- 0
---
--- print(length(range(0)))
--- -- 0
--- ```
exports.length = export0(length)

---@category Reducing
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return boolean @true when the iterator is empty or finished, false otherwise
---@overload fun(obj: fun.Iterable): boolean
local is_null = function(gen, param, state)
    return gen(param, deepcopy(state)) == nil
end
methods.is_null = method0(is_null)
--- otherwise.
---
--- Return true when the iterator is empty or finished, and false otherwise.
---
---
--- Example:
--- ```lua
--- print(is_null({"a", "b", "c", "d", "e"}))
--- -- false
---
--- print(is_null({}))
--- -- true
---
--- print(is_null(range(0)))
--- -- true
--- ```
exports.is_null = export0(is_null)

---@category Reducing
---@param iter_x fun.Iterator @the first iterator
---@param iter_y fun.Iterable @the second iterator
---@return boolean|nil @true if the first iterator is a prefix of the second
---@overload fun(iter_x: fun.Iterator, iter_y: fun.Iterable): boolean|nil
local is_prefix_of = function(iter_x, iter_y)
    local gen_x, param_x, state_x = rawiter(iter_x)
    local gen_y, param_y, state_y = rawiter(iter_y)

    local r_x, r_y
    repeat
        state_x, r_x = gen_x(param_x, state_x)
        if state_x == nil then
            return true
        end

        state_y, r_y = gen_y(param_y, state_y)
    until state_y == nil or r_x ~= r_y

    return false
end
methods.is_prefix_of = is_prefix_of
--- Return `true` if the first iterator is a prefix of the second, and false
--- otherwise.
---
---
--- Example:
--- ```lua
--- print(is_prefix_of({"a"}, {"a", "b", "c"}))
--- -- true
---
--- print(is_prefix_of(range(6), range(5)))
--- -- false
--- ```
exports.is_prefix_of = is_prefix_of

---@category Reducing
---@param fun fun.Predicate @a predicate
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return boolean @true if all iteration values satisfy the predicate
---@overload fun(fn: fun.Predicate, obj: fun.Iterable): boolean
local all = function(fun, gen_x, param_x, state_x)
    local r
    repeat
        state_x, r = call_if_not_empty(fun, gen_x(param_x, state_x))
    until state_x == nil or not r
    return state_x == nil
end
methods.all = method1(all)
--- Return true if all return values of the iterator satisfy the **predicate**.
---
--- [every](reducing.md#funevery) is an alias of all.
---
---
--- Example:
--- ```lua
--- print(all(function(x) return x end, {true, true, true, true}))
--- -- true
---
--- print(all(function(x) return x end, {true, true, true, false}))
--- -- false
--- ```
exports.all = export1(all)
methods.every = methods.all
--- An alias for [all](reducing.md#funall).
exports.every = exports.all

---@category Reducing
---@param fun fun.Predicate @a predicate
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return boolean @true if at least one iteration value satisfies the predicate
---@overload fun(fn: fun.Predicate, obj: fun.Iterable): boolean
local any = function(fun, gen_x, param_x, state_x)
    local r
    repeat
        state_x, r = call_if_not_empty(fun, gen_x(param_x, state_x))
    until state_x == nil or r
    return not not r
end
methods.any = method1(any)
--- Return true if at least one return value of the iterator satisfies the
--- **predicate**. The iteration stops on the first such value. Therefore,
--- infinity iterators that have at least one satisfying value might work.
---
--- [some](reducing.md#funsome) is an alias of any.
---
---
--- Example:
--- ```lua
--- print(any(function(x) return x end, {false, false, false, false}))
--- -- false
---
--- print(any(function(x) return x end, {false, false, false, true}))
--- -- true
--- ```
exports.any = export1(any)
methods.some = methods.any
--- An alias for [any](reducing.md#funany).
exports.some = exports.any

---@category Reducing
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return number @the sum of all iteration values
---@overload fun(obj: fun.Iterable): number
local sum = function(gen, param, state)
    local s = 0
    local r = 0
    repeat
        s = s + r
        state, r = gen(param, state)
    until state == nil
    return s
end
methods.sum = method0(sum)
--- Sum up all iteration values. An optimized alias for [foldl](reducing.md#funfoldl):
---
--- ```lua
--- foldl(operator.add, 0, gen, param, state)
--- ```
---
--- For an empty iterator `0` is returned.
---
---
--- Example:
--- ```lua
--- print(sum(range(5)))
--- -- 15
--- ```
exports.sum = export0(sum)

---@category Reducing
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return number @the product of all iteration values
---@overload fun(obj: fun.Iterable): number
local product = function(gen, param, state)
    local p = 1
    local r = 1
    repeat
        p = p * r
        state, r = gen(param, state)
    until state == nil
    return p
end
methods.product = method0(product)
--- Multiply all iteration values. An optimized alias for [foldl](reducing.md#funfoldl):
---
--- ```lua
--- foldl(operator.mul, 1, gen, param, state)
--- ```
---
--- For an empty iterator `1` is returned.
---
---
--- Example:
--- ```lua
--- print(product(range(1, 5)))
--- -- 120
--- ```
exports.product = export0(product)

local min_cmp = function(m, n)
    if n < m then return n else return m end
end

local max_cmp = function(m, n)
    if n > m then return n else return m end
end

---@category Reducing
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return any @the minimum value; an error is raised if the iterator is empty
---@overload fun(obj: fun.Iterable): any
local min = function(gen, param, state)
    local state, m = gen(param, state)
    if state == nil then
        error("min: iterator is empty")
    end

    local cmp
    if type(m) == "number" then
        -- An optimization: use math.min for numbers
        cmp = math.min
    else
        cmp = min_cmp
    end

    for _, r in gen, param, state do
        m = cmp(m, r)
    end
    return m
end
methods.min = method0(min)
--- Return a minimum value from the iterator using `math.min` or `<` for
--- numbers and other types respectively. The iterator must be non-null,
--- otherwise an error is raised.
---
--- [minimum](reducing.md#funminimum) is an alias of min.
---
---
--- Example:
--- ```lua
--- print(min(range(1, 10, 1)))
--- -- 1
---
--- print(min({"f", "d", "c", "d", "e"}))
--- -- c
---
--- print(min({}))
--- -- error: min: iterator is empty
--- ```
exports.min = export0(min)
methods.minimum = methods.min
--- An alias for [min](reducing.md#funmin).
exports.minimum = exports.min

---@category Reducing
---@param cmp fun.Comparator @a function used as the comparison operator
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return any @the minimum value; an error is raised if the iterator is empty
---@overload fun(fn: fun.Comparator, obj: fun.Iterable): any
local min_by = function(cmp, gen_x, param_x, state_x)
    local state_x, m = gen_x(param_x, state_x)
    if state_x == nil then
        error("min: iterator is empty")
    end

    for _, r in gen_x, param_x, state_x do
        m = cmp(m, r)
    end
    return m
end
methods.min_by = method1(min_by)
--- Return a minimum value from the iterator using the **cmp** as a `<`
--- operator. The iterator must be non-null, otherwise an error is raised.
---
--- [minimum_by](reducing.md#funminimum_by) is an alias of min_by.
---
---
--- Example:
--- ```lua
--- function min_cmp(a, b) if -a < -b then return a else return b end end
--- print(min_by(min_cmp, range(1, 10, 1)))
--- -- 9
--- ```
exports.min_by = export1(min_by)
methods.minimum_by = methods.min_by
--- An alias for [min_by](reducing.md#funmin_by).
exports.minimum_by = exports.min_by

---@category Reducing
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return any @the maximum value; an error is raised if the iterator is empty
---@overload fun(obj: fun.Iterable): any
local max = function(gen_x, param_x, state_x)
    local state_x, m = gen_x(param_x, state_x)
    if state_x == nil then
        error("max: iterator is empty")
    end

    local cmp
    if type(m) == "number" then
        -- An optimization: use math.max for numbers
        cmp = math.max
    else
        cmp = max_cmp
    end

    for _, r in gen_x, param_x, state_x do
        m = cmp(m, r)
    end
    return m
end
methods.max = method0(max)
--- Return a maximum value from the iterator using `math.max` or `>` for
--- numbers and other types respectively. The iterator must be non-null,
--- otherwise an error is raised.
---
--- [maximum](reducing.md#funmaximum) is an alias of max.
---
---
--- Example:
--- ```lua
--- print(max(range(1, 10, 1)))
--- -- 9
---
--- print(max({"f", "d", "c", "d", "e"}))
--- -- f
---
--- print(max({}))
--- -- error: max: iterator is empty
--- ```
exports.max = export0(max)
methods.maximum = methods.max
--- An alias for [max](reducing.md#funmax).
exports.maximum = exports.max

---@category Reducing
---@param cmp fun.Comparator @a function used as the comparison operator
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return any @the maximum value; an error is raised if the iterator is empty
---@overload fun(fn: fun.Comparator, obj: fun.Iterable): any
local max_by = function(cmp, gen_x, param_x, state_x)
    local state_x, m = gen_x(param_x, state_x)
    if state_x == nil then
        error("max: iterator is empty")
    end

    for _, r in gen_x, param_x, state_x do
        m = cmp(m, r)
    end
    return m
end
methods.max_by = method1(max_by)
--- Return a maximum value from the iterator using the **cmp** as a `>`
--- operator. The iterator must be non-null, otherwise an error is raised.
---
--- [maximum_by](reducing.md#funmaximum_by) is an alias of max_by.
---
---
--- Example:
--- ```lua
--- function max_cmp(a, b) if -a > -b then return a else return b end end
--- print(max_by(max_cmp, range(1, 10, 1)))
--- -- 1
--- ```
exports.max_by = export1(max_by)
methods.maximum_by = methods.max_by
--- An alias for [max_by](reducing.md#funmax_by).
exports.maximum_by = exports.max_by

---@category Reducing
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return any[] @a new table (array) with all iteration values
---@overload fun(obj: fun.Iterable): any[]
local totable = function(gen_x, param_x, state_x)
    local tab, val = {}
    while true do
        state_x, val = gen_x(param_x, state_x)
        if state_x == nil then
            break
        end
        table.insert(tab, val)
    end
    return tab
end
methods.totable = method0(totable)
---
--- Collect all iteration values into a new table (array).
---
--- The function reduces the iterator from left to right using `table.insert`.
---
---
--- Example:
--- ```lua
--- local tab = totable("abcdef")
--- print(type(tab), #tab)
--- -- table 6
--- each(print, tab)
--- -- a
--- -- b
--- -- c
--- -- d
--- -- e
--- -- f
--- ```
exports.totable = export0(totable)

---@category Reducing
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return table<any, any> @a new table (map) from iteration key-value pairs
---@overload fun(obj: fun.Iterable): table<any, any>
local tomap = function(gen_x, param_x, state_x)
    local tab, key, val = {}
    while true do
        state_x, key, val = gen_x(param_x, state_x)
        if state_x == nil then
            break
        end
        tab[key] = val
    end
    return tab
end
methods.tomap = method0(tomap)
---
--- Collect all iteration key-value pairs into a new table (map).
---
--- The function reduces the iterator from left to right using the
--- `tab[val1] = val2` expression.
---
---
--- Example:
--- ```lua
--- local tab = tomap(zip(range(1, 7), 'abcdef'))
--- print(type(tab), #tab)
--- -- table   6
--- each(print, iter(tab))
--- -- a
--- -- b
--- -- c
--- -- d
--- -- e
--- -- f
--- ```
exports.tomap = export0(tomap)

--------------------------------------------------------------------------------
-- Transformations
--------------------------------------------------------------------------------

local map_gen = function(param, state)
    local gen_x, param_x, fun = param[1], param[2], param[3]
    return call_if_not_empty(fun, gen_x(param_x, state))
end

---@category Transformations
---@param fun fun(...): any @a function to apply
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return fun.Iterator, any, any @a new iterator of mapped values (mapped on the fly)
---@overload fun(fn: fun(...): any, obj: fun.Iterable): fun.Iterator
local map = function(fun, gen, param, state)
    return wrap(map_gen, {gen, param, fun}, state)
end
methods.map = method1(map)
---
--- Return a new iterator by applying the **fun** to each element of
--- `gen, param, state` iterator. The mapping is performed on the fly
--- and no values are buffered.
---
---
--- Example:
--- ```lua
--- each(print, map(function(x) return 2 * x end, range(4)))
--- -- 2
--- -- 4
--- -- 6
--- -- 8
---
--- fun = function(...) return 'map', ... end
--- each(print, map(fun, range(4)))
--- -- map 1
--- -- map 2
--- -- map 3
--- -- map 4
--- ```
exports.map = export1(map)

local enumerate_gen_call = function(_state, i, state_x, ...)
    if state_x == nil then
        return nil
    end
    return {i + 1, state_x}, i, ...
end

local enumerate_gen = function(param, state)
    local gen_x, param_x = param[1], param[2]
    local i, state_x = state[1], state[2]
    return enumerate_gen_call(state, i, gen_x(param_x, state_x))
end

---@category Transformations
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return fun.Iterator, any, any @a new iterator enumerating all elements starting from 1
---@overload fun(obj: fun.Iterable): fun.Iterator
local enumerate = function(gen, param, state)
    return wrap(enumerate_gen, {gen, param}, {1, state})
end
methods.enumerate = method0(enumerate)
---
--- Return a new iterator by enumerating all elements of the
--- `gen, param, state` iterator starting from `1`. The mapping is performed
--- on the fly and no values are buffered.
---
---
--- Example:
--- ```lua
--- each(print, enumerate({"a", "b", "c", "d", "e"}))
--- -- 1 a
--- -- 2 b
--- -- 3 c
--- -- 4 d
--- -- 5 e
---
--- each(print, enumerate(zip({"one", "two", "three", "four", "five"},
---     {"a", "b", "c", "d", "e"})))
--- -- 1 one a
--- -- 2 two b
--- -- 3 three c
--- -- 4 four d
--- -- 5 five e
--- ```
exports.enumerate = export0(enumerate)

local intersperse_call = function(i, state_x, ...)
    if state_x == nil then
        return nil
    end
    return {i + 1, state_x}, ...
end

local intersperse_gen = function(param, state)
    local x, gen_x, param_x = param[1], param[2], param[3]
    local i, state_x = state[1], state[2]
    if i % 2 == 1 then
        return {i + 1, state_x}, x
    else
        return intersperse_call(i, gen_x(param_x, state_x))
    end
end

-- TODO: interperse must not add x to the tail
---@category Transformations
---@param x any @a value to intersperse between the elements
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return fun.Iterator, any, any @a new iterator with x interspersed between the elements
---@overload fun(x: any, obj: fun.Iterable): fun.Iterator
local intersperse = function(x, gen, param, state)
    return wrap(intersperse_gen, {x, gen, param}, {0, state})
end
methods.intersperse = method1(intersperse)
---
--- Return a new iterator where the **x** value is interspersed between the
--- elements of the source iterator. The **x** value can also be added as a
--- last element of returning iterator if the source iterator contains the odd
--- number of elements.
---
---
--- Example:
--- ```lua
--- each(print, intersperse("x", {"a", "b", "c", "d", "e"}))
--- -- a
--- -- x
--- -- b
--- -- x
--- -- c
--- -- x
--- -- d
--- -- x
--- -- e
--- -- x
--- ```
exports.intersperse = export1(intersperse)

--------------------------------------------------------------------------------
-- Compositions
--------------------------------------------------------------------------------

local function zip_gen_r(param, state, state_new, ...)
    if #state_new == #param / 2 then
        return state_new, ...
    end

    local i = #state_new + 1
    local gen_x, param_x = param[2 * i - 1], param[2 * i]
    local state_x, r = gen_x(param_x, state[i])
    if state_x == nil then
        return nil
    end
    table.insert(state_new, state_x)
    return zip_gen_r(param, state, state_new, r, ...)
end

local zip_gen = function(param, state)
    return zip_gen_r(param, state, {})
end

-- A special hack for zip/chain to skip last two state, if a wrapped iterator
-- has been passed
local numargs = function(...)
    local n = select('#', ...)
    if n >= 3 then
        -- Fix last argument
        local it = select(n - 2, ...)
        if type(it) == 'table' and getmetatable(it) == iterator_mt and
           it.param == select(n - 1, ...) and it.state == select(n, ...) then
            return n - 2
        end
    end
    return n
end

---@category Compositions
---@vararg fun.Iterable @iterators to zip
---@return fun.Iterator, any, any @an iterator whose i-th value holds the i-th element of each iterator
---@overload fun(...: fun.Iterable): fun.Iterator
local zip = function(...)
    local n = numargs(...)
    if n == 0 then
        return wrap(nil_gen, nil, nil)
    end
    ---@type table<any, any>
    local param = { [2 * n] = 0 }
    ---@type table<any, any>
    local state = { [n] = 0 }

    local gen_x, param_x, state_x
    for i=1,n,1 do
        local it = select(n - i + 1, ...)
        gen_x, param_x, state_x = rawiter(it)
        param[2 * i - 1] = gen_x
        param[2 * i] = param_x
        state[i] = state_x
    end

    return wrap(zip_gen, param, state)
end
methods.zip = zip
---
--- Return a new iterator where the i-th return value contains the i-th
--- element from each of the iterators. The returned iterator is truncated in
--- length to the length of the shortest iterator. For multi-return iterators
--- only the first variable is used.
---
---
--- Example:
--- ```lua
--- dump(zip({"a", "b", "c", "d"}, {"one", "two", "three"}))
--- -- a one
--- -- b two
--- -- c three
---
--- each(print, zip())
---
--- each(print, zip(range(5), {'a', 'b', 'c'}, rands()))
--- -- 1       a       0.57514179487402
--- -- 2       b       0.79693061238668
--- -- 3       c       0.45174307459403
---
--- each(print, zip(partition(function(x) return x > 7 end, range(1, 15, 1))))
--- -- 8       1
--- -- 9       2
--- -- 10      3
--- -- 11      4
--- -- 12      5
--- -- 13      6
--- -- 14      7
--- ```
exports.zip = zip

local cycle_gen_call = function(param, state_x, ...)
    if state_x == nil then
        local gen_x, param_x, state_x0 = param[1], param[2], param[3]
        return gen_x(param_x, deepcopy(state_x0))
    end
    return state_x, ...
end

local cycle_gen = function(param, state_x)
    local gen_x, param_x = param[1], param[2]
    return cycle_gen_call(param, gen_x(param_x, state_x))
end

---@category Compositions
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return fun.Iterator, any, any @a cycled version of the iterator
---@overload fun(obj: fun.Iterable): fun.Iterator
local cycle = function(gen, param, state)
    return wrap(cycle_gen, {gen, param, state}, deepcopy(state))
end
methods.cycle = method0(cycle)
---
--- Make a new iterator that returns elements from the iterator until the end
--- and then "restarts" the iteration using a saved clone of the iterator.
--- The returned iterator is constant space and no return values are buffered.
--- Instead of that the function makes a clone of the source iterator.
--- Therefore, the source iterator must be pure functional to make an identical
--- clone. Infinity iterators are supported, but are not recommended.
---
--- ```{note}
--- `{gen, param, state}` must be pure functional to work properly with the
--- function.
--- ```
---
---
--- Example:
--- ```lua
--- each(print, take(15, cycle(range(5))))
--- -- 1
--- -- 2
--- -- 3
--- -- 4
--- -- 5
--- -- 1
--- -- 2
--- -- 3
--- -- 4
--- -- 5
--- -- 1
--- -- 2
--- -- 3
--- -- 4
--- -- 5
---
--- each(print, take(15, cycle(zip(range(5), {"a", "b", "c", "d", "e"}))))
--- -- 1       a
--- -- 2       b
--- -- 3       c
--- -- 4       d
--- -- 5       e
--- -- 1       a
--- -- 2       b
--- -- 3       c
--- -- 4       d
--- -- 5       e
--- -- 1       a
--- -- 2       b
--- -- 3       c
--- -- 4       d
--- -- 5       e
--- ```
exports.cycle = export0(cycle)

-- call each other
local chain_gen_r1
local chain_gen_r2 = function(param, state, state_x, ...)
    if state_x == nil then
        local i = state[1]
        i = i + 1
        if param[3 * i - 2] == nil then
            return nil
        end
        ---@diagnostic disable-next-line: need-check-nil
        return chain_gen_r1(param, {i, param[3 * i]})
    end
    return {state[1], state_x}, ...
end

chain_gen_r1 = function(param, state)
    local i = state[1]
    local gen_x, param_x = param[3 * i - 2], param[3 * i - 1]
    return chain_gen_r2(param, state, gen_x(param_x, state[2]))
end

---@category Compositions
---@vararg fun.Iterable @iterators to chain
---@return fun.Iterator, any, any @a consecutive iterator from the sources
---@overload fun(...: fun.Iterable): fun.Iterator
local chain = function(...)
    local n = numargs(...)
    if n == 0 then
        return wrap(nil_gen, nil, nil)
    end

    ---@type table<any, any>
    local param = { [3 * n] = 0 }
    local gen_x, param_x, state_x
    for i=1,n,1 do
        local elem = select(i, ...)
        gen_x, param_x, state_x = iter(elem)
        param[3 * i - 2] = gen_x
        param[3 * i - 1] = param_x
        param[3 * i] = state_x
    end

    return wrap(chain_gen_r1, param, {1, param[3]})
end
methods.chain = chain
---
--- Make an iterator that returns elements from the first iterator until it is
--- exhausted, then proceeds to the next iterator, until all of the iterators
--- are exhausted. Used for treating consecutive iterators as a single
--- iterator. Infinity iterators are supported, but are not recommended.
---
---
--- Example:
--- ```lua
--- each(print, chain(range(2), {"a", "b", "c"}, {"one", "two", "three"}))
--- -- 1
--- -- 2
--- -- a
--- -- b
--- -- c
--- -- one
--- -- two
--- -- three
---
--- each(print, take(15, cycle(chain(enumerate({"a", "b", "c"}),
---     {"one", "two", "three"}))))
--- -- 1       a
--- -- 2       b
--- -- 3       c
--- -- one
--- -- two
--- -- three
--- -- 1       a
--- -- 2       b
--- -- 3       c
--- -- one
--- -- two
--- -- three
--- -- 1       a
--- -- 2       b
--- -- 3       c
--- ```
exports.chain = chain

--------------------------------------------------------------------------------
-- Operators
--------------------------------------------------------------------------------

--- A table of Lua operators exported as intrinsic functions, to be used with
--- the library high-order primitives.
---
--- ```{note}
--- **op** can be used as a shortcut to **operator**.
--- ```
---
--- Comparison operators: le (a <= b), lt (a < b), eq (a == b), ne (a ~= b),
--- ge (a >= b), gt (a > b).
---
--- Arithmetic operators: add (a + b), div/truediv (a / b, "true" float
--- division), floordiv (math.floor(a / b)), intdiv (C-like integer division),
--- mod (a % b), mul (a * b), neq/unm (-a), pow (a ^ b), sub (a - b).
---
--- String operators: concat (a .. b), len/length (#a).
---
--- Logical operators: land (a and b), lor (a or b), lnot (not a), truth
--- (not not a).
---
--- Example:
--- ```lua
--- print(operator.div(10, 3))
--- -- 3.3333333333333
--- print(operator.div(-10, 3))
--- -- -3.3333333333333
---
--- print(operator.floordiv(10, 3))
--- -- 3
--- print(operator.floordiv(12, 3))
--- -- 4
--- print(operator.floordiv(-10, 3))
--- -- -4
--- print(operator.floordiv(-12, 3))
--- -- -4
---
--- print(operator.intdiv(10, 3))
--- -- 3
--- print(operator.intdiv(12, 3))
--- -- 4
--- print(operator.intdiv(-10, 3))
--- -- -3
--- print(operator.intdiv(-12, 3))
--- -- -4
---
--- print(operator.mod(10, 2))
--- -- 0
--- print(operator.mod(10, 3))
--- -- 2
--- print(operator.mod(-10, 3))
--- -- 2 -- == -1 in C, Java, JavaScript but not in Lua, Python, Haskell!
---
--- print(operator.truth(1))
--- -- true
--- print(operator.truth(0))
--- -- true -- It is Lua, baby!
--- print(operator.truth(nil))
--- -- false
--- print(operator.truth(""))
--- -- true
--- print(operator.truth({}))
--- -- true
--- ```
---
--- ```{note}
--- Result has same sign as **divisor**. Modulo in Lua is defined as
--- `a % b == a - math.floor(a/b)*b`.
--- ```
---
---@class fun.OperatorTable
---@field lt fun(a: any, b: any): boolean @**a** < **b**
---@field le fun(a: any, b: any): boolean @**a** <= **b**
---@field eq fun(a: any, b: any): boolean @**a** == **b**
---@field ne fun(a: any, b: any): boolean @**a** ~= **b**
---@field ge fun(a: any, b: any): boolean @**a** >= **b**
---@field gt fun(a: any, b: any): boolean @**a** > **b**
---@field add fun(a: number, b: number): number @**a** + **b**
---@field div fun(a: number, b: number): number @**a** / **b** (an alias for [truediv](#operatortabletruediv))
---@field floordiv fun(a: number, b: number): number @math.floor(**a** / **b**)
---@field intdiv fun(a: number, b: number): number @C-like integer division
---@field mod fun(a: number, b: number): number @**a** % **b**
---@field mul fun(a: number, b: number): number @**a** * **b**
---@field neq fun(a: number): number @-**a**
---@field unm fun(a: number): number @-**a** (an alias for [neq](#operatortableneq))
---@field pow fun(a: number, b: number): number @math.pow(**a**, **b**)
---@field sub fun(a: number, b: number): number @**a** - **b**
---@field truediv fun(a: number, b: number): number @**a** / **b** (true float division)
---@field concat fun(a: any, b: any): any @**a** .. **b**
---@field len fun(a: string|table): number @# **a**
---@field length fun(a: string|table): number @# **a** (an alias for [len](#operatortablelen))
---@field land fun(a: any, b: any): any @**a** and **b**
---@field lor fun(a: any, b: any): any @**a** or **b**
---@field lnot fun(a: any): boolean @not **a**
---@field truth fun(a: any): boolean @not not **a**
---@category Operators
local operator = {
    ----------------------------------------------------------------------------
    -- Comparison operators
    ----------------------------------------------------------------------------
    lt  = function(a, b) return a < b end,
    le  = function(a, b) return a <= b end,
    eq  = function(a, b) return a == b end,
    ne  = function(a, b) return a ~= b end,
    ge  = function(a, b) return a >= b end,
    gt  = function(a, b) return a > b end,

    ----------------------------------------------------------------------------
    -- Arithmetic operators
    ----------------------------------------------------------------------------
    add = function(a, b) return a + b end,
    div = function(a, b) return a / b end,
    floordiv = function(a, b) return math.floor(a/b) end,
    intdiv = function(a, b)
        local q = a / b
        if a >= 0 then return math.floor(q) else return math.ceil(q) end
    end,
    mod = function(a, b) return a % b end,
    mul = function(a, b) return a * b end,
    neq = function(a) return -a end,
    unm = function(a) return -a end, -- an alias
    pow = function(a, b) return a ^ b end,
    sub = function(a, b) return a - b end,
    truediv = function(a, b) return a / b end,

    ----------------------------------------------------------------------------
    -- String operators
    ----------------------------------------------------------------------------
    concat = function(a, b) return a..b end,
    len = function(a) return #a end,
    length = function(a) return #a end, -- an alias

    ----------------------------------------------------------------------------
    -- Logical operators
    ----------------------------------------------------------------------------
    land = function(a, b) return a and b end,
    lor = function(a, b) return a or b end,
    lnot = function(a) return not a end,
    truth = function(a) return not not a end,
}
--- Lua operators exported as functions
exports.operator = operator
methods.operator = operator
--- An alias for [operator](operators.md#funoperator).
exports.op = operator
methods.op = operator

--------------------------------------------------------------------------------
-- module definitions
--------------------------------------------------------------------------------

-- a special syntax sugar to export all functions to the global table
setmetatable(exports, {
    __call = function(t, override)
        for k, v in pairs(t) do
            if rawget(_G, k) ~= nil then
                local msg = 'function ' .. k .. ' already exists in global scope.'
                if override then
                    rawset(_G, k, v)
                    print('WARNING: ' .. msg .. ' Overwritten.')
                else
                    print('NOTICE: ' .. msg .. ' Skipped.')
                end
            else
                rawset(_G, k, v)
            end
        end
    end,
})

return exports
