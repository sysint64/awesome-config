Welcome to the Lain wiki!

Dependency
------------

Package | Requested by | Reason of choice
--- | --- | ---
[curl](https://curl.haxx.se) | widgets accessing network resources | faster and simpler to use than [LuaSocket](https://github.com/diegonehab/luasocket); also, it's in the core of almost every distro

Installation
------------

### Arch Linux

[AUR package](https://aur.archlinux.org/packages/lain-git/)

### Other distributions

```shell
git clone https://github.com/copycat-killer/lain.git ~/.config/awesome/lain
```

Also available via [LuaRocks](https://luarocks.org/modules/aajjbb/lain).

Usage
--------

First, include it into your `rc.lua`:

```lua
local lain = require("lain")
```

Then check out the submodules you want:

- [Layouts](https://github.com/copycat-killer/lain/wiki/Layouts)
- [Widgets](https://github.com/copycat-killer/lain/wiki/Widgets)
- [Utilities](https://github.com/copycat-killer/lain/wiki/Utilities)