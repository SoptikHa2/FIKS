using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Mocal
{
    class newComp
    {
        public static void Compute()
        {
            string[] lines = File.ReadAllLines("input.txt");
            int countedLine = 0;

            for (int test = 0; test < 10; test++)
            {
                int count = 0;
                string[] line = lines[countedLine++].Split(' ');
                int islands = int.Parse(line[0]);
                int pth = int.Parse(line[1]);

                List<Path>[] pathsForIslands = new List<Path>[islands];

                for(int i = 0; i < islands; i++)
                {
                    pathsForIslands[i] = new List<Path>();
                }

                for(int i = 0; i < pth; i++)
                {
                    string[] s = lines[countedLine++].Split(' ');
                    Path p = new Path() { from = int.Parse(s[0]) - 1, to = int.Parse(s[1]) - 1 };
                    pathsForIslands[p.from].Add(p);
                    pathsForIslands[p.to].Add(p);
                }

                // For all islands
                for(int i = 0; i < islands; i++)
                {
                    // Get island's paths
                    List<Path> paths = pathsForIslands[i];
                    int pathCount = paths.Count;
                    for(int m = 0; m < pathCount; m++)
                    {
                        // New island
                        Path p = paths[m];
                        int midIsle = p.from == i ? p.to : p.from;
                        List<Path> nPaths = pathsForIslands[midIsle];
                        int nPathCount = nPaths.Count;

                        for(int f = 0; f < nPathCount; f++)
                        {
                            // Final island
                            Path fP = nPaths[f];
                            int finIsle = fP.from == midIsle ? fP.to : fP.from;
                            if (finIsle != i)
                                count++;
                        }
                    }
                }

                File.AppendAllText("output.txt", (count / 2).ToString() + (test == 9 ? "" : Environment.NewLine));
            }
        }
    }
}
