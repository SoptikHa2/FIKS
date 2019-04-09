import 'dart:collection';
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

    // Start values
    List<int> startArray = List<int>();

    /// Key: the number in startArray. Hashset: all indexes that had the value
    Map<int, HashSet<int>> lookupMap = Map();
    int x = i_x0;
    for (var i = 0; i < i_n; i++) {
      int result = nextLong(i_a, x, i_b);
      x = result;
      int itemInArray = result % i_n;
      if (!lookupMap.containsKey(itemInArray)) {
        lookupMap[itemInArray] = HashSet();
        startArray.add(itemInArray);
      }
      lookupMap[itemInArray].add(i);
    }

    // Sort the array
    startArray.sort();

    List<int> results = List<int>(i_q);
    // Queries
    for (var i = 0; i < i_q; i++) {
      int result = nextLong(i_a, x, i_b);
      x = result;
      int B = result % i_n;
      result = nextLong(i_a, x, i_b);
      x = result;
      int E = result % i_n;
      result = nextLong(i_a, x, i_b);
      x = result;
      int K = result;

      if (B > E) {
        int _tmp = B;
        B = E;
        E = _tmp;
      }

      K %= (E - B + 1);

      // Run the query
      int current_k = 0;
      for (var item in startArray) {
        if (item == null) continue;
        var passedItems = lookupMap[item].where((n) => n >= B && n <= E);
        if (passedItems.length > 0) {
          if (current_k >= K) {
            // We have a result
            results[i] = item;
            break;
          } else {
            current_k += passedItems.length;
          }
        }
      }
    }

    int xor = 0;
    for (var item in results) {
      xor ^= item;
    }
    print(xor);
  }
}

int nextLong(int a, int x, int b) {
  return (a * x + b) % (1000000007);
}
