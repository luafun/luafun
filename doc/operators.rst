Operators
=========

.. module:: fun.operator

This auxiliary module exports a set of Lua operators as intrinsic functions
to use with the library high-order primitives.

.. contents::

Comparison operators
--------------------

.. seealso:: `Lua Relational Operators
              <http://www.lua.org/manual/5.2/manual.html#3.4.3>`_

.. function:: le(a, b)

   :returns: **a** <= **b**

.. function:: lt(a, b)

   :returns: **a** < **b**

.. function:: eq(a, b)

   :returns: **a** == **b**

.. function:: ne(a, b)

   :returns: **a** ~= **b**

.. function:: ge(a, b)

   :returns: **a** >= **b**

.. function:: gt(a, b)

   :returns: **a** > **b**

Arithmetic operators
--------------------

.. seealso:: `Lua Arithmetic Operators 
              <http://www.lua.org/manual/5.2/manual.html#3.4.1>`_ and
             `Lua Mathematical Functions
              <http://www.lua.org/manual/5.2/manual.html#6.6>`_

.. function:: abs(a)

   :returns: math.abs(**a**)

.. function:: add(a, b)

   :returns: **a** + **b**

.. function:: div(a, b)

    An alias for :func:`truediv`.

.. function:: truediv(a, b)

   :returns: **a** / **b**

   Performs "true" float division.
   Examples:

   .. code-block:: lua

    > print(operator.div(10, 3))
    3.3333333333333
    > print(operator.div(-10, 3))
    -3.3333333333333

.. function:: floordiv(a, b)

   :returns: math.floor(**a** / **b**)

   Performs division where a result is rounded down. Examples:

   .. code-block:: lua

    > print(operator.floordiv(10, 3))
    3
    > print(operator.floordiv(12, 3))
    4
    > print(operator.floordiv(-10, 3))
    -4
    > print(operator.floordiv(-12, 3))
    -4

.. function:: intdiv(a, b)

   Performs C-like integer division.

   Equvalent to:

   .. code-block:: lua

    function(a, b)
        local q = a / b
        if a >= 0 then return math.floor(q) else return math.ceil(q) end
    end

   Examples:

   .. code-block:: lua

    > print(operator.floordiv(10, 3))
    3
    > print(operator.floordiv(12, 3))
    4
    > print(operator.floordiv(-10, 3))
    -3
    > print(operator.floordiv(-12, 3))
    -4

.. function:: mod(a, b)

   :returns: math.mod(**a**, **b**)

.. function:: neq(a)

   :returns: -**a**

.. function:: unm(a)

   Unary minus. An alias for :func:`neq`.

.. function:: pow(a, b)

   :returns: math.pow(**a**, **b**)

.. function:: sub(a, b)

   :returns: **a** - **b**

.. function:: min(a, b)

   :returns: math.min(**a**, **b**)

.. function:: max(a, b)

   :returns: math.max(**a**, **b**)

String operators
----------------

.. seealso:: `Lua Concatenation Operator
              <http://www.lua.org/manual/5.2/manual.html#3.4.5>`_ ,
             `Lua Length Operator
              <http://www.lua.org/manual/5.2/manual.html#3.4.6>`_

.. function:: concat(a, b)

   :returns: **a** .. **b**

.. function:: len(a)

   :returns: # **a**

.. function:: length(a)

   An alias for :func:`len`.

Logical operators
-----------------

.. seealso:: `Lua Logical Operators
              <http://www.lua.org/manual/5.2/manual.html#3.4.4>`_

.. function:: land(a, b)

   :returns: **a** and **b**

.. function:: lor(a, b)

   :returns: **a** or **b**

.. function:: lnot(a)

   :returns: not **a**

.. function:: truth(a)

   :returns: not not **a**

   Return ``true`` if **a** is true, and ``false`` otherwise. Examples:

   .. code-block:: lua

    > print(operator.truth(1))
    true
    > print(operator.truth(0))
    true -- It is Lua, baby!
    > print(operator.truth(nil))
    false
    > print(operator.truth(""))
    true
    > print(operator.truth({}))
    true

Bitwise operators
-----------------

.. seealso:: `LuaJIT bit module <http://bitop.luajit.org/api.html>`_.

.. function:: band(a, b)

   :returns: bit.band(**a**, **b**)

.. function:: rol(a, n)

   :returns: bit.brol(**a**, **n**)

   Performs the bitwise left rotation.

.. function:: ror(a, n)

   :returns: bit.bror(**a**, **n**)

   Performs the bitwise right rotation.

.. function:: arshift(a, n)

   :returns: bit.arshift(**a**, **n**)

    Performs arithmetic right-shift of **a** by the **n** bit. Examples:

   .. code-block:: lua

    operator.arshift(256, 8) == 1
    operator.arshift(-256, 8) == -1
    operator.arshift(0x87654321, 12) == 0xfff87654

.. function:: lshift(a, n)

   :returns: bit.lshift(**a**, **n**)

    Performs logical left-shift of **a** by the **n** bit.

.. function:: rshift(a, n)

   :returns: bit.rshift(**a**, **n**)

    Performs logical right-shift of **a** by the **n** bit.

.. function:: bswap(a)

   :returns: bit.bswap(**a**)

   Return a byte order swapped integer. Examples:

   .. code-block:: lua

    bit.bswap(0x12345678) == 0x78563412
    bit.bswap(0x78563412) == 0x12345678

.. function:: bor(a, b)

   :returns: bit.bor(**a**, **b**)

.. function:: bnot(a)

   :returns: bit.bnot(**a**)

.. function:: bxor(a, b)

   :returns: bit.bxor(**a**, **b**)
