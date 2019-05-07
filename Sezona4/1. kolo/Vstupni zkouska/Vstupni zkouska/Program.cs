using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Vstupni_zkouska
{
    public class Program
    {
        static void Main(string[] args)
        {
            string[] n_m = Console.ReadLine().Split(' ');
            int N = int.Parse(n_m[0]);
            int M = int.Parse(n_m[1]);
            int[,] map = new int[N, M];
            for (int i = 0; i < N; i++)
            {
                string[] nms = Console.ReadLine().Split(' ');
                for (int j = 0; j < M; j++)
                {
                    map[i, j] = int.Parse(nms[j]);
                }
            }

            Console.WriteLine(CompOutput(CompPoints(map)));
        }

        public static Point[] CompPoints(int[,] map)
        {
            Point[] solution = null;
            // For all on map
            for (int i = 0; i < map.GetLength(0); i++)
            {
                for (int j = 0; j < map.GetLength(1); j++)
                {
                    // Get start point
                    Point startPoint = new Point { x = i, y = j };

                    // Get end point
                    // For all on map (after start point)
                    for (int a = i; a < map.GetLength(0); a++)
                    {
                        for (int b = j; b < map.GetLength(1); b++)
                        {
                            Point endPoint = new Point { x = a, y = b };

                            // StartPoint must have the same value as EndPoint
                            if (map[startPoint.x, startPoint.y] != map[endPoint.x, endPoint.y])
                                continue;

                            Point[] newSolution = GetSolution(new List<Point> { startPoint }, new List<Point> { endPoint }, map.GetLength(0), map.GetLength(1), map);
                            if (newSolution == null)
                                continue;
                            if (solution == null || newSolution.Length > solution.Length)
                                solution = newSolution;
                        }
                    }
                }
            }

            if (solution == null) // Not able to form any
                solution = new Point[] { new Point() { x = 0, y = 0 } };

            return solution;
        }

        private static Point[] GetSolution(List<Point> pathFromStart, List<Point> pathFromEnd, int width, int height, int[,] map)
        {
            Point lastFromStart = pathFromStart.Last();
            Point lastFromEnd = pathFromEnd.Last();
            Point[] solution = null;

            if (lastFromStart.x == lastFromEnd.x && lastFromStart.y == lastFromEnd.y)
            {
                Point[] result = new Point[pathFromStart.Count + pathFromEnd.Count - 1];
                pathFromStart.CopyTo(result);
                int q = pathFromStart.Count;
                for (int e = pathFromEnd.Count - 2; e > 0; e--)
                {
                    result[q++] = pathFromEnd[e];
                }
                return result;
            }

            // For all points around latest PathFromStart:
            for (int i = -1; i <= 1; i++)
            {
                if (i + lastFromStart.x < 0 || i + lastFromStart.x >= width)
                    continue;
                for (int j = -1; j <= 1; j++)
                {
                    if (j + lastFromStart.y < 0 || j + lastFromStart.y >= height)
                        continue;

                    Point newPossiblePathFromStart = new Point { x = lastFromStart.x + i, y = lastFromStart.y + j };

                    // If I already used this point
                    if (pathFromStart.Where(x => x.x == newPossiblePathFromStart.x && x.y == newPossiblePathFromStart.y).Count() > 0 ||
                        pathFromEnd.Where(x => x.x == newPossiblePathFromStart.x && x.y == newPossiblePathFromStart.y).Count() > 0)
                        continue;


                    // For all points around latest PathFromEnd:

                    for (int a = -1; a <= 1; a++)
                    {
                        if (a + lastFromEnd.x < 0 || a + lastFromEnd.x >= width)
                            continue;
                        for (int b = -1; b <= 1; b++)
                        {
                            if (b + lastFromEnd.y < 0 || b + lastFromEnd.y >= height)
                                continue;

                            // Get point that has the same value as [NewPossiblePathFromStart]
                            Point newPossiblePathFromEnd = new Point { x = lastFromEnd.x + a, y = lastFromEnd.y + b };

                            // If I already used this point
                            if (pathFromEnd.Where(x => x.x == newPossiblePathFromEnd.x && x.y == newPossiblePathFromEnd.y).Count() > 0 ||
                                pathFromStart.Where(x => x.x == newPossiblePathFromEnd.x && x.y == newPossiblePathFromEnd.y).Count() > 0)
                                continue;



                            if (map[newPossiblePathFromStart.x, newPossiblePathFromStart.y] == map[newPossiblePathFromEnd.x, newPossiblePathFromEnd.y])
                            {

                                // If I reached end
                                if (newPossiblePathFromEnd.x == lastFromStart.x && newPossiblePathFromEnd.y == lastFromStart.y)
                                {
                                    Point[] result = new Point[pathFromStart.Count + 1 + pathFromEnd.Count];
                                    pathFromStart.CopyTo(result);
                                    result[pathFromStart.Count] = newPossiblePathFromEnd;
                                    int q = pathFromStart.Count + 1;
                                    for (int e = pathFromEnd.Count - 1; e >= 0; e--)
                                    {
                                        result[q++] = pathFromEnd[e];
                                    }
                                    if (solution == null || solution.Length < result.Length)
                                        solution = result;
                                }
                                // If are these points on the same coordinates
                                else if (newPossiblePathFromStart.x - newPossiblePathFromEnd.x == 0 && newPossiblePathFromStart.y - newPossiblePathFromEnd.y == 0)
                                {
                                    Point[] result = new Point[pathFromStart.Count + 1 + pathFromEnd.Count];
                                    pathFromStart.CopyTo(result);
                                    result[pathFromStart.Count] = newPossiblePathFromStart;
                                    int q = pathFromStart.Count + 1;
                                    for (int e = pathFromEnd.Count - 1; e >= 0; e--)
                                    {
                                        result[q++] = pathFromEnd[e];
                                    }
                                    if (solution == null || solution.Length < result.Length)
                                        solution = result;
                                }
                                // Or the points are next to each other
                                else if (Math.Abs(newPossiblePathFromStart.x - newPossiblePathFromEnd.x) <= 1 && Math.Abs(newPossiblePathFromStart.y - newPossiblePathFromEnd.y) <= 1)
                                {
                                    Point[] result = new Point[pathFromStart.Count + 2 + pathFromEnd.Count];
                                    pathFromStart.CopyTo(result);
                                    result[pathFromStart.Count] = newPossiblePathFromStart;
                                    result[pathFromStart.Count + 1] = newPossiblePathFromEnd;
                                    int q = pathFromStart.Count + 2;
                                    for (int e = pathFromEnd.Count - 1; e >= 0; e--)
                                    {
                                        result[q++] = pathFromEnd[e];
                                    }
                                    if (solution == null || solution.Length < result.Length)
                                        solution = result;
                                }
                                // Still nothing found? Let recursion solve it
                                else
                                {
                                    List<Point> newPathFromStart = new List<Point>(pathFromStart.Count + 1);
                                    newPathFromStart.AddRange(pathFromStart);
                                    newPathFromStart.Add(newPossiblePathFromStart);

                                    List<Point> newPathFromEnd = new List<Point>(pathFromEnd.Count + 1);
                                    newPathFromEnd.AddRange(pathFromEnd);
                                    newPathFromEnd.Add(newPossiblePathFromEnd);

                                    Point[] s = GetSolution(newPathFromStart, newPathFromEnd, width, height, map);

                                    if (s == null)
                                        continue;

                                    if (solution == null || solution.Length < s.Length)
                                        solution = s;
                                }
                            }
                        }
                    }
                }
            }

            return solution;
        }

        public static string CompOutput(Point[] points)
        {
            var pointsX = points.Select(x => x.x);
            var pointsY = points.Select(x => x.y);

            return (pointsY.Min() + 1) + " " + (pointsX.Min() + 1) + " " +
                   (pointsY.Max() + 1) + " " + (pointsX.Max() + 1);
        }
    }

    public struct Point
    {
        public int x, y;
        public override string ToString()
        {
            return $"Point: {x} | {y}";
        }
    }
}
