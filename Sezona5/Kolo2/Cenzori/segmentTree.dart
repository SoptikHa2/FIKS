import 'dart:math';

class SegmentTree {
  List<int> _input;
  List<int> _segmentTree;
  dynamic mergeFunction;

  SegmentTree(this._input, int mergeFunction(int a, int b)) {
    this.mergeFunction = mergeFunction;
    _segmentTree =
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
    if (from <= low && to >= high) {
      // We have total overlap
      return _segmentTree[pos];
    }
    if (from > high || to < low) {
      // We have no overlap
      return null;
    }
    int mid = (low + high) ~/ 2;
    return mergeFunction(_query(from, to, low, mid, 2 * pos + 1),
        _query(from, to, mid + 1, high, 2 * pos + 2));
  }

  void updateOnRange(int from, int to, int delta) {
    _changeTree(from, to, 0, _input.length - 1, 0, ((val) => val == null ? delta : val + delta));
    for (var i = from; i < to; i++) {
      _input[i] == null ? delta : _input[i] + delta;
    }
  }

  void setOnRange(int from, int to, int value) {
    _changeTree(from, to, 0, _input.length - 1, 0, ((val) => value));
    for (var i = from; i < to; i++) {
      _input[i] = value;
    }
  }

  void _changeTree(int from, int to, int low, int high, int pos,
      int changeFunction(int lastValue)) {
    if (low > high || from > high || to < low) {
      return;
    }

    if (low == high) {
      _segmentTree[pos] = changeFunction(_segmentTree[pos]);
      return;
    }

    int middle = (low + high) ~/ 2;
    _changeTree(from, to, low, middle, 2 * pos + 1, changeFunction);
    _changeTree(from, to, middle + 1, high, 2 * pos + 2, changeFunction);
    _segmentTree[pos] =
        mergeFunction(_segmentTree[2 * pos + 1], _segmentTree[2 * pos + 2]);
  }
}

// int leftChildIndex(int index) => 2 * index + 1;
// int rightChildIndex(int index) => 2 * index + 2;
// int parentIndex(int index) => (index - 1) ~/ 2;

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
