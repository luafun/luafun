Compositions
============

.. module:: fun

.. function:: zip(...)

   :param ...: iterators to "zip"
   :type  ...: ``{gen, param, state}`` - iterator triplet in table

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

    > each(print, zip({range(5)}, {'a', 'b', 'c'}, {rands()}))
    0       a       0.57514179487402
    1       b       0.79693061238668
    2       c       0.45174307459403

    > each(print, zip(partition(function(x) return x > 7 end, range(1, 15, 1))))
    8 1
    9 2
    10 3
    11 4
    12 5
    13 6
    14 7

   .. note:: An each interator in the parameters list must be surrounded by
             a curly brackets. This is a limitation of Lua programming language.
             The plain tables and strings should be passed without braces. 

.. function:: cycle(gen, param, state)

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
    0
    1
    2
    3
    4
    0
    1
    2
    3
    4
    0
    1
    2
    3
    4

    > each(print, take(15, cycle(zip({range(5)}, {"a", "b", "c", "d", "e"}))))
    0 a
    1 b
    2 c
    3 d
    4 e
    0 a
    1 b
    2 c
    3 d
    4 e
    0 a
    1 b
    2 c
    3 d
    4 e

.. function:: chain(...)

   :param ...: iterators to chain
   :type  ...: ``{gen, param, state}`` - an iterator triplet surrounded by
               braces
   :returns: a consecutive iterator from sources (left from right)

   Make an iterator that returns elements from the first iterator until it is
   exhausted, then proceeds to the next iterator, until all of the iterators
   are exhausted. Used for treating consecutive iterators as a single iterator.
   Infinity iterators are supported, but are not recommended.

   Examples:

   .. code-block:: lua

    each(print, chain({range(2)}, {"a", "b", "c"}, {"one", "two", "three"}))
    0
    1
    a
    b
    c
    one
    two
    three

    each(print, take(15, cycle(chain({enumerate({"a", "b", "c"})},
        {"one", "two", "three"}))))
    0 a
    1 b
    2 c
    one
    two
    three
    0 a
    1 b
    2 c
    one
    two
    three
    0 a
    1 b
    2 c

   .. note:: An each interator in the parameters list must be surrounded by
             a curly brackets. This is a limitation of Lua programming language.
             The plain tables and strings should be passed without braces. 

