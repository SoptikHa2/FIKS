using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace Mocal
{
    class Program
    {
        static void Main(string[] args)
        {
            newComp.Compute();
            Environment.Exit(0);

            const int zpusob = 0;


            string[] lines = File.ReadAllLines("input.txt");
            int countedLine = 0;
            DateTime spusteni = DateTime.Now;
            for (int test = 0; test < 10; test++)
            {
                #region StaryZpusob
                // O(M + N^2(M) * log(N))
                if (zpusob == 0)
                {

                    Path[] paths;
                    List<Solution> solutions = new List<Solution>();
                    string[] line = lines[countedLine++].Split(' ');
                    int islands = int.Parse(line[0]);
                    int pth = int.Parse(line[1]);
                    paths = new Path[pth];


                    // O (M)
                    for (int i = 0; i < pth; i++)
                    {
                        line = lines[countedLine++].Split(' ');
                        paths[i] = new Path() { from = int.Parse(line[0]), to = int.Parse(line[1]) };
                    }

                    // Postup:

                    // 1) Pujdu ode vsech ostrovu -> vsema cestama
                    // 2) Od nich pujdu vsema cestama
                    // 3) Potom se zastavim. Kdyz neexituje zadna cesta, ktera by bylo po obraceni stejna, pridam to

                    // O(N + M)
                    // Ode vsech ostrovu:
                    for (int i = 0; i < islands; i++)
                    {
                        // O(M + N(M))
                        // Vyber vsechny mozny cesty
                        var pths = paths.Where(x => x.from == i || x.to == i).ToArray();
                        int pthsCount = pths.Count();
                        // Pro kazdou cestu:
                        // O(M + N^2(M))
                        for (int p = 0; p < pthsCount; p++)
                        {
                            // Najdi, na kterym jsi ostrove
                            int ostrovTed = pths[p].from == i ? pths[p].to : pths[p].from;

                            // Vyber vsechny mozny cesty z tohohle ostrova
                            var pths2 = paths.Where(x => ((x.from == ostrovTed && x.to != i) || (x.to == ostrovTed && x.from != i))).ToArray();
                            int pths2Count = pths2.Count();
                            // Pro kazou cestu:
                            // O(M + N^2(M) * log(N))
                            for (int k = 0; k < pths2Count; k++)
                            {
                                // Zjisti, jestli dana linka uz neni
                                Solution s = new Solution() { path1 = pths[p], path2 = pths2[k] };
                                if (solutions.Where(x => x.Equals(s)).Count() > 0)
                                    continue;
                                else
                                    solutions.Add(s);
                                //Console.WriteLine($"Solving test {test + 1}/10, done {i + 1}/{islands} islands, counted {p + 1}/{pths.Count()}, {k + 1}/{pths2.Count()} paths");
                            }
                        }
                    }
                    Console.WriteLine("Done test " + (test + 1));
                    File.AppendAllText("output.txt", solutions.Count.ToString() + (test < 9 ? Environment.NewLine : ""));
                }
                #endregion
                // Nefunguje
                #region Staronovy zpusob
                if (zpusob == 1)
                {
                    Path[] paths;
                    List<Solution> solutions = new List<Solution>();
                    string[] line = lines[countedLine++].Split(' ');
                    int islands = int.Parse(line[0]);
                    int pth = int.Parse(line[1]);
                    paths = new Path[pth];


                    // O (M)
                    for (int i = 0; i < pth; i++)
                    {
                        line = lines[countedLine++].Split(' ');
                        paths[i] = new Path() { from = int.Parse(line[0]), to = int.Parse(line[1]) };
                    }

                    // Postup:

                    // 1) Pujdu ode vsech ostrovu -> vsema cestama
                    // 2) Od nich pujdu vsema cestama
                    // 3) Potom se zastavim. Kdyz neexituje zadna cesta, ktera by bylo po obraceni stejna, pridam to

                    // Ted pro kazdy ostrov udelam seznam cest
                    List<Path>[] islandPaths = new List<Path>[islands];

                    // Pro kazdy ostrov: 
                    // O(N + M)
                    for (int i = 0; i < islands; i++)
                    {
                        islandPaths[i] = new List<Path>();
                    }
                    for (int i = 0; i < paths.Length; i++)
                    {
                        islandPaths[paths[i].from - 1].Add(paths[i]);
                        islandPaths[paths[i].to - 1].Add(paths[i]);
                    }

                    // Ode vsech ostrovu:
                    for (int i = 0; i < islands; i++)
                    {
                        // O(M + N(M))
                        // Vyber vsechny mozny cesty
                        var pths = islandPaths[i];
                        int pthsCount = pths.Count();
                        // Pro kazdou cestu:
                        // O(M + N^2(M))
                        for (int p = 0; p < pthsCount; p++)
                        {
                            // Najdi, na kterym jsi ostrove
                            int ostrovTed = pths[p].from == i ? pths[p].to : pths[p].from;

                            // Vyber vsechny mozny cesty z tohohle ostrova
                            var pths2 = islandPaths[ostrovTed - 1];
                            int pths2Count = pths2.Count();
                            // Pro kazou cestu:
                            // O(M + N^2(M) * log(N))
                            for (int k = 0; k < pths2Count; k++)
                            {
                                if (pths2[k].from == i || pths2[k].to == i)
                                    continue;
                                // Zjisti, jestli dana linka uz neni
                                Solution s = new Solution() { path1 = pths[p], path2 = pths2[k] };
                                if (solutions.Where(x => x.Equals(s)).Count() > 0)
                                    continue;
                                else
                                    solutions.Add(s);
                                //Console.WriteLine($"Solving test {test + 1}/10, done {i + 1}/{islands} islands, counted {p + 1}/{pths.Count()}, {k + 1}/{pths2.Count()} paths");
                            }
                        }
                    }
                    Console.WriteLine("Done test " + (test + 1));
                    File.AppendAllText("output.txt", solutions.Count.ToString() + (test < 9 ? Environment.NewLine : ""));
                }
                #endregion
                #region Novy zpusob                
                if (zpusob == 2)
                {
                    // Nactu vsechny ostrovy a cesty
                    string[] line = lines[countedLine++].Split(' ');
                    int islands = int.Parse(line[0]);
                    int pth = int.Parse(line[1]);
                    Path[] paths = new Path[pth];
                    paths = paths.OrderBy(x => x.to).ThenBy(x => x.from).ToArray();

                    for (int i = 0; i < pth; i++)
                    {
                        line = lines[countedLine++].Split(' ');
                        if (int.Parse(line[0]) < int.Parse(line[1]))
                            paths[i] = new Path() { from = int.Parse(line[0]), to = int.Parse(line[1]) };
                        else
                            paths[i] = new Path() { from = int.Parse(line[1]), to = int.Parse(line[0]) };
                    }

                    // Ted pro kazdy ostrov udelam seznam cest
                    List<Path>[] islandPaths = new List<Path>[islands];

                    // Pro kazdy ostrov: 
                    // O(N + M)
                    for (int i = 0; i < islands; i++)
                    {
                        islandPaths[i] = new List<Path>();
                    }
                    for (int i = 0; i < paths.Length; i++)
                    {
                        islandPaths[paths[i].from - 1].Add(paths[i]);
                        islandPaths[paths[i].to - 1].Add(paths[i]);
                    }

                    int count = 0;
                    // Pro kazdy ostrov:
                    // O(N + M + (N*M^2))
                    for (int i = 0; i < islands; i++)
                    {
                        // Pro vsechny cesty z tohohle ostrova
                        int nextPathCount1 = islandPaths[i].Count;
                        for (int j = 0; j < nextPathCount1; j++)
                        {
                            Path currPath = islandPaths[i][j];
                            int midIsland = currPath.from == i ? currPath.to : currPath.from;
                            int nextPathCount2 = islandPaths[midIsland - 1].Count;
                            for (int k = 0; k < nextPathCount2; k++)
                            {
                                Path currPath2 = islandPaths[midIsland - 1][k];
                                int endIsland = currPath2.from == midIsland ? currPath.to : currPath.from;
                                if (endIsland - 1 == i)
                                    continue;
                                count++;
                            }
                        }
                    }
                    File.AppendAllText("output.txt", (count / 2).ToString() + (test < 9 ? Environment.NewLine : ""));
                }
                #endregion
            }
            Console.WriteLine((DateTime.Now - spusteni).TotalMilliseconds);
            Console.ReadKey();
        }
    }

    struct Solution
    {
        public Path path1, path2;

        public bool Equals(Solution solution)
        {
            return (solution.path1.Equals(path1) && solution.path2.Equals(path2)) || (solution.path1.Equals(path2) && solution.path2.Equals(path1));
        }
    }

    struct Path
    {
        public int from, to;

        public bool Equals(Path path)
        {
            return from == path.from && to == path.to;
        }
    }
}
