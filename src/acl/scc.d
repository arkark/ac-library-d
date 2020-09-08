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
