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
