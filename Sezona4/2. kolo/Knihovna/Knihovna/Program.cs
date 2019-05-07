using System.Collections.Generic;
using System.Linq;
using System.IO;
using System;
using System.Text;
using System.Threading.Tasks;
using System.Threading;

namespace Knihovna
{
    public class Program
    {
        static void Main(string[] args)
        {
            string[] lns = File.ReadAllLines("input.txt");
            int T = int.Parse(lns[0]);
            for (int i = 1000; i < T; i++)
            {
                int firstParam = int.Parse(lns[i * 2 + 1].Split(' ')[1]);
                string secondParam = lns[i * 2 + 2];
                File.AppendAllText("output.txt", /* Compute(firstParam, secondParam) */ ComputeVer2(firstParam, secondParam) + Environment.NewLine);
                Console.SetCursorPosition(0, 0);
                Console.WriteLine("Done " + i + " of " + lns.Length);
            }
        }

        public static string Compute(int wordLength, string input)
        {
            // First of all, get all those strings and
            // store them with their hash into my dictionary
            Dictionary<int, int> HashStringDictionary = SplitStringByNumberAndSaveThemWithTheirHashAsync(input, wordLength);

            int x = HashStringDictionary.Count;
            int y = HashStringDictionary.Select(kvp => kvp.Value).Max();
            int z = HashStringDictionary.Where(kvp => kvp.Value == y).Count();

            return x + " " + y + " " + z;
        }

        public static string ComputeVer2(int wordLength, string input)
        {
            Dictionary<int, int> HashStringDictionary = new Dictionary<int, int>(input.Length - wordLength + 1);

            StringBuilder[] words = new StringBuilder[wordLength];
            for (int i = 0; i < words.Length; i++) words[i] = new StringBuilder();

            for(int i = 0; i < input.Length; i++)
            {
                int mainIndex = i % wordLength;

                if(words[mainIndex].Length == wordLength)
                {
                    int hash = words[mainIndex].GetHashCode();

                    if (HashStringDictionary.ContainsKey(hash))
                    {
                        HashStringDictionary[hash]++;
                    }
                    else
                    {
                        HashStringDictionary.Add(hash, 1);
                    }
                    words[mainIndex].Clear();

                }


                for(int index = 0; index < words.Length; index++)
                {
                    int secondaryIndex = index % wordLength;

                    words[secondaryIndex].Append(input[i]);
                }

                Console.SetCursorPosition(0, 1);
                Console.Write(i);
            }

            int x = HashStringDictionary.Count;
            int y = HashStringDictionary.Select(kvp => kvp.Value).Max();
            int z = HashStringDictionary.Where(kvp => kvp.Value == y).Count();

            return x + " " + y + " " + z;
        }

        static List<Dictionary<int, int>> threadResults = new List<Dictionary<int, int>>();
        static Dictionary<int, int> SplitStringByNumberAndSaveThemWithTheirHashAsync(string input, int number)
        {
            Dictionary<int, int> output = new Dictionary<int, int>(input.Length - number + 1);

            if (input.Length - number > 10000)
            {
                threadResults.Clear();
                int step = (input.Length - number) / 8;
                int extra = (input.Length - number) - step * 8;
                List<Task<Dictionary<int, int>>> results = new List<Task<Dictionary<int, int>>>();
                List<Thread> threads = new List<Thread>(8);
                // Use multi-threading
                for (int i = 0; i < 7; i++)
                {
                    Thread t = new Thread(() => { threadResults.Add(RunTask(input, i * step, (i + 1) * step, i, step, number)); });
                    threads.Add(t);
                    t.Name = "Computing thread " + i;
                    t.Start();
                }
                Thread tn = new Thread(() => { threadResults.Add(RunTask(input, 7 * step, 8 * step + extra, 7, step, number)); });
                threads.Add(tn);
                tn.Name = "Computing thread 7";
                tn.Start();

                // Wait for all threads to end
                for (int i = 0; i < 8; i++)
                {
                    threads[i].Join();
                }
                // Gather info
                for (int i = 0; i < 8; i++)
                {
                    Dictionary<int, int> tr = threadResults[i];
                    foreach (KeyValuePair<int, int> kvp in tr)
                    {
                        if (output.ContainsKey(kvp.Key))
                        {
                            output[kvp.Key] += kvp.Value;
                        }
                        else
                        {
                            output.Add(kvp.Key, kvp.Value);
                        }
                    }
                }
            }
            else
            {
                for (int i = 0; i <= input.Length - number; i++)
                {
                    string word = input.Substring(i, number);
                    int hash = word.GetHashCode();
                    if (output.ContainsKey(hash))
                    {
                        output[hash]++;
                    }
                    else
                    {
                        output.Add(hash, 1);
                    }
                }
            }

            return output;
        }

        static object _lock = new object();
        static Dictionary<int, int> RunTask(string input, int from, int to, int threadNumber, int dictSize, int wordLength)
        {
            Dictionary<int, int> output = new Dictionary<int, int>(dictSize);
            for (int i = from; i <= to; i++)
            {
                string word = input.Substring(i, wordLength);
                int hash = word.GetHashCode();
                if (output.ContainsKey(hash))
                {
                    output[hash]++;
                }
                else
                {
                    output.Add(hash, 1);
                }

                if (i % 1000 == 0)
                {
                    lock (_lock)
                    {
                        Console.SetCursorPosition(0, 1 + threadNumber);
                        Console.Write(Math.Round(i / (double)(to) * 100, 2) + "%");
                    }
                }
            }
            return output;
        }

        public static string CreateMD5(string input)
        {
            // Use input string to calculate MD5 hash
            using (System.Security.Cryptography.MD5 md5 = System.Security.Cryptography.MD5.Create())
            {
                byte[] inputBytes = Encoding.ASCII.GetBytes(input);
                byte[] hashBytes = md5.ComputeHash(inputBytes);

                // Convert the byte array to hexadecimal string
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < hashBytes.Length; i++)
                {
                    sb.Append(hashBytes[i].ToString("X2"));
                }
                return sb.ToString();
            }
        }
    }

    public struct DictValue
    {
        public string stringValue;
        public int count;
    }
}
