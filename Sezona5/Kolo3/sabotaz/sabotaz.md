# Sabotáž

Cílem je zjistit zda bomba vybouchne. To můžeme určit následovně.

Pustíme upravený BFS. Ten bude každé hraně přiřazovat číslo, a to kolik oddělení nastalo od rootu.
Například tento příklad:

. ![graf](img.png){#id .class width=90px height=262px}

Z uzlu 0 vede jedna hrana, bude tedy mít přířazené číslo 1. Následovně z uzlu 1 vedou dvě hrany, obě dvě tedy budou mít číslo 2. Z uzlu 3 vede opět dvojková hrana, zatímco z uzlu 2 vedou dvě trojkové (opět jsou rozdělené).

Jakmile nějaké hrany jdou dovnitř uzlu (jako u uzlu 4), začnu zjišťovat, jestli je bomba validní. To je právě tehdy, když můžu zkombinovat čísla všech příchozích hran.

```
Příchozí čísla: 3, 3, 2.
Zkombinuji dvě trojky a vznikne mi dvojka: 2, 2
Zkombijuji dvě dvojky a vznikne mi jednička: 1
```

Teď už mám pouze jedno číslo, můžu tedy pokračovat a další hranu označit jako číslo, které mi vyšlo - 1. Pokud se nestane, že bych nebyl schopný čísla zkombinovat, bomba je validní.

## Proč to funguje?

Tyto dvě povolené kombinace (dvě vyšší čísla na jedno menší) a (jedno číslo se nezmění), korespondují k zadání: dvě hrany vedle sebe nebo jedna dlouhá hrana. Já akorát místo toho, abych to například řešil tím, že budu povolené hrany nahrazovat jednoduššími, si to čísluji a skládám je dohromady ve vrcholu.

Toto skládání ve vrcholu funguje vždy. Jakmile mám nějakou nekonzistenci, není možné, abych čísla zkombinoval. Díky tomu vím, že výbušnost bomby vždy určím správně.

Jediné dvě možnosti jak totiž můžu čísla kombinovat jsou ekvivalentní k zadání.

## Jak je to rychlé?

Celkově projdu až `M` hran. Pro každý uzel (z celkově `N` uzlů) budu kombinovat. Celkově budu muset kombinovat až `M` čísel.

Jak kombinuji? Postupuji od nejvyššího čísla. Pokud jich je sudý počet, zredukuji je na polovinu menších. Pokud jich je lichý počet, a existují i další čísla, bomba není validní.

Kombinace tedy trvá `O(log(X))`.

Celkově by tento algoritmus tedy měl mít složitost `O(N*log(M))`.

Petr Šťastný
