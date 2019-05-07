using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MapTests
{
    [TestClass]
    public class MapTest
    {
        [TestMethod]
        public void MapTestFromPDF1()
        {
            string input = @"///\\//\/\\\";
            Assert.AreEqual(7, Mapa.Program.GetTotalNumberOfHours(input));
        }

        [TestMethod]
        public void MapTestFromPDF2()
        {
            string input = @"\\/_///\\_/_";
            Assert.AreEqual(7, Mapa.Program.GetTotalNumberOfHours(input));
        }

        [TestMethod]
        public void MapTestFromPDF3()
        {
            string input = @"//\\_/\//\__";
            Assert.AreEqual(9, Mapa.Program.GetTotalNumberOfHours(input));
        }

        [TestMethod]
        public void MapTestFromPDF4()
        {
            string input = @"/\\\_//_/\\/";
            Assert.AreEqual(9, Mapa.Program.GetTotalNumberOfHours(input));
        }

        [TestMethod]
        public void MapTestFromPDF5()
        {
            string input = @"\\//\\//";
            Assert.AreEqual(7, Mapa.Program.GetTotalNumberOfHours(input));
        }

        [TestMethod]
        public void MapTestFromPDF6()
        {
            string input = @"\\///\\\//";
            Assert.AreEqual(8, Mapa.Program.GetTotalNumberOfHours(input));
        }

        [TestMethod]
        public void MapTestFromPDF7()
        {
            string input = @"\\//_\\//";
            Assert.AreEqual(7, Mapa.Program.GetTotalNumberOfHours(input));
        }
    }
}
