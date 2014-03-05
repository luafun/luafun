Compositions
============

.. module:: fun

.. function:: zip(...)
              iterator1:zip(iterator2, iterator3, ...)

   :param ...: iterators to "zip"
   :type  ...: iterator

   :returns: an iterator

   Return a new iterator where i-th return value contains the i-th element
   from each of the iterators. The returned iterator is truncated in length
   to the length of the shortest iterator. For multi-return iterators only the
   first variable is used.

   Examples:

   .. code-block:: lua

    > dump(zip({"a", "b", "c", "d"}, {"one", "two", "three"}))
    a one
    b two
    c three

    > each(print, zip())

    > each(print, zip(range(5), {'a', 'b', 'c'}, rands()))
    1       a       0.57514179487402
    2       b       0.79693061238668
    3       c       0.45174307459403

    > each(print, zip(partition(function(x) return x > 7 end, range(1, 15, 1))))
    8       1
    9       2
    10      3
    11      4
    12      5
    13      6
    14      7

.. function:: cycle(gen, param, state)
              iterator:cycle()

   :returns: a cycled version of ``{gen, param, state}`` iterator

   Make a new iterator that returns elements from ``{gen, param, state}``
   iterator until the end and then "restart" iteration using a saved clone of
   ``{gen, param, state}``. The returned iterator is constant space and no
   return values are buffered. Instead of that the function make a clone of the
   source ``{gen, param, state}`` iterator. Therefore, the source iterator
   must be pure functional to make an indentical clone. Infinity iterators
   are supported, but are not recommended.

   .. note:: ``{gen, param, state}`` must be pure functional to work properly
            with the function.

   Examples:

   .. code-block:: lua

    > each(print, take(15, cycle(range(5))))
    1
    2
    3
    4
    5
    1
    2
    3
    4
    5
    1
    2
    3
    4
    5

    > each(print, take(15, cycle(zip(range(5), {"a", "b", "c", "d", "e"}))))
    1       a
    2       b
    3       c
    4       d
    5       e
    1       a
    2       b
    3       c
    4       d
    5       e
    1       a
    2       b
    3       c
    4       d
    5       e

.. function:: chain(...)
              iterator1:chain(iterator2, iterator3, ...)

   :param ...: iterators to chain
   :type  ...: iterator
   :returns: a consecutive iterator from sources (left from right)

   Make an iterator that returns elements from the first iterator until it is
   exhausted, then proceeds to the next iterator, until all of the iterators
   are exhausted. Used for treating consecutive iterators as a single iterator.
   Infinity iterators are supported, but are not recommended.

   Examples:

   .. code-block:: lua

    > each(print, chain(range(2), {"a", "b", "c"}, {"one", "two", "three"}))
    1
    2
    a
    b
    c
    one
    two
    three

    > each(print, take(15, cycle(chain(enumerate({"a", "b", "c"}),
        {"one", "two", "three"}))))
    1       a
    2       b
    3       c
    one
    two
    three
    1       a
    2       b
    3       c
    one
    two
    three
    1       a
    2       b
    3       c
