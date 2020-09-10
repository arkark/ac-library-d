# ac-library-d

[![](https://github.com/arkark/ac-library-d/workflows/D/badge.svg)](https://github.com/arkark/ac-library-d/actions)
[![License: CC0-1.0](https://img.shields.io/badge/License-CC0%201.0-lightgrey.svg)](http://creativecommons.org/publicdomain/zero/1.0/)
[![](https://tokei.rs/b1/github/arkark/ac-library-d)](https://github.com/arkark/ac-library-d)

:construction: WIP :construction:

An [ac-library](https://github.com/atcoder/ac-library) implementation in D language.

Bundled files are [here](https://github.com/arkark/ac-library-d/tree/bundle) :)

- Data Structures
    - [x] fenwicktree
    - [ ] segtree
    - [ ] lazysegtree
    - [ ] string
- Math
    - [ ] math
    - [ ] convolution
    - [ ] modint
- Graphs
    - [x] dsu
    - [x] maxflow
    - [x] mincostflow
    - [x] scc
    - [x] twosat
- Dependencies
    - [ ] internal bit
    - [ ] internal math
    - ~~[ ] internal queue~~ (unnecessary)
    - [x] internal scc
    - [ ] internal type traits
    - [x] internal array (not in ac-library)

## Commands

Bundle all files:
```fish
$ ./bundle src/acl/all.d > output.d
```

Bundle files dependent on `{name}.d`:
```fish
$ ./bundle src/acl/{name}.d > output.d
```

Browse docs for ac-library:
```fish
$ make browse-docs
```

Format source code:
```fish
$ make format
```

## Links

- Official repository: https://github.com/atcoder/ac-library
