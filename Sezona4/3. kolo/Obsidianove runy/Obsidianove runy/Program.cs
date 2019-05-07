using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Obsidianove_runy
{
    public class Program
    {
        static void Main(string[] args)
        {
            string[] text = File.ReadAllText("input.txt").Replace("\r", "").Split('\n');

            int N = int.Parse(text[0]);
            StringBuilder result = new StringBuilder(N);
            for (int i = 0; i < N; i++)
            {
                string input = text[i + 1];
                File.AppendAllText("output.txt", Calc(input) + Environment.NewLine);
                Console.WriteLine("Done " + i);
            }
        }

        public static int Calc(string input)
        {
            int maxLength = 1;
            for (int start = 0; start < input.Length; start++)
            {
                char[] chars = new char[94];
                for (int i = start; i < start + 94; i++)
                {
                    int c = i;
                    while (c >= input.Length)
                        c -= input.Length;
                    if (chars.Contains(input[c]))
                    {
                        int length = i - start;
                        if (maxLength < length)
                            maxLength = length;
                        break;
                    }
                    chars[i - start] = input[c];
                }
            }

            return maxLength;
        }
    }
}
