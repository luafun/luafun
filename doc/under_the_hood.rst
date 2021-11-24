Under the Hood
==============

.. module:: fun

The section shed some light on the internal library structure and working
principles.

Iterators
---------

A basic primitive of the library after functions is an iterator. Most functions
takes an iterator and returns a new iteraror(s). Iterators all the way down!
[#iterators]_.

The simplest iterator is (surprise!) :func:`pairs` and :func:`ipairs`
Lua functions. Have you ever tried to call, say, :func:`ipairs` function
without using it inside a ``for`` loop? Try to do that on any Lua
implementation:

.. _iterator_triplet:
.. code-block:: bash

    > =ipairs({'a', 'b', 'c'})
    function: builtin#6     table: 0x40f80e38       0

The function returned three strange values which look useless without a ``for``
loop. We call these values **iterator triplet**.
Let's see how each value is used for:

``gen`` -- first value
   A generating function that can produce a next value on each iteration.
   Usually returns a new ``state`` and iteration values (multireturn).

``param`` -- second value
   A permanent (constant) parameter of a generating function is used to create
   specific instance of the generating function. For example, a table itself
   for ``ipairs`` case.

``state`` -- third value
   A some transient state of an iterator that is changed after each iteration.
   For example, an array index for ``ipairs`` case.

Try to call ``gen`` function manually:

   .. code-block:: lua

    > gen, param, state = ipairs({'a', 'b', 'c'})
    > =gen(param, state)
    1       a

The ``gen`` function returned a new state ``1`` and the next iteration
value ``a``. The second call to ``gen`` with the new state will return the next
state  and the next iteration value. When the iterator finishes to the end
the ``nil`` value is returned instead of the next state.

**Please do not panic!** You do not have to use these values directly.
It is just a nice trick to get ``for .. in`` loop working in Lua.

Iterations
----------

What happens when you type the following code into a Lua console::

    for _it, x in ipairs({'a', 'b', 'c'}) do print(x) end

According to Lua reference manual [#lua_for]_ the code above is equivalent to::

    do
        -- Initialize the iterator
        local gen, param, state = ipairs({'a', 'b', 'c'})
        while true do
            -- Next iteration
            local state, var_1, ···, var_n = gen(param, state)
            if state == nil then break end
            -- Assign values to our variables
            _it = state
            x = var_1
            -- Execute the code block
            print(x)
        end
    end

What does it mean for us?

* An iterator can be used together with ``for .. in`` to generate a loop
* An iterator is fully defined using ``gen``, ``param`` and ``state`` iterator
  triplet
* The ``nil`` state marks the end of an iteration
* An iterator can return an arbitrary number of values (multireturn)
* It is possible to make some wrapping functions to take an iterator and

  return a new modified iterator

**The library provides a set of iterators** that can be used like ``pairs``
and ``ipairs``.

Iterator Types
--------------

Pure functional iterators
`````````````````````````

Iterators can be either pure functional or have some side effects and returns
different values for some initial conditions [#pure_function]_. An **iterator is
pure functional** if it meets the following criteria:

- ``gen`` function always returns the same values for the same ``param`` and
  ``state`` values (idempotence property)
- ``param`` and ``state`` values are not modified during ``gen`` call and
  a new ``state`` object is returned instead (referential transparency
  property).

Pure functional iterators are very important for us. Pure functional iterator
can be safety cloned or reapplied without creating side effects. Many library
function use these properties.

Finite iterators
````````````````

Iterators can be **finite** (sooner or later end up) or **infinite**
(never end).
Since there is no way to determine automatically if an iterator is finite or
not [#turing]_ the library function can not automatically resolve infinite
loops. It is your obligation to do not pass infinite iterator to reducing
functions.

Tracing JIT
-----------

Tracing just-in-time compilation is a technique used by virtual machines to
optimize the execution of a program at runtime. This is done by recording a
linear sequence of frequently executed operations, compiling them to native
machine code and executing them.

First profiling information for loops is collected. After a hot loop has been
identified, a special tracing mode is entered which records all executed
operations of that loop. This sequence of operations is called a **trace**.
The trace is then optimized and compiled to machine code (trace). When this
loop is executed again the compiled trace is called instead of the program
counterpart [#tracing_jit]_.

Why the tracing JIT is important for us? The LuaJIT tracing compiler can detect
tail-, up- and down-recursion [#luajit-recursion]_, unroll compositions of
functions and inline high-order functions [#luajit-optimizations]_.
All of these concepts make the foundation for functional programming.

.. [#iterators] https://en.wikipedia.org/wiki/Turtles_all_the_way_down
.. [#lua_for] https://www.lua.org/manual/5.2/manual.html#3.3.5
.. [#pure_function] https://en.wikipedia.org/wiki/Pure_function
.. [#turing] `Proved by Turing <https://en.wikipedia.org/wiki/Halting_problem>`_
.. [#tracing_jit] https://en.wikipedia.org/wiki/Tracing_just-in-time_compilation
.. [#luajit-recursion] http://lambda-the-ultimate.org/node/3851#comment-57679
.. [#luajit-optimizations] http://wiki.luajit.org/Optimizations
