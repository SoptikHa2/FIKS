using System;

namespace Zbojnici
{
    public class Program
    {
        static void Main(string[] args)
        {
            string[] input = Console.ReadLine().Split(' ');
            int N = int.Parse(input[0]);
            int M = int.Parse(input[1]);
            int A = int.Parse(input[2]);
            int B = int.Parse(input[3]);

            Console.WriteLine(Compute(N, M, A, B));
        }

        public static int Compute(int N, int M, int A, int B)
        {
            int result = 0;

            // For all tiles:
            for (int i = 0; i < N; i++)
            {
                for (int j = 0; j < M; j++)
                {
                    bool[,] map = new bool[N, M];

                    // Try to pos ship 1st way
                    if (i + A <= N)
                    {
                        // Mark tiles
                        for (int a = i; a < i + A; a++)
                            map[a, j] = true;

                        // For all tiles
                        for (int x = 0; x < N; x++)
                        {
                            for (int y = 0; y < M; y++)
                            {
                                // Try to pos 2nd ship 1st way
                                if (x + B <= N)
                                {
                                    bool canPos = true;
                                    for (int a = x; a < x + B; a++)
                                    {
                                        if (map[a, y])
                                        {
                                            canPos = false;
                                            break;
                                        }
                                    }
                                    if (canPos)
                                        result++;
                                }

                                // Try to pos 2nd ship 2nd way
                                if (y + B <= M)
                                {
                                    bool canPos = true;
                                    for (int a = y; a < y + B; a++)
                                    {
                                        if (map[x, a])
                                        {
                                            canPos = false;
                                            break;
                                        }
                                    }
                                    if (canPos)
                                        result++;
                                }
                            }
                        }
                    }

                    map = new bool[N, M];

                    // Try to pos ship 2nd way
                    if (j + A <= M)
                    {
                        // Mark tiles
                        for (int a = j; a < j + A; a++)
                            map[i, a] = true;

                        // For all tiles
                        for (int x = 0; x < N; x++)
                        {
                            for (int y = 0; y < M; y++)
                            {
                                // Try to pos 2nd ship 1st way
                                if (x + B <= N)
                                {
                                    bool canPos = true;
                                    for (int a = x; a < x + B; a++)
                                    {
                                        if (map[a, y])
                                        {
                                            canPos = false;
                                            break;
                                        }
                                    }
                                    if (canPos)
                                        result++;
                                }

                                // Try to pos 2nd ship 2nd way
                                if (y + B <= M)
                                {
                                    bool canPos = true;
                                    for (int a = y; a < y + B; a++)
                                    {
                                        if (map[x, a])
                                        {
                                            canPos = false;
                                            break;
                                        }
                                    }
                                    if (canPos)
                                        result++;
                                }
                            }
                        }
                    }
                }
            }

            // If are ships unrecognizable
            if (A == B || A == 1 || B == 1)
                result /= 2;
            return result;
        }
    }
}
