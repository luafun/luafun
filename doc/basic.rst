Basic Functions
===============

.. module:: fun

The section contains functions to create iterators from Lua objects.

.. function:: iter(array)
              iter(map)
              iter(string)
              iter(gen, param, state)

   :returns: ``gen, param, state`` -- :ref:`iterator triplet <iterator_triplet>`

   Make ``gen, param, state`` iterator from the iterable object.
   The function is a generalized version of :func:`pairs` and :func:`ipairs`.

   The function distinguish between arrays and maps using ``#arg == 0``
   check to detect maps. For arrays ``ipairs`` is used. For maps a modified
   version of ``pairs`` is used that also returns keys. Userdata objects
   are handled in the same way as tables.

   If ``LUAJIT_ENABLE_LUA52COMPAT`` [#luajit_lua52compat]_ mode is enabled and
   argument has metamethods ``__pairs`` (for maps) or ``__ipairs`` for (arrays),
   call it with the table or userdata as argument and return the first three
   results from the call [#lua52_ipairs]_.

   All library iterator are suitable to use with Lua's ``for .. in`` loop.

   .. code-block:: lua

    > for _it, a in iter({1, 2, 3}) do print(a) end
    1
    2
    3

    > for _it, k, v in iter({ a = 1, b = 2, c = 3}) do print(k, v) end
    b 2
    a 1
    c 3

    > for _it, a in iter("abcde") do print(a) end
    a
    b
    c
    d
    e

   The first cycle variable *_it* is needed to store an internal state of
   the iterator. The value must be always ignored in loops:

   .. code-block:: lua

    for _it, a, b in iter({ a = 1, b = 2, c = 3}) do print(a, b) end
    -- _it is some internal iterator state - always ignore it
    -- a, b are values return from the iterator

   Simple iterators like ``iter({1, 2, 3})`` have simple states, whereas
   other iterators like :func:`zip` or :func:`chain` have complicated
   internal states which values senseless for the end user.

   Check out :doc:`under_the_hood` section for more details.

   There is also the possibility to supply custom iterators to the
   function:

   .. code-block:: lua

    > local function mypairs_gen(max, state)
        if (state >= max) then
                return nil
        end
        return state + 1, state + 1
    end

    > local function mypairs(max)
        return mypairs_gen, max, 0
    end

    > for _it, a in iter(mypairs(10)) do print(a) end
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

   Iterators can return multiple values.

   Check out :doc:`under_the_hood` section for more details.

   .. [#luajit_lua52compat] http://luajit.org/extensions.html
   .. [#lua52_ipairs] http://www.lua.org/manual/5.2/manual.html#pdf-ipairs

.. function:: each(fun, gen, param, state)
              iterator:each(fun)

   :returns: none

   Execute the *fun* for each iteration value. The function is equivalent to
   the code below:

   .. code-block:: lua

    for _it, ... in iter(gen, param, state) do
        fun(...)
    end

   Examples:

   .. code-block:: lua

    > each(print, { a = 1, b = 2, c = 3})
    b 2
    a 1
    c 3

    > each(print, {1, 2, 3})
    1
    2
    3

   The function is used for its side effects. Implementation directly applies
   *fun* to all iteration values without returning a new iterator, in contrast
   to functions like :func:`map`.

   .. seealso:: :func:`map`, :func:`reduce`

.. function:: for_each(fun, gen, param, state)
              iterator:for_each(fun)

    An alias for :func:`each`.

.. function:: foreach(fun, gen, param, state)
              iterator:foreach(fun)

    An alias for :func:`each`.
