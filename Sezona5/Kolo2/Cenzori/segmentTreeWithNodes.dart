library segmentTree;

import 'dart:math';

class SegmentTree {
  Node rootNode;
  List<int> input;
  dynamic mergeFunction;

  SegmentTree(this.input, int this.mergeFunction(int a, int b)) {
    _build();
  }
  SegmentTree.min(this.input) {
    this.mergeFunction =
        ((a, b) => a == null ? b : (b == null ? a : (a < b ? a : b)));
    _build();
  }
  SegmentTree.max(this.input) {
    this.mergeFunction =
        ((a, b) => a == null ? b : (b == null ? a : (a > b ? a : b)));
    _build();
  }
  SegmentTree.sum(this.input) {
    this.mergeFunction = ((a, b) => a == null ? b : (b == null ? a : (a + b)));
    _build();
  }

  void _build() {
    rootNode = Node(0, input.length - 1, mergeFunction);
    rootNode.build(mergeFunction);
    for (var i = 0; i < input.length; i++) {
      if (input[i] != 0) rootNode.setUpdateLazy(input[i], i, i);
    }
  }

  String getDescriptionInDOT() =>
      rootNode.generateStringRepresentationOfSubtreeInDOT();

  void addOnIntervalLazy(int intervalFrom, int intervalTo, int delta) =>
      rootNode.addUpdateLazy(delta, intervalFrom, intervalTo);

  void setOnIntervalLazy(int intervalFrom, int intervalTo, int value) =>
      rootNode.setUpdateLazy(value, intervalFrom, intervalTo);

  int queryOnInterval(int intervalFrom, int intervalTo) =>
      rootNode.query(intervalFrom, intervalTo);
}

class Node {
  Node leftChild = null;
  Node rightChild = null;
  Node parent = null;
  int value = 0;
  int addLazyUpdate = null;
  int setLazyUpdate = null;
  int currentIntervalStart;
  int currentIntervalEnd;
  dynamic mergeFunction;
  // If any of the children are lazy-changed, we mark this,
  // so when lazy propagation happens, it doesn't ignore this node.
  bool requireAddLazyUpdate = false;
  bool requireSetLazyUpdate = false;

  Node(this.currentIntervalStart, this.currentIntervalEnd, this.mergeFunction);

  /// Create new nodes, build the whole tree
  void build(dynamic mergeFunction) {
    if (currentIntervalStart == currentIntervalEnd) {
      // This is a leaf node
      this.value = 0;
      return;
    }

    int intervalMid = (currentIntervalStart + currentIntervalEnd) ~/ 2;
    this.leftChild = Node(currentIntervalStart, intervalMid, mergeFunction);
    this.leftChild.parent = this;
    this.leftChild.build(mergeFunction);
    // Maybe we should have only one child
    if (intervalMid + 1 > currentIntervalEnd) {
      return;
    }
    this.rightChild = Node(intervalMid + 1, currentIntervalEnd, mergeFunction);
    this.rightChild.parent = this;
    this.rightChild.build(mergeFunction);
  }

  /// Add lazy update (addition) from `intervalFrom`, to `intervalTo`.
  /// You can later push the update with `propagateLaziness`.
  void addUpdateLazy(int delta, int intervalFrom, int intervalTo, [bool forceUpdateAdd = false]) {
    if ((currentIntervalStart >= intervalFrom &&
        currentIntervalEnd <= intervalTo) || forceUpdateAdd) {
      // Perfect match
      if (currentIntervalStart == currentIntervalEnd) {
        // Leaf node, no need to add laziness
        this.value += delta;
      } else {
        this.requireAddLazyUpdate = true;
        if (this.addLazyUpdate == null) {
          this.addLazyUpdate = delta;
        } else {
          this.addLazyUpdate += delta;
        }
      }
      return;
    } else if (currentIntervalStart > intervalTo ||
        currentIntervalEnd < intervalFrom) {
      // No match
      return;
    } else {
      this.requireAddLazyUpdate = true;
      // Partial match - propagate to children
      if (leftChild != null)
        leftChild.addUpdateLazy(delta, intervalFrom, intervalTo);
      if (rightChild != null)
        rightChild.addUpdateLazy(delta, intervalFrom, intervalTo);
    }
  }

  /// Add lazy update (set) from `intervalFrom`, to `intervalTo`.
  /// You can later push the update with `propagateLaziness`.
  void setUpdateLazy(int value, int intervalFrom, int intervalTo,
      [bool forceUpdateSet = false]) {
    if ((currentIntervalStart >= intervalFrom &&
            currentIntervalEnd <= intervalTo) ||
        forceUpdateSet) {
      // Perfect match

      // Propagate laziness
      if (setLazyUpdate != null) {
        propagateLaziness(this.currentIntervalStart, this.currentIntervalEnd);
      }

      if (currentIntervalStart == currentIntervalEnd) {
        // Leaf node, no need to add laziness
        this.value = value;
      } else {
        this.requireSetLazyUpdate = true;
        this.setLazyUpdate = value;
        this.addLazyUpdate = null;
      }
      return;
    } else if (currentIntervalStart > intervalTo ||
        currentIntervalEnd < intervalFrom) {
      // No match
      return;
    } else {
      // Propagate laziness
      if (setLazyUpdate != null) {
        propagateLaziness(this.currentIntervalStart, this.currentIntervalEnd);
      }

      this.requireSetLazyUpdate = true;
      // Partial match - propagate to children
      if (leftChild != null)
        leftChild.setUpdateLazy(value, intervalFrom, intervalTo);
      if (rightChild != null)
        rightChild.setUpdateLazy(value, intervalFrom, intervalTo);
    }
  }

  /// Propagate all laziness on interval. Nodes not on the interval will not be deep-propagated.
  void propagateLaziness(int intervalFrom, int intervalTo) {
    // if (currentIntervalStart > intervalTo ||
    //     currentIntervalEnd < intervalFrom) {
    //   // No match
    //   return;
    // } else {
    if (currentIntervalStart == currentIntervalEnd) {
      // This is a leaf node
      if (setLazyUpdate != null) {
        this.value = setLazyUpdate;
      }
      if (addLazyUpdate != null) {
        this.value += addLazyUpdate;
      }
      this.setLazyUpdate = null;
      this.addLazyUpdate = null;
      this.requireAddLazyUpdate = false;
      this.requireSetLazyUpdate = false;
      return;
    } else {
      // This is not a leaf node, propagate laziness to children and update self value
      if (requireSetLazyUpdate) {
        if (setLazyUpdate != null) {
          if (leftChild != null) {
            leftChild.setUpdateLazy(
                setLazyUpdate, intervalFrom, intervalTo, true);
          }
          if (rightChild != null) {
            rightChild.setUpdateLazy(
                setLazyUpdate, intervalFrom, intervalTo, true);
          }
        }
      }
      if (requireAddLazyUpdate) {
        if (addLazyUpdate != null) {
          if (leftChild != null) {
            leftChild.addUpdateLazy(
                addLazyUpdate, intervalFrom, intervalTo, true);
          }
          if (rightChild != null) {
            if (addLazyUpdate != null)
              rightChild.addUpdateLazy(
                  addLazyUpdate, intervalFrom, intervalTo, true);
          }
        }
      }
      if (currentIntervalStart <= intervalTo &&
          currentIntervalEnd >= intervalFrom) {
        // If this node is completely out of range, deep-propagate
        // it's children
        if (leftChild != null) {
          leftChild.propagateLaziness(intervalFrom, intervalTo);
        }
        if (rightChild != null) {
          rightChild.propagateLaziness(intervalFrom, intervalTo);
        }
      }
    }

    setLazyUpdate = null;
    addLazyUpdate = null;
    requireAddLazyUpdate = false;
    requireSetLazyUpdate = false;
    this.value = mergeFunction(leftChild?.value, rightChild?.value);
  }

  /// Query on selected interval, propagate laziness if needed
  int query(int intervalFrom, int intervalTo) {
    if (this.currentIntervalStart >= intervalFrom &&
        this.currentIntervalEnd <= intervalTo) {
      // Total match
      if (this.requireAddLazyUpdate || this.requireSetLazyUpdate) {
        this.propagateLaziness(intervalFrom, intervalTo);
      }
      return this.value;
    } else if (this.currentIntervalStart > intervalTo ||
        this.currentIntervalEnd < intervalFrom) {
      // No match
      return null;
    } else {
      // Partial match
      if (this.requireAddLazyUpdate || this.requireSetLazyUpdate) {
        this.propagateLaziness(intervalFrom, intervalTo);
      }
      return mergeFunction(leftChild?.query(intervalFrom, intervalTo),
          rightChild?.query(intervalFrom, intervalTo));
    }
  }

  // ############################################## //
  // #              DEBUG DRAW                    # //
  // ############################################## //
  String generateStringRepresentationOfSubtreeInDOT() {
    var nodeHashesAndLabels =
        _generateStringRepresentationOfSubtreeInDOT_getHashesAndLabels();

    String result = "digraph segmentTree {\n";
    for (var key in nodeHashesAndLabels.keys) {
      result += "key$key [label=\"${nodeHashesAndLabels[key]}\"]\n";
    }
    result += "\n";
    result +=
        this._generateStringRepresentationOfSubtreeInDOT_getDigraphLines();

    result += "}";

    return result;
  }

  Map<int, String>
      _generateStringRepresentationOfSubtreeInDOT_getHashesAndLabels() {
    var nodeHashesAndLabels = Map<int, String>();
    nodeHashesAndLabels[this.hashCode] = this.value.toString() +
        " ($currentIntervalStart - $currentIntervalEnd) (+$addLazyUpdate =$setLazyUpdate)";
    if (leftChild != null) {
      nodeHashesAndLabels.addAll(leftChild
          ._generateStringRepresentationOfSubtreeInDOT_getHashesAndLabels());
    }
    if (rightChild != null) {
      nodeHashesAndLabels.addAll(rightChild
          ._generateStringRepresentationOfSubtreeInDOT_getHashesAndLabels());
    }
    return nodeHashesAndLabels;
  }

  String _generateStringRepresentationOfSubtreeInDOT_getDigraphLines() {
    String s = "";
    if (leftChild != null) {
      s += "key${this.hashCode} -> key${leftChild.hashCode}\n";
      s += leftChild
          ._generateStringRepresentationOfSubtreeInDOT_getDigraphLines();
    }
    if (rightChild != null) {
      s += "key${this.hashCode} -> key${rightChild.hashCode}\n";
      s += rightChild
          ._generateStringRepresentationOfSubtreeInDOT_getDigraphLines();
    }
    return s;
  }
}
