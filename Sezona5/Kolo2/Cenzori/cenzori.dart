import 'segmentTree.dart';

main(List<String> args) {
  var tree = SegmentTree([2, 1, 2, 3, 0]);
  print(tree.queryMinimum(2, 5));
}


Input generateInput(int t, int n, int a, int b, int x0) {
  int x = nextInt(x0, a, b);
  int t = x % 3;
  x = nextInt(x, a, b);
  int nextB = x % n;
  x = nextInt(x, a, b);
  int e = x % n;
  if(nextB > e){
    int c = nextB;
    nextB = e;
    e = c;
  }

  int nextA = nextInt(x, a, b) % n;

  return Input(t, nextB, e, nextA);
}

int nextInt(int x, int a, int b) => ((x * a + b) % 1000000007);


class Input{
  int t;
  int b;
  int e;
  int a;

  Input(this.t, this.b, this.e, this.a);
}