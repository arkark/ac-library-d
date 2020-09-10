module acl.fenwicktree;

// Reference: https://en.wikipedia.org/wiki/Fenwick_tree
template FenwickTree(T) {
  import std.traits : isSigned, Unsigned;

  static if (isSigned!T) {
    alias U = Unsigned!T;
  } else {
    alias U = T;
  }

  struct FenwickTree {

  private:
    long _n;
    U[] data;

  public:
    this(long n) {
      _n = n;
      data = new U[n];
    }

    void add(long p, T x)
    in (0 <= p && p < _n) {
      p++;
      while (p <= _n) {
        data[p - 1] += U(x);
        p += p & -p;
      }
    }

    T sum(long l, long r)
    in (0 <= l && l <= r && r <= _n) {
      return sum(r) - sum(l);
    }

  private:
    U sum(long r) {
      U s = 0;
      while (r > 0) {
        s += data[r - 1];
        r -= r & -r;
      }
      return s;
    }
  }
}

unittest {
  // https://atcoder.jp/contests/practice2/tasks/practice2_b
  // Sample 1

  long n = 5;
  auto tree = FenwickTree!long(5);
  foreach (i, a; [1, 2, 3, 4, 5]) {
    tree.add(i, a);
  }
  assert(tree.sum(0, 5) == 15);
  assert(tree.sum(2, 4) == 7);
  tree.add(3, 10);
  assert(tree.sum(0, 5) == 25);
  assert(tree.sum(0, 3) == 6);
}
