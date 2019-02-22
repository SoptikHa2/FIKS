# Srovnání účtů

Nejdříve si vstup přepíšeme do tabulky, abychom mohli jednodušeji najít řešení.

Například tento vstup:
```
6 0 0
1 1 1
1 1 1
```
přepíšeme následovně:
|   |   |   |
|---|---|---|
|   |   |4  |
|2  |2  |   |

Nejdříve určíme aritmetický průměr počátečních zůstatků na účtech zaokrouhlený nahoru - zde 2. Následně u všech účtů určíme rozdíl k tomuto průměru a absolutní hodnotu tohoto čísla zapíšeme buďto do posledního sloupce nebo posledního řádku tabulky. Pokud má účet menší zůstatek než je průměr, zapíšeme ho do posledního řádku, pokud větší tak ho zapíšeme do posledního sloupce. 

Poté do tabulky vyplníme ceny přesunu jednoho kreditu z účtu na účet.

|   |   |   |
|---|---|---|
|2  |2  |4  |
|2  |2  |   |

Vpravo jsou tedy všechny účty, které mají větší zůstatek než průměr (číslo je rozdíl k průměru - zde 4) a úplně dole jsou účty s nižším zůstatkem než průměr (číslo je rozdíl k průměru - zde 2 a 2). Mezi jsou čísla, které označují cenu transakce ve směru od účtu v pravém sloupci k účtu v dolním řádku.

Toto je podstatně lepší zobrazení a dovolí nám přesněji uvažovat nad způsobem řešení.

Co teď uděláme bude, že provedeme co nejlevnější transakce.

Kdybychom například měli tuto tabulku:

|   |   |   |
|---|---|---|
|1  |2  |4  |
|2  |2  |   |

Tak vybereme minimální cenu transakce (1) a provedeme převod peněz.

|   |   |   |
|---|---|---|
|1  |2  |2(-2)|
|0(-2)|2  |   |

A pokračujeme, znovu vybereme minimální cenu transakce, kde ani jeden z účtů nemá hodnotu 0.

|   |   |   |
|---|---|---|
|1  |2  |0(-2)|
|0  |0(-2)|   |

A máme řešení. Případně se prostě zastavíme před tímto momentem pokud nám dojdou peníze na transakce. Protože jsme utráceli peníze nejhospodárnějším možným způsobem a nikdy jsme nezvedli zůstatek žádného účtu nad průměr, můžeme si být jistí, že jsme situaci maximálně zlepšili, a tedy máme optimální řešení.

Pokud by se stalo, že najdeme více hodnot se stejnou hodnotou (jako u první tabulky), je jedno co si vybereme.

Co si ale počneme s příkladem, kde účtů se zůstatkem nad maximem je více než jeden? Vybereme účet, který má nejvyšší zůstatek (A). Poté ze všech ostatních účtů  vybereme ten s nejvyšším zůstatkem (B).

Poté znovu spustíme tento algoritmus popsaný výše, až na pár změn. Zaprvé, jediný účet, ze kterého budeme předávat peníze, bude účet A. Zadruhé, místo toho, abychom účet A snižovali až na průměr, budeme ho snižovat maximálně na hodnotu účtu B.

Jestli i poté budeme mít peníze na transakce, sloučíme účty A a B. Výsledný účet A' bude mít počet peněz pořád stejný a ceny transakcí A + B.

A znovu opakujeme. Pokud je více účtů nad průměrem, sloučíme je. Pokud je jenom jeden, najdeme nejlevnější transakce a uskutečníme je.

Na konci máme určitě nejoptimálnější řešení - vždy jsme z účtu s maximálním zůstatkem odebírali peníze co nejlevněji.

TODO: složitost, přidat do účtu nad průměrem, backpack problem, flow in network