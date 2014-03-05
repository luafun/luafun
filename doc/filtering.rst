Filtering
=========

.. module:: fun

This section contains functions to filter values during iteration.

.. function:: filter(predicate, gen, param, state)
              iterator:filter(predicate)

   :param param: an predicate to filter the iterator
   :type  param: (function(...) -> bool)

   Return a new iterator of those elements that satisfy the **predicate**.

   Examples:

   .. code-block:: lua

    > each(print, filter(function(x) return x % 3 == 0 end, range(10)))
    3
    6
    9

    > each(print, take(5, filter(function(i, x) return i % 3 == 0 end,
        enumerate(duplicate('x')))))
    3       x
    6       x
    9       x
    12      x
    15      x

   .. note:: Multireturn iterators are supported but can cause performance 
             regressions.

   .. seealso:: :func:`take_while` and :func:`drop_while`.

.. function:: remove_if(predicate, gen, param, state)
              iterator:remove_if(predicate)

   An alias for :func:`filter`.

.. function:: grep(regexp_or_predicate, gen, param, state)
              iterator:grep(regexp_or_predicate)

   If **regexp_or_predicate** is string then the parameter is used as a regular
   expression to build filtering predicate. Otherwise the function is just an
   alias for :func:`filter`.

   Equivalent to:

   .. code-block:: lua

    local fun = regexp_or_predicate
    if type(regexp_or_predicate) == "string" then
        fun = function(x) return string.find(x, regexp_or_predicate) ~= nil end
    end
    return filter(fun, gen, param, state)

   Examples:

   .. code-block:: lua

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

    each(print, grep("^Em", lines_to_grep))
    --[[test
    Emily
    Emma
    --test]]

    each(print, grep("^P", lines_to_grep))
    --[[test
    --test]]

    > each(print, grep(function(x) return x % 3 == 0 end, range(10)))
    3
    6
    9

.. function:: partition(predicate, gen, param, state)
              iterator:partition(predicate)

   :param x: a value to find
   :returns: {gen1, param1, state1}, {gen2, param2, state2}

   The function returns two iterators where elements do and do not satisfy the
   prediucate. Equivalent to:

   .. code-block:: lua

       return filter(predicate, gen', param', state'),
       filter(function(...) return not predicate(...) end, gen, param, state);

   The function make a clone of the source iterator. Iterators especially
   returned in tables to work with :func:`zip` and other functions.

   Examples:

   .. code-block:: lua

    > each(print, zip(partition(function(i, x) return i % 3 == 0 end, range(10))))
    3       1
    6       2
    9       4

   .. note:: ``gen, param, state`` must be pure functional to work properly
             with the function.

   .. seealso:: :func:`span`
