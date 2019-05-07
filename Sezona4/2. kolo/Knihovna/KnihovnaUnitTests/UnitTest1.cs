using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Linq;
using System.Diagnostics;

namespace KnihovnaUnitTests
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void BaseExamples()
        {
            Assert.AreEqual("26 2 1", Knihovna.Program.Compute(2, "abcdefghijklmnopqrstuvwxyzab"));
            Assert.AreEqual("26 1 26", Knihovna.Program.Compute(3, "abcdefghijklmnopqrstuvwxyzab"));
            Assert.AreEqual("3 2 1", Knihovna.Program.Compute(3, "abcabc"));
        }

        private const string engAlphabet = "qwertyuiopasdfghjklzxcvbnm";
        [TestMethod]
        public void TimerEasyExample()
        {
            for (int T = 0; T <= 1000; T++)
            {
                string text = RandomString(1000);
                int wordLength = 2;
                Knihovna.Program.Compute(wordLength, text);
                Debug.WriteLine("Finished");
            }
        }

        [TestMethod]
        public void TimerHardExample()
        {
            Stopwatch sw = new Stopwatch();
            for (int T = 0; T <= 3; T++)
            {
                sw.Reset();
                string text = RandomString(2000000);
                int wordLength = 2;
                sw.Start();
                Knihovna.Program.Compute(wordLength, text);
                sw.Stop();
                Debug.WriteLine(sw.ElapsedMilliseconds);
            }
        }

        private static Random rnd = new Random();

        private string RandomString(int length)
        {
            return new string(Enumerable.Repeat(engAlphabet, length).Select(x => x[rnd.Next(x.Length)]).ToArray());
        }
    }
}
