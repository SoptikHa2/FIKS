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
    cityFrom.paths.add(path);
    cityTo.paths.add(path);
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
      double minDistance = double.infinity;
      double minDistance2 = double.infinity;
      Path selectedPath = null;
      Path secondSelectedPath = null;

      for (var path in currentPath.cities.last.paths) {
        var anotherCity =
            path.from == currentPath.cities.last ? path.to : path.from;
        if (anotherCity.shortestAvailablePath == null) {
          if (path.distance < minDistance) {
            if (minDistance < minDistance2) {
              minDistance2 = minDistance;
              secondSelectedPath = selectedPath;
            }
            minDistance = path.distance;
            selectedPath = path;
          } else {
            if (path.distance < minDistance2) {
              minDistance2 = path.distance;
              secondSelectedPath = path;
            }
          }
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
      for (var path in city.paths) {
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
  List<Path> paths;

  /// null - City was not visited yet
  ///
  /// \d - length of shortest unvisited path (from this city)
  ///
  /// infinity - city has no more unvisited paths
  double shortestAvailablePath = null;

  City(this.id) {
    paths = List<Path>();
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
class PairingMinHeap {
  HeapNode root;

  PairingMinHeap(this.root);

  PairingMinHeap.fromHeap(PairingMinHeap first, PairingMinHeap second) {
    this.root = first.root;
    this.root.leftChild = second.root;
  }

  /// Return root, it's always the minimum
  HeapNode findMin() {
    return root;
  }

  /// Remove root, then merge all subheaps
  void deleteMin() {
    // Subheaps: root's left child and all left child's siblings
    var subheaps = [root.leftChild]..addAll(root.leftChild.siblings);
    this.root =
        subheaps.reduce((first, second) => PairingMinHeap.merge(first, second));
  }

  /// Merge the node with rest of the heap
  void insert(double value) {
    this.root = merge(this.root, HeapNode(value));
  }

  /// Merge two heaps
  static HeapNode merge(HeapNode first, HeapNode second) {
    if (first == null) return second;
    if (second == null) return first;
    if (first.value < second.value) {
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

class HeapNode {
  double value;
  HeapNode leftChild;
  List<HeapNode> siblings;

  HeapNode(this.value) {
    this.siblings = List<HeapNode>();
  }
}
