Transformations
===============

.. module:: fun

.. function:: map(fun, gen, param, state)
              iterator:map(fun)

   :param fun: a function to apply
   :type  fun: (function(...) -> ...)
   :returns: a new iterator

   Return a new iterator by applying the **fun** to each element of
   ``gen, param, state`` iterator. The mapping is performed on the fly
   and no values are buffered.

   Examples:

   .. code-block:: lua

    > each(print, map(function(x) return 2 * x end, range(4)))
    0
    2
    4
    6

    fun = function(...) return 'map', ... end
    > each(print, map(fun, range(4)))
    map 0
    map 1
    map 2
    map 3

.. function:: enumerate(gen, param, state)
              iterator:enumerate()

   :returns: a new iterator

   Return a new iterator by enumerating all elements of the
   ``gen, param, state`` iterator. The mapping is performed on the fly
   and no values are buffered.

   Examples:

   .. code-block:: lua

    > each(print, enumerate({"a", "b", "c", "d", "e"}))
    0 a
    1 b
    2 c
    3 d
    4 e

    > each(print, enumerate(zip({"one", "two", "three", "four", "five"},
        {"a", "b", "c", "d", "e"})))
    0 one a
    1 two b
    2 three c
    3 four d
    4 five e

.. function:: intersperse(x, gen, param, state)
              iterator:intersperse(x)

   :type x: any
   :returns: a new iterator

   Return a new iterator where the **x** value is interspersed between the
   elements of the source iterator. The **x** value can also be added as a
   last element of returning iterator if the source iterator contains the odd
   number of elements.

   Examples:

   .. code-block:: lua

    > each(print, intersperse("x", {"a", "b", "c", "d", "e"}))
    a
    x
    b
    x
    c
    x
    d
    x
    e
    x
