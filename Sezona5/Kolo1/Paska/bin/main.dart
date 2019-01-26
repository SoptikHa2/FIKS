import 'dart:math';
import 'dart:io';

main(List<String> args) {
  // Postup:
  //
  // Vyberu 2-4 extremy (vetsinou 4, ale nekdy to nemusi vyjit - ale bylo
  // by moc pomale to zajistit, aby bylo vzdy vybrano co nejvic extremu)
  //
  // Tyhle extremy pridam do finalniho reseni. Potom
  // vezmu vsechny body uvnitr N-uhelniku reseni a vymazu je.
  //
  // Potom opakuji cyklus dokud jeste jsou nejake body:
  // Pro vsechny zbyvajici body, kazdy priradim k te nejblizsi
  // strane reseni.
  // Potom pro kazdou stranu najdu nejvzdalenejsi prirazeny bod
  // a pridam ho do reseni (mezi body dane strany).
  test();
  benchmark();
  exit(0);

  var input = List<Point>();
  int numberOfInputs = int.parse(stdin.readLineSync());
  for (var i = 0; i < numberOfInputs; i++) {
    var line =
        stdin.readLineSync().split(' ').map((s) => int.parse(s)).toList();
    for (var i = 0; i < line[0]; i++) {
      input.add(Point(line[2 * i + 1].toDouble(), line[2 * i + 2].toDouble()));
    }
  }
  print(solve(input).lengthBetweenPoints());

  //test();
}

void test() {
  assert(abs(solve([Point(0, 0), Point(0, 2), Point(2, 0), Point(2, 2)]).lengthBetweenPoints() - 8) <
      0.01);
  assert(abs(solve([
            Point(-4, 3),
            Point(-3, 1),
            Point(-1, 1),
            Point(0, 3),
            Point(-2, 4),
            Point(-1, 2),
            Point(3, 2),
            Point(6, 2),
            Point(6, 6),
            Point(2, 5),
            Point(0, 4),
            Point(0, 0),
            Point(1, -2),
            Point(1, 1)
          ]).lengthBetweenPoints() -
          28.12) <
      0.01);
}

double benchmark() {
  int testsCount = 5 * 1000;
  int pointsPerTestMin = 1000;
  int pointsPerTestMax = 1000 * 1000;
  int pointsMax = 10 * 1000;

  var rnd = Random();
    var sw = Stopwatch();

  for (var i = 0; i < testsCount; i++) {
    int pointsInThisTest = rnd.nextInt(pointsPerTestMax-pointsPerTestMin)+pointsPerTestMin;
    List<Point> input = List<Point>(pointsInThisTest);
    for (var j = 0; j < pointsInThisTest; j++) {
      double x = rnd.nextInt(pointsMax).toDouble();
      double y = rnd.nextInt(pointsMax).toDouble();
      input[j] = Point(x, y);
    }
    sw.start();
    var solution = solve(input);
    sw.stop();
    print('$pointsInThisTest\t${sw.elapsedMilliseconds}');
    sw.reset();
  }
}

Result solve(List<Point> input) {
  var result = Result();
  if (input.length == 3) {
    result.list = input;
  } else {
    // Vyber extremy
    var topMost = maxWhere<Point>(input, (p) => -p.y).first;
    var botMost = firstOrNull(
        maxWhere<Point>(input, (p) => p.y).where((p) => p != topMost));
    var rightMost = firstOrNull(maxWhere<Point>(input, (p) => p.x)
        .where((p) => p != topMost && p != botMost));
    var leftMost = firstOrNull(maxWhere<Point>(input, (p) => -p.x)
        .where((p) => p != topMost && p != botMost && p != rightMost));
    if(leftMost != null && rightMost != null)
      leftMost = null;

    // Pridej je do reseni
    result.list = List<Point>();
    result.list.add(topMost);
    result.list.add(botMost);
    if (rightMost != null) {
      result.list.add(rightMost);
    }
    if (leftMost != null) {
      result.list.add(leftMost);
    }

    // Oznac body co jsou soucasti reseni nebo jsou uvnitr N-uhlenika jako vymazane
    input
        .where((p) => result.list.contains(p) || isPointInside(result.list, p))
        .forEach((p) => p.enabled = false);

    while (input.any((p) => p.enabled)) {
      // Prirad kazdy bod k jedne ze stran
      var sides = Map<int, List<Point>>(); // klic := index prvniho bodu strany
      for (var point in input.where((p) => p.enabled)) {
        double distanceFromSide = double.infinity;
        int firstPointOfSide = null;
        for (var i = 0; i < result.list.length; i++) {
          var firstPoint = result.list[i];
          var secondPoint = (i + 1 < result.list.length)
              ? result.list[i + 1]
              : result.list[0];
          var distance = point.distanceToLine(firstPoint, secondPoint);
          if (distance < distanceFromSide) {
            distanceFromSide = distance;
            firstPointOfSide = i;
          }
        }
        if (sides.containsKey(firstPointOfSide))
          sides[firstPointOfSide].add(point);
        else
          sides[firstPointOfSide] = [point];
      }

      // Ke kazde strane vyber jeden bod, ktery do ni zahrnu
      var selectedPoints = Map<Point, Point>();
      for (var key in sides.keys) {
        var value = sides[key];
        var firstPoint = result.list[key];
        var secondPoint = key + 1 < result.list.length
            ? result.list[key + 1]
            : result.list[0];
        var selectedPoint = firstOrNull(maxWhere<Point>(
            value, (p) => p.distanceToLine(firstPoint, secondPoint)));
        selectedPoints[firstPoint] = selectedPoint;
      }

      // Pridej bod do vysledku
      result.addToSides(selectedPoints);

      // Oznac body co jsou soucasti reseni nebo jsou uvnitr N-uhlenika jako vymazane
      input
          .where((p) =>
              p.enabled &&
              (result.list.contains(p) || isPointInside(result.list, p)))
          .forEach((p) => p.enabled = false);
    }
  }

  return result;
}

class Result {
  List<Point> list;

  void addToSides(Map<Point, Point> selectedPoints) {
    var newList = List<Point>();

    for (var item in list) {
      newList.add(item);
      if (selectedPoints.containsKey(item)) {
        newList.add(selectedPoints[item]);
      }
    }

    list = newList;
  }

  double lengthBetweenPoints() {
    double distance = 0;
    for (var i = 0; i < list.length; i++) {
      var firstPoint = list[i];
      var secondPoint = i + 1 < list.length ? list[i + 1] : list[0];
      distance += firstPoint - secondPoint;
    }
    return distance;
  }
}

class Point {
  double x, y;
  bool enabled = true;
  double operator -(Point other) =>
      sqrt(pow(abs(x - other.x), 2) + pow(abs(y - other.y), 2));
  Point(this.x, this.y);

  // Delka tohoto bodu od usecky |p1 p2|
  double distanceToLine(Point p1, Point p2) {
    // Delka strany
    /*double a = this - p2;
    double b = p1 - p2;
    double c = p1 - this;

    // Heronuv vzorec
    double s = (a + b + c) / 2;
    double S = sqrt(s * (s - a) * (s - b) * (s - c));
    return 2 * S / c;*/

    var l2 = dist2(p1, p2);
    if (l2 == 0) return dist2(this, p1);
    var t =
        ((this.x - p1.x) * (p2.x - p1.x) + (this.y - p1.y) * (p2.y - p1.y)) /
            l2;
    t = max(0, min(1, t));
    return dist2(
        this, Point(p1.x + t * (p2.x - p1.x), p1.y + t * (p2.y - p1.y)));
  }

  double dist2(Point a, Point b) {
    return pow(a.x - b.x, 2) + pow(a.y - b.y, 2);
  }

  @override
  String toString() {
    return "$x $y";
  }
}

num abs(num n) => n >= 0 ? n : -n;

List<T> maxWhere<T>(Iterable<T> list, double score(T input)) {
  var currentScore = double.negativeInfinity;
  var result = List<T>();
  for (var item in list) {
    var scoreOfItem = score(item);
    if (scoreOfItem > currentScore) {
      result.clear();
      result.add(item);
      currentScore = scoreOfItem;
    } else if (scoreOfItem == currentScore) {
      result.add(item);
    }
  }
  return result;
}

T firstOrNull<T>(Iterable<T> list) {
  if (list.length > 0)
    return list.first;
  else
    return null;
}

// Jak zjistime jestli je bod uvnitr nebo venku N-uhelniku?
// Podivame se, na jake strane vsech stran bod lezi
bool isPointInside(List<Point> convexHull, Point p) {
  int pos = 0;
  int neg = 0;
  for (var i = 0; i < convexHull.length; i++) {
    var p1 = convexHull[i];
    var p2 = convexHull[i + 1 < convexHull.length ? i + 1 : 0];

    var d = sideOfLine(p, p1, p2);

    if (d > 0) pos++;
    if (d < 0) neg++;

    if (pos > 0 && neg > 0) return false;
  }
  return true;
}

// Usecka AB, bod P
double sideOfLine(Point p, Point a, Point b) {
  return (p.x - b.x) * (a.y - b.y) - (a.x - b.x) * (p.y - b.y);
}

double max(double a, double b) => a >= b ? a : b;
double min(double a, double b) => a < b ? a : b;
