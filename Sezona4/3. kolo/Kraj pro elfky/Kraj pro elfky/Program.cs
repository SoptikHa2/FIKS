using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Kraj_pro_elfky
{
    public class Program
    {
        static void Main(string[] args)
        {
            string[] firstRow = Console.ReadLine().Split(' ');
            int N = int.Parse(firstRow[0]);
            int M = int.Parse(firstRow[1]);
            Path[] paths = new Path[M];

            for (int i = 0; i < M; i++)
            {
                string[] row = Console.ReadLine().Split(' ');
                int regOne = int.Parse(row[0]);
                int regTwo = int.Parse(row[1]);
                paths[i] = new Path(regOne, regTwo);
            }

            Console.WriteLine(Calculate(paths, N) ? "Ba." : "Vu+");
            Console.ReadKey();
        }

        public static bool Calculate(Path[] paths, int regions)
        {
            // First of all, create list of adjacent regions
            List<int>[] regionPaths = new List<int>[regions];

            for (int i = 0; i < paths.Length; i++)
            {
                Path p = paths[i];

                if (regionPaths[p.regionFrom] == null)
                    regionPaths[p.regionFrom] = new List<int>();
                if (regionPaths[p.regionTo] == null)
                    regionPaths[p.regionTo] = new List<int>();

                regionPaths[p.regionFrom].Add(p.regionTo);
                regionPaths[p.regionTo].Add(p.regionFrom);
            }


            // List of not possed regions
            List<int> notPossedRegions = new List<int>();
            // Array of all regions - holds number, which says, which race is in region
            int[] regionNumbers = new int[regions];


            // Now, go through all regions

            // If there is neighbour(s) with only one race, pick the other one
            // If there are neighbours with both races, add this region to notPossedRegions
            // If there is no neighbour with known race, assign any race to this region
            AddRaceToRegion(0, regionNumbers, regionPaths, notPossedRegions);

            // Now get all not possed regions
            // If everything is possed, it's possible
            // If there is only one, set the region as elven region and it's possiblee
            // If there are more not possed regions, it is possible if they are not connected and they have common neighbour
            // If it is, set the neighbour as elven region
            // If not, there is no way we could do this

            if (notPossedRegions.Count == 0)
            {
                return true;
            }
            else if (notPossedRegions.Count == 1)
            {
                return true;
            }
            else
            {
                // If are the regions connected, there is no solution
                for (int i = 0; i < notPossedRegions.Count; i++)
                {
                    for (int j = 0; j < regionPaths[notPossedRegions[i]].Count; j++)
                    {
                        if (notPossedRegions.Contains(regionPaths[notPossedRegions[i]][j]))
                            return false;
                    }
                }

                // If all not possed regions have at least one common neighbour, we can solve this problem
                bool possibleToSolve = true;
                for (int i = 0; i < regionPaths[notPossedRegions[0]].Count; i++)
                {
                    int possibleElvenRegion = regionPaths[notPossedRegions[0]][i];

                    for (int j = 1; j < notPossedRegions.Count; j++)
                    {
                        List<int> neighboursForThisNotPossedRegion = regionPaths[notPossedRegions[j]];
                        if (!neighboursForThisNotPossedRegion.Contains(possibleElvenRegion))
                        {
                            possibleToSolve = false;
                            break;
                        }
                    }

                    if (possibleToSolve)
                    {
                        break;
                    }
                    else
                    {
                        possibleToSolve = true;
                    }
                }

                return possibleToSolve;
            }
        }

        private static void AddRaceToRegion(int region, int[] regionNumbers, List<int>[] regionPaths, List<int> notPossedRegions)
        {
            List<int> adjRegions = regionPaths[region];

            // Select race for this region
            int selectedRace = -1;
            //regionNumbers[adjRegions[0]] == 1 ? 2 : 1;
            for (int i = 0; i < adjRegions.Count; i++)
            {
                if (regionNumbers[adjRegions[i]] == 100)
                    continue;

                if (selectedRace == -1)
                {
                    selectedRace = regionNumbers[adjRegions[i]] == 1 ? 2 : 1;
                }
                else
                {

                    if (regionNumbers[adjRegions[i]] == selectedRace)
                    {
                        selectedRace = 0;
                        notPossedRegions.Add(region);
                        break;
                    }
                }
            }
            if (selectedRace == -1)
                selectedRace = 1;


            if (selectedRace == 0)
            {
                regionNumbers[region] = 100;
            }
            else
            {
                regionNumbers[region] = selectedRace;
            }

            // Do the same for all neighbours
            for (int i = 0; i < adjRegions.Count; i++)
            {
                if (regionNumbers[adjRegions[i]] == 0)
                    AddRaceToRegion(adjRegions[i], regionNumbers, regionPaths, notPossedRegions);
            }
        }
    }

    public struct Path
    {
        public int regionFrom;
        public int regionTo;

        public Path(int regionFrom, int regionTo)
        {
            this.regionFrom = regionFrom;
            this.regionTo = regionTo;
        }
    }
}
