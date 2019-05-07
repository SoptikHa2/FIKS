using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace SiluetaMesta
{
    class Program
    {
        static void Main(string[] args)
        {
            //const int restart = 100;
            string[] totalInput = File.ReadLines("input.txt").ToArray();
            string[] totalOutput = null;
            int instruction = 0;
            int poc = 0;
            //bool increased = false;

            /*try
            {
                if (File.ReadAllText("output.txt").Length > 10)
                {
                    poc = restart;
                    increased = true;
                }
            }
            catch { }*/

            bool[,] pole = null;
            int maxX = 0, maxY = 0, translate = 0;
            int pocetVelkychVstupu = int.Parse(totalInput[instruction++]);
            totalOutput = new string[pocetVelkychVstupu];
            for (; poc < pocetVelkychVstupu; poc++)
            {
                /*if (poc >= restart && !increased)
                {
                    totalOutput = totalOutput.Where(x => !string.IsNullOrEmpty(x)).ToArray();
                    File.AppendAllLines("output.txt", totalOutput);
                    File.WriteAllText("lastInstruction", instruction.ToString());
                    Environment.Exit(0);
                }
                else if (increased && poc == restart)
                {
                    string s = File.ReadAllText("lastInstruction");
                    instruction = int.Parse(s);
                }*/


                Console.WriteLine(poc);
                ulong vysledek = 0;
                int pocetVstupu = int.Parse(totalInput[instruction++]);
                Budova[] budovy = new Budova[pocetVstupu];
                for (int i = 0; i < pocetVstupu; i++)
                {
                    string[] input = totalInput[instruction++].Split(' ');

                    int H = int.Parse(input[0]);
                    int L = int.Parse(input[1]);
                    int R = int.Parse(input[2]);

                    if (L < 0 && -L > translate)
                    {
                        translate = -L;
                    }
                    if (maxX < R)
                        maxX = R;
                    if (maxY < H)
                        maxY = H;

                    budovy[i] = new Budova { H = H, L = L, R = R };
                }
                ulong sizeX = 0;
                ulong mX = (ulong)maxX;
                ulong t = (ulong)translate;
                sizeX = mX + t;
                try
                {
                    pole = new bool[sizeX, (ulong)maxY];

                    for (int i = 0; i < pocetVstupu; i++)
                    {
                        Budova bud = budovy[i];
                        for (int a = bud.L + translate; a < bud.R + translate; a++)
                        {
                            for (int b = 0; b < bud.H; b++)
                            {
                                if (pole[a, b] == false)
                                    vysledek++;
                                pole[a, b] = true;
                            }
                        }
                    }
                }
                catch
                {
                    vysledek = 0;
                }
                File.AppendAllText("output.txt", (vysledek.ToString() + (poc == pocetVelkychVstupu - 1 ? "" : Environment.NewLine)));
                //totalOutput[poc] += vysledek.ToString();
            }

            try
            {
                //totalOutput = totalOutput.Where(x => !string.IsNullOrEmpty(x)).ToArray();
                //File.AppendAllLines("output.txt", totalOutput);
            }
            catch
            {
                Console.Write(totalOutput);
            }
        }
    }

    struct Budova
    {
        public int H, L, R;
    }
}
