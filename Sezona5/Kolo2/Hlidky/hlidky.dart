import 'dart:io';

main(List<String> args) {
  if (args.contains("-v")) {
    Log.enabled = true;
  }

  // Input
  var line = stdin.readLineSync().split(' ').map((s) => int.parse(s)).toList();
  int n = line[0]; // Number of cities
  int k = line[1]; // Number of paths  between cities

  var input = Region(n);

  for (var i = 0; i < k; i++) {
    line = stdin.readLineSync().split(' ').map((s) => int.parse(s)).toList();
    // Number of control points `h` between city `a` and city `b`
    int a = line[0];
    int b = line[1];
    int h = line[2];
    input.addPath(a - 1, b - 1, h.toDouble());
  }

  if (args.contains("--DEBUG")) {
    print(input.generateDebugInDotFormat());
    return;
  }

  int q = int.parse(stdin.readLineSync());
  // Queries
  for (var i = 0; i < q; i++) {
    line = stdin.readLineSync().split(' ').map((s) => int.parse(s)).toList();
    int s = line[0]; // Query: from
    int c = line[1]; // Query: to
    var result = input.query(s - 1, c - 1);
    if (result != null) {
      print(result.toResultString());
    } else {
      // No solution
      print("42");
      print("-1");
    }
  }
}

class Region {
  List<City> _cities;

  Region(int numberOfCities) {
    _cities =
        List.generate(numberOfCities, (index) => City(index), growable: false);
  }

  void addPath(int from, int to, double numberOfControls) {
    var cityFrom = _cities[from];
    var cityTo = _cities[to];
    var path = Path(cityFrom, cityTo, numberOfControls);
    cityFrom.paths.insert(path);
    cityTo.paths.insert(path);
  }

  /// Remove old results from all objects here
  void _purge() {
    for (var city in _cities) {
      city.shortestAvailablePath = null;
    }
  }

  /// Execute query from city `from` to city `to`.
  Result query(int from, int to) {
    _purge();

    Log.writeln("Starting query from ${from + 1} to ${to + 1}");
    // Initialize
    List<Result> savedPaths = List<Result>();
    Result currentPath = Result();
    currentPath.cities.add(_cities[from]);

    while (true) {
      if (currentPath.cities.last.id == to) {
        // We have result!
        Log.writeln("Found result with path " + currentPath.toString());
        return currentPath;
      }
      Log.writeln("New beginning: " + currentPath.toString());

      // Select shortest and 2nd shortest path from this city to another unvisited city
      // The shortest one (might) be the one we will go to, in which case the second one will be
      // added to the list of possible routes from current city

    }
  }

  Result _backtrackToShortestPossiblePath(List<Result> results) {
    double min = double.infinity;
    Result res = null;

    for (var result in results) {
      if (result.cities.last.shortestAvailablePath != null &&
          result.cities.last.shortestAvailablePath < min) {
        min = result.cities.last.shortestAvailablePath;
        res = result;
      }
    }

    return res;
  }

  String generateDebugInDotFormat() {
    String s = "graph hlidky {\n";
    for (var city in _cities) {
      s += "$city\n";
    }
    s += "\n\n";
    for (var city in _cities) {
      for (var path in city.paths.toIterable()) {
        if (path.from == city) {
          s +=
              "${path.from} -- ${path.to} [label=${path.distance.toStringAsFixed(0)}]\n";
        }
      }
    }
    s += "}";
    return s;
  }
}

class Path {
  City from;
  City to;

  /// Length, or number of control points
  double distance;

  Path(this.from, this.to, this.distance);

  @override
  String toString() {
    return distance.toStringAsFixed(0);
  }
}

class City {
  int id;
  PairingHeap<Path> paths;

  /// null - City was not visited yet
  ///
  /// \d - length of shortest unvisited path (from this city)
  ///
  /// infinity - city has no more unvisited paths
  double shortestAvailablePath = null;

  City(this.id) {
    paths = PairingHeap<Path>(null, ((a, b) => a.distance < b.distance));
  }

  @override
  String toString() {
    return (id + 1).toString();
  }
}

/// This structure contains cities in path.
/// It is used to easily backtrack to older paths
class Result {
  List<City> cities;
  double currentMaximumPath = double.negativeInfinity;

  Result() {
    cities = List<City>();
  }

  Result.from(Result other) {
    cities = List.from(other.cities);
    currentMaximumPath = other.currentMaximumPath;
  }

  void addNewCityFromPath(Path path) {
    cities.add(path.from == cities.last ? path.to : path.from);
    if (path.distance > currentMaximumPath) {
      Log.writeln(
          "Changed maximum distance from ${currentMaximumPath.toStringAsFixed(0)} to ${path.distance.toStringAsFixed(0)} for $this");
      currentMaximumPath = path.distance;
    }
  }

  @override
  String toString() {
    return cities.join(" -> ");
  }

  String toResultString() {
    String s = cities.map((c) => c.id + 1).join(" ") + "\n";
    s += currentMaximumPath.toStringAsFixed(0);
    return s;
  }
}

class Log {
  static bool enabled = false;

  static void writeln(Object o) {
    if (Log.enabled) {
      stderr.writeln(o);
    }
  }
}

/// # Minimum pairing heap.
/// https://en.wikipedia.org/wiki/Pairing_heap
/// https://brilliant.org/wiki/pairing-heap/
///
/// Find min: `O(1)`
/// Insert: `O(1)`
/// Merge: `O(1)`
/// Remove min: `O(log(n))`
///
/// ## Structure
/// Tree, where all nodes contain
/// pointer to left child and
/// siblings.
class PairingHeap<T> {
  HeapNode root;
  dynamic defaultMergeFunction;

  /// root may be null.
  /// defaultMergeFunction returns `bool` and accepts
  /// two arguments (`T one`, `T other`).
  PairingHeap(
      this.root, bool defaultCompareFunction(dynamic one, dynamic other)) {
    this.defaultMergeFunction = defaultCompareFunction;
  }

  PairingHeap.fromHeap(PairingHeap first, PairingHeap second) {
    this.root = first.root;
    this.root.leftChild = second.root;
    this.defaultMergeFunction = first.defaultMergeFunction;
  }

  /// Return root, it's always the minimum
  HeapNode findMin() {
    return root;
  }

  void insert(T value) {
    this.root = HeapNode.merge(root, new HeapNode(value, defaultMergeFunction));
  }

  /// Find minimum and delete it
  void deleteMin() {
    this.root = _recDelMerge(root.leftChild);
  }

  HeapNode _recDelMerge(HeapNode node) {
    if (node == null || node.nextSibling == null) {
      return node;
    } else {
      HeapNode a, b, newNode;
      a = node;
      b = node.nextSibling;
      newNode = node.nextSibling.nextSibling;

      a.nextSibling = null;
      b.nextSibling = null;

      return HeapNode.merge(HeapNode.merge(a, b), _recDelMerge(newNode));
    }
  }

  /// Generate iterable of node values,
  /// in no particular order.
  Iterable<T> toIterable() sync* {
    if (this.root != null) {
      for (var yieldedValue in root.toIterable()) {
        yield yieldedValue;
      }
    }
  }

  @override
  String toString() {
    return this.toIterable().map((n) => n.toString()).toList().toString();
  }
}

class HeapNode<T> {
  T value;
  HeapNode leftChild;
  HeapNode nextSibling;
  dynamic compareFunction;

  /// Create new heapnode with value of given type T.
  /// Define compareFunction, that returns if `T one` has
  /// higher priority (is lower?) than `T other`.
  HeapNode(this.value, bool compareFunction(dynamic one, dynamic other)) {
    this.compareFunction = compareFunction;
  }

  static HeapNode merge(HeapNode one, HeapNode other) {
    if (one == null) return other;
    if (other == null) return one;
    if (one.compareFunction(one.value, other.value)) {
      one.addChild(other);
      return one;
    } else {
      other.addChild(one);
      return other;
    }
  }

  void addChild(HeapNode other) {
    if (leftChild == null) {
      leftChild = other;
    } else {
      other.nextSibling = leftChild;
      leftChild = other;
    }
  }

  /// Generate list of node values
  Iterable<T> toIterable() sync* {
    yield this.value;
    if (nextSibling != null) {
      for (var yieldedValue in nextSibling.toIterable()) {
        yield yieldedValue;
      }
    }
    if (leftChild != null) {
      for (var yieldedValue in leftChild.toIterable()) {
        yield yieldedValue;
      }
    }
  }

  @override
  String toString() {
    return value.toString();
  }
}
