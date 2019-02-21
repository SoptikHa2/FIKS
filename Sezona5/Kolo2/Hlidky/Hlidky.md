# Hlídky

*Řešení jsem napsal v [Dartu](https://www.dartlang.org/).*

`$ dart Hlidky-Petr-Stastny.txt`


Cílem je napsat program, který najde cestu mezi dvěma vrcholy grafu tak, aby maximální vzdálenost (počet kontrol) na všech hranách cesty byla co nejnižší.

Toho můžeme docílit následujícím algoritmem:

```
mozneCesty = [] // Libovolna kolekce, ktera nam umoznuje rychle najit nejkratsi moznou cestu
lokace = startovniMesto
pridej do mozneCesty vsechny cesty z startovniMesto
loop:
    pokud lokace je ciloveMesto:
        konec, mame reseni
    dalsiCesta = najdiNejkratsiCestu(mozneCesty) // Vyloucime cesty, ktere jdou do mesta, ktere jsme uz navstivili
    pokud dalsiCesta neexistuje:
        konec, reseni neexistuje
    
    jdi(dalsiCesta)
    lokace = dalsiCesta.noveMesto
    pridej do mozneCesty vsechny cesty z lokace // Vyloucime cesty, ktere jdou do emsta, ktere jsme uz navstivili
```

V podstatě to tedy funguje takto. Jdeme z města A do města B. Pokaždé, když se objevíme v novém městě, přidáme všechny cesty, které z něj vedou do libovolného nenavštíveného města do seznamu možných cest. Vybereme z tohoto seznamu nejkratší cestu vedoucí do nenavštíveného města, odstraníme ji z daného seznamu a jdeme po ní. Toto opakujeme dokud se nedostaneme do města B. Protože jsme celou dobu chodili po nejkratších možných cestách, nemůže existovat cesta, která neobsahuje nejdelší cestu, po které jsme šli. Celkově navštívíme řádově až `n` cest, s tím že hledání minima je triviální a mazání cest vedoucích do navštívených měst zvládneme v `log(n)`.

Časová složitost může tedy být až řádově `O(n*log(n))` - `n` je počet cest (při volbě vhodné kolekce, která dovoluje hledání minima v O(1) - samozřejmě se nabízí použít haldu, v mé implementaci jsem použil párovací haldu).

Petr Šťastný