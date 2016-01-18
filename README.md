Lua Functional
==============

<img src="/doc/logo.png" align="right" width="174px" height="144px" />

**Lua Fun** is a high-performance functional programming library for [Lua]
designed with [LuaJIT's trace compiler][LuaJIT] in mind.

Lua Fun provides a set of more than 50 programming primitives typically
found in languages like Standard ML, Haskell, Erlang, JavaScript, Python and
even Lisp. High-order functions such as ``map``, ``filter``, ``reduce``,
``zip``, etc., make it easy to **write simple and efficient functional code**.

Let's see an example:

    > -- Functional style
    > require "fun" ()
    > -- calculate sum(x for x^2 in 1..n)
    > n = 100
    > print(reduce(operator.add, 0, map(function(x) return x^2 end, range(n))))
    328350

    > -- Object-oriented style
    > local fun = require "fun"
    > -- calculate sum(x for x^2 in 1..n)
    > print(fun.range(n):map(function(x) return x^2 end):reduce(operator.add, 0))
    328350

**Lua Fun** takes full advantage of the innovative **tracing JIT compiler**
to achieve transcendental performance on nested functional expressions.
Functional compositions and high-order functions can be translated into
**efficient machine code**. Can you believe it? Just try to run the example
above with ``luajit -jdump`` and see what happens:

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

Status
------

**Lua Fun** is in an early alpha stage. The library fully [documented]
[Documentation] and covered with unit tests.

[![Build Status](https://travis-ci.org/rtsisyk/luafun.png)]
(https://travis-ci.org/rtsisyk/luafun)

LuaJIT 2.1 alpha is recommended. The library designed in mind of fact that
[LuaJIT traces tail-, up- and down-recursion][LuaJIT-Recursion] and has a lot of
[byte code optimizations][LuaJIT-Optimizations]. Lua 5.1-5.3 are also
supported.

This is **master** (development) branch. API may be changed without any special
notice. Please use **stable** branch for your production deployments.
If you still want to use **master**, please don't forget to grep `git log`
for *Incompatible API changes* message. Thanks!

Please check out [documentation][Documentation] for more information.

Misc
----

**Lua Fun** is distributed under the [MIT/X11 License] -
(same as Lua and LuaJIT).

The library was written to use with [Tarantool] - an efficient in-memory
store and an asynchronous Lua application server.

See Also
--------

* [Documentation]
* [RockSpec]
* [RPM/DEB packages](https://packagecloud.io/rtsisyk/master)
* lua-l@lists.lua.org
* luajit@freelists.org
* roman@tsisyk.com

 [Lua]: http://www.lua.org/
 [LuaJIT]: http://luajit.org/luajit.html
 [LuaJIT-Recursion]: http://lambda-the-ultimate.org/node/3851#comment-57679
 [LuaJIT-Optimizations]: http://wiki.luajit.org/Optimizations
 [MIT/X11 License]: http://opensource.org/licenses/MIT
 [Tarantool]: http://github.com/tarantool/tarantool
 [Getting Started]: http://rtsisyk.github.io/luafun/getting_started.html
 [Documentation]: http://rtsisyk.github.io/luafun
 [RockSpec]: https://raw.github.com/rtsisyk/luafun/master/fun-scm-1.rockspec

Please **"Star"** the project on GitHub to help it to survive! Thanks!

*****

**Lua Fun**. Simple, Efficient and Functional. In Lua. With JIT.
