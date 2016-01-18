Operators
=========

.. module:: fun.operator

This auxiliary module exports a set of Lua operators as intrinsic functions
to use with the library high-order primitives.

.. contents::

.. note:: **op** can be used as a shortcut to **operator**.

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
              <http://www.lua.org/manual/5.2/manual.html#3.4.1>`_

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

   :returns: **a** % **b**

   .. note:: Result has same sign as **divisor**. Modulo in Lua is defined as
             ``a % b == a - math.floor(a/b)*b``.

   Examples:

   .. code-block:: lua
    :emphasize-lines: 5-6

    > print(operator.mod(10, 2))
    0
    > print(operator.mod(10, 3))
    2
    print(operator.mod(-10, 3))
    2 -- == -1 in C, Java, JavaScript and but not in Lua, Python, Haskell!

.. function:: neq(a)

   :returns: -**a**

.. function:: unm(a)

   Unary minus. An alias for :func:`neq`.

.. function:: pow(a, b)

   :returns: math.pow(**a**, **b**)

.. function:: sub(a, b)

   :returns: **a** - **b**

String operators
----------------

.. seealso:: `Lua Concatenation Operator
              <http://www.lua.org/manual/5.2/manual.html#3.4.5>`_

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

