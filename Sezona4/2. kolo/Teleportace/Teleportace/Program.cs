using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Teleportace
{
    class Program
    {
        static void Main(string[] args)
        {
            string[] firstLine = Console.ReadLine().Split(' ');
            int len = int.Parse(firstLine[0]);
            int hei = int.Parse(firstLine[1]);
            int mag = int.Parse(firstLine[2]);

            List<Formula> magic = new List<Formula>();
            for (int i = 0; i < mag; i++)
            {
                string[] formulaLine = Console.ReadLine().Split(' ');
                magic.Add(new Formula
                {
                    x = int.Parse(formulaLine[0]),
                    y = int.Parse(formulaLine[1])
                });
            }

            Console.WriteLine(new Game(len, hei, magic.ToArray()).Play());
            Console.ReadKey();
        }
    }

    class Game
    {
        private readonly string[] players = { "Martien", "Pepie" };

        private int length;
        private int height;
        private Formula[] magic;
        public Game(int length, int height, Formula[] magic)
        {
            this.length = length;
            this.height = height;
            this.magic = magic;
        }

        public string Play()
        {
            int curX = 0;
            int curY = 0;
            int currPlayer = -1;

            do
            {
                currPlayer++;
                if (currPlayer == players.Length)
                    currPlayer = 0;

                Formula play = ChooseFormula(curX, curY);

                curX += play.x;
                curY += play.y;
            } while (curX < length && curY < height);

            return players[currPlayer == 0 ? 1 : 0];
        }

        private Formula ChooseFormula(int currX, int currY)
        {
            Formula[] magicWithoutFormulasThatWillMakeCurrentPlayerLoose = magic.Where(x => currX + x.x < length && currY + x.y < height).ToArray();

            if (magicWithoutFormulasThatWillMakeCurrentPlayerLoose.Length == 0)
                return magic[0];

            // Return formula that will teleport players nearest to the edge
            int nearest = int.MaxValue;
            int nearestI = -1;
            for (int i = 0; i < magicWithoutFormulasThatWillMakeCurrentPlayerLoose.Length; i++)
            {
                int distance = Math.Min(magicWithoutFormulasThatWillMakeCurrentPlayerLoose[i].x,
                                                magicWithoutFormulasThatWillMakeCurrentPlayerLoose[i].y);

                if (distance < nearest)
                {
                    nearest = distance;
                    nearestI = i;
                }
            }
            return magicWithoutFormulasThatWillMakeCurrentPlayerLoose[nearestI];
        }
    }

    struct Formula
    {
        public int x, y;
    }
}
