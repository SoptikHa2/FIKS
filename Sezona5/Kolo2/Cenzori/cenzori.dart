import 'segmentTree.dart';
import 'dart:io';

main(List<String> args) {
  //int numberOfInputs = int.parse(stdin.readLineSync());
  int numberOfInputs = 1;
  for (var i = 0; i < numberOfInputs; i++) {
    // var line =
    //     stdin.readLineSync().split(' ').map((s) => int.parse(s)).toList();
    // int inp_t = line[0];
    // int inp_n = line[1];
    // int inp_a = line[2];
    // int inp_b = line[3];
    // int inp_x = line[4];
    int inp_t = 3;
    int inp_n = 3;
    int inp_a = 4;
    int inp_b = 5;
    int inp_x = 5;

    var tree = SegmentTree(List.generate(inp_n, (_) => 0));
    var results = List<int>();
    for (var i = 0; i < inp_t; i++) {
      var realInput = generateInput(inp_n, inp_a, inp_b, inp_x);
      inp_x = realInput.x;

      switch (realInput.t) {
        case 0:
          results.add(tree.queryMinimum(realInput.b, realInput.e));
          break;
        case 1:
          tree.updateOnRange(realInput.b, realInput.e, realInput.a);
          break;
        case 2:
          tree.setOnRange(realInput.b, realInput.e, realInput.a);
          break;
      }
    }

    int currentMinXor = 0;
    int currentMaxXor = 0;
    int currentMin = 999999999999999999;
    int currentMax = -99999999999999999;
    int sum = 0;
    for (var number in results) {
      sum ^= number;
      if (number < currentMin) {
        currentMin = number;
        currentMinXor = 0;
      } else {
        currentMinXor ^= number;
      }
      if (number > currentMax) {
        currentMax = number;
        currentMaxXor = 0;
      } else {
        currentMaxXor ^= number;
      }
    }
    print(results);
    print(currentMinXor);
    print(currentMaxXor);
    print(sum);
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
