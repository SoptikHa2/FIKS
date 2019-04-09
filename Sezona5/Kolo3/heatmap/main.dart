import 'dart:collection';
import 'dart:io';

main(List<String> args) {
  var line =
      stdin.readLineSync().trim().split(' ').map((s) => int.parse(s)).toList();
  int s = line[0]; // City group
  int w = line[1]; // City width
  int h = line[2]; // City height
  int p = line[3]; // Number of obstacles
  int c = line[4]; // Number of queries

  var heatmap = Heatmap(s, w, h);
  for (var i = 0; i < p; i++) {
    line = stdin
        .readLineSync()
        .trim()
        .split(' ')
        .map((s) => int.parse(s))
        .toList();
    heatmap.addObstacle(line[0], line[1]);
  }
  // heatmap.preprocess();
  for (var i = 0; i < c; i++) {
    line = stdin
        .readLineSync()
        .trim()
        .split(' ')
        .map((s) => int.parse(s))
        .toList();
    heatmap.query(line[0], line[1], line[2], line[3]);
  }
  print(heatmap.toPPM());
}

class Heatmap {
  int s, w, h;

  /// Map that contains obstacles and resulting heatmap
  List<int> map;

  /// Map that contains obstacles and temporary data needed for floodfill
  List<int> _floodFillMap;
  int ymax = 1;
  Heatmap(this.s, this.w, this.h) {
    map = List<int>.filled(w * h, 0);
    _floodFillMap = List<int>.filled(w * h, 0);
  }

  int mapGet(int x, int y) {
    return map[x + w * y];
  }

  void mapSet(int x, int y, int value) {
    map[x + w * y] = value;
  }

  int _floodfillGet(int x, int y) {
    if (x < 0 || y < 0 || x >= w || y >= h) {
      return -100;
    }
    return _floodFillMap[x + w * y];
  }

  void _floodfillSet(int x, int y, int value) {
    _floodFillMap[x + w * y] = value;
  }

  void addObstacle(int x, int y) {
    mapSet(x, y, -1);
    _floodfillSet(x, y, -1);
  }

  void preprocess() {
    throw UnimplementedError();
  }

  void query(int x1, int y1, int x2, int y2) {
    // Find all shortest paths with BFS floodfill
    // Start from end, and go to start

    if (_floodfillGet(x1, y1) == -1 || _floodfillGet(x2, y2) == -1) {
      // Very funny
      return;
    }

    var pointsToDo = Queue<Point>();
    pointsToDo.add(Point(x2, y2));
    _floodfillSet(x2, y2, 1);

    int limit = -1;
    while (pointsToDo.isNotEmpty) {
      var p = pointsToDo.removeFirst();
      for (int dx = -1; dx <= 1; dx++) {
        for (int dy = -1; dy <= 1; dy++) {
          int rx = p.x + dx;
          int ry = p.y + dy;
          // If we are out of the map or there is a wall, ignore this
          if ((dx != 0 && dy != 0) || _floodfillGet(rx, ry) < 0) {
            continue;
          }
          int basePointValue = _floodfillGet(p.x, p.y);
          int currPointValue = _floodfillGet(rx, ry);
          // If the target tile is unoccupied (0) or it's value is higher (which should not happen)...
          if (currPointValue == 0 || currPointValue > basePointValue) {
            // Occupy the value
            _floodfillSet(rx, ry, basePointValue + 1);
            // If we are at the end, set upper limit to the number (so we don't continue trying to find longer way)
            if (rx == x1 && ry == y1) {
              limit = basePointValue + 1;
            } else {
              // If didn't find the goal and we're within limit, mark the target tile for next BFS iteration
              if (basePointValue + 1 <= limit || limit == -1)
                pointsToDo.add(Point(rx, ry));
            }
          }
        }
      }
    }

    // If the path does not exist, skip the coloring phase
    if (_floodfillGet(x1, y1) != 0) {
      // Start from the start (which has highest number) and go to lowest possible number.
      // If there are multiple possible numbers, decide depending on city group
      Point currentPoint = Point(x1, y1);
      while (true) {
        int currentVal = _floodfillGet(currentPoint.x, currentPoint.y);

        // Increment this tile
        mapSet(currentPoint.x, currentPoint.y,
            mapGet(currentPoint.x, currentPoint.y) + 1);
        ymax = max(ymax, mapGet(currentPoint.x, currentPoint.y));

        if (currentVal == 1) {
          break;
        }

        // Go somewhere else
        bool north = _floodfillGet(currentPoint.x, currentPoint.y - 1) > -1 &&
            _floodfillGet(currentPoint.x, currentPoint.y - 1) < currentVal;
        bool south = _floodfillGet(currentPoint.x, currentPoint.y + 1) > -1 &&
            _floodfillGet(currentPoint.x, currentPoint.y + 1) < currentVal;
        bool west = _floodfillGet(currentPoint.x - 1, currentPoint.y) > -1 &&
            _floodfillGet(currentPoint.x - 1, currentPoint.y) < currentVal;
        bool east = _floodfillGet(currentPoint.x + 1, currentPoint.y) > -1 &&
            _floodfillGet(currentPoint.x + 1, currentPoint.y) < currentVal;

        // Decide where to go next
        switch (s) {
          case 1:
            if (north) {
              currentPoint = Point(currentPoint.x, currentPoint.y - 1);
              continue;
            }
            if (south) {
              currentPoint = Point(currentPoint.x, currentPoint.y + 1);
              continue;
            }
            if (west) {
              currentPoint = Point(currentPoint.x - 1, currentPoint.y);
              continue;
            }
            if (east) {
              currentPoint = Point(currentPoint.x + 1, currentPoint.y);
              continue;
            }
            break;
          case 2:
            if (east) {
              currentPoint = Point(currentPoint.x + 1, currentPoint.y);
              continue;
            }
            if (west) {
              currentPoint = Point(currentPoint.x - 1, currentPoint.y);
              continue;
            }
            if (south) {
              currentPoint = Point(currentPoint.x, currentPoint.y + 1);
              continue;
            }
            if (north) {
              currentPoint = Point(currentPoint.x, currentPoint.y - 1);
              continue;
            }
            break;
          case 3:
            if (west) {
              currentPoint = Point(currentPoint.x - 1, currentPoint.y);
              continue;
            }
            if (north) {
              currentPoint = Point(currentPoint.x, currentPoint.y - 1);
              continue;
            }
            if (south) {
              currentPoint = Point(currentPoint.x, currentPoint.y + 1);
              continue;
            }
            if (east) {
              currentPoint = Point(currentPoint.x + 1, currentPoint.y);
              continue;
            }
            break;
          case 4:
            if (south) {
              currentPoint = Point(currentPoint.x, currentPoint.y + 1);
              continue;
            }
            if (east) {
              currentPoint = Point(currentPoint.x + 1, currentPoint.y);
              continue;
            }
            if (north) {
              currentPoint = Point(currentPoint.x, currentPoint.y - 1);
              continue;
            }
            if (west) {
              currentPoint = Point(currentPoint.x - 1, currentPoint.y);
              continue;
            }
            break;
        }

        // This should never happen
        break;
      }
    }

    // Clear floodfill map
    for (var i = 0; i < w; i++) {
      for (var j = 0; j < h; j++) {
        if (_floodfillGet(i, j) > -1) _floodfillSet(i, j, 0);
      }
    }
  }

  String toPPM() {
    var retValue = "P3\n$w $h\n255\n";
    for (var j = 0; j < h; j++) {
      for (var i = 0; i < w; i++) {
        if (mapGet(i, j) == -1) {
          retValue += "255 0 0 ";
        } else {
          int x = (255 * mapGet(i, j) / ymax).ceil();
          retValue += "0 $x 0 ";
        }
      }
      retValue += "\n";
    }
    return retValue;
  }
}

class Point {
  int x, y;
  Point(this.x, this.y);
}

num max(num a, num b) => a > b ? a : b;