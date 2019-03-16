import 'dart:collection';
import 'dart:io';

main(List<String> args) {
  int n = int.parse(stdin.readLineSync());

  for (int i = 0; i < n; i++) {
    stdin.readLineSync();
    int numberOfCities = int.parse(stdin.readLineSync().split(' ')[0]);
    HashSet<int> forbiddenCities = HashSet.from(
        stdin.readLineSync().trim().split(' ').map((s) => int.parse(s)));
    List<List<Connection>> cityPaths = List(numberOfCities);
    for (int j = 0; j < numberOfCities; j++) {
      var stringPaths = stdin.readLineSync().split(' ');
      int m = int.parse(stringPaths[0]);
      var list = List<Connection>();
      for (int k = 0; k < m; k++) {
        int number = int.parse(stringPaths[k + 1]);
        list.add(Connection(j, number, k + 1));
      }
      cityPaths[j] = list;
    }

    // Input loaded
    var network = Network(numberOfCities, forbiddenCities, cityPaths);
    print(network.solve());
  }
}

class Network {
  int numberOfCities;
  HashSet<int> forbiddenCities;
  HashSet<int> processedCities;
  List<List<Connection>> connections;

  Network(this.numberOfCities, this.forbiddenCities, this.connections) {
    this.processedCities = HashSet();
  }

  int solve() {
    var connectionQueue =
        PairingHeap(null, (c1, c2) => c1.priority < c2.priority);
    var maximumPriority = -1;
    int currentPriority = 1;

    // Process city 0
    {
      var city0Connections = this.connections[0];
      for (var connection in city0Connections) {
        connectionQueue.insert(connection);
      }
      processedCities.add(0);
    }

    // Process the rest
    while (!connectionQueue.empty()) {
      Connection connectionToCurrentCity = connectionQueue.findMin().value;
      connectionQueue.deleteMin();

      if(currentPriority < connectionToCurrentCity.priority){
        currentPriority =connectionToCurrentCity.priority;
      }

      if (processedCities.contains(connectionToCurrentCity.cityTo)) continue;

      if (this.forbiddenCities.contains(connectionToCurrentCity.cityTo)) {
        int myMax = currentPriority - 1;
        if (myMax < maximumPriority || maximumPriority == -1) {
          maximumPriority = myMax;
        }
        continue;
      }

      processedCities.add(connectionToCurrentCity.cityTo);

      // Go to other cities
      var thisCityConnections =
          this.connections[connectionToCurrentCity.cityTo];
      for (var connection in thisCityConnections) {
        if (!processedCities.contains(connection.cityTo)) {
          connectionQueue.insert(connection);
        }
      }
    }

    return maximumPriority;
  }
}

class Connection {
  int cityFrom, cityTo, priority;

  Connection(this.cityFrom, this.cityTo, this.priority);
}

/// # Pairing heap.
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
  int _count = 0;
  bool empty() => _count == 0;

  /// root may be null.
  /// defaultMergeFunction returns `bool` and accepts
  /// two arguments (`T one`, `T other`). It returns true
  /// if the first argument (`T one`) has priority over `T other`.
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
    _count++;
  }

  /// Find minimum and delete it
  void deleteMin() {
    this.root = _recDelMerge(root.leftChild);
    _count--;
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
  /// Define compareFunction, that returns true if `T one` has
  /// higher priority than `T other`.
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
