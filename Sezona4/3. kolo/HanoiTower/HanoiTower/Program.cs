using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HanoiTower
{
    class Program
    {
        static Stack<Tower> PosA;
        static Stack<Tower> PosB;
        static Stack<Tower> PosC;

        static void Main(string[] args)
        {
            List<Move> moves = StartDoubleHanoi(5, "A", "C", "B");
            Console.WriteLine(moves.Count + " moves");
            Console.WriteLine();
            Console.WriteLine();
            Console.WriteLine("A: " + PosA.Count);
            Console.WriteLine("B: " + PosB.Count);
            Console.WriteLine("C: " + PosC.Count);
            Console.WriteLine();
            Console.WriteLine();
            Console.WriteLine(String.Join("\n", moves));
            Console.ReadKey();
        }

        static List<Move> StartHanoi(int N, string from, string aux, string to)
        {
            List<Move> moves = new List<Move>();

            PosA = new Stack<Tower>(N);
            PosB = new Stack<Tower>(N);
            PosC = new Stack<Tower>(N);

            for (int i = N; i > 0; i--)
                GetStack(from).Push(new Tower(i, true));

            Hanoi(N, from, aux, to, moves);

            return moves;
        }

        static List<Move> StartDoubleHanoi(int N, string from, string aux, string to)
        {
            List<Move> moves = new List<Move>();
            PosA = new Stack<Tower>(N);
            PosB = new Stack<Tower>(N);
            PosC = new Stack<Tower>(N);

            for (int i = N; i > 0; i--)
            {
                GetStack(from).Push(new Tower(i, true));
                GetStack(to).Push(new Tower(i, false));
            }

            DoubleHanoi(N, from, aux, to, moves);

            return moves;
        }

        #region Hanoi
        static void Hanoi(int N, string from, string aux, string to, List<Move> moves)
        {
            if (N == 1)
            {
                EnhancedTryToMove(from, to, aux, moves);
            }
            else
            {
                /*Hanoi(N - 1, from, to, aux, moves);
                Hanoi(N - 1, aux, from, to, moves);
                TryToMove(from, aux, to, moves);
                Hanoi(N - 1, to, aux, from, moves);
                TryToMove(aux, to, from, moves);        41, neotestovano
                Hanoi(N - 1, from, aux, to, moves);*/

                Hanoi(N - 1, from, to, aux, moves); // Jdu na C

                //TryToMove(from, to, aux, moves); // Jdu na B //29
                EnhancedTryToMove(from, to, aux, moves); //27

                Hanoi(N - 1, aux, from, to, moves); // Jdu z C na B
            }
        }

        static void Move(string from, string to, string aux, List<Move> moves)
        {
            if (from == "A" && to == "B" && false)
            {
                EnhancedTryToMove(from, aux, to, moves); // was not enahnced
                EnhancedTryToMove(aux, to, from, moves);
            }
            else
            {
                //Console.WriteLine($"{from} -> {to}");
                GetStack(to).Push(GetStack(from).Pop());
                moves.Add(new Move(from, to));
            }
        }

        static Stack<Tower> GetStack(string stack)
        {
            switch (stack)
            {
                case "A":
                    return PosA;
                case "B":
                    return PosB;
                case "C":
                    return PosC;
                default:
                    throw new ArgumentException();
            }
        }

        static void TryToMove(string from, string to, string aux, List<Move> moves)
        {
            Stack<Tower> toStack = GetStack(to);
            Stack<Tower> fromStack = GetStack(from);
            int toStackNum = toStack.Count == 0 ? int.MaxValue : toStack.Peek().value;
            int fromStackNum = fromStack.Count == 0 ? int.MaxValue : fromStack.Peek().value;

            if (toStackNum < fromStackNum)
            {
                TryToMove(to, aux, from, moves);
                TryToMove(from, to, aux, moves);
                TryToMove(aux, to, from, moves);
            }
            else
            {
                Move(from, to, aux, moves);
            }
        }

        static void EnhancedTryToMove(string from, string to, string aux, List<Move> moves)
        {
            Stack<Tower> toStack = GetStack(to);
            Stack<Tower> fromStack = GetStack(from);
            int toStackNum = toStack.Count == 0 ? int.MaxValue : toStack.Peek().value;
            int fromStackNum = fromStack.Count == 0 ? int.MaxValue : fromStack.Peek().value;

            if (toStackNum < fromStackNum)
            {
                int num = toStack.ToArray().Where(x => x.value < fromStackNum).Count();
                Hanoi(num, to, from, aux, moves);
                Move(from, to, aux, moves);
                Hanoi(num, aux, from, to, moves);
            }
            else
            {
                Move(from, to, aux, moves);
            }
        }
        #endregion

        #region DoubleHanoi
        static void ClassicalHanoi(int N, string from, string aux, string to, List<Move> moves)
        {
            if(N == 1)
            {
                GetStack(to).Push(GetStack(from).Pop());
                moves.Add(new Move(from, to));
            }
            else
            {
                ClassicalHanoi(N - 1, from, to, aux, moves);
                ClassicalHanoi(1, from, aux, to, moves);
                ClassicalHanoi(N - 1, aux, from, to, moves);
            }
        }

        static void DoubleHanoi(int N, string from, string aux, string to, List<Move> moves)
        {
            // 123 ABC ___
            ClassicalHanoi(N - 1, from, aux, to, moves); // Presun zleva doprostred 1 AB2C3 ___
            Move(from, aux, to, moves); // Presun nejvetsi zleva doprava ___ AB2C3 1
            ClassicalHanoi(N * 2 - 2, to, from, aux, moves); // Presun vsechno krome nejvetsiho uplne doprava ___ A 1B2C3
            Move(to, from, aux, moves); // Presun nejvetsi zprostredka doleva A ___ 1B2C3
            ClassicalHanoi(N * 2 - 2, aux, to, from, moves); // Presun vsechno krome nejvetsiho zleva doprava AB2C3 ___ 1
            Move(aux, to, from, moves); // Presun ten nejvetsi doprostred AB2C3 1 ___
            MoveAllOfType(from, aux, to, true, moves); // ! NEFUNGUJE // Presun vsechny veze ktere byly vlevo (cisla) doprostred ABC 123 ___
            /// ABC 123 ___
        }

        static void MoveAll(int N, string from, string aux, string to, List<Move> moves)
        {
            if (N == 1)
            {
                TryToMove(from, to, aux, moves);
            }
            else
            {
                Hanoi(N - 1, from, to, aux, moves); // Jdu na C
                EnhancedTryToMove(from, to, aux, moves); //27
                Hanoi(N - 1, aux, from, to, moves); // Jdu z C na B
            }
        }

        static void MoveAllOfType(string from, string aux, string to, bool type, List<Move> moves)
        {
            Stack<Tower> towersFrom = GetStack(from);
            int towersOfType = towersFrom.Where(x => x.type == type).Count();

            int movedTowersOfType = 0;
            int movedTowersOfAnotherType = 0;

            while (movedTowersOfType < towersOfType)
            {
                Tower newTower = towersFrom.Peek();
                if (newTower.type == type)
                {
                    movedTowersOfType++;
                    EnhancedTryToMove(from, to, aux, moves); // Nefunguje
                }
                else
                {
                    movedTowersOfAnotherType++;
                    EnhancedTryToMove(from, aux, to, moves); // Mozna nefunguje
                }
            }

            for (int i = 0; i < movedTowersOfAnotherType; i++)
            {
                EnhancedTryToMove(aux, from, to, moves);
            }
        }
        #endregion
    }

    struct Move
    {
        public string From;
        public string To;

        public Move(string from, string to)
        {
            From = from;
            To = to;
        }

        public override string ToString()
        {
            return From + " " + To;
        }
    }

    struct Tower
    {
        public int value;
        public bool type;

        public Tower(int value, bool type)
        {
            this.value = value;
            this.type = type;
        }

        public override string ToString()
        {
            return $"{value} ({type})";
        }
    }
}
