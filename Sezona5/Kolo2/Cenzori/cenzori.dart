import 'segmentTree.dart';
import 'dart:io';

main(List<String> args) {
  int numberOfInputs = int.parse(stdin.readLineSync());
  for (var i = 0; i < numberOfInputs; i++) {
    var line =
        stdin.readLineSync().split(' ').map((s) => int.parse(s)).toList();
    int t = line[0];
    int n = line[1];
    int a = line[2];
    int b = line[3];
    int x = line[4];

    var tree = SegmentTree(List.generate(n, (_) => null));
    var results = List<int>();
    for (var i = 0; i < t; i++) {
      var realInput = generateInput(n, a, b, x);
      x = realInput.x;

      switch (realInput.t) {
        case 0:
          print('case 0');
          results.add(tree.queryMinimum(realInput.b, realInput.e));
          break;
        case 1:
          print('case 1');
          tree.updateOnRange(realInput.b, realInput.e, realInput.a);
          break;
        case 2:
          print('case 2');
          tree.setOnRange(realInput.b, realInput.e, realInput.a);
          break;
      }
    }
    print(results);
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
  int nextA = nextInt(x, a, b) % n;

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
