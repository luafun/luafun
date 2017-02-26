--------
-- Lua Fun - a high-performance functional programming library for LuaJIT
--
-- Patched version maintained at:
-- https://github.com/HeinrichHartmann/luafun
--
-- @module fun
-- @license MIT/X11 License
-- @copyright 2013-2016 Roman Tsisyk <roman@tsisyk.com>
--

local exports = {}
local methods = {}

-- compatibility with Lua 5.1/5.2
local unpack = rawget(table, "unpack") or unpack

local MISSING_VAL = false
local is_missing = function(x) return x == MISSING_VAL end

--- General Tooling
-- @section Tools

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
    __tostring = function(self)
        return '<generator>'
    end;
    -- add all exported methods
    __index = methods;
}

--- wrap a (gen, param, state) tuple into a an iterator object.
--@return iterator
local wrap = function(
    gen, -- A function that transforms the next state when called `get(param, state)`
    param, -- A permanent (constant) parameter of a generating function is used to create specific instance of the generating function.
    state -- initial state of the iterator
    )
    return setmetatable({
        gen = gen,
        param = param,
        state = state
    }, iterator_mt), param, state
end
exports.wrap = wrap

--@param iterator_object
--@return gen, param, state - triple
local unwrap = function(self)
    return self.gen, self.param, self.state
end
methods.unwrap = unwrap

--- Basic Functions
--@section


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

local pairs_gen = pairs({ a = 0 }) -- get the generating function from pairs
local map_gen = function(tab, key)
    local value
    local key, value = pairs_gen(tab, key)
    return key, key, value
end

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

--- Create an iterator from object.
--  @usage Where object can be:
--  - an iterator (do nothing)
--  - a table (use pairs/ipairs)
--  - a generator function
--  - a string
local iter = function(obj, param, state)
    return wrap(rawiter(obj, param, state))
end
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

local export0 = function(fun)
    return function(gen, param, state)
        return fun(rawiter(gen, param, state))
    end
end

local export1 = function(fun)
    return function(arg1, gen, param, state)
        return fun(arg1, rawiter(gen, param, state))
    end
end

local export2 = function(fun)
    return function(arg1, arg2, gen, param, state)
        return fun(arg1, arg2, rawiter(gen, param, state))
    end
end

local each = function(fun, gen, param, state)
    repeat
        state = call_if_not_empty(fun, gen(param, state))
    until state == nil
end
methods.each = method1(each)
exports.each = export1(each)
methods.for_each = methods.each
exports.for_each = exports.each
methods.foreach = methods.each
exports.foreach = exports.each

--- Generators
--@section

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

--- range generator.
local range = function(start, stop, step)
  if start == nil then start = 1 end
  if stop == nil then stop = 1/0 end -- don't stop
  if step == nil then
    step = (start <= stop) and 1 or -1
  end

  assert(type(start) == "number", "start must be a number")
  assert(type(stop) == "number", "stop must be a number")
  assert(type(step) == "number", "step must be a number")

  if (step >= 0) then
    return wrap(range_gen, {stop, step}, start - step)
  elseif (step < 0) then
    return wrap(range_rev_gen, {stop, step}, start - step)
  end
end
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

---iterate over arguments
--@param item_ot_table
local duplicate = function(...)
    if select('#', ...) <= 1 then
        return wrap(duplicate_gen, select(1, ...), 0)
    else
        return wrap(duplicate_table_gen, {...}, 0)
    end
end
exports.duplicate = duplicate
exports.replicate = duplicate
exports.xrepeat = duplicate

local tabulate = function(fun)
    assert(type(fun) == "function")
    return wrap(duplicate_fun_gen, fun, 0)
end
exports.tabulate = tabulate

---constant iterator: 0
local zeros = function()
    return wrap(duplicate_gen, 0, 0)
end
exports.zeros = zeros

---constant iterator: 1
local ones = function()
    return wrap(duplicate_gen, 1, 0)
end
exports.ones = ones

local rands_gen = function(param_x, _state_x)
    return 0, math.random(param_x[1], param_x[2])
end

local rands_nil_gen = function(_param_x, _state_x)
    return 0, math.random()
end

---random iterator
--@int n -- lower bound
--@int m -- upper bound
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
exports.rands = rands


--- Slicing
--@section

---nth.
local nth = function(n, gen_x, param_x, state_x)
    assert(n > 0, "invalid first argument to nth")
    -- An optimization for arrays and strings
    if gen_x == ipairs then
        return param_x[n]
    elseif gen_x == string_gen then
        if n <= #param_x then
            return string.sub(param_x, n, n)
        else
            return nil
        end
    end
    for i=1,n-1,1 do
        state_x = gen_x(param_x, state_x)
        if state_x == nil then
            return nil
        end
    end
    return return_if_not_empty(gen_x(param_x, state_x))
end
methods.nth = method1(nth)
exports.nth = export1(nth)

local head_call = function(state, ...)
    if state == nil then
        return nil -- empty iterator
    end
    return ...
end

---head.
local head = function(gen, param, state)
    return head_call(gen(param, state))
end
methods.head = method0(head)
exports.head = export0(head)
exports.car = exports.head
methods.car = methods.head

local cdr = function(gen, param, state)
    state = gen(param, state)
    if state == nil then
        return wrap(nil_gen, nil, nil)
    end
    return wrap(gen, param, state)
end
exports.cdr = exports.cdr
methods.cdr = methods.cdr

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

---take_n.
local take_n = function(n, gen, param, state)
    assert(n >= 0, "invalid first argument to take_n")
    return wrap(take_n_gen, {n, gen, param}, {0, state})
end
methods.take_n = method1(take_n)
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

---take while.
local take_while = function(fun, gen, param, state)
    assert(type(fun) == "function", "invalid first argument to take_while")
    return wrap(take_while_gen, {fun, gen, param}, state)
end
methods.take_while = method1(take_while)
exports.take_while = export1(take_while)

local take = function(n_or_fun, gen, param, state)
    if type(n_or_fun) == "number" then
        return take_n(n_or_fun, gen, param, state)
    else
        return take_while(n_or_fun, gen, param, state)
    end
end
methods.take = method1(take)
exports.take = export1(take)

---drop_n.
local drop_n = function(n, gen, param, state)
    assert(n >= 0, "invalid first argument to drop_n")
    local i
    for i=1,n,1 do
        state = gen(param, state)
        if state == nil then
            return wrap(nil_gen, nil, nil)
        end
    end
    return wrap(gen, param, state)
end
methods.drop_n = method1(drop_n)
exports.drop_n = export1(drop_n)

local drop_while_x = function(fun, state_x, ...)
    if state_x == nil or not fun(...) then
        return state_x, false
    end
    return state_x, true, ...
end

local drop_while = function(fun, gen_x, param_x, state_x)
    assert(type(fun) == "function", "invalid first argument to drop_while")
    local cont, state_x_prev
    repeat
        state_x_prev = deepcopy(state_x)
        state_x, cont = drop_while_x(fun, gen_x(param_x, state_x))
    until not cont
    if state_x == nil then
        return wrap(nil_gen, nil, nil)
    end
    return wrap(gen_x, param_x, state_x_prev)
end
methods.drop_while = method1(drop_while)
exports.drop_while = export1(drop_while)

local drop = function(n_or_fun, gen_x, param_x, state_x)
    if type(n_or_fun) == "number" then
        return drop_n(n_or_fun, gen_x, param_x, state_x)
    else
        return drop_while(n_or_fun, gen_x, param_x, state_x)
    end
end
methods.drop = method1(drop)
exports.drop = export1(drop)

local split = function(n_or_fun, gen_x, param_x, state_x)
    return take(n_or_fun, gen_x, param_x, state_x),
           drop(n_or_fun, gen_x, param_x, state_x)
end
methods.split = method1(split)
exports.split = export1(split)
methods.split_at = methods.split
exports.split_at = exports.split
methods.span = methods.split
exports.span = exports.split

--- Indexing
--@section

---index.
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
exports.index = export1(index)
methods.index_of = methods.index
exports.index_of = exports.index
methods.elem_index = methods.index
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

---indexes.
local indexes = function(x, gen, param, state)
    return wrap(indexes_gen, {x, gen, param}, {0, state})
end
methods.indexes = method1(indexes)
exports.indexes = export1(indexes)
methods.elem_indexes = methods.indexes
exports.elem_indexes = exports.indexes
methods.indices = methods.indexes
exports.indices = exports.indexes
methods.elem_indices = methods.indexes
exports.elem_indices = exports.indexes

--- Filtering
--@section

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

--- filter.
--@param fun filter function. If fun(y) == true then yield y.
local filter = function(fun, gen, param, state)
    return wrap(filter_gen, {fun, gen, param}, state)
end
methods.filter = method1(filter)
exports.filter = export1(filter)
methods.remove_if = methods.filter
exports.remove_if = exports.filter

--- grep for function or regexp.
local grep = function(fun_or_regexp, gen, param, state)
    local fun = fun_or_regexp
    if type(fun_or_regexp) == "string" then
        fun = function(x) return string.find(x, fun_or_regexp) ~= nil end
    end
    return filter(fun, gen, param, state)
end
methods.grep = method1(grep)
exports.grep = export1(grep)

---partition.
local partition = function(fun, gen, param, state)
    local neg_fun = function(...)
        return not fun(...)
    end
    return filter(fun, gen, param, state),
           filter(neg_fun, gen, param, state)
end
methods.partition = method1(partition)
exports.partition = export1(partition)

--- Reducing
--@section
local foldl_call = function(fun, start, state, ...)
    if state == nil then
        return nil, start
    end
    return state, fun(start, ...)
end

---foldl.
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
exports.foldl = export2(foldl)
methods.reduce = methods.foldl
exports.reduce = exports.foldl

---length.
local length = function(gen, param, state)
    if gen == ipairs or gen == string_gen then
        return #param
    end
    local len = 0
    repeat
        state = gen(param, state)
        len = len + 1
    until state == nil
    return len - 1
end
methods.length = method0(length)
exports.length = export0(length)

local is_null = function(gen, param, state)
    return gen(param, deepcopy(state)) == nil
end
methods.is_null = method0(is_null)
exports.is_null = export0(is_null)

local is_prefix_of = function(iter_x, iter_y)
    local gen_x, param_x, state_x = iter(iter_x)
    local gen_y, param_y, state_y = iter(iter_y)

    local r_x, r_y
    for i=1,10,1 do
        state_x, r_x = gen_x(param_x, state_x)
        state_y, r_y = gen_y(param_y, state_y)
        if state_x == nil then
            return true
        end
        if state_y == nil or r_x ~= r_y then
            return false
        end
    end
end
methods.is_prefix_of = is_prefix_of
exports.is_prefix_of = is_prefix_of

local all = function(fun, gen_x, param_x, state_x)
    local r
    repeat
        state_x, r = call_if_not_empty(fun, gen_x(param_x, state_x))
    until state_x == nil or not r
    return state_x == nil
end
methods.all = method1(all)
exports.all = export1(all)
methods.every = methods.all
exports.every = exports.all

local any = function(fun, gen_x, param_x, state_x)
    local r
    repeat
        state_x, r = call_if_not_empty(fun, gen_x(param_x, state_x))
    until state_x == nil or r
    return not not r
end
methods.any = method1(any)
exports.any = export1(any)
methods.some = methods.any
exports.some = exports.any

local totable = function(gen_x, param_x, state_x)
    local tab, key, val = {}
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
exports.totable = export0(totable)

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
exports.tomap = export0(tomap)

--
-- Transformations
--

local map_gen = function(param, state)
    local gen_x, param_x, fun = param[1], param[2], param[3]
    return call_if_not_empty(fun, gen_x(param_x, state))
end

local map = function(fun, gen, param, state)
    return wrap(map_gen, {gen, param, fun}, state)
end
methods.map = method1(map)
exports.map = export1(map)

local enumerate_gen_call = function(state, i, state_x, ...)
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

local enumerate = function(gen, param, state)
    return wrap(enumerate_gen, {gen, param}, {1, state})
end
methods.enumerate = method0(enumerate)
exports.enumerate = export0(enumerate)

--
-- Compositions
--

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

local zip = function(...)
    local n = numargs(...)
    if n == 0 then
        return wrap(nil_gen, nil, nil)
    end
    local param = { [2 * n] = 0 }
    local state = { [n] = 0 }

    local i, gen_x, param_x, state_x
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
exports.zip = zip

local cycle_gen_call = function(param, state_x, ...)
    if state_x == nil then
        local gen_x, param_x, state_x0 = param[1], param[2], param[3]
        return gen_x(param_x, deepcopy(state_x0))
    end
    return state_x, ...
end

local cycle_gen = function(param, state_x)
    local gen_x, param_x, state_x0 = param[1], param[2], param[3]
    return cycle_gen_call(param, gen_x(param_x, state_x))
end

local cycle = function(gen, param, state)
    return wrap(cycle_gen, {gen, param, state}, deepcopy(state))
end
methods.cycle = method0(cycle)
exports.cycle = export0(cycle)

-- call each other
local chain_gen_r1
local chain_gen_r2 = function(param, state, state_x, ...)
    if state_x == nil then
        local i = state[1]
        i = i + 1
        if i > #param / 3 then
            return nil
        end
        local state_x = param[3 * i]
        return chain_gen_r1(param, {i, state_x})
    end
    return {state[1], state_x}, ...
end

chain_gen_r1 = function(param, state)
    local i, state_x = state[1], state[2]
    local gen_x, param_x = param[3 * i - 2], param[3 * i - 1]
    return chain_gen_r2(param, state, gen_x(param_x, state[2]))
end

local chain = function(...)
    local n = numargs(...)
    if n == 0 then
        return wrap(nil_gen, nil, nil)
    end

    local param = { [3 * n] = 0 }
    local i, gen_x, param_x, state_x
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
exports.chain = chain

--
-- Operators
--

local operator = {
    --
    -- Comparison operators
    --
    lt  = function(a, b) return a < b end,
    le  = function(a, b) return a <= b end,
    eq  = function(a, b) return a == b end,
    ne  = function(a, b) return a ~= b end,
    ge  = function(a, b) return a >= b end,
    gt  = function(a, b) return a > b end,

    --
    -- Arithmetic operators
    --
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

    --
    -- String operators
    --
    concat = function(a, b) return a..b end,
    len = function(a) return #a end,
    length = function(a) return #a end, -- an alias

    --
    -- Logical operators
    --
    land = function(a, b) return a and b end,
    lor = function(a, b) return a or b end,
    lnot = function(a) return not a end,
    truth = function(a) return not not a end,

}
exports.operator = operator
methods.operator = operator
exports.op = operator
methods.op = operator

--- Custom Additions
--@section

local run_call_if_not_empty = function(update_s, state_s, state_x, ...)
  if state_x == nil then return nil end
  update_s(state_s, ...)  -- update state_s
  return state_x, state_s -- return state_s
end
local run_gen = function(param, state_x)
  local gen_x, param_x, update_s, state_s = param[1], param[2], param[3], param[4]
  return run_call_if_not_empty(update_s, state_s, gen_x(param_x, state_x))
end

--- run a state machine `s` across the stream,
-- @usage given by
-- - s_init -- initial state
-- - update(s, ...) -- update state
-- returns sequence of states
--
-- E.g.
--
--    local s_init = { c = 0 }
--    local function update(s, y) s.c = s.c + 1 end
--    local function get(s) return s.c end
--    iter():run(update, s_init):map(get)
--
local run = function(update_s, state_s, gen_x, param_x, state_x)
  return wrap(run_gen, {gen_x, param_x, update_s, state_s}, state_x)
end
methods.run = method2(run)
exports.run = export2(run)

local pass_call = function(fun, state_x, ...)
  if state_x == nil then return nil end
  fun(...)
  return state_x, ...
end
local pass_gen = function(param, state_x)
  local gen_x, param_x, fun = param[1], param[2], param[3]
  return pass_call(fun, gen_x(param_x, state_x))
end
--- pass values to a function, discard return values
-- useful to inspect intermediate results
local pass = function(fun, gen, param, state)
  return wrap(pass_gen, {gen, param, fun}, state)
end
methods.pass = method1(pass)
exports.pass = export1(pass)

--- return last element of iterator
-- only works for single valued iterators
local tail = function(gen, param, state)
  local x, last_x
  while state ~= nil do
    last_x = x
    state, x = gen(param, state)
  end
  return last_x
end
methods.tail = method0(tail)
exports.tail = export0(tail)

--- drop missing values.
local drop = function(drop_val, gen, param, state)
  local drop_fun = function(x) return not (drop_val == x) end
  return filter(drop_fun, gen, param, state)
end
methods.drop = method1(drop)
exports.drop = export1(drop)

--- replace MISSING_VAL with given value
local fill = function(replacement, gen, param, state)
  fill_map = function(x)
    if is_missing(x) then
      return replacement
    else
      return x
    end
  end
  return map(fill_map, gen, param, state)
end
methods.fill = method1(fill)
exports.fill = export1(fill)

--- Arithmetic Methods
--@section

local moments_update = function(M, y)
  if is_missing(y) then return end
  local y_power = 1
  for m = 1, #M do
    M[m] = M[m] + y_power
    y_power = y_power * y
  end
end

--- Moments
--
-- compute the first k moments over the iterator
-- Respects MISSING_VAL values
-- M[1] = count -- the 0th moment -- caution: index shift!
-- M[2] = sum   -- the 1st moment
methods.moments = function(self, k)
  local M = {}
  for i = 1, k+1 do M[i] = 0 end
  return self:run(moments_update, M)
end

local function first(S)
  return S[1]
end

local product_update = function(S, y)
  if is_missing(y) then return end
  S[1] = S[1] * y
end
---running product.
methods.prod = function(self)
  return self:run(product_update, {1}):map(first)
end

local sum_update = function(S, y)
  if is_missing(y) then return end
  S[1] = S[1] + y
end
---running sum.
methods.sum = function(self)
  return self:run(sum_update, {0}):map(first)
end

local min_update = function(S, y)
  if is_missing(y) then return end
  if y < S[1] then S[1] = y end
end
---running min.
methods.min = function(self)
  return self:run(min_update, {1/0}):map(first)
end

local max_update = function(S, y)
  if is_missing(y) then return end
  if y > S[1] then S[1] = y end
end

---running max.
methods.max = function(self)
  return self:run(max_update, {-1/0}):map(first)
end

local diff_update = function(S, y)
  S[1], S[2] = y, S[1]
end
local diff_get = function(S)
  if is_missing(S[1]) or is_missing(S[2]) then
    return MISSING_VAL
  else
    return S[1] - S[2]
  end
end
--- running differences.
methods.diff = function(self)
  return self:run(diff_update, {MISSING_VAL, MISSING_VAL}):map(diff_get)
end

local mean_update = function(S, y)
  if is_missing(y) then return end
  S[1] = S[1] + y -- sum
  S[2] = S[2] + 1 -- count
end
local mean_get = function(S)
  return S[1] / S[2]
end
---running mean.
methods.mean = function(self)
  return self:run(mean_update, {0, 0}):map(mean_get)
end

--
-- module definitions
--

-- a special syntax sugar to export all functions to the global table
setmetatable(exports, {
               __call = function(t, override)
                 for k, v in pairs(t) do
                   if _G[k] ~= nil then
                     local msg = 'function ' .. k .. ' already exists in global scope.'
                     if override then
                       _G[k] = v
                       print('WARNING: ' .. msg .. ' Overwritten.')
                     else
                       print('NOTICE: ' .. msg .. ' Skipped.')
                     end
                   else
                     _G[k] = v
                   end
                 end
               end,
})

return exports
