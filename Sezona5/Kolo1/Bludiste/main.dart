import 'dart:io';

// Kdyz mam bludiste, do nespravnyho smeru se musim pohnout
// ((required)-(m+n-1))/2
// Kdyz tohle cislo nevyjde cele,
// nelze to udelat. Kdyz vyjde zaporne,
// nezle to udelat. Obcas to nejde udelat i tak.

// Takze by slo spustit ten generator
// nejdelsi cesty jenom na N zdi

main(List<String> args) {
  int numberOfLines = int.parse(stdin.readLineSync());
  for (var i = 0; i < numberOfLines; i++) {
    var numbers = stdin.readLineSync().split(' ').map((f) => int.parse(f)).toList();
    solveAndPrintToStdOut(numbers[1], numbers[0], numbers[2]);
    //forceSolveAndCompare(numbers[0], numbers[1], numbers[2]);
  }
}

void solveAndPrintToStdOut(int n, int m, int required){
  int magicalNumber = ((required) - (m+n-1));
  if(magicalNumber.isEven && magicalNumber >= 0){
    var solution = createLongestPath(m, n, required);
    // Test:
    // var actualSolution = shortestPathToEnd(solution);
    // if(actualSolution != required){
    //   print('Nejde to.');
    //   stderr.writeln('Failed for $n $m $required');
    // }else{
    //   printArray(solution);
    // }
    printArray(solution);
  }else{
    print('Nejde to.');
  }
}

void forceSolveAndCompare(int n, int m, int required){
  var solution = createLongestPath(m, n, required);
  int magicalNumber = ((required) - (m+n-1));
  int shortestPath = shortestPathToEnd(solution);
  bool okByMagicalNumber = magicalNumber.isEven && magicalNumber >= 0;
  bool okByFloodfill = shortestPath == required;
  if(okByFloodfill != okByMagicalNumber){
    stderr.writeln('Failed magical number for $n $m $required');
  }
  if(shortestPath != required){
    stderr.writeln('Failed maze construction for $n $m $required');
  }
}

List<List<dynamic>> createLongestPath(int m, int n, int targetLength) {
  // 2D pole
  var array = List.generate(m, (_) => List.generate(n, (_) => 0));
  int x = 0, y = 0;
  int remainingTargetLength = targetLength - (m+n-1);
  if (remainingTargetLength == 0) {
    return array;
  }
  while (m > 4) {
    m -= 4;
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < n; j++) {
        if (j < n - 1 && i == 1) {
          array[y][x] = 1;
        } else if (j > 0 && i == 3) {
          array[y][array.first.length - x] = 1;

          remainingTargetLength -= 2;
          if (remainingTargetLength == 0) {
            return array;
          }
        }
        x++;
      }
      x = 0;
      y++;
    }
  }

  x++;
  int topY = y;
  while (x < array.first.length - 1) {
    while (y < array.length - 1) {
      array[y][x] = 1;
      y++;
    }
    x += 2;
    if (x < array.first.length - 1) {
      while (y > topY) {
        array[y][x] = 1;
        y--;

        remainingTargetLength -= 2;
        if (remainingTargetLength == 0) {
          return array;
        }
      }
    }
    x += 2;
  }

  return array;
}

void printArray(List<List<dynamic>> array) {
  for (var innerList in array) {
    for (var item in innerList) {
      stdout.write(item == 0 ? '.' : '#');
    }
    stdout.write('\n');
  }
}

int shortestPathToEnd(List<List<dynamic>> array, [bool debug = false]) {
  var tempArray = _copyArray(array);
  if (debug) printArray(tempArray);
  _visitOthers(tempArray, 0, 0, 100, debug);
  if (debug) printArray(tempArray);
  int value = tempArray.last.last - 100;
  return value+1;
}

void _visitOthers(List<List<dynamic>> array, int currentX, int currentY,
    int currentValue, bool debug) {
  array[currentX][currentY] = currentValue;
  if (debug) print("$currentX $currentY \t $currentValue");
  try {
    if (array[currentX + 1][currentY] == 0 ||
        array[currentX + 1][currentY] > currentValue + 1) {
      _visitOthers(array, currentX + 1, currentY, currentValue + 1, debug);
    }
  } catch (e) {}
  try {
    if (array[currentX - 1][currentY] == 0 ||
        array[currentX - 1][currentY] > currentValue + 1) {
      _visitOthers(array, currentX - 1, currentY, currentValue + 1, debug);
    }
  } catch (e) {}
  try {
    if (array[currentX][currentY + 1] == 0 ||
        array[currentX][currentY + 1] > currentValue + 1) {
      _visitOthers(array, currentX, currentY + 1, currentValue + 1, debug);
    }
  } catch (e) {}
  try {
    if (array[currentX][currentY - 1] == 0 ||
        array[currentX][currentY - 1] > currentValue + 1) {
      _visitOthers(array, currentX, currentY - 1, currentValue + 1, debug);
    }
  } catch (e) {}
}

List<List<dynamic>> _copyArray(List<List<dynamic>> array) {
  var newArray = List.generate(array.length, (_) => List(array.first.length));
  for (var i = 0; i < array.length; i++) {
    for (var j = 0; j < array.first.length; j++) {
      newArray[i][j] = array[i][j];
    }
  }
  return newArray;
}
