using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ZbojniciTest
{
    [TestClass]
    public class UnitTest1
    {
        [TestInitialize]
        public void TestInitialize()
        {

        }

        [TestMethod]
        public void TestBasicInput()
        {
            Assert.AreEqual(36, Zbojnici.Program.Compute(3, 3, 2, 3));
        }

        [TestMethod]
        public void TestBigInput()
        {
            Assert.AreEqual(7510160, Zbojnici.Program.Compute(50, 50, 23, 21));
        }

        [TestMethod]
        public void TestFailInput()
        {
            Assert.AreEqual(0, Zbojnici.Program.Compute(5, 3, 2, 6));
        }

        [TestMethod]
        public void TestSameShipsInput()
        {
            Assert.AreEqual(686, Zbojnici.Program.Compute(5, 5, 2, 2));
        }

        [TestMethod]
        public void TestOne1TileShip()
        {
            Assert.AreEqual(8, Zbojnici.Program.Compute(2, 2, 1, 2));
        }
    }
}
