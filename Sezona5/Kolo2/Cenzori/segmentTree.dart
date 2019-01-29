import 'dart:math';

class SegmentTree {
  List<int> _input;
  List<int> _segmentTree;
  List<int> _lazyAdditions;
  List<int> _lazySets;
  dynamic mergeFunction;

  SegmentTree(this._input, int mergeFunction(int a, int b)) {
    this.mergeFunction = mergeFunction;
    _segmentTree =
        List.generate(nextPowerOf2(_input.length) * 2 - 1, (i) => null);
    _lazySets = List.generate(nextPowerOf2(_input.length) * 2 - 1, (i) => null);
    _lazyAdditions =
        List.generate(nextPowerOf2(_input.length) * 2 - 1, (i) => null);
    _constructTree(0, _input.length - 1, 0);
  }

  void _constructTree(int low, int high, int pos) {
    if (low == high) {
      _segmentTree[pos] = _input[low];
      return;
    }
    int mid = (low + high) ~/ 2;
    _constructTree(low, mid, 2 * pos + 1);
    _constructTree(mid + 1, high, 2 * pos + 2);
    _segmentTree[pos] =
        mergeFunction(_segmentTree[2 * pos + 1], _segmentTree[2 * pos + 2]);
  }

  int query(int from, int to) {
    return _query(from, to, 0, _input.length - 1, 0);
  }

  /// From - queryFrom
  /// To - queryTo
  /// Low - on the input array, from what index are we operating
  /// High - on the input array, to what index are we operating
  /// Pos - current node (in the array)
  int _query(int from, int to, int low, int high, int pos) {
    if (low > high) {
      return null;
    }

    // propagate lazy changes
    if (_lazyAdditions[pos] != null) {
      _segmentTree[pos] += _lazyAdditions[pos];
      if (low != high) {
        if (_lazyAdditions[2 * pos + 1] == null) {
          _lazyAdditions[2 * pos + 1] = _lazyAdditions[pos];
        } else {
          _lazyAdditions[2 * pos + 1] += _lazyAdditions[pos];
        }
        if (_lazyAdditions[2 * pos + 2] == null) {
          _lazyAdditions[2 * pos + 2] = _lazyAdditions[pos];
        } else {
          _lazyAdditions[2 * pos + 2] += _lazyAdditions[pos];
        }
      }
      _lazyAdditions[pos] = null;
    }
    if (_lazySets[pos] != null) {
      _segmentTree[pos] = _lazySets[pos];
      if (low != high) {
        _lazySets[2 * pos + 1] = _lazySets[pos];
        _lazySets[2 * pos + 2] = _lazySets[pos];
      }
      _lazySets[pos] = null;
    }

    // No overlap
    if (from > high || to < low) {
      return null;
    }

    // Total overlap
    if (from <= low && to >= high) {
      return _segmentTree[pos];
    }

    // Parital overlap
    int mid = (low + high) ~/ 2;
    return mergeFunction(_query(from, to, low, mid, 2 * pos + 1),
        _query(from, to, mid + 1, high, 2 * pos + 2));
  }

  void updateOnRange(int from, int to, int delta) {
    _changeTreeAdd(from, to, 0, _input.length - 1, 0, delta);
    for (var i = from; i < to; i++) {
      _input[i] == null ? delta : _input[i] + delta;
    }
  }

  void setOnRange(int from, int to, int value) {
    _changeTreeSet(from, to, 0, _input.length - 1, 0, value);
    for (var i = from; i < to; i++) {
      _input[i] = value;
    }
  }

  void _changeTreeAdd(int from, int to, int low, int high, int pos, int delta) {
    if (low > high) {
      return;
    }

    if (_lazyAdditions[pos] != null) {
      _segmentTree[pos] += _lazyAdditions[pos];
      if (low != high) {
        if (_lazyAdditions[2 * pos + 1] == null) {
          _lazyAdditions[2 * pos + 1] = delta;
        } else {
          _lazyAdditions[2 * pos + 1] += delta;
        }
        if (_lazyAdditions[2 * pos + 2] == null) {
          _lazyAdditions[2 * pos + 2] = delta;
        } else {
          _lazyAdditions[2 * pos + 2] += delta;
        }
      }
      _lazyAdditions[pos] = null;
    }

    if (from > high || to < low) {
      return;
    }

    if (from <= low && to >= high) {
      _segmentTree[pos] += delta;
      if (low != high) {
        if (_lazyAdditions[2 * pos + 1] == null) {
          _lazyAdditions[2 * pos + 1] = delta;
        } else {
          _lazyAdditions[2 * pos + 1] += delta;
        }
        if (_lazyAdditions[2 * pos + 2] == null) {
          _lazyAdditions[2 * pos + 2] = delta;
        } else {
          _lazyAdditions[2 * pos + 2] += delta;
        }
      }
      return;
    }

    int mid = (low + high) ~/ 2;
    _changeTreeAdd(from, to, low, mid, 2 * pos + 1, delta);
    _changeTreeAdd(from, to, mid + 1, high, 2 * pos + 2, delta);
    _segmentTree[pos] =
        mergeFunction(_segmentTree[2 * pos + 1], _segmentTree[2 * pos + 2]);
  }

  void _changeTreeSet(int from, int to, int low, int high, int pos, int value) {
    if (low > high) {
      return;
    }

    if (_lazySets[pos] != null) {
      _segmentTree[pos] += _lazySets[pos];
      if (low != high) {
        _lazySets[2 * pos + 1] = _lazySets[pos];
        _lazySets[2 * pos + 2] = _lazySets[pos];
      }
      _lazySets[pos] = null;
    }

    if (from > high || to < low) {
      return;
    }

    if (from <= low && to >= high) {
      _segmentTree[pos] = value;
      if (low != high) {
        _lazySets[2 * pos + 1] = value;
        _lazySets[2 * pos + 2] = value;
      }
      return;
    }

    int mid = (low + high) ~/ 2;
    _changeTreeSet(from, to, low, mid, 2 * pos + 1, value);
    _changeTreeSet(from, to, mid + 1, high, 2 * pos + 2, value);
    _segmentTree[pos] =
        mergeFunction(_segmentTree[2 * pos + 1], _segmentTree[2 * pos + 2]);
  }
}

int nextPowerOf2(int number) {
  if (number == 0) {
    return 1;
  }
  if (number > 0 && (number & (number - 1)) == 0) {
    return number;
  }
  while ((number & (number - 1)) > 0) {
    number = number & (number - 1);
  }
  return number << 1;
}
