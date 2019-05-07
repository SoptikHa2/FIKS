using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Vstupni_zkouska;

namespace VstupniZkouskaTest
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void Vstup1()
        {
            Point[] points = Program.CompPoints(new int[,] { { 1, 1, 1, 1 }, { 1, 0, 0, 1 }, { 1, 1, 1, 1 } });
            Assert.AreEqual(12, points.Length);
            string output = Program.CompOutput(points);
            Assert.AreEqual("1 1 4 3", output);
        }

        [TestMethod]
        public void Vstup2()
        {
            Point[] points = Program.CompPoints(new int[,] { { 1, 2, 3 }, { 4, 5, 6 }, { 7, 6, 5 } });
            Assert.AreEqual(4, points.Length);
            string output = Program.CompOutput(points);
            Assert.AreEqual("2 2 3 3", output);
        }

        [TestMethod]
        public void Vstup3()
        {
            Point[] points = Program.CompPoints(new int[,] { { 6, 2, 3, 2, 1, 5 } });
            Assert.AreEqual(3, points.Length);
            string output = Program.CompOutput(points);
            Assert.AreEqual("2 1 4 1", output);
        }

        [TestMethod]
        public void Vstup4()
        {
            Point[] points = Program.CompPoints(new int[,] { { 1, 2 }, { 3, 4 } });
            Assert.AreEqual(1, points.Length);
            string output = Program.CompOutput(points);
            Assert.AreEqual("1 1 1 1", output);
        }

        [TestMethod]
        public void CustomVstup1()
        {
            Point[] points = Program.CompPoints(new int[,] { { 0, 1 }, { 2, 1 }, { 1, 1 }, { 1, 2 }, { 1, 1 }, { 2, 1 }, { 0, 1 } });
            Assert.AreEqual(13, points.Length);
            string output = Program.CompOutput(points);
            Assert.AreEqual("1 1 2 7", output);
        }

        [TestMethod]
        public void CustomVstup2()
        {
            Point[] points = Program.CompPoints(new int[,] { { 1 } });
            Assert.AreEqual(1, points.Length);
            string output = Program.CompOutput(points);
            Assert.AreEqual("1 1 1 1", output);
        }
    }
}
