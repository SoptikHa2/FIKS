# Meziměstská doprava

*Řešení jsem napsal v [Dartu](https://www.dartlang.org/).*

`$ dart Hlidky-Petr-Stastny.txt`


Cílem je napsat program, který najde cestu mezi dvěma vrcholy grafu tak, aby maximální vzdálenost (počet kontrol) na všech hranách cesty byla co nejnižší.

Toho můžeme docílit následujícím algoritmem:

```
// zaciname na vrcholu A, ze ktereho se mame dostat do vrcholu B
// mame seznam vrcholu, k nekterym z nich budeme postupne prirazovat cisla
loop:
    pokud jsme na vrcholu B:
        konec

    vyber nejkratsi cestu z tohoto vrcholu co vede k nenavstivenemu vrcholu
    pokud zadna takova cesta neexistuje:
        jdi k vrcholu s nejmensim cislem v seznamu
        pokud takovy vrchol neexistuje, konec
        jinak: goto loop
    pokud je delka teto cesty kratsi, nez nejmensi cislo ze seznamu vrcholu:
        k tomuto vrcholu zapis delku druhe nejkratsi cesty (nebo ∞, pokud takova cesta neexistuje)
        jdi po ceste k dalsimu vrcholu
        goto loop
    jinak:
        zapis delku teto cesty k tomuto vrcholu
        jdi na vrchol s nejmensim cislem v seznamu
        goto loop
```

V podstatě to tedy funguje takto. Cestujeme z vrcholu A, a to vždy po nejkratší možné cestě (tedy s nejmenším počtem hlídek). Takto postupujeme dokud nedorazíme do vrcholu B. Jelikož jsme celou dobu chodili po těch nejkratších možných cestách, určitě je maximum těchto vzdáleností minimální - tedy máme cestu, kde maximální počet hlídek mezi městy je co nejmenší.

Časová složitost může být až řádově `O(n)` - `n` je počet cest (při volbě vhodně kolekce, která dovoluje hledání minima (a ideálně i vkládání) v O(1) - například Fibonacciho halda).

Moje implementace používá binární haldu, takže složitost by měla být řádově `O(n*log(m)*log(n))` (m - počet měst) kvůli logaritmické časové složitosti při budování haldy.

Petr Šťastný