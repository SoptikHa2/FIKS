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
      Path selectedPath = null;
      Path secondSelectedPath = null;
      double minDistance = null;
      double minDistance2 = null;

      // Choose shortest path
      while (selectedPath == null) {
        selectedPath = currentPath.cities.last.paths.findMin().value;
        if (selectedPath == null) {
          break;
        }
        var cityOnTheOtherEndOfThisPath =
            selectedPath.from == currentPath.cities.last
                ? selectedPath.to
                : selectedPath.from;
        if (cityOnTheOtherEndOfThisPath.shortestAvailablePath != null) {
          selectedPath = null;
          currentPath.cities.last.paths.deleteMin();
        }
      }
      if (selectedPath != null) {
        minDistance = selectedPath.distance;
        currentPath.cities.last.paths.deleteMin();
        // And choose second shortest path
        while(secondSelectedPath == null){
          
        }
      }

      if (selectedPath == null) {
        Log.writeln("No path from last city on path " + currentPath.toString());
        // No path
        // Return to another city, if exists and
        // discard this path
        currentPath.cities.last.shortestAvailablePath = double.infinity;
        currentPath = _backtrackToShortestPossiblePath(savedPaths);
        if (currentPath == null) {
          // No solution exists
          return null;
        }
        continue;
      }

      // Get shortest available distance of any available paths
      var shortestPath = _backtrackToShortestPossiblePath(savedPaths);
      if (shortestPath == null ||
          shortestPath.cities.last.shortestAvailablePath >=
              selectedPath.distance) {
        // Let's use this path
        if (secondSelectedPath != null) {
          // Mark that there are another routes from this city
          savedPaths.add(Result.from(currentPath));
          currentPath.cities.last.shortestAvailablePath = minDistance2;
        } else {
          currentPath.cities.last.shortestAvailablePath = double.infinity;
        }

        // Go!
        currentPath.addNewCityFromPath(selectedPath);
        Log.writeln("Added new city");
        continue;
      } else {
        // Jump to another city
        savedPaths.add(currentPath);
        currentPath.cities.last.shortestAvailablePath = minDistance;
        currentPath = shortestPath;
        Log.writeln("Jumped to new path: $currentPath");
      }
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
}

class City {
  int id;
  PairingMinHeap<Path> paths;

  /// null - City was not visited yet
  ///
  /// \d - length of shortest unvisited path (from this city)
  ///
  /// infinity - city has no more unvisited paths
  double shortestAvailablePath = null;

  City(this.id) {
    paths = PairingMinHeap<Path>(null, ((a, b) => a.distance < b.distance));
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
class PairingMinHeap<T> {
  HeapNode root;
  dynamic defaultMergeFunction;

  /// root may be null.
  /// defaultMergeFunction returns `bool` and accepts
  /// two arguments (`T one`, `T other`).
  PairingMinHeap(this.root, bool defaultMergeFunction(T one, T other)) {
    this.defaultMergeFunction = defaultMergeFunction;
  }

  PairingMinHeap.fromHeap(PairingMinHeap first, PairingMinHeap second) {
    this.root = first.root;
    this.root.leftChild = second.root;
    this.defaultMergeFunction = first.defaultMergeFunction;
  }

  /// Return root, it's always the minimum
  HeapNode findMin() {
    return root;
  }

  /// Remove root, then merge all subheaps
  void deleteMin() {
    if (root == null) return;
    if (root.leftChild == null) {
      root = root.leftChild;
      return;
    }

    // Subheaps: root's left child and all left child's siblings
    var subheaps = [root.leftChild]..addAll(root.leftChild.siblings);
    this.root =
        subheaps.reduce((first, second) => PairingMinHeap.merge(first, second));
  }

  /// Merge the node with rest of the heap
  void insert(T value) {
    this.root = merge(this.root, HeapNode(value, defaultMergeFunction));
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

  /// Merge two heaps
  static HeapNode merge(HeapNode first, HeapNode second) {
    if (first == null) return second;
    if (second == null) return first;
    if (first.compareFunction(first.value, second.value)) {
      if (first.leftChild == null) {
        first.leftChild = second;
      } else {
        first.leftChild.siblings.add(second);
      }
      return first;
    } else {
      if (second.leftChild == null) {
        second.leftChild = first;
      } else {
        second.leftChild.siblings.add(first);
      }
      return second;
    }
  }
}

class HeapNode<T> {
  T value;
  HeapNode leftChild;
  List<HeapNode> siblings;
  dynamic compareFunction;

  /// Create new heapnode with value of given type T.
  /// Define compareFunction, that returns if `T one` has
  /// higher priority (is lower?) than `T other`.
  HeapNode(this.value, bool compareFunction(T one, T other)) {
    this.siblings = List<HeapNode>();
    this.compareFunction = compareFunction;
  }

  /// Generate list of node values
  Iterable<T> toIterable() sync* {
    yield this.value;
    for (var sibling in siblings) {
      yield sibling.value;
    }
    if (leftChild != null) {
      for (var yieldedValue in leftChild.toIterable()) {
        yield yieldedValue;
      }
    }
  }
}
