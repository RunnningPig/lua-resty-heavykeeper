## Name

lua-resty-heavykeeper - LuaJIT FFI-based [heavykeeper](https://www.usenix.org/conference/atc18/presentation/gong) library for OpenResty

## Table of Contents

* [Name](#name)
* [Methods](#methods)
  * [new](#new)
  * [add](#add)
  * [query](#query)
  * [list](#list)
* [Installation](#installation)
* [Author](#author)
* [Licence](#licence)

## Description

This library implements the [heavykeeper](https://www.usenix.org/conference/atc18/presentation/gong) algorithm, which queries Top-K by spending very little memory space. This algorithm is used by [redis](https://github.com/RedisBloom/RedisBloom).

## Methods

### new

`syntax: topk, err = topk.new(k, opts?)`

Creates a topk object. In case of failures, returns `nil` and a string describing the error.

The `k` argument specifies the number of top occurring items to keep.

The options table accepts the following options:

* `width`
  Number of counters kept in each array. (Default 8)
* `depth`
  Number of arrays. (Default 7)
* `decay`
  The probability of reducing a counter in an occupied bucket. It is raised to power of it's counter (decay ^ bucket[i].counter). Therefore, as the counter gets higher, the chance of a reduction is being reduced. (Default 0.9)

[Back to TOC](#table-of-contents)

### add

`syntax: topk:add(item)`

Adds an item to the data structure.

[Back to TOC](#table-of-contents)

### query

`syntax: topking = topk:query(item)`

Checks whether an item is one of Top-K items.

[Back to TOC](#table-of-contents)

### list

`syntax: items = topk:list(res?)`

Return full list of items in Top K list. An optional `res` argument can be used to reuse the table returned by this method.

[Back to TOC](#table-of-contents)

## Installation

Using [just](https://just.systems/man/en/pre-built-binaries.html)

```shell
# Installation path
export LUA_LIB_DIR=/usr/local/openresty/site/lualib

# Compile and Install
just install
```

[Back to TOC](#table-of-contents)

## Author

Liangliang Lin <im.linliangliang@gmail.com>

## License

This project is primarily distributed under the terms of the Apache License (Version 2.0).

See [LICENSE-APACHE](LICENSE) for details.