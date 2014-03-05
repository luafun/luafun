Reducing
========

.. module:: fun

The section contains functions to analyze iteration values and recombine
through use of a given combining operation the results of recursively processing
its constituent parts, building up a return value

.. contents::

.. note:: An attempt to use infinity iterators with the most function from
          the module causes an infinite loop.

Folds
-----

.. function:: foldl(accfun, initval, gen, param, state)
              iterator:reduce(accfun, initval)

   :param accfun: an accumulating function
   :type  param: (function(prevval, ...) -> val)
   :param initval: an initial value that passed to **accfun** on the first
          iteration

   The function reduces the iterator from left to right using the binary
   operator **accfun** and the initial value **initval**.
   Equivalent to::

        local val = initval
        for _k, ... in gen, param, state do
            val = accfun(val, ...)
        end
        return val

   Examples:

   .. code-block:: lua

    > print(foldl(function(acc, x) return acc + x end, 0, range(5)))
    15

    > print(foldl(operator.add, 0, range(5)))
    15

    > print(foldl(function(acc, x, y) return acc + x * y; end, 0,
        zip(range(1, 5), {4, 3, 2, 1})))
    20

.. function:: reduce(accfun, initval, gen, param, state)
              iterator:reduce(accfun, initval)

   An alias to :func:`foldl`.

.. function:: length(gen, param, state)
              iterator:length()

   :returns: a number of elements in ``gen, param, state`` iterator.

   Return a number of elements in ``gen, param, state`` iterator.
   This function is equivalent to ``#obj`` for basic array and string iterators.

   Examples:

   .. code-block:: lua

    > print(length({"a", "b", "c", "d", "e"}))
    5

    > print(length({}))
    0

    > print(length(range(0)))
    0

   .. warning:: An attempt to call this function on an infinite iterator will
                result an infinite loop.

   .. note:: This function has ``O(n)`` complexity for all iterators except
             basic array and string iterators.

.. function:: totable(gen, param, state)

   :returns: a new table (array) from iterated values.

   The function reduces the iterator from left to right using ``table.insert``.

   Examples:

   .. code-block:: lua

    > local tab = totable("abcdef")
    > print(type(tab), #tab)
    table 6
    > each(print, tab)
    a
    b
    c
    d
    e
    f

.. function:: tomap(gen, param, state)

   :returns: a new table (map) from iterated values.

   The function reduces the iterator from left to right using
   ``tab[val1] = val2`` expression.

   Examples:

   .. code-block:: lua

    > local tab = tomap(zip(range(1, 7), 'abcdef'))
    > print(type(tab), #tab)
    table   6
    > each(print, iter(tab))
    a
    b
    c
    d
    e
    f

Predicates
----------

.. function:: is_prefix_of(iterator1, iterator2)
              iterator1:is_prefix_of(iterator2)

   The function takes two iterators and returns ``true`` if the first iterator
   is a prefix of the second. 

   Examples:

   .. code-block:: lua

    > print(is_prefix_of({"a"}, {"a", "b", "c"}))
    true

    > print(is_prefix_of(range(6), range(5)))
    false

.. function:: is_null(gen, param, state)
              iterator:is_null()

   :returns: true when `gen, param, state`` iterator is empty or finished.
   :returns: false otherwise.

   Example::

    > print(is_null({"a", "b", "c", "d", "e"}))
    false

    > print(is_null({}))
    true

    > print(is_null(range(0)))
    true

.. function:: all(predicate, gen, param, state)
              iterator:all(predicate)

   :param predicate: a predicate

   Returns true if all return values of iterator satisfy the **predicate**.

   Examples:

   .. code-block:: lua

    > print(all(function(x) return x end, {true, true, true, true}))
    true

    > print(all(function(x) return x end, {true, true, true, false}))
    false

.. function:: every(predicate, gen, param, state)

   An alias for :func:`every`.

.. function:: any(predicate, gen, param, state)
              iterator:any(predicate)

   :param predicate: a predicate

   Returns ``true`` if at least one return values of iterator satisfy the
   **predicate**. The iteration stops on the first such value. Therefore,
   infinity iterators that have at least one satisfying value might work.

   Examples:

   .. code-block:: lua

    > print(any(function(x) return x end, {false, false, false, false}))
    false

    > print(any(function(x) return x end, {false, false, false, true}))
    true

.. function:: some(predicate, gen, param, state)

   An alias for :func:`any`.

Special folds
-------------

.. function:: sum(gen, param, state)
              iterator:sum()

   Sum up all iteration values. An optimized alias for::

       foldl(operator.add, 0, gen, param, state)

   For an empty iterator ``0`` is returned.

   Examples:

   .. code-block:: lua

    > print(sum(range(5)))
    15

.. function:: product(gen, param, state)
              iterator:product()

   Multiply all iteration values. An optimized alias for::

       foldl(operator.mul, 1, gen, param, state)

   For an empty iterator ``1`` is returned.

   Examples:

   .. code-block:: lua

    > print(product(range(1, 5)))
    120

.. function:: min(gen, param, state)
              iterator:min()

   Return a maximum value from the iterator using :func:`operator.min` or ``<``
   for numbers and other types respectivly. The iterator must be
   non-null, otherwise an error is raised.

   Examples:

   .. code-block:: lua

    > print(min(range(1, 10, 1)))
    1

    > print(min({"f", "d", "c", "d", "e"}))
    c

    > print(min({}))
    error: min: iterator is empty

.. function:: minimum(gen, param, state)

   An alias for :func:`min`.

.. function:: min_by(cmp, gen, param, state)
              iterator:min_by(cmp)

   Return a minimum value from the iterator using the **cmp** as a ``<``
   operator. The iterator must be non-null, otherwise an error is raised.

   Examples:

   .. code-block:: lua

    > function min_cmp(a, b) if -a < -b then return a else return b end end
    > print(min_by(min_cmp, range(1, 10, 1)))
    9

.. function:: minimum_by(cmp, gen, param, state)

   An alias for :func:`min_by`.

.. function:: max(gen, param, state)
              iterator:max()

   Return a maximum value from the iterator using :func:`operator.max` or ``>``
   for numbers and other types respectivly.

   The iterator must be non-null, otherwise an error is raised.

   Examples:

   .. code-block:: lua

    > print(max(range(1, 10, 1)))
    9

    > print(max({"f", "d", "c", "d", "e"}))
    f

    > print(max({}))
    error: max: iterator is empty

.. function:: maximum(gen, param, state)

   An alias for :func:`max`.

.. function:: max_by(cmp, gen, param, state)
              iterator:max_by(cmp)

   Return a maximum value from the iterator using the **cmp** as a `>`
   operator. The iterator must be non-null, otherwise an error is raised.

   Examples:

   .. code-block:: lua

    > function max_cmp(a, b) if -a > -b then return a else return b end end
    > print(max_by(max_cmp, range(1, 10, 1)))
    1

.. function:: maximum_by(cmp, gen, param, state)

   An alias for :func:`max_by`.
