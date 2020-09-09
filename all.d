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
