class Point:
    # int x
    # int y

    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __str__(self):
        return "({0},{1})".format(self.x, self.y)

    def __add__(self, other):
        x = self.x + other.x
        y = self.y + other.y
        return Point(x, y)

    def isInsideTriangle(self, p1, p2, p3):
        d1 = self.onWhichSideIs(p1, p2)
        d2 = self.onWhichSideIs(p2, p3)
        d3 = self.onWhichSideIs(p3, p1)

        hasNegResult = (d1 < 0) or (d2 < 0) or (d3 < 0)
        hasPosResult = (d1 > 0) or (d2 > 0) or (d3 > 0)

        return not(hasNegResult and hasPosResult)

    def onWhichSideIs(self, p1, p2):
        return (self.x - p2.x) * (p1.y - p2.y) - (p1.x - p2.x) * (self.y - p2.y)

    def distanceBetween(self, other):
        return pow(pow(abs(self.x - other.x), 2) + pow(abs(self.y - other.y), 2), 1/2)



nInputs = input()
inputs = []
for i in range(0, int(nInputs)):
    numbers = [int(num) for num in input().split(' ')]
    for j in range(1, len(numbers), 2):
        if len([samePoint for samePoint in inputs if samePoint.x == numbers[j] and samePoint.y == numbers[j + 1]]) == 0:
            inputs.append(Point(numbers[j], numbers[j+1]))

# If there is less then 4 points, we know the answer
if len(inputs) == 0:
    print(0)
    exit()
elif len(inputs) < 4:
    distance = 0
    for i in range(1, len(inputs)):
        distance += inputs[i - 1].distanceBetween(inputs[i])
    print(distance)
    exit()

# First of all, choose the leftmost, rightmost and bottommost point. All points has to be different
leftmost = inputs[0]
for i in range(1, len(inputs)):
    if inputs[i].x < leftmost.x:
        leftmost = inputs[i]
rightmost = Point(-2147483647, 0)
for i in range(0, len(inputs)):
    if inputs[i].x > rightmost.x and inputs[i].x != leftmost.x and inputs[i].y != leftmost.y:
        rightmost = inputs[i]
downmost = Point(0, -2147483647)
for i in range(0, len(inputs)):
    if (inputs[i].y > downmost.y and (inputs[i].x != leftmost.x or inputs[i].y != leftmost.y) and
            (inputs[i].x != rightmost.x or inputs[i].y != leftmost.y)):
        downmost = inputs[i]

# These points now form a triangle and are always in the fingle convex hull
# Remove all points from input that are in the triangle
inputs = [point for point in inputs if not point.isInsideTriangle(leftmost, rightmost, downmost)]
convexHullPoints = [ leftmost, rightmost, downmost] # This is result collection
while len(inputs) != 0:
    # While we still have some points to process
    
    # First step: Find out which point should we add into convex hull.
    # The target point is farthest away from points of the closest side of the polygon we have in [convexHullPoints]
    
    # We'll assign each point to the closest side
    assignments = []  # Structure: [ (index of point), (index of side), (distance between this and closest point of side) ]
    for i in range(1, len(convexHullPoints)):
        pointA = convexHullPoints[i - 1]
        pointB = convexHullPoints[i % len(convexHullPoints)]

        for j in range(0, len(inputs)):
            distance = min(pointA.distanceBetween(inputs[j]), pointB.distanceBetween(inputs[j]))
            if len(assignments) - 1 < j:
                assignments.append([ j, i, distance ])
            else:
                if distance < assignments[j][1]:
                    assignments[j] = [ j, i, distance  ]

    # Each side will take one point farthest away and add it between the points into convex hull
    pointsToInsert = [ ] # Structure: [ (insertAfterIndex, point) ]
    for i in range(1, len(convexHullPoints) + 1):
        pointA = convexHullPoints[i - 1]
        pointB = convexHullPoints[i % len(convexHullPoints)]
        possiblePoints = [inputs[structure[0]] for structure in assignments if structure[1] == i]
        if len(possiblePoints) == 0:
            continue
        chosenPoint = [ possiblePoints[0], -1 ] # Structure: [ (point), (distance) ]
        chosenPoint[1] = min(chosenPoint[0].distanceBetween(pointA), chosenPoint[0].distanceBetween(pointB))
        for j in range(1, len(possiblePoints)):
            point = possiblePoints[j]
            distance = min(point.distanceBetween(pointA), point.distanceBetween(pointB))
            if distance > chosenPoint[1]:
                chosenPoint = [ point, distance ]

        pointsToInsert.append([ i - 1, chosenPoint[0]])

    # Insert these points
    if len(pointsToInsert) == 0:
        break

    offset = 0
    for command in pointsToInsert:
        insertAfterIndex = command[0] + offset
        convexHullPoints = convexHullPoints[:insertAfterIndex] + [command[1]] + convexHullPoints[insertAfterIndex:]
        offset += 1

    # Remove points that are in the convex hull from inputs list
    # For all three-points
    forbiddenPoints = [ ]
    for i in range(2, len(convexHullPoints) + 2):
        pointA = convexHullPoints[i - 2]
        pointB = convexHullPoints[(i - 1) % len(convexHullPoints)]
        pointC = convexHullPoints[i % len(convexHullPoints)]
        for point in inputs:
            if point.isInsideTriangle(pointA, pointB, pointC):
                forbiddenPoints.append(point)

    inputs = [point for point in inputs if point not in forbiddenPoints]


# Compute size of convex hull
result = 0.0
for i in range(1, len(convexHullPoints) + 1):
    pointA = convexHullPoints[i - 1]
    pointB = convexHullPoints[i % len(convexHullPoints)]
    result += pointA.distanceBetween(pointB)

print(result)
