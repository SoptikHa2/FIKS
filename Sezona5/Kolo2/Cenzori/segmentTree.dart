import 'dart:math';

class SegmentTree {
  List<int> _segmentTree;
  List<int> _input;

  SegmentTree(this._input) {
    int nextPower = nextPowerOf2(_input.length);
    _segmentTree = List.generate(nextPower * 2 - 1, (i) => 576460752303423486);

    _constructMinSegmentTree(_input, 0, _input.length - 1, 0);
  }

  void _constructMinSegmentTree(List<int> input, int low, int high, int pos) {
    if (low == high) {
      _segmentTree[pos] = input[low];
      return;
    }

    int mid = (low + high) ~/ 2;
    _constructMinSegmentTree(input, low, mid, 2 * pos + 1);
    _constructMinSegmentTree(input, mid + 1, high, 2 * pos + 2);
    _segmentTree[pos] =
        min(_segmentTree[2 * pos + 1], _segmentTree[2 * pos + 2]);
  }

  void _updateSegmentTree(int index, int delta, int low, int high, int pos) {
    if (index < low || index > high) {
      return;
    }

    if (low == high) {
      _segmentTree[pos] += delta;
      return;
    }

    int mid = (low + high) ~/ 2;
    _updateSegmentTree(index, delta, low, mid, 2 * pos + 1);
    _updateSegmentTree(index, delta, mid + 1, high, 2 * pos + 2);
    _segmentTree[pos] =
        min(_segmentTree[2 * pos + 1], _segmentTree[2 * pos + 2]);
  }

  void _updateSegmentTreeRange(
      int startRange, int endRange, int delta, int low, int high, int pos) {
    if (low > high || startRange > high || endRange < low) {
      return;
    }

    if (low == high) {
      _segmentTree[pos] += delta;
      return;
    }

    int middle = (low + high) ~/ 2;
    _updateSegmentTreeRange(
        startRange, endRange, delta, low, middle, 2 * pos + 1);
    _updateSegmentTreeRange(
        startRange, endRange, delta, middle + 1, high, 2 * pos + 2);
    _segmentTree[pos] =
        min(_segmentTree[2 * pos + 1], _segmentTree[2 * pos + 2]);
  }

  void updateSegmentTree(int index, int delta) {
    _input[index] += delta;
    _updateSegmentTree(index, delta, 0, _input.length - 1, 0);
  }

  void updateSegmentTreeRange(int startRange, int endRange, int delta) {
    for (var i = startRange; i <= endRange; i++) {
      _input[i] += delta;
    }
    _updateSegmentTreeRange(
        startRange, endRange, delta, 0, _input.length - 1, 0);
  }

  int _rangeMinimumQuery(int low, int high, int qlow, int qhigh, int pos) {
    if (qlow <= low && qhigh >= high) {
      return _segmentTree[pos];
    }
    if (qlow > high || qhigh < low) {
      return 576460752303423486;
    }
    int mid = (low + high) ~/ 2;
    return min(_rangeMinimumQuery(low, mid, qlow, qhigh, 2 * pos + 1),
        _rangeMinimumQuery(mid + 1, high, qlow, qhigh, 2 * pos + 2));
  }

  int rangeMinimumQuery(int qlow, int qhigh) {
    return _rangeMinimumQuery(0, (qhigh - qlow) - 1, qlow, qhigh, 0);
  }
}

int nextPowerOf2(int number){
        if(number ==0){
            return 1;
        }
        if(number > 0 && (number & (number-1)) == 0){
            return number;
        }
        while((number & (number-1)) > 0){
            number = number & (number-1);
        }
        return number<<1;
}

num min(num a, num b) => a < b ? a : b;
