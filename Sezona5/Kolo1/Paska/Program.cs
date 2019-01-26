using System;
using System.Collections.Generic;
using System.Linq;
using System.Transactions;

namespace Paska
{
    class Program
    {
        static void Main(string[] args)
        {
            Run();
        }
        
        public static double Run()
        {
            /*
             * SOLVING CONVEX HULL
             *
             * 1. If we have <= 3 points - nothing to worry about
             * 2. Select 3 points (extreme points, that are guaranteed to be                                            
             *    in the convex hull - for example leftmost, rightmost and topmost
             * 3. eliminate all points from input if they are in triangle (from 3 extreme points)                       
             * 4. While not-eliminated points from input exists:                                                        
             *     i.      for each "side" (two points) from final convex hull, find points from input                  
             *                 that are closest to exactly this side
             *     ii.     for each "side", select exactly one point (from step i.) that is farthest away               
             *     iii.    add the point between the side from step ii.                                                 
             *     iv.     for each "triangle" (three points) from final convex hull, eliminate points from input       
             *                 that are in any of these triangles
             */
            
            /* * * * * * * */
            /* LOAD  INPUT */
            /* * * * * * * */
            int numberOfInputs = int.Parse(Console.ReadLine());
            var points = new List<Point>();
            for (int i = 0; i < numberOfInputs; i++)
            {
                string line = Console.ReadLine();
                var numbers = line.Split(' ').Skip(1).Select(chr => int.Parse(chr)).ToArray();
                for (int j = 0; j < numbers.Length; j += 2)
                {
                    int x = numbers[j];
                    int y = numbers[j + 1];
                    if (points.Any(kvp => kvp.x == x && kvp.y == y))
                        continue;
                    points.Add(new Point(x, y));
                    
                }
            }

            if (points.Count == 1)
            {
                Console.WriteLine("0.00");
                return 0;
            }
            else if (points.Count <= 3)
            {
                double distance = 0d;
                for (int i = 1; i < points.Count; i++)
                {
                    distance += points[i - 1].DistanceTo(points[i]);
                }
                Console.WriteLine(Math.Round(distance, 2));
                return distance;
            }
            
            
            /* * * * * * * * * * * * * */
            /* SELECT 3 EXTREME POINTS */
            /* * * * * * * * * * * * * */
            Point leftmost = new Point(int.MaxValue, 0);
            foreach (var point in points)
            {
                if (point.x < leftmost.x)
                    leftmost = point;
            }
            Point rightmost = new Point(int.MinValue, 0);
            foreach (var point in points)
            {
                if ((point.x != leftmost.x || point.y != leftmost.y) && point.x > rightmost.x)
                    rightmost = point;
            }
            Point topmost = new Point(0, int.MaxValue);
            foreach (var point in points)
            {
                if ((point.x != leftmost.x || point.y != leftmost.y) &&
                    (point.x != rightmost.x || point.y != rightmost.y) &&
                    point.y < topmost.y)
                    topmost = point;
            }
            
            
            /* * * * * * * * * * * * * * * * * * * * */
            /* ELIMINATE ALL POINTS INSIDE TRIANGLE  */
            /* * * * * * * * * * * * * * * * * * * * */
            foreach (var point in points.Where(point => point.isInsideTriangle(leftmost, rightmost, topmost)))
            {
                point.Enabled = false;
            }
            
            
            /* * * * * * * * * * * * * * * * * * */ 
            /*             DO    MAGIC           */
            /* * * * * * * * * * * * * * * * * * */
            LinkedList<Point> convexHull = new LinkedList<Point>();
            convexHull.InsertAfter(leftmost);
            convexHull.InsertAfter(rightmost);
            convexHull.InsertAfter(topmost);
            convexHull.JumpToBeginning();
            convexHull.DEBUG_PRINT();
            while (points.Any(point => point.Enabled))
            {
                var enabledPoints = points.Where(point => point.Enabled);
                
                // Now, for each side, find all points that are closest to this side
                int index = 0;
                while (!convexHull.IsAtEnd())
                {
                    convexHull.MoveRight();
                    index++;
                    var sideStart = convexHull.ReadPrevious();
                    var sideEnd = convexHull.Read();

                    foreach (var point in enabledPoints)
                    {
                        var distance = Math.Min(point.DistanceTo(sideStart), point.DistanceTo(sideEnd));
                        if (distance < point.AssignedSideDistance)
                        {
                            point.AssignedSideDistance = distance;
                            point.AssignedSideEnd = index;
                        }
                    }
                }
                convexHull.JumpToBeginning();
                
                // For each side, find one point that is farthest away and insert it into the side
                index = 0;
                while (!convexHull.IsAtEnd())
                {
                    convexHull.MoveRight();
                    index++;

                    var sideStart = convexHull.ReadPrevious();
                    var sideEnd = convexHull.Read();
                    
                    var thisSidePoints = enabledPoints.Where(point => point.AssignedSideEnd == index);
                    if (!thisSidePoints.Any())
                        continue;
                    Point selectedPoint = null;
                    double selectPointDistance = Double.NegativeInfinity;
                    foreach (var point in thisSidePoints)
                    {
                        var distance = point.DistanceToLine(sideStart, sideEnd);
                            //point.DistanceTo(sideStart) + point.DistanceTo(sideEnd);
                        if (distance > selectPointDistance)
                        {
                            selectedPoint = point;
                            selectPointDistance = distance;
                        }
                    }
                    convexHull.DEBUG_PRINT();
                    convexHull.InsertBefore(selectedPoint);
                    convexHull.DEBUG_PRINT();
                }
                convexHull.JumpToBeginning();
                
                // Eliminate any still enabled points that are now inside convex hull
                foreach (var point in enabledPoints)
                {
                    while (!convexHull.IsAtEnd())
                    {
                        var point1 = convexHull.Read();
                        convexHull.MoveRight();
                        var point2 = convexHull.Read();
                        convexHull.MoveRight();
                        var point3 = convexHull.Read();
                        convexHull.MoveRight();

                        if (point.isInsideTriangle(point1, point2, point3))
                        {
                            point.Enabled = false;
                        }
                        
                        convexHull.MoveLeft();
                        convexHull.MoveLeft();
                    }
                    convexHull.JumpToBeginning();
                }
            }

            var result = 0d;
            while (!convexHull.IsAtEnd())
            {
                Console.WriteLine(convexHull.Read());
                result += convexHull.Read().DistanceTo(convexHull.ReadNext());
                convexHull.MoveRight();
            }
            // There is still one point remaining
            var lastPoint = convexHull.Read();            
            Console.WriteLine(lastPoint);
            convexHull.JumpToBeginning();
            result += lastPoint.DistanceTo(convexHull.Read());
            
            Console.WriteLine(Math.Round(result, 2));

            return result;
        }
    }

    /// <summary>
    /// Cyclic LinkedList
    /// </summary>
    class LinkedList<T>
    {
        private Node<T> pointer;
        private Node<T> firstNode;
        private Node<T> lastNode;

        /// <summary>
        /// Initialize new Linked List. Insert first node with
        /// <see cref="InsertBefore"/> or <see cref="InsertAfter"/>
        /// </summary>
        public LinkedList()
        {
        }

        public T Read()
        {
            return pointer.Value;
        }

        public T ReadPrevious()
        {
            if (!IsAtBeginning())
            {
                return pointer.PreviousNode.Value;
            }
            else
            {
                return lastNode.Value;
            }
        }

        public T ReadNext()
        {
            if (!IsAtEnd())
            {
                return pointer.NextNode.Value;
            }
            else
            {
                return firstNode.Value;
            }
        }

        public void Write(T value)
        {
            pointer.Value = value;
        }

        public void MoveLeft()
        {
            if (pointer.PreviousNode == null)
            {
                JumpToEnd();
            }
            else
            {
                pointer = pointer.PreviousNode;
            }
        }

        public void MoveRight()
        {
            if (pointer.NextNode == null)
            {
                JumpToBeginning();
            }
            else
            {
                pointer = pointer.NextNode;
            }
        }

        public bool IsAtBeginning()
        {
            return pointer.PreviousNode == null;
        }

        public bool IsAtEnd()
        {
            return pointer.NextNode == null;
        }

        public void JumpToBeginning()
        {
            pointer = firstNode;
        }

        public void JumpToEnd()
        {
            pointer = lastNode;
        }

        /// <summary>
        /// Insert new node with given value BEFORE current node.
        /// Pointer will be stay at the same node.
        /// </summary>
        public void InsertBefore(T value)
        {
            if (pointer == null)
            {
                var newNode = new Node<T>(value, null, null);
                firstNode = newNode;
                lastNode = newNode;
                pointer = newNode;
            }
            else
            {
                if (pointer == firstNode)
                {
                    var newNode = new Node<T>(value, pointer, null);
                    firstNode = newNode;
                    pointer.PreviousNode = newNode;
                }
                else
                {
                    var newNode = new Node<T>(value, pointer, pointer.PreviousNode);
                    var lastPreviousNode = pointer.PreviousNode;
                    lastPreviousNode.NextNode = newNode;
                    pointer.PreviousNode = newNode;
                }
            }
        }

        /// <summary>
        /// Insert new node with given value AFTER current node.
        /// Pointer will stay at the same node.
        /// </summary>
        public void InsertAfter(T value)
        {
            if (pointer == null)
            {
                var newNode = new Node<T>(value, null, null);
                firstNode = newNode;
                lastNode = newNode;
                pointer = newNode;
            }
            else
            {
                if (pointer == lastNode)
                {
                    var newNode = new Node<T>(value, null, pointer);
                    lastNode = newNode;
                    pointer.NextNode = newNode;
                }
                else
                {
                    var newNode = new Node<T>(value, pointer.NextNode, pointer);
                    var lastNextNode = pointer.NextNode;
                    lastNextNode.PreviousNode = newNode;
                    pointer.NextNode = newNode;
                }
            }
        }

        public void DEBUG_PRINT()
        {
            Console.WriteLine("=== DEBUG ===");
            var node = firstNode;
            while (node.NextNode != null)
            {
                if (node == pointer)
                {
                    Console.WriteLine($">>> {node.Value} <<<");
                }
                else
                    Console.WriteLine(node.Value);
                node = node.NextNode;
            }
            Console.WriteLine("=============");
        }

        class Node<T>
        {
            public T Value;
            public Node<T> NextNode;
            public Node<T> PreviousNode;

            public Node(T value, Node<T> nextNode, Node<T> previousNode)
            {
                this.Value = value;
                this.NextNode = nextNode;
                this.PreviousNode = previousNode;
            }
        }
    }

    class Point
    {
        public int x, y;
        public bool Enabled;
        public int AssignedSideEnd;
        public double AssignedSideDistance;
        
        public Point(int x, int y)
        {
            this.x = x;
            this.y = y;
            Enabled = true;
            AssignedSideEnd = -1;
            AssignedSideDistance = double.PositiveInfinity;
        }

        public override string ToString()
        {
            return $"({x},{y})";
        }

        public double DistanceTo(Point other)
        {
            return Math.Sqrt(Math.Pow(Math.Abs(x - other.x), 2) + Math.Pow(Math.Abs(y - other.y), 2));
        }

        /// <summary>
        /// Find distance from point B (this) to line between points p1 (A) and p2 (C)
        /// 
        /// (https://cs.wikipedia.org/wiki/Heron%C5%AFv_vzorec)
        /// </summary>
        public double DistanceToLine(Point p1, Point p2)
        {
            // Delka strany A
            double a = this.DistanceTo(p2);
            double b = p1.DistanceTo(p2);
            double c = p1.DistanceTo(this);

            double s = (a + b + c) / 2;
            double S = Math.Sqrt(s * (s - a) * (s - b) * (s - c));
            return 2 * S / c;
        }

        public bool isInsideTriangle(Point p1, Point p2, Point p3)
        {
            double d1 = onWhichSideOfLineIs(p1, p2);
            double d2 = onWhichSideOfLineIs(p2, p3);
            double d3 = onWhichSideOfLineIs(p3, p1);

            bool hasNegativeResult = d1 < 0 || d2 < 0 || d3 < 0;
            bool hasPositiveResult = d1 > 0 || d2 > 0 || d3 > 0;

            return !hasNegativeResult || !hasPositiveResult;
        }

        private double onWhichSideOfLineIs(Point p1, Point p2)
        {
            return (x - p2.x) * (p1.y - p2.y) - (p1.x - p2.y) * (y - p2.y);
        }
    }
    
}
