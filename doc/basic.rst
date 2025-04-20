Basic Functions
===============

.. currentmodule:: fun

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

.. function:: from(gen, param, state)

   :returns: ``gen, param, state`` -- :ref:`iterator triplet <iterator_triplet>`

   Wraps an existing :ref:`iterator triplet <iterator_triplet>` into a form
   which is compatible with library functions. It is designed to directly adapt
   existing iterator triplets (e.g., from ``ipairs`` or ``string.gmatch``).
   
   Unlike :func:`iter`, this wrapper preserves all values returned by the
   generating function. For historical reasons, when using :func:`iter` with a
   generator triplet, the first element returned by the generating function,
   usually the state, is inaccessible. :func:`from` avoids this behavior, making
   it suitable for iterators whose first returned values are needed.

   Examples:

   .. code-block:: lua

    > for _it, i, v in from(ipairs({"a", "b", "c"})) do print(i, v) end
    1 a
    2 b
    3 c

    > for _it, a, b in from(string.gmatch('a1b2c3', '(%a)(%d)')) do print(a, b) end
    a 1
    b 2
    c 3

   Contrast with :func:`iter`'s behavior:

   .. code-block:: lua

    > -- ``i``` is inaccessible
    > for _it, v in iter(ipairs({"a", "b", "c"})) do print(v) end
    a
    b
    c

    > -- ``a``` is inaccessible
    > for _it, b in iter(string.gmatch('a1b2c3', '(%a)(%d)')) do print(b) end
    1
    2
    3

.. function:: ipairs_of(array)

   :returns: ``gen, param, state`` -- :ref:`iterator triplet <iterator_triplet>`

   Returns an iterator triplet equivalent to ``from(ipairs(array))``. This
   function is aware of the ``__ipairs`` metamethod.

   Example:

   .. code-block:: lua

    > for _it, i, v in ipairs_of({"a", "b", "c"}) do print(i, v) end
    1 a
    2 b
    3 c

.. function:: pairs_of(map)

   :returns: ``gen, param, state`` -- :ref:`iterator triplet <iterator_triplet>`

   Returns an iterator triplet equivalent to ``from(pairs(map))``. This function 
   is aware of the ``__pairs`` metamethod.

   Example:

   .. code-block:: lua

    > for _it, k, v in pairs_of({ a = 1, b = 2, c = 3 }) do print(k, v) end
    b 2
    a 1
    c 3

.. function:: items(tab)

   :returns: ``gen, param, state`` -- :ref:`iterator triplet <iterator_triplet>`

   Returns an iterator triplet that iterates over array elements of a table
   using ``ipairs``. This function is aware of the ``__ipairs`` metamethod.

   Example:

   .. code-block:: lua

    > for _it, a in items({ 1, 2, 3, a = 4, b = 5, c = 6 }) do print(a) end
    1
    2
    3

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
