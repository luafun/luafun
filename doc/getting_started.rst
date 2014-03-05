Getting Started
===============

Please jump to `Using the Library`_ section if you are familiar with Lua and
LuaJIT.

.. contents::

Prerequisites
-------------

The library is designed for LuaJIT_. **LuaJIT 2.1 alpha** is high^W **Highly**
recommended for performance reasons. Lua 5.1--5.3 are also supported.

The library is platform-independent and expected to work on all platforms that
supported by Lua(JIT). It can be also used in any Lua(JIT) based applications,
e.g. Tarantool_ or OpenResty_.

You might need diff_ tool to run test system and sphinx_ to regenerate the
documentation from source files.

.. _LuaJIT: http://luajit.org/
.. _Tarantool: http://tarantool.org/
.. _OpenResty: http://openresty.org/
.. _diff: http://en.wikipedia.org/wiki/Diff
.. _sphinx: http://sphinx-doc.org/

Installing LuaJIT
-----------------

You can build LuaJIT from sources or install it from a binary archive.

From Sources
````````````

1. Clone LuaJIT git repository. Please note that **v2.1** branch is needed.
You can always select this branch using ``git checkout v2.1``.

.. code-block:: bash

    $ git clone http://luajit.org/git/luajit-2.0.git -b v2.1 luajit-2.1
    Cloning into 'luajit-2.1'...

2. Compile LuaJIT

.. code-block:: bash

    $ cd luajit-2.1/
    luajit-2.1 $ make -j8

3. Install LuaJIT

.. code-block:: bash

    luajit-2.1 $ make install
    luajit-2.1 $ ln -s /usr/local/bin/luajit-2.1.0-alpha /usr/local/bin/luajit

Install operation might require root permissions. However, you can install
LuaJIT into your home directory.

From a Binary Archive
`````````````````````

If operations above look too complicated for you, you always can download a
binary archive from http://luajit.org/download.html page.
Your favorite package manager may also have LuaJIT packages.

Running LuaJIT
``````````````

Ensure that freshly installed LuaJIT works:

.. code-block:: bash

    $ luajit
    LuaJIT 2.1.0-alpha -- Copyright (C) 2005-2013 Mike Pall. http://luajit.org/
    JIT: ON SSE2 SSE3 SSE4.1 fold cse dce fwd dse narrow loop abc sink fuse
    > = 2 + 2
    4

It is good idea to use LuaJIT CLI under ``rlwrap`` (on nix platforms):

.. code-block:: bash

    alias luajit="rlwrap luajit"
    $ luajit
    LuaJIT 2.1.0-alpha -- Copyright (C) 2005-2013 Mike Pall. http://luajit.org/
    JIT: ON SSE2 SSE3 SSE4.1 fold cse dce fwd dse narrow loop abc sink fuse
    > = 2 + 2
    4
    > = 2 + 2 <!-- You can use arrows, completion and so on, like in Bash

Installing the Library
----------------------

Using LuaRocks
``````````````

Use the rockspec_ file.

.. _rockspec: https://raw.github.com/rtsisyk/luafun/master/fun-scm-1.rockspec

Using git
`````````
1. Clone Lua Fun repository:

.. code-block:: bash

    git clone git://github.com/rtsisyk/luafun.git
    $ cd luafun

2. Run tests (optional):

.. code-block:: bash

    luafun $ cd tests
    luafun/tests $ ./runtest *.lua
    Testing basic.lua
    Testing compositions.lua
    Testing filters.lua
    Testing folds.lua
    Testing generators.lua
    Testing slices.lua
    Testing transformations.lua
    All tests have passed!

Using wget
``````````

Just download https://raw.github.com/rtsisyk/luafun/master/fun.lua file:

.. code-block:: bash

    $ wget https://raw.github.com/rtsisyk/luafun/master/fun.lua

Using the Library
-----------------

Try to run LuaJIT in the same directory where ``fun.lua`` file is located:

.. code-block:: bash
   :emphasize-lines: 4

    luafun $ luajit
    LuaJIT 2.1.0-alpha -- Copyright (C) 2005-2013 Mike Pall. http://luajit.org/
    JIT: ON SSE2 SSE3 fold cse dce fwd dse narrow loop abc sink fuse
    > fun = require 'fun'
    >
    > for _k, a in fun.range(3) do print(a) end
    1
    2
    3

If you see an error message like ``stdin:1: module 'fun' not found:`` then
you need to configure you Package Path (``package.path``). Please consult
`Lua Wiki <http://lua-users.org/wiki/PackagePath>`_ for additional information.


**Lua Fun** designed to be small ubiquitous library. It is a good idea to import
all library functions to the global table:

.. code-block:: bash
   :emphasize-lines: 1

    > for k, v in pairs(require "fun") do _G[k] = v end -- import fun.*
    > for _k, a in range(3) do print(a) end
    0
    1
    2

**Lua Fun** also provides a special **shortcut** to autoimport all functions:

.. code-block:: bash
   :emphasize-lines: 1

    > require 'fun'() -- to import all lua.* functions to globals
    > each(print, range(5))
    1
    2
    3
    4
    5

Now you can use **Lua Fun**:

.. code-block:: bash

    > print(sum(filter(function(x) return x % 16 == 0 end, range(10000))))
    3130000

    > each(print, take(5, tabulate(math.sin)))
    0
    2
    4
    6
    8

    > each(print, enumerate(zip({"one", "two", "three", "four", "five"},
        {"a", "b", "c", "d", "e"})))
    1       one     a
    2       two     b
    3       three   c
    4       four    d
    5       five    e

    > lines_to_grep = {
        [[Emily]],
        [[Chloe]],
        [[Megan]],
        [[Jessica]],
        [[Emma]],
        [[Sarah]],
        [[Elizabeth]],
        [[Sophie]],
        [[Olivia]],
        [[Lauren]]
    }

    > each(print, grep("Em", lines_to_grep))
    Emily
    Emma

    > each(print, take(10, cycle(chain(
        {enumerate({"a", "b", "c"})},
        {"one", "two", "three"}))
      ))
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

Please note that functions support multireturn.

Further Actions
---------------

- Take a look on :doc:`reference`.
- Use :ref:`genindex` to find functions by its names.
- Checkout **examples** from
  `tests/ <https://github.com/rtsisyk/luafun/tree/master/tests>`_ directory
- Read :doc:`under_the_hood` section
- "Star" us the on GitHub_ to help the project to survive
- Make Great Software
- Have fun

**Lua Fun**. Simple, Efficient and Functional. In Lua. With JIT.

.. _GitHub: http://github.com/rtsisyk/luafun
