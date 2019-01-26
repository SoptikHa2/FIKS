import 'dart:io';

/// Input:
/// 1. T (numer of tests)
/// For each T:
///   1. N Q (number of inputs in line, number of questions)
///   2. a1, a2, a3, ... an (inputs)
///   For each Q:
///     1. If It (<interval from, to>)
///   
///  Output:
///   1. Lowest ID at interval
///   2. Index of highest ID at interval
///   3. XOR of *all* IDs at the interval
void main(List<String> args){
  int tests = int.parse(stdin.readLineSync());
  for (var i = 0; i < tests; i++) {
    var line = stdin.readLineSync();
    int inputs = int.parse(line.split(' ')[0]);
    int questions = int.parse(line.split(' ')[1]);
    var numbers = stdin.readLineSync().split(' ').map((number) => int.parse(number))
                                        .toList();
    for (var j = 0; j < questions; j++) {
      line = stdin.readLineSync();
      int intervalFrom = int.parse(line.split(' ')[0]);
      int intervalTo = int.parse(line.split(' ')[1]);

      int minValue = 2147483647;
      int maxValue = -2147483647;
      int maxIndex = -1;
      int xor = 0;
      for(int index = intervalFrom; index <= intervalTo; index++){
        int numberValue = numbers[index];
        if(numberValue < minValue){
          minValue = numberValue;
        }
        if(numberValue > maxValue){
          maxValue = numberValue;
          maxIndex = index;
        }
        xor ^= numberValue;
      }

      print(minValue);
      print(maxIndex);
      print(xor);
    }
  }
}
