import 'dart:io';

main(List<String> args) {
  int t = int.parse(stdin.readLineSync().trim());

  for (int _t = 0; _t < t; _t++) {
    var input = stdin.readLineSync().trim().split(' ');
    int i_n = int.parse(input[0]);
    int i_q = int.parse(input[1]);
    int i_a = int.parse(input[2]);
    int i_b = int.parse(input[3]);
    int i_x0 = int.parse(input[4]);

    List<int> startArray = List<int>(i_n);
    int x = i_x0;
    for (var i = 0; i < i_n; i++) {
      int result = nextLong(i_a, x, i_b);
      x = result;
      startArray[i] = result % i_n;
    }

    // Queries
    for (var i = 0; i < i_q; i++) {
      int result =nextLong(i_a, x, i_b);
      x = result;
      int B = result % i_n;
      result =nextLong(i_a, x, i_b);
      x = result;
      int E = result % i_n;
      result =nextLong(i_a, x, i_b);
      x = result;
      int K = result;

      if(B > E){
        int _tmp = B;
        B = E;
        E = _tmp;
      }

      K %= (E-B+1);

    }
  }
}

int nextLong(int a, int x, int b) {
  return (a * x + b) % (1000000007);
}
