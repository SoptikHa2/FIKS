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

  //if (args.contains("--DEBUG")) {
  //print(input.generateDebugInDotFormat());
  //return;
  //}

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
  // All paths that can be went to
  PairingHeap<Path> pathsThatAreAvailableToBacktrack;

  List<City> cities;

  Region(int numberOfCities) {
    this.pathsThatAreAvailableToBacktrack =
        PairingHeap<Path>(null, ((p1, p2) => p1.distance < p2.distance));
    this.cities = List<City>(numberOfCities);
  }

  void addPath(int cityFrom, int cityTo, double distance) {
    var path = Path();
    path.firstCity = cities[cityFrom];
    path.secondCity = cities[cityTo];
    path.distance = distance;
    cities[cityFrom].paths.add(path);
    cities[cityTo].paths.add(path);
  }

  Result query(int cityFrom, int cityTo) {
    _tidyEverything();

    // Init
    var sourceCity = cities[cityFrom];
    var targetCity = cities[cityTo];

    // Add paths from source city to list of paths that can be used
    Result currentPath = Result(sourceCity);
    _addCurrentPathsToAvailablePaths(currentPath);

    while (true) {
      if (currentPath.passedCities.last == targetCity) {
        // Solution!
        return currentPath;
      } else {
        var bestPathToFollow = popBestPathToFollow();
        if (bestPathToFollow == null) {
          // No solution
          return null;
        }
        currentPath = bestPathToFollow.associatedBacktrack;

        // Let's follow the path
        currentPath.goToNextCity(bestPathToFollow);
        // Add paths from this new city to list of possible routes
        _addCurrentPathsToAvailablePaths(currentPath);
      }
    }
  }

  /// Pop path from pathsThatAreAvailableToBacktrack,
  /// while throwing away invalid paths
  Path popBestPathToFollow() {
    Path selectedPath = null;
    while (selectedPath != null) {
      selectedPath = pathsThatAreAvailableToBacktrack.findMin().value;
      if (selectedPath == null) {
        // No path available
        break;
      }

      var city = selectedPath.isDestinationFirstCity
          ? selectedPath.firstCity
          : selectedPath.secondCity;
      if (city.visited) {
        // Invalid path
        pathsThatAreAvailableToBacktrack.deleteMin();
        selectedPath = null;
      }
    }

    if (selectedPath != null) {
      // Pop
      pathsThatAreAvailableToBacktrack.deleteMin();
    }

    return selectedPath;
  }

  void _addCurrentPathsToAvailablePaths(Result currentResult) {
    var currentCity = currentResult.passedCities.last;
    for (var path in currentCity.paths) {
      if (path.associatedBacktrack != null) {
        continue;
      }
      path.isDestinationFirstCity = path.firstCity != currentCity;
      path.associatedBacktrack = currentResult;
      pathsThatAreAvailableToBacktrack.insert(path);
    }
  }

  /// This needs to be runned before running every query, so we clean all the changes after last one
  void _tidyEverything() {
    pathsThatAreAvailableToBacktrack =
        PairingHeap<Path>(null, ((p1, p2) => p1.distance < p2.distance));
    for (var city in cities) {
      city.visited = false;
    }
  }
}

class Path {
  City firstCity;
  City secondCity;
  Result associatedBacktrack;
  double distance;

  /// If this is true, `firstCity` is the target destination.
  bool isDestinationFirstCity;
}

class City {
  int id;
  bool visited;
  List<Path> paths;

  City() {
    paths = List<Path>();
  }
}

class Result {
  List<City> passedCities;
  double maximumPathLength;

  Result(City sourceCity) {
    this.passedCities = [sourceCity];
  }

  Result.from(Result otherResult) {
    this.maximumPathLength = otherResult.maximumPathLength;
    this.passedCities = List.from(otherResult.passedCities);
  }

  goToNextCity(Path usedPath) {
    var otherCity = usedPath.isDestinationFirstCity
        ? usedPath.firstCity
        : usedPath.secondCity;
    this.passedCities.add(otherCity);
    otherCity.visited = true;
    if (maximumPathLength < usedPath.distance) {
      maximumPathLength = usedPath.distance;
    }
  }

  String toResultString() {
    String s = passedCities.map((c) => c.id + 1).join(" ") + "\n";
    s += maximumPathLength.toStringAsFixed(0);
    return s;
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
  HeapNode<T> root;
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
  HeapNode<T> findMin() {
    return root;
  }

  void insert(T value) {
    this.root =
        HeapNode.merge(root, new HeapNode<T>(value, defaultMergeFunction));
  }

  /// Find minimum and delete it
  void deleteMin() {
    this.root = _recDelMerge(root.leftChild);
  }

  HeapNode<T> _recDelMerge(HeapNode<T> node) {
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

class Log {
  static bool enabled = false;

  static void writeln(Object o) {
    if (Log.enabled) {
      stderr.writeln(o);
    }
  }
}
