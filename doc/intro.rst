Introduction
============

.. module:: fun

**Lua Fun** is a high-performance functional programming library
designed for `LuaJIT tracing just-in-time compiler
<http://luajit.org/luajit.html>`_.

The library provides a set of more than 50 programming primitives typically
found in languages like Standard ML, Haskell, Erlang, JavaScript, Python and
even Lisp. High-order functions such as :func:`map`, :func:`filter`,
:func:`reduce`, :func:`zip` will help you to **write simple and efficient
functional code**.

Let's see an example:

.. code-block:: lua
   :emphasize-lines: 2, 4

    -- Functional style
    require "fun" ()
    n = 100
    x = sum(map(function(x) return x^2 end, take(n, tabulate(math.sin))))
    -- calculate sum(sin(x)^2 for x in 0..n-1)
    print(x)
    50.011981355266

.. code-block:: lua
   :emphasize-lines: 2, 4

    -- Object-oriented style
    local fun = require "fun"
    n = 100
    x = fun.tabulate(math.sin):take(n):map(function(x) return x^2 end):sum()
    -- calculate sum(sin(x)^2 for x in 0..n-1)
    print(x)
    50.011981355266

**Lua Fun** takes full advantage of the innovative **tracing JIT compiler**
to achieve transcendental performance on nested functional expressions.
Functional compositions and high-order functions can be translated into
**efficient machine code**. Can you believe it? Just try to run the example above
with ``luajit -jdump`` and see what happens:

.. code-block:: none
   :emphasize-lines: 2,14

    -- skip some initilization code --
    ->LOOP:
    0bcaffd0  movsd [rsp+0x8], xmm7
    0bcaffd6  addsd xmm4, xmm5
    0bcaffda  ucomisd xmm6, xmm1
    0bcaffde  jnb 0x0bca0028        ->6
    0bcaffe4  addsd xmm6, xmm0
    0bcaffe8  addsd xmm7, xmm0
    0bcaffec  fld qword [rsp+0x8]
    0bcafff0  fsin
    0bcafff2  fstp qword [rsp]
    0bcafff5  movsd xmm5, [rsp]
    0bcafffa  mulsd xmm5, xmm5
    0bcafffe  jmp 0x0bcaffd0        ->LOOP
    ---- TRACE 1 stop -> loop


The functional chain above was translated by LuaJIT to (!) **one machine loop**
containing just 10 CPU assembly instructions without CALL. Unbelievable!

Readable? Efficient? Can your Python/Ruby/V8 do better?
