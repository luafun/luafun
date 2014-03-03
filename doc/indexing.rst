Indexing
========

.. module:: fun

This section contains functions to find elements by its values.

.. function:: index(x, gen, param, state)
              iterator:index(x)

   :param x: a value to find
   :returns: the position of the first element that equals to the **x**

   The function returns the position of the first element in the given iterator
   which is equal (using ``==``) to the query element, or ``nil`` if there is
   no such element.

   Examples:

   .. code-block:: lua

    > print(index(2, range(0)))
    nil

    > print(index("b", {"a", "b", "c", "d", "e"}))
    2

.. function:: index_of(x, gen, param, state)
              iterator:index_of(x)

   An alias for :func:`index`.

.. function:: elem_index(x, gen, param, state)
              iterator:elem_index(x)

   An alias for :func:`index`.

.. function:: indexes(x, gen, param, state)
              iterator:indexes(x)

   :param x: a value to find
   :returns: an iterator which positions of elements that equal to the **x**

   The function returns an iterator to positions of elements which equals to 
   the query element.

   Examples:

   .. code-block:: lua

    > each(print, indexes("a", {"a", "b", "c", "d", "e", "a", "b", "a", "a"}))
    1
    6
    9
    10

   .. seealso:: :func:`filter`

.. function:: indices(x, gen, param, state)
              iterator:indices(x)

   An alias for :func:`indexes`.

.. function:: elem_indexes(x, gen, param, state)
              iterator:elem_indexes(x)

   An alias for :func:`indexes`.

.. function:: elem_indices(x, gen, param, state)
              iterator:elem_indices(x)

   An alias for :func:`indexes`.


