module acl.mincostflow;

import acl.internal.array;

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
