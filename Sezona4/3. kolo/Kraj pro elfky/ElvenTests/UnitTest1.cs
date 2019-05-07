using System;
using Kraj_pro_elfky;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ElvenTests
{
    [TestClass]
    public class CompleteTests
    {
        [TestMethod]
        public void PdfTestOne()
        {
            Path[] paths = new Path[]
            {
                new Path(1, 2),
                new Path(2, 3),
                new Path(3, 0),
                new Path(0, 1),
                new Path(0, 2),
                new Path(1, 3)
            };
            Assert.AreEqual(false, Program.Calculate(paths, 4));
        }

        [TestMethod]
        public void PdfTestTwo()
        {
            Path[] paths = new Path[]
            {
                new Path(0, 1),
                new Path(0, 2),
                new Path(1, 2),
                new Path(2, 3),
                new Path(2, 4),
                new Path(3, 4)
            };
            Assert.AreEqual(true, Program.Calculate(paths, 5));
        }

        [TestMethod]
        public void CustomTestOne()
        {
            Path[] paths = new Path[]
            {
                new Path(0, 1),
                new Path(0, 4),
                new Path(0, 7),
                new Path(1, 2),
                new Path(2, 7),
                new Path(2, 3),
                new Path(2, 4),
                new Path(4, 5),
                new Path(5, 6),
                new Path(6, 7)
               
            };
            Assert.AreEqual(true, Program.Calculate(paths, 8));
        }
    }
}
