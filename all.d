// Implement (union by size) + (path compression)
// Reference:
// Zvi Galil and Giuseppe F. Italiano,
// Data structures and algorithms for disjoint set union problems
struct Dsu {
  import std.algorithm : swap, filter;
  import std.array : array;

private:
  long _n;

  // root node: -1 * component size
  // otherwise: parent
  long[] parentOrSize;

public:
  this(long n) {
    _n = n;
    parentOrSize = new long[n];
    parentOrSize[] = -1;
  }

  long merge(long a, long b)
  in (0 <= a && a < _n)
  in (0 <= b && b < _n) {
    long x = leader(a);
    long y = leader(b);
    if (x == y)
      return x;
    if (-parentOrSize[x] < -parentOrSize[y])
      swap(x, y);
    parentOrSize[x] += parentOrSize[y];
    parentOrSize[y] = x;
    return x;
  }

  bool same(long a, long b)
  in (0 <= a && a < _n)
  in (0 <= b && b < _n) {
    return leader(a) == leader(b);
  }

  long leader(long a)
  in (0 <= a && a < _n) {
    if (parentOrSize[a] < 0) {
      return a;
    } else {
      return parentOrSize[a] = leader(parentOrSize[a]);
    }
  }

  long size(long a)
  in (0 <= a && a < _n) {
    return -parentOrSize[leader(a)];
  }

  long[][] groups() {
    long[] leaderBuf = new long[_n];
    long[] groupSize = new long[_n];
    foreach (i; 0 .. _n) {
      leaderBuf[i] = leader(i);
      groupSize[leaderBuf[i]]++;
    }
    long[][] result = new long[][_n];
    foreach (i; 0 .. _n) {
      result[i].reserve(groupSize[i]);
    }
    foreach (i; 0 .. _n) {
      result[leaderBuf[i]] ~= i;
    }
    return result.filter!"!a.empty".array;
  }

}
static struct InternalArray {

  // Array
  //   - Dynamic array in D is slow.
  //   - ac-library does not contain this.
  struct Array(T) {
    import std.algorithm : min, max;
    import std.conv : to;
    import std.format : format;

  private:
    T[] data = [];
    size_t size = 0;

    // [beginIndex, endIndex)
    size_t beginIndex = 0;
    size_t endIndex = 0;

  public:

    this(T[] data) {
      this(data, data.length, 0, data.length, false);
    }

    bool empty() @property {
      return beginIndex == endIndex;
    }

    size_t length() @property {
      return endIndex - beginIndex;
    }

    void clear() {
      beginIndex = endIndex = 0;
      data = [];
      size = 0;
    }

    ref T front() @property
    in {
      assert(!empty, "Attempting to get the front of an empty Array");
    }
    body {
      return this[0];
    }

    ref T front(T value) @property
    in {
      assert(!empty, "Attempting to assign to the front of an empty Array");
    }
    body {
      return this[0] = value;
    }

    ref T back() @property
    in {
      assert(!empty, "Attempting to get the back of an empty Array");
    }
    body {
      return this[$ - 1];
    }

    ref T back(T value) @property
    in {
      assert(!empty, "Attempting to assign to the back of an empty Array");
    }
    body {
      return this[$ - 1] = value;
    }

    void insertBack(T value) {
      if (size >= data.length) {
        resize();
      }
      data[size++] = value;
      endIndex++;
    }

    void removeFront()
    in {
      assert(!empty, "Attempting to remove the front of an empty Array");
    }
    body {
      beginIndex++;
    }

    alias popFront = removeFront;

    void removeBack()
    in {
      assert(!empty, "Attempting to remove the back of an empty Array");
    }
    body {
      size--;
      endIndex--;
    }

    alias popBack = removeBack;

    typeof(this) save() @property {
      return typeof(this)(data, size, beginIndex, endIndex, true);
    }

    alias dup = save;

    // xs ~= value
    typeof(this) opOpAssign(string op)(T value) if (op == "~") {
      this.insertBack(value);
      return this;
    }

    // xs[index]
    ref T opIndex(size_t index)
    in {
      assert(0 <= index && index < length, "Access violation");
    }
    body {
      size_t _index = beginIndex + index;
      return data[_index];
    }

    // xs[indices[0] .. indices[1]]
    typeof(this) opIndex(size_t[2] indices)
    in {
      assert(0 <= indices[0] && indices[1] <= length, "Access violation");
    }
    body {
      size_t newBeginIndex = beginIndex + indices[0];
      size_t newEndIndex = beginIndex + indices[1];
      size_t size = newEndIndex;
      return typeof(this)(data, size, newBeginIndex, newEndIndex, false);
    }

    // xs[]
    typeof(this) opIndex() {
      return this;
    }

    // xs[index] = value
    ref T opIndexAssign(T value, size_t index)
    in {
      assert(0 <= index && index < length, "Access violation");
    }
    body {
      size_t _index = index - beginIndex;
      return data[_index] = value;
    }

    // xs[indices[0] .. indices[1]] = value
    typeof(this) opIndexAssign(T value, size_t[2] indices)
    in {
      assert(0 <= indices[0] && indices[1] <= length, "Access violation");
    }
    body {
      size_t _beginIndex = beginIndex + indices[0];
      size_t _endIndex = beginIndex + indices[1];
      data[_beginIndex .. _endIndex] = value;
      return this;
    }

    // xs[] = value
    typeof(this) opIndexAssign(T value) {
      data[0 .. size] = value;
      return this;
    }

    // xs[indices[0] .. indices[1]] op= value
    typeof(this) opIndexOpAssign(string op)(T value, size_t[2] indices)
    in {
      assert(0 <= indices[0] && indices[1] <= length, "Access violation");
    }
    body {
      size_t _beginIndex = beginIndex + indices[0];
      size_t _endIndex = beginIndex + indices[1];
      mixin(q{
      data[_beginIndex.._endIndex] %s= value;
    }.format(op));
      return this;
    }

    // xs[] op= value
    typeof(this) opIndexOpAssign(string op)(T value) {
      mixin(q{
      data[0..size] %s= value;
    }.format(op));
      return this;
    }

    // $
    size_t opDollar(size_t dim : 0)() {
      return length;
    }

    // i..j
    size_t[2] opSlice(size_t dim : 0)(size_t i, size_t j)
    in {
      assert(0 <= i && j <= length, "Access violation");
    }
    body {
      return [i, j];
    }

    bool opEquals(S : T)(Array!S that) {
      if (this.length != that.length)
        return false;
      foreach (i; 0 .. this.length) {
        if (this[i] != that[i])
          return false;
      }
      return true;
    }

    bool opEquals(S : T)(S[] that) {
      if (this.length != that.length)
        return false;
      foreach (i; 0 .. this.length) {
        if (this[i] != that[i])
          return false;
      }
      return true;
    }

    string toString() const {
      auto xs = data[beginIndex .. endIndex];
      return "Array(%s)".format(xs);
    }

    void reserve(size_t size) {
      data.length = max(data.length, size);
    }

  private:
    this(T[] data, size_t size, size_t beginIndex, ptrdiff_t endIndex, bool shouldDuplicate) {
      this.size = size;
      this.data = shouldDuplicate ? data.dup : data[0 .. min(endIndex, $)];
      this.beginIndex = beginIndex;
      this.endIndex = endIndex;
    }

    void resize() {
      data.length = max(size * 2, 1);
    }

    invariant {
      assert(size <= data.length);
      assert(beginIndex <= endIndex);
      assert(endIndex == size);
    }
  }

  @safe pure unittest {
    // Array should be Range
    import std.range;

    assert(isInputRange!(Array!long));
    // assert(isOutputRange!(Array!long, int));
    // assert(isOutputRange!(Array!long, long));
    assert(isForwardRange!(Array!long));
    assert(isBidirectionalRange!(Array!long));
    assert(isRandomAccessRange!(Array!long));
  }

  @safe pure unittest {
    // test basic operations

    Array!long xs = [1, 2, 3]; // == Array!long([1, 2, 3])
    assert(xs.length == 3);
    assert(xs.front == 1 && xs.back == 3);
    assert(xs[0] == 1 && xs[1] == 2 && xs[2] == 3);
    assert(xs == [1, 2, 3]);

    size_t i = 0;
    foreach (x; xs) {
      assert(x == ++i);
    }

    xs.front = 4;
    xs[1] = 5;
    xs.back = 6;
    assert(xs == [4, 5, 6]);

    xs.removeBack;
    xs.removeBack;
    assert(xs == [4]);
    xs.insertBack(5);
    xs ~= 6;
    assert(xs == [4, 5, 6]);
    xs.removeFront;
    assert(xs == [5, 6]);

    xs.clear;
    assert(xs.empty);
    xs.insertBack(1);
    assert(!xs.empty);
    assert(xs == [1]);
    xs[0]++;
    assert(xs == [2]);
  }

  @safe pure unittest {
    // test slicing operations

    Array!long xs = [1, 2, 3];
    assert(xs[] == [1, 2, 3]);
    assert((xs[0 .. 2] = 0) == [0, 0, 3]);
    assert((xs[0 .. 2] += 1) == [1, 1, 3]);
    assert((xs[] -= 2) == [-1, -1, 1]);

    Array!long ys = xs[0 .. 2];
    assert(ys == [-1, -1]);
    ys[0] = 5;
    assert(ys == [5, -1]);
    assert(xs == [5, -1, 1]);
  }

  @safe pure unittest {
    // test using phobos
    import std.algorithm, std.array;

    Array!long xs = [10, 5, 8, 3];
    assert(sort!"a<b"(xs).equal([3, 5, 8, 10]));
    assert(xs == [3, 5, 8, 10]);
    Array!long ys = sort!"a>b"(xs).array;
    assert(ys == [10, 8, 5, 3]);
  }

  @safe pure unittest {
    // test different types of equality

    int[] xs = [1, 2, 3];
    Array!int ys = [1, 2, 3];
    Array!long zs = [1, 2, 3];
    assert(xs == ys);
    assert(xs == zs);
    assert(ys == zs);

    ys.removeBack;
    assert(ys != zs);
    ys.insertBack(3);
    assert(ys == zs);
  }
}

import std.traits : isIntegral;

struct MfGraph(Cap) if (isIntegral!Cap) {
  import std.algorithm : min;
  import std.typecons : Tuple, tuple;

private:
  long _n;
  Tuple!(long, long)[] pos;
  _Edge[][] g;

public:
  this(long n) {
    _n = n;
    g = new _Edge[][n];
  }

  long addEdge(long fromV, long toV, Cap cap)
  in (0 <= fromV && fromV < _n)
  in (0 <= toV && toV < _n)
  in (0 <= cap) {
    long m = pos.length;
    pos ~= tuple(fromV, cast(long) g[fromV].length);
    g[fromV] ~= _Edge(toV, g[toV].length, cap);
    g[toV] ~= _Edge(fromV, g[fromV].length - 1, 0);
    return m;
  }

  struct Edge {
    long fromV, toV;
    Cap cap, flow;
  }

  Edge getEdge(long i) {
    long m = pos.length;
    assert(0 <= i && i < m);
    auto _e = g[pos[i][0]][pos[i][1]];
    auto _re = g[_e.toV][_e.rev];
    return Edge(pos[i][0], _e.toV, _e.cap + _re.cap, _re.cap);
  }

  Edge[] edges() {
    long m = pos.length;
    Edge[] result;
    foreach (i; 0 .. m) {
      result ~= getEdge(i);
    }
    return result;
  }

  void changeEdge(long i, Cap newCap, Cap newFlow) {
    long m = pos.length;
    assert(0 <= i && i < m);
    assert(0 <= newFlow && newFlow <= newCap);
    auto _e = &g[pos[i][0]][pos[i][1]];
    auto _re = &g[_e.toV][_e.rev];
    _e.cap = newCap - newFlow;
    _re.cap = newFlow;
  }

  Cap flow(long s, long t) {
    return flow(s, t, Cap.max);
  }

  Cap flow(long s, long t, Cap flowLimit)
  in (0 <= s && s < _n)
  in (0 <= t && t < _n) {
    long[] level = new long[_n];
    long[] iter = new long[_n];
    InternalArray.Array!long que;

    void bfs() {
      level[] = -1;
      level[s] = 0;
      que.clear();
      que.insertBack(s);
      while (!que.empty) {
        long v = que.front;
        que.removeFront;
        foreach (e; g[v]) {
          if (e.cap == 0 || level[e.toV] >= 0)
            continue;
          level[e.toV] = level[v] + 1;
          if (e.toV == t)
            return;
          que.insertBack(e.toV);
        }
      }
    }

    Cap dfs(long v, Cap up) {
      if (v == s)
        return up;
      Cap res = 0;
      long levelV = level[v];
      for (; iter[v] < g[v].length; iter[v]++) {
        long i = iter[v];
        auto e = g[v][i];
        if (levelV <= level[e.toV] || g[e.toV][e.rev].cap == 0)
          continue;
        Cap d = dfs(e.toV, min(up - res, g[e.toV][e.rev].cap));
        if (d <= 0)
          continue;
        g[v][i].cap += d;
        g[e.toV][e.rev].cap -= d;
        res += d;
        if (res == up)
          break;
      }
      return res;
    }

    Cap flow = 0;
    while (flow < flowLimit) {
      bfs();
      if (level[t] == -1)
        break;
      iter[] = 0;
      while (flow < flowLimit) {
        Cap f = dfs(t, flowLimit - flow);
        if (f == 0)
          break;
        flow += f;
      }
    }
    return flow;
  }

  bool[] minCut(long s) {
    bool[] visited = new bool[_n];
    InternalArray.Array!long que;
    que.insertBack(s);
    while (!que.empty) {
      long p = que.front;
      que.removeFront;
      visited[p] = true;
      foreach (e; g[p]) {
        if (e.cap && !visited[e.toV]) {
          visited[e.toV] = true;
          que.insertBack(e.toV);
        }
      }
    }
    return visited;
  }

private:
  struct _Edge {
    long toV;
    long rev;
    Cap cap;
    this(long toV, long rev, Cap cap) {
      this.toV = toV;
      this.rev = rev;
      this.cap = cap;
    }
  }
}

unittest {
  MfGraph!long g;
  // TODO
}
import std.traits : isIntegral;

struct McfGraph(Cap, Cost) if (isIntegral!Cap && isIntegral!Cost) {
  import std.range : popBack, back;
  import std.algorithm : min;
  import std.typecons : Tuple, tuple;
  import std.container : BinaryHeap;

private:
  long _n;

  Tuple!(long, long)[] pos;
  _Edge[][] g;

public:
  this(long n) {
    _n = n;
    g = new _Edge[][n];
  }

  long addEdge(long fromV, long toV, Cap cap, Cost cost)
  in (0 <= fromV && fromV < _n)
  in (0 <= toV && toV < _n) {
    long m = pos.length;
    pos ~= tuple(fromV, cast(long) g[fromV].length);
    g[fromV] ~= _Edge(toV, g[toV].length, cap, cost);
    g[toV] ~= _Edge(fromV, g[fromV].length - 1, 0, -cost);
    return m;
  }

  struct Edge {
    long fromV, toV;
    Cap cap, flow;
    Cost cost;
  }

  Edge getEdge(long i) {
    long m = pos.length;
    assert(0 <= i && i < m);
    auto _e = g[pos[i][0]][pos[i][1]];
    auto _re = g[_e.toV][_e.rev];
    return Edge(
        pos[i][0], _e.toV, _e.cap + _re.cap, _re.cap, _e.cost,
    );
  }

  Edge[] edges() {
    long m = pos.length;
    Edge[] result = new Edge[m];
    foreach (i; 0 .. m) {
      result[i] = getEdge(i);
    }
    return result;
  }

  Tuple!(Cap, Cost) flow(long s, long t) {
    return flow(s, t, Cap.max);
  }

  Tuple!(Cap, Cost) flow(long s, long t, Cap flowLimit) {
    return slope(s, t, flowLimit).back;
  }

  Tuple!(Cap, Cost)[] slope(long s, long t) {
    return slope(s, t, Cap.max);
  }

  Tuple!(Cap, Cost)[] slope(long s, long t, Cap flowLimit)
  in (0 <= s && s < _n)
  in (0 <= t && t < _n)
  in (s != t) {
    // variants (C = maxcost):
    // -(n-1)C <= dual[s] <= dual[i] <= dual[t] = 0
    // reduced cost (= e.cost + dual[e.fromV] - dual[e.toV]) >= 0 for all edge

    Cost[] dual = new Cost[_n];
    Cost[] dist = new Cost[_n];
    dual[] = 0;
    long[] pv = new long[_n];
    long[] pe = new long[_n];
    bool[] vis = new bool[_n];

    bool dualRef() {
      dist[] = Cost.max;
      pv[] = -1;
      pe[] = -1;
      vis[] = false;

      struct Q {
        Cost key;
        long toV;
      }

      BinaryHeap!(InternalArray.Array!Q, "a.key > b.key") que;
      dist[s] = 0;
      que.insert(Q(0, s));
      while (!que.empty) {
        long v = que.front.toV;
        que.removeFront;
        if (vis[v])
          continue;
        vis[v] = true;
        if (v == t)
          break;
        // dist[v] = shortest(s, v) + dual[s] - dual[v]
        // dist[v] >= 0 (all reduced cost are positive)
        // dist[v] <= (n-1)C
        foreach (i; 0 .. g[v].length) {
          auto e = g[v][i];
          if (vis[e.toV] || e.cap == 0)
            continue;
          // |-dual[e.to] + dual[v]| <= (n-1)C
          // cost <= C - -(n-1)C + 0 = nC
          Cost cost = e.cost - dual[e.toV] + dual[v];
          if (dist[e.toV] - dist[v] > cost) {
            dist[e.toV] = dist[v] + cost;
            pv[e.toV] = v;
            pe[e.toV] = i;
            que.insert(Q(dist[e.toV], e.toV));
          }
        }
      }

      if (!vis[t]) {
        return false;
      }

      foreach (v; 0 .. _n) {
        if (!vis[v])
          continue;
        // dual[v] = dual[v] - dist[t] + dist[v]
        //         = dual[v] - (shortest(s, t) + dual[s] - dual[t]) + (shortest(s, v) + dual[s] - dual[v])
        //         = - shortest(s, t) + dual[t] + shortest(s, v)
        //         = shortest(s, v) - shortest(s, t) >= 0 - (n-1)C
        dual[v] -= dist[t] - dist[v];
      }
      return true;
    }

    Cap flow = 0;
    Cost cost = 0, prevCost = -1;
    Tuple!(Cap, Cost)[] result;
    result ~= tuple(flow, cost);
    while (flow < flowLimit) {
      if (!dualRef())
        break;
      Cap c = flowLimit - flow;
      for (long v = t; v != s; v = pv[v]) {
        c = min(c, g[pv[v]][pe[v]].cap);
      }
      for (long v = t; v != s; v = pv[v]) {
        auto e = &g[pv[v]][pe[v]];
        e.cap -= c;
        g[v][e.rev].cap += c;
      }
      Cost d = -dual[s];
      flow += c;
      cost += c * d;
      if (prevCost == d) {
        result.popBack();
      }
      result ~= tuple(flow, cost);
      prevCost = cost;
    }
    return result;
  }

private:
  struct _Edge {
    long toV;
    long rev;
    Cap cap;
    Cost cost;
  }
}

unittest {
  McfGraph!(long, long) g;
  // TODO
}
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
      InternalArray.Array!long visited;
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
            low[v] = min(low[v], ord[toV]);
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

    InternalArray.Array!long[] scc() {
      auto ids = sccIds();
      long groupNum = ids[0];
      long[] counts = new long[groupNum];
      foreach (x; ids[1]) {
        counts[x]++;
      }
      auto groups = new InternalArray.Array!long[groupNum];
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
        elist = new E[edges.length];
        foreach (e; edges) {
          start[e[0] + 1]++;
        }
        foreach (i; 1 .. n + 1) {
          start[i] += start[i - 1];
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
// Reference:
// B. Aspvall, M. Plass, and R. Tarjan,
// A Linear-Time Algorithm for Testing the Truth of Certain Quantified Boolean Formulas
struct TwoSat {

private:
  long _n;
  bool[] _answer;
  InternalScc.SccGraph scc;

public:
  this(long n) {
    _n = n;
    _answer = new bool[n];
    scc = InternalScc.SccGraph(2 * n);
  }

  // amortized O(1)
  void addClause(long i, bool f, long j, bool g)
  in (0 <= i && i < _n)
  in (0 <= j && j < _n)
  body {
    scc.addEdge(2 * i + (f ? 0 : 1), 2 * j + (g ? 1 : 0));
    scc.addEdge(2 * j + (g ? 0 : 1), 2 * i + (f ? 1 : 0));
  }

  // O(n + m)
  bool satisfiable() {
    auto id = scc.sccIds()[1];
    foreach (i; 0 .. _n) {
      if (id[2 * i] == id[2 * i + 1])
        return false;
      _answer[i] = id[2 * i] < id[2 * i + 1];
    }
    return true;
  }

  // O(n)
  bool[] answer() {
    return _answer;
  }
}
