module acl.internal.scc;

static struct InternalScc {

  // Strongly Connected Components
  // Reference:
  //   R. Tarjan,
  //   Depth-First Search and Linear Graph Algorithms
  struct SccGraph {
    import std.range : back, popBack;
    import std.algorithm : min;
    import std.typecons : Tuple, tuple;

  private:
    long _n;
    Tuple!(long, Edge)[] edges;

  public:
    this(long n) {
      _n = n;
    }

    long numVertices() {
      return _n;
    }

    void addEdge(long fromV, long toV)
    in (0 <= fromV && fromV < _n)
    in (0 <= toV && toV < _n)
    body {
      edges ~= tuple(fromV, Edge(toV));
    }

    // @return pair of (# of scc, scc id)
    Tuple!(long, long[]) sccIds() {
      auto g = Csr!Edge(_n, edges);
      long nowOrd = 0;
      long groupNum = 0;
      long[] visited;
      visited.reserve(_n);
      long[] low = new long[_n];
      long[] ord = new long[_n];
      ord[] = -1;
      long[] ids = new long[_n];

      void dfs(long v) {
        low[v] = ord[v] = nowOrd++;
        visited ~= v;
        foreach (i; g.start[v] .. g.start[v + 1]) {
          auto toV = g.elist[i].toV;
          if (ord[toV] == -1) {
            dfs(toV);
            low[v] = min(low[v], low[toV]);
          } else {
            low[v] = min(low[v], ord[v]);
          }
        }
        if (low[v] == ord[v]) {
          while (true) {
            long u = visited.back;
            visited.popBack;
            ord[u] = _n;
            ids[u] = groupNum;
            if (u == v)
              break;
          }
          groupNum++;
        }
      }

      foreach (i; 0 .. _n) {
        if (ord[i] == -1) {
          dfs(i);
        }
      }
      foreach (ref x; ids) {
        x = groupNum - 1 - x;
      }
      return tuple(groupNum, ids);
    }

    long[][] scc() {
      auto ids = sccIds();
      long groupNum = ids[0];
      long[] counts = new long[groupNum];
      foreach (x; ids[1]) {
        counts[x]++;
      }
      long[][] groups = new long[][groupNum];
      foreach (i; 0 .. groupNum) {
        groups[i].reserve(counts[i]);
      }
      foreach (i; 0 .. _n) {
        groups[ids[1][i]] ~= i;
      }
      return groups;
    }

  private:
    // Compressed Sparse Row
    struct Csr(E) {
      long[] start;
      E[] elist;

      this(long n, Tuple!(long, E)[] edges) {
        start = new long[n + 1];
        elist = new E[n];
        foreach (e; edges) {
          start[e[0] + 1]++;
        }
        foreach (i; 1 .. n + 1) {
          start[i] += start[i + 1];
        }
        auto counter = start.dup;
        foreach (e; edges) {
          elist[counter[e[0]]++] = e[1];
        }
      }
    }

    struct Edge {
      long toV;
    }
  }

}
