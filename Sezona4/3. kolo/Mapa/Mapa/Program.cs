using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Mapa
{
    public class Program
    {
        static void Main(string[] args)
        {
            /*string input = @"///\\//\/\\\";
            Console.WriteLine(GetTotalNumberOfHours(input));
            Console.ReadKey();*/

            string[] lines = File.ReadAllLines("input.txt");
            for(int i = 0; i < lines.Length - 1; i += 2)
            {
                File.AppendAllText("output.txt", GetTotalNumberOfHours(lines[i + 1]) + Environment.NewLine);
            }
        }

        const double ascendCost = 0.5d;
        const double descendCost = 1 / 3d;
        const double walkCost = 0.25d;
        const double swimCost = 1d;

        const char ascend = '/';
        const char descend = '\\';
        const char flat = '_';

        public static int GetTotalNumberOfHours(string input)
        {
            int waterStart = GetWaterStartPos(input);
            int waterEnd = GetWaterEndPos(input);
            double hours = 0;

            // First of all, set terrain height
            int[] height = GetHeightOfTerrain(input);
            // Then, set water
            WaterCoverage[] water = GetWaterCoverage(input, height, waterStart, waterEnd);
            // Now, let's count hours
            bool waterContinue = false;
            bool walking = false;
            for (int tile = 0; tile < input.Length; tile++)
            {
                // First of all, check if there is water
                if (water[tile].isWater)
                {
                    // Takova ta spicka co vyresetuje walking
                    if (tile > 0)
                        if (water[tile - 1].heightLevel == height[tile - 1])
                            waterContinue = false;

                    if (!waterContinue)
                    {
                        walking = true;
                        waterContinue = true;
                    }

                    int deltaHeight = water[tile].heightLevel - height[tile];
                    if (deltaHeight > 1)
                        walking = false;

                    if (walking)
                    {
                        hours += GetValueOfTerrain('_');
                        //Console.WriteLine("Added: " + GetValueOfTerrain('_'));
                    }
                    else
                    {
                        hours += swimCost;
                        //Console.WriteLine("Added: " + swimCost);
                    }
                }
                else
                {
                    // If there is no water, simply add terrain cost to [hours]
                    hours += GetValueOfTerrain(input[tile]);
                    //Console.WriteLine("Added: " + GetValueOfTerrain(input[tile]));
                    waterContinue = false;
                }
            }

            return (int)Math.Ceiling(hours);
        }

        static int[] GetHeightOfTerrain(string input)
        {
            int[] height = new int[input.Length];

            int h = 0;
            for (int i = 0; i < input.Length; i++)
            {
                h += GetTerrainModifier(input[i]);
                height[i] = h;
            }

            return height;
        }

        static WaterCoverage[] GetWaterCoverage(string input, int[] heightLevels, int start, int end)
        {
            WaterCoverage[] coverage = new WaterCoverage[input.Length];

            for (int i = 0; i < input.Length; i++)
            {

                // If outside water zone
                if (i < start || i > end)
                {
                    // Set tile as no water and continue
                    coverage[i] = new WaterCoverage(false, -1);
                    continue;
                }

                // If we descend...
                if (input[i] == '\\')
                {
                    // Get current height + 1
                    int height = heightLevels[i] + 1;
                    // Check if in future there is the (at least) same height
                    bool canPosWater = false;

                    for (int tile = i + 1; tile <= end; tile++)
                    {
                        if (heightLevels[tile] >= height)
                        {
                            canPosWater = true;
                            break;
                        }
                    }

                    if (canPosWater)
                    {
                        // Set coverage to this tile
                        coverage[i] = new WaterCoverage(true, height);
                        // And all tiles till tile height is higher than water height
                        for (; i <= end; i++)
                        {
                            if (heightLevels[i] >= height)
                            {
                                // RESENI
                                if (heightLevels[i] == height &&
                                   input[i] == ascend)
                                    coverage[i] = new WaterCoverage(true, height);

                                break;
                            }

                            coverage[i] = new WaterCoverage(true, height);
                        }
                    }
                }
                else
                {
                    // If we don't descend AND there is no water, set current water coverage to no coverage
                    coverage[i] = new WaterCoverage(false, -1);
                }
            }

            return coverage;
        }

        static double GetValueOfTerrain(char path)
        {
            switch (path)
            {
                case ascend:
                    return ascendCost;
                case descend:
                    return descendCost;
                case flat:
                    return walkCost;
                default:
                    throw new ArgumentException();
            }
        }

        static int GetWaterStartPos(string input)
        {
            for (int i = 0; i < input.Length; i++)
            {
                if (input[i] == descend)
                    return i;
            }
            return input.Length - 1;
        }

        static int GetWaterEndPos(string input)
        {
            for (int i = input.Length - 1; i >= 0; i--)
            {
                if (input[i] == ascend)
                    return i;
            }
            return 0;
        }

        static int GetTerrainModifier(char path)
        {
            switch (path)
            {
                case '_':
                    return 0;
                case '/':
                    return 1;
                case '\\':
                    return -1;
                default:
                    throw new ArgumentException();
            }
        }
    }

    public struct WaterCoverage
    {
        public bool isWater;
        public int heightLevel;

        public WaterCoverage(bool isWater, int heightLevel)
        {
            this.isWater = isWater;
            this.heightLevel = heightLevel;
        }

        public override string ToString()
        {
            return isWater.ToString();
        }
    }
}