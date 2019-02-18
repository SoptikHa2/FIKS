import 'dart:io';

main(List<String> args) {
  if (args.contains("-v")) {
    Log.enabled = true;
  }

  // Input
  var line = stdin.readLineSync().split(' ').map((s) => int.parse(s)).toList();
  int n = line[0]; // Pocet mest
  int k = line[1]; // Pocet cest

  var input = Region(n);

  for (var i = 0; i < k; i++) {
    line = stdin.readLineSync().split(' ').map((s) => int.parse(s)).toList();
    // Pocet hlidek `h` mezi mesty `a` a `b`
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
        currentPath =
            _getResultWhereLastCityHasSmallestAvailableDistancePath(savedPaths);
        if (currentPath == null) {
          // No solution exists
          return null;
        }
        continue;
      }

      // Get shortest available distance of any available paths
      var shortestPath =
          _getResultWhereLastCityHasSmallestAvailableDistancePath(savedPaths);
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

  Result _getResultWhereLastCityHasSmallestAvailableDistancePath(
      List<Result> results) {
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

  /// Distance, or number of controls
  double distance;

  Path(this.from, this.to, this.distance);
}

class City {
  int id;
  List<Path> paths;

  /// null - City was not visited yet
  ///
  /// \d - length shortest unvisited path (from this city)
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

/// Result path
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
