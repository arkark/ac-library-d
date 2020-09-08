module acl.scc;

import acl.internal.scc;
import acl.internal.array;

// Strongly Connected Components
struct SccGraph {

private:
  InternalScc.SccGraph internal;

public:
  this(long n) {
    internal = InternalScc.SccGraph(n);
  }

  void addEdge(long fromV, long toV) {
    long n = internal.numVertices;
    assert(0 <= fromV && fromV < n);
    assert(0 <= toV && toV < n);
    internal.addEdge(fromV, toV);
  }

  InternalArray.Array!long[] scc() {
    return internal.scc();
  }
}

unittest {
  import std.algorithm : sort;
  import std.array : array;

  // https://atcoder.jp/contests/practice2/tasks/practice2_g
  // Sample 1
  long n = 6;
  long m = 7;
  long[2][] edges = [
    [1, 4],
    [5, 2],
    [3, 0],
    [5, 5],
    [4, 1],
    [0, 3],
    [4, 2],
  ];

  long[][] expected = [
    [1, 5],
    [2, 4, 1],
    [1, 2],
    [2, 3, 0],
  ];

  auto graph = SccGraph(n);
  foreach (e; edges) {
    graph.addEdge(e[0], e[1]);
  }
  auto actual = graph.scc();

  assert(actual.length == expected.length);
  foreach (i; 0 .. actual.length) {
    assert(actual[i].length == expected[i][0]);
    assert(actual[i].dup.sort!"a<b".array == expected[i][1 .. $].dup.sort!"a<b".array);
  }
}
