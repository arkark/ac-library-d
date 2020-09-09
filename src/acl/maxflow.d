module acl.maxflow;

import acl.internal.array;

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
