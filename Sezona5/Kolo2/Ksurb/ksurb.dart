// http://codinghelmet.com/exercises/expression-from-numbers
import 'dart:collection';
import 'dart:io';

main(List<String> args) {
  int numberOfInputs = int.parse(stdin.readLineSync());
  for (var i = 0; i < numberOfInputs; i++) {
    var line = stdin.readLineSync().split(' ');
    int requiredResult = int.parse(line[0]);
    var numbers = line.skip(2).map((s) => int.parse(s)).toList();
    bool canBeDone = guess(numbers, requiredResult);
    if(canBeDone){
      canBeDone = backtrack(numbersToMap(numbers), Queue<int>(), requiredResult, 0);
    }

    if (numbers.length > 6) {
      // There is no way we can do this in time
      canBeDone = guess(numbers, requiredResult);
    } else {
      canBeDone = solve(numbers, requiredResult);
    }

    if (canBeDone) {
      print('LZE');
    } else {
      print('NELZE');
    }
  }
}

Map<int, int> numbersToMap(List<int> numbers){
  var map = Map<int, int>();
  for (var number in numbers) {
    if(map.containsKey(number)){
      map[number]++;
    }else{
      map[number] = 1;
    }
  }
  return map;
}

List<int> mapToNumbers(Map<int, int> map){
  var list = List<int>();
  for (var key in map.keys) {
    var value = map[key];
    for (var i = 0; i < value; i++) {
      list.add(key);
    }
  }
  return list;
}

void test() {
  print('Running tests...');
  int testNumber = 1;
  runOneTest([10, 5, 14], 1, true, 'Test ${testNumber++}');
  runOneTest([4, 7, 5, 2], 8, true, 'Test ${testNumber++}');
  runOneTest([5, 10, 15, 5, 20], 8, false, 'Test ${testNumber++}');
  runOneTest([7, 4, 14, 17, 2, 16, 9, 4], 37, true, 'Test ${testNumber++}');
  runOneTest([0, 1, 2], 44037, false, 'Test ${testNumber++}');
  runOneTest([20, 7, 8, 6], 10000, false, 'Test ${testNumber++}');
  runOneTest([1, 1, 1, 2], 4, false, 'Test ${testNumber++}');
  runOneTest([1, 1, 1, 2], 3, true, 'Test ${testNumber++}');
  runOneTest([1, 1, 2, 2], 4, true, 'Test ${testNumber++}');
}

void runOneTest(
    List<int> numbers, int target, bool assertValue, String testName) {
  var actualValue = solve(numbers, target);
  if (actualValue == assertValue) {
    print('$testName OK!');
  } else {
    stderr.writeln(
        'FAILURE: $testName. Expected: $assertValue. Actual: $actualValue');
  }
}

bool solve(List<int> numbers, int target) {
  int targetKey = (target << numbers.length) + (1 << numbers.length) - 1;

  var solvedKeys = HashSet<int>();
  var keyToLeftParent = Map<int, int>();
  var keyToRightParent = Map<int, int>();
  var keyToOperator = Map<int, String>();
  var queue = Queue<int>();

  // Initialize structures
  for (var i = 0; i < numbers.length; i++) {
    int key = (numbers[i] << numbers.length) + (1 << i);

    solvedKeys.add(key);
    queue.add(key);
  }

  while (queue.length > 0 && !solvedKeys.contains(targetKey)) {
    int curKey = queue.removeFirst();

    int curMask = curKey & ((1 << numbers.length) - 1);
    int curValue = curKey >> numbers.length;

    var keys = solvedKeys.toList(growable: false);

    for (var i = 0; i < keys.length; i++) {
      int mask = keys[i] & ((1 << numbers.length) - 1);
      int value = keys[i] >> numbers.length;

      if ((mask & curMask) == 0) {
        for (int op = 0; op < 6; op++) {
          var opSign = '';
          int newValue = 0;

          switch (op) {
            case 0: // Addition
              newValue = curValue + value;
              opSign = '+';
              break;
            case 1: // Subtraction - another value subtracted from current
              newValue = curValue - value;
              opSign = '-';
              break;
            case 2: // Subtraction - current value subtracted from another
              newValue = value - curValue;
              opSign = '-';
              break;
            /*case 3: // Multiplication
              newValue = curValue * value;
              opSign = '*';
              break;
            case 4: // Division - current divided by another
              newValue = -1; // Indicates failure to divide
              if (value != 0 && curValue % value == 0)
                newValue = curValue ~/ value;
              opSign = '/';
              break;
            case 5: // Division - other value divided by current
              newValue = -1; // Indicates failure to divide
              if (curValue != 0 && value % curValue == 0)
                newValue = value ~/ curValue;
              opSign = '/';
              break;*/
          }

          if (newValue >= 0) {
            // Ignore negative values - they can always be created
            // the other way around, by subtracting them
            // from a larger value so that positive value is reached.

            int newMask = (curMask | mask);
            // Combine the masks to indicate that all input numbers
            // from both operands have been used to produce
            // the resulting expression

            int newKey = (newValue << numbers.length) + newMask;

            if (!solvedKeys.contains(newKey)) {
              // We have reached a new entry.
              // This expression should now be added
              // to data structures and processed further
              // in the following steps.

              // Populate entries that describe newly created expression
              solvedKeys.add(newKey);

              if (op == 2 || op == 5) {
                // Special cases - antireflexive operations
                // with interchanged operands
                keyToLeftParent[newKey] = keys[i];
                keyToRightParent[newKey] = curKey;
              } else {
                keyToLeftParent[newKey] = curKey;
                keyToRightParent[newKey] = keys[i];
              }

              keyToOperator[newKey] = opSign;

              // Add expression to list of reachable expressions
              solvedKeys.add(newKey);

              // Add expression to the queue for further expansion
              queue.add(newKey);
            }
          }
        }
      }
    }
  }

  return solvedKeys.contains(targetKey);
}

bool guess(List<int> numbers, int target) {
  if(numbers.length == 0){
    return target == 0;
  }

  // Veryify maximum
  int maximumAddition = numbers.reduce((a, b) => a + b);
  if (target > maximumAddition) return false;

  // Verify parity
  int numberOfOddNumbers = numbers.where((n) => n.isOdd).length;
  if (numberOfOddNumbers.isEven != target.isEven) {
    return false;
  }

  return true;
}

bool minimizeInput(List<int> numbers, int target) {
  var s = HashSet<int>();
  for (var number in numbers) {
    if (s.contains(number)) {
      if (target > 0)
        target -= number;
      else
        target += number;
    } else {
      s.add(number);
    }
  }

  print('Running solve @ target $target and numbers $s');

  return solve(s.toList(), target);
}

bool backtrack(
    Map<int, int> numbers, Queue<int> currentPath, int result, int currentSum) {
  
  stderr.writeln(currentPath);
  if (currentSum == result) {
    return true;
  }
  if(guess(mapToNumbers(numbers), result - currentSum) == false){
    return false;
  }

  for (var key in numbers.keys) {
    var value = numbers[key];
    int newSum = currentSum;
    if (value > 0) {
      numbers[key]--;
      if (result - currentSum > 0) {
        newSum -= key;
      } else {
        newSum += key;
      }
      currentPath.add(key);
      var btResult = backtrack(numbers, currentPath, result, newSum);
      currentPath.removeLast();
      //numbers[key]++;
      if(btResult == true){
        return true;
      }
    }
  }

  return false;
}

class MinimizedInput {
  Iterable<int> numbers;
  int target;
  MinimizedInput(this.numbers, this.target);
}
