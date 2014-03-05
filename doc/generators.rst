Generators
==========

.. module:: fun

This section contains a number of useful generators modeled after Standard ML,
Haskell, Python, Ruby, JavaScript and other languages.

Finite Generators
-----------------

.. function:: range([start,] stop[, step])

   :param start: an endpoint of the interval (see below)
   :type  start: number
   :param stop: an endpoint of the interval (see below)
   :type  stop: number
   :param step: a step
   :type  step: number

   :returns: an iterator

   The iterator to create arithmetic progressions. Iteration values are generated
   within closed interval ``[start, stop]`` (i.e. *stop* is included).
   If the *start* argument is omitted, it defaults to ``1`` (*stop* > 0) or
   to ``-1`` (*stop* < 0). If the *step* argument is omitted, it defaults to
   ``1`` (*start* <= *stop*) or to ``-1`` (*start* > *stop*).  If *step* is
   positive, the last element is the largest ``start + i * step`` less than or
   equal to *stop*; if *step* is negative, the last element is the smallest
   ``start + i * step`` greater than or equal to *stop*.
   *step* must not be zero (or else an error is raised).
   ``range(0)`` returns empty iterator.

   Examples:

   .. code-block:: lua

    > for _it, v in range(5) do print(v) end
    1
    2
    3
    4
    5
    > for _it, v in range(-5) do print(v) end
    -1
    -2
    -3
    -4
    -5
    > for _it, v in range(1, 6) do print(v) end
    1
    2
    3
    4
    5
    6
    > for _it, v in range(0, 20, 5) do print(v) end
    0
    5
    10
    15
    20
    > for _it, v in range(0, 10, 3) do print(v) end
    0
    3
    6
    9
    > for _it, v in range(0, 1.5, 0.2) do print(v) end
    0
    0.2
    0.4
    0.6
    0.8
    1
    1.2
    1.4
    > for _it, v in range(0) do print(v) end
    > for _it, v in range(1) do print(v) end
    1
    > for _it, v in range(1, 0) do print(v) end
    1
    0
    > for _it, v in range(0, 10, 0) do print(v) end
    error: step must not be zero

Infinity Generators
-------------------

.. function:: duplicate(...)

   :param ...: objects to duplicate
   :type  ...: non nil
   :returns: an iterator

   The iterator returns values over and over again indefinitely. All values
   that passed to the iterator are returned as-is during the iteration.

   Examples:

   .. code-block:: lua

    > each(print, take(3, duplicate('a', 'b', 'c')))
    a       b       c
    a       b       c
    > each(print, take(3, duplicate('x')))
    x
    x
    x
    > for _it, a, b, c, d, e in take(3, duplicate(1, 2, 'a', 3, 'b')) do
        print(a, b, c, d, e)
    >> end
    1       2       a       3       b
    1       2       a       3       b
    1       2       a       3       b

.. function:: xrepeat(...)

   An alias for :func:`duplicate`.

.. function:: replicate(...)

   An alias for :func:`duplicate`.

.. function:: tabulate(fun)

   :param fun: an unary generating function
   :type fun: function(n: uint) -> ... 
   :returns: an iterator

   The iterator that returns ``fun(0)``, ``fun(1)``, ``fun(2)``, ``...`` values
   indefinitely.

   Examples:

   .. code-block:: lua

    > each(print, take(5, tabulate(function(x)  return 'a', 'b', 2*x end)))
    a       b       0
    a       b       2
    a       b       4
    a       b       6
    a       b       8
    > each(print, take(5, tabulate(function(x) return x^2 end)))
    0
    1
    4
    9
    16

.. function:: zeros()

   :returns: an iterator

   The iterator returns ``0`` indefinitely.

   Examples:

   .. code-block:: lua

    > each(print, take(5, zeros()))
    0
    0
    0
    0
    0

.. function:: ones()

   :returns: an iterator

   The iterator that returns ``1`` indefinitely.

   Example::

    > each(print, take(5, ones()))
    1
    1
    1
    1
    1

Random sampling
---------------

.. function:: rands([n[, m]])

   :param n: an endpoint of the interval (see below)
   :type  n: uint
   :param m: an endpoint of the interval (see below)
   :type  m: uint
   :returns: an iterator

   The iterator returns random values using :func:`math.random`.
   If the **n** and **m** are set then the iterator returns pseudo-random
   integers in the ``[n, m)`` interval (i.e. **m** is not included).
   If the **m** is not set then the iterator generates pseudo-random integers
   in the ``[0, n)`` interval. When called without arguments returns
   pseudo-random real numbers with uniform distribution in the
   interval ``[0, 1)``.

   .. warning:: This iterator is not pure-functional and may not work as
                expected with some library functions.

   Examples:

   .. code-block:: lua

    > each(print, take(10, rands(10, 20)))
    19
    17
    11
    19
    12
    13
    14
    16
    10
    11

    > each(print, take(5, rands(10)))
    7
    6
    5
    9
    0

    > each(print, take(5, rands()))
    0.79420629243124
    0.69885246563716
    0.5901037417281
    0.7532286166836
    0.080971251199854

