module acl.twosat;

import acl.internal.scc;

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
