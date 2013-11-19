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
   :emphasize-lines: 1, 3

    > require "fun"()
    > n = 100
    > reduce(operator.add, 0, map(function(x) return x^2 end, range(n)))
    > -- calculate sum(x for x^2 in 1..n)
    328350

**Lua Fun** takes full advantage of the innovative **tracing JIT compiler**
to achieve transcendental performance on nested functional expressions.
Functional compositions and high-order functions can be translated into
**efficient machine code**. Can you believe it? Just try to run the example above
with ``luajit -jdump`` and see what happens:

.. code-block:: none
   :emphasize-lines: 2,11

    -- skip some initilization code --
    ->LOOP:
    0bcaffd0  movaps xmm5, xmm7
    0bcaffd3  movaps xmm7, xmm1
    0bcaffd6  addsd xmm7, xmm5
    0bcaffda  ucomisd xmm7, xmm0
    0bcaffde  jnb 0x0bca0024        ->5
    0bcaffe4  movaps xmm5, xmm7
    0bcaffe7  mulsd xmm5, xmm5
    0bcaffeb  addsd xmm6, xmm5
    0bcaffef  jmp 0x0bcaffd0        ->LOOP
    ---- TRACE 1 stop -> loop

The functional chain above was translated by LuaJIT to (!) **one machine loop**
containing just 10 CPU assembly instructions without CALL. Unbelievable!

Readable? Efficient? Can your Python/Ruby/V8 do better?
