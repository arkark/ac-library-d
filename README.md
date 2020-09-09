# ac-library-d

[![](https://github.com/arkark/ac-library-d/workflows/D/badge.svg)](https://github.com/arkark/ac-library-d/actions)

:construction: WIP :construction:

An ac-library implementation in D language.

Bundled files are [here](https://github.com/arkark/ac-library-d/tree/bundle) :)

- Data Structures
    - [ ] fenwicktree
    - [ ] segtree
    - [ ] lazysegtree
    - [ ] string
- Math
    - [ ] math
    - [ ] convolution
    - [ ] modint
- Graphs
    - [ ] dsu
    - [ ] maxflow
    - [ ] mincostflow
    - [x] scc
    - [x] twosat
- Dependencies
    - [ ] internal bit
    - [ ] internal math
    - [ ] internal queue
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

- https://atcoder.jp/posts/517
