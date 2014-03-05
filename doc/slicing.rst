Slicing
=======

.. module:: fun

This section contains functions to make subsequences from iterators.

Basic
-----

.. function:: nth(n, gen, param, state)
              iterator:nth(n)

   :param uint n: a sequential number (indexed starting from ``1``,
                  like Lua tables)
   :returns: **n**-th element of ``gen, param, state`` iterator

   This function returns the **n**-th element of ``gen, param, state``
   iterator. If the iterator does not have **n** items then ``nil`` is returned.

   Examples:

   .. code-block:: lua

    > print(nth(2, range(5)))
    2

    > print(nth(10, range(5)))
    nil

    > print(nth(2, {"a", "b", "c", "d", "e"}))
    b

    > print(nth(2, enumerate({"a", "b", "c", "d", "e"})))
    2 b

   This function is optimized for basic array and string iterators and has
   ``O(1)`` complexity for these cases.

.. function:: head(gen, param, state)
              iterator:head()

   :returns: a first element of ``gen, param, state`` iterator

   Extract the first element of ``gen, param, state`` iterator.
   If the iterator is empty then an error is raised.

   Examples:

   .. code-block:: lua

    > print(head({"a", "b", "c", "d", "e"}))
    a
    > print(head({}))
    error: head: iterator is empty
    > print(head(range(0)))
    error: head: iterator is empty
    > print(head(enumerate({"a", "b"})))
    1 a

.. function:: car(gen, param, state)

   An alias for :func:`head`.

.. function:: tail(gen, param, state)
              iterator:tail()

   :returns: ``gen, param, state`` iterator without a first element

   Return a copy of ``gen, param, state`` iterator without its first element.
   If the iterator is empty then an empty iterator is returned.

   Examples:

   .. code-block:: lua

    > each(print, tail({"a", "b", "c", "d", "e"}))
    b
    c
    d
    e
    > each(print, tail({}))
    > each(print, tail(range(0)))
    > each(print, tail(enumerate({"a", "b", "c"})))
    2 b
    3 c

.. function:: cdr(gen, param, state)

   An alias for :func:`tail`.

Subsequences
------------

.. function:: take_n(n, gen, param, state)
              iterator:take_n(n)

   :param n: a number of elements to take
   :type  n: uint
   :returns: an iterator on the subsequence of first **n** elements

   Examples:

   .. code-block:: lua

    > each(print, take_n(5, range(10)))
    1
    2
    3
    4
    5

    > each(print, take_n(5, enumerate(duplicate('x'))))
    1 x
    2 x
    3 x
    4 x
    5 x

.. function:: take_while(predicate, gen, param, state)
              iterator:take_while(predicate)

   :type predicate: function(...) -> bool
   :returns: an iterator on the longest prefix of ``gen, param, state``
             elements that satisfy **predicate**.

   Examples:

   .. code-block:: lua

    > each(print, take_while(function(x) return x < 5 end, range(10)))
    1
    2
    3
    4

    > each(print, take_while(function(i, a) return i ~=a end,
        enumerate({5, 3, 4, 4, 2})))
    1       5
    2       3
    3       4

   .. seealso:: :func:`filter`

.. function:: take(n_or_predicate, gen, param, state)
              iterator:take(n_or_predicate)

   An alias for :func:`take_n` and :func:`take_while` that autodetects
   required function based on **n_or_predicate** type.

.. function:: drop_n(n, gen, param, state)
              iterator:drop_n(n)

   :param n: the number of elements to drop
   :type  n: uint
   :returns: ``gen, param, state`` iterator after skipping first **n**
             elements

   Examples:

   .. code-block:: lua

    > each(print, drop_n(2, range(5)))
    3
    4
    5

    > each(print, drop_n(2, enumerate({'a', 'b', 'c', 'd', 'e'})))
    3       c
    4       d
    5       e

.. function:: drop_while(predicate, gen, param, state)
              iterator:drop_while(predicate)

   :type predicate: function(...) -> bool
   :returns: ``gen, param, state`` after skipping the longest prefix
             of  elements that satisfy **predicate**.

   Examples:

   .. code-block:: lua

    > each(print, drop_while(function(x) return x < 5 end, range(10)))
    5
    6
    7
    8
    9
    10

   .. seealso:: :func:`filter`

.. function:: drop(n_or_predicate, gen, param, state)
              iterator:drop(n_or_predicate)

   An alias for :func:`drop_n` and :func:`drop_while` that autodetects
   required function based on **n_or_predicate** type.


.. function:: span(n_or_predicate, gen, param, state)
              iterator:span(n_or_predicate)

   :type n_or_predicate: function(...) -> bool or uint
   :returns: iterator, iterator

   Return an iterator pair where the first operates on the longest prefix
   (possibly empty) of ``gen, param, state`` iterator of elements that
   satisfy **predicate** and second operates the remainder of
   ``gen, param, state`` iterator. 
   Equivalent to:

   .. code-block:: lua

       return take(n_or_predicate, gen, param, state),
              drop(n_or_predicate, gen, param, state);

   Examples:

   .. code-block:: lua

    > each(print, zip(span(function(x) return x < 5 end, range(10))))
    1       5
    2       6
    3       7
    4       8

    > each(print, zip(span(5, range(10))))
    1       6
    2       7
    3       8
    4       9
    5       10

   .. note:: ``gen, param, state`` must be pure functional to work properly
             with the function.

   .. seealso:: :func:`partition`

.. function:: split(n_or_predicate, gen, param, state)

    An alias for :func:`span`.

.. function:: split_at(n, gen, param, state)

    An alias for :func:`span`.
