//import 'segmentTree.dart';
import '/home/petr/Programming/Dart/Libraries/SegmentTree/lib/segmentTreeWithNodes.dart';
import 'dart:io';

main(List<String> args) {
  int numberOfInputs = int.parse(stdin.readLineSync());
  for (var i = 0; i < numberOfInputs; i++) {
    var line =
        stdin.readLineSync().split(' ').map((s) => int.parse(s)).toList();
    int inp_t = line[0];
    int inp_n = line[1];
    int inp_a = line[2];
    int inp_b = line[3];
    int inp_x = line[4];

    stderr.writeln('#######################');
    stderr.writeln('$i / $numberOfInputs');
    stderr.writeln('#######################');

    var treeMin = SegmentTree.min(List.generate(inp_n, (_) => 0));
    var treeMax = SegmentTree.max(List.generate(inp_n, (_) => 0));
    var treeSum = SegmentTree.sum(List.generate(inp_n, (_) => 0));
    var resultsMin = List<int>();
    var resultsMax = List<int>();
    var resultsSum = List<int>();
    for (var i = 0; i < inp_t; i++) {
      if (i % 1000 == 0) {
        stderr.writeln('$i / $inp_t');
      }

      var realInput = generateInput(inp_n, inp_a, inp_b, inp_x);
      inp_x = realInput.x;

      switch (realInput.t) {
        case 0:
          resultsMin.add(treeMin.queryOnInterval(realInput.b, realInput.e));
          resultsMax.add(treeMax.queryOnInterval(realInput.b, realInput.e));
          resultsSum.add(treeSum.queryOnInterval(realInput.b, realInput.e));
          break;
        case 1:
          treeMin.addOnIntervalLazy(realInput.b, realInput.e, realInput.a);
          treeMax.addOnIntervalLazy(realInput.b, realInput.e, realInput.a);
          treeSum.addOnIntervalLazy(realInput.b, realInput.e, realInput.a);
          break;
        case 2:
          treeMin.setOnIntervalLazy(realInput.b, realInput.e, realInput.a);
          treeMax.setOnIntervalLazy(realInput.b, realInput.e, realInput.a);
          treeSum.setOnIntervalLazy(realInput.b, realInput.e, realInput.a);
          break;
      }
    }

    int minXor = 0;
    int maxXor = 0;
    int sumXor = 0;
    for (var number in resultsMin) {
      minXor ^= number;
    }
    for (var number in resultsMax) {
      maxXor ^= number;
    }
    for (var number in resultsSum) {
      sumXor ^= number;
    }
    print(minXor);
    print(maxXor);
    print(sumXor);
  }
}

Input generateInput(int n, int a, int b, int x0) {
  int x = nextInt(x0, a, b);
  int t = x % 3;
  x = nextInt(x, a, b);
  int nextB = x % n;
  x = nextInt(x, a, b);
  int e = x % n;
  if (nextB > e) {
    int c = nextB;
    nextB = e;
    e = c;
  }
  x = nextInt(x, a, b);
  int nextA = x % n;

  return Input(t, nextB, e, nextA, x);
}

int nextInt(int x, int a, int b) => ((x * a + b) % 1000000007);

class Input {
  int t;
  int b;
  int e;
  int a;
  int x;

  Input(this.t, this.b, this.e, this.a, this.x);
}
