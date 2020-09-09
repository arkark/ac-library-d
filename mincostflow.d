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
