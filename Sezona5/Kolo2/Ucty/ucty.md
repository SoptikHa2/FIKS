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
|   |   |   |

Nejdříve určíme aritmetický průměr počátečních zůstatků na účtech zaokrouhlený nahoru - zde 2. Následně u všech účtů určíme rozdíl k tomuto průměru a absolutní hodnotu tohoto čísla zapíšeme buďto do posledního sloupce nebo posledního řádku tabulky. Pokud má účet menší zůstatek než je průměr, zapíšeme ho do posledního řádku, pokud větší tak ho zapíšeme do posledního sloupce. 

Poté do tabulky vyplníme ceny přesunu jednoho kreditu z účtu na účet.

|   |   |   |
|---|---|---|
|2  |2  |4  |
|2  |2  |   |
|   |   |   |

Vpravo jsou tedy všechny účty, které mají větší zůstatek než průměr (číslo je rozdíl k průměru - zde 4) a úplně dole jsou účty s nižším zůstatkem než průměr (číslo je rozdíl k průměru - zde 2 a 2). Mezi jsou čísla, které označují cenu transakce ve směru od účtu v pravém sloupci k účtu v dolním řádku.

Toto je podstatně lepší zobrazení a dovolí nám přesněji uvažovat nad způsobem řešení.

Co teď uděláme bude, že provedeme co nejlevnější transakce.

Kdybychom například měli tuto tabulku:

|   |   |   |
|---|---|---|
|1  |2  |4  |
|2  |2  |   |
|   |   |   |

Tak vybereme minimální cenu transakce (1) a provedeme převod peněz.

<br />
<br />
<br />

|   |   |   |
|---|---|---|
|1  |2  |2(-2)|
|0(-2)|2  |   |
|   |   |   |

A pokračujeme, znovu vybereme minimální cenu transakce, kde ani jeden z účtů nemá hodnotu 0.

|   |   |   |
|---|---|---|
|1  |2  |0(-2)|
|0  |0(-2)|   |
|   |   |   |

A máme řešení. Případně se prostě zastavíme před tímto momentem pokud nám dojdou peníze na transakce. Protože jsme utráceli peníze nejhospodárnějším možným způsobem a nikdy jsme nezvedli zůstatek žádného účtu nad průměr, můžeme si být jistí, že jsme situaci maximálně zlepšili, a tedy máme (téměř) optimální řešení.

Pokud by se stalo, že najdeme více hodnot se stejnou hodnotou (jako u první tabulky), je jedno co si vybereme.

Co si ale počneme s příkladem, kde účtů se zůstatkem nad maximem je více než jeden? Vybereme účet, který má nejvyšší zůstatek (A). Poté ze všech ostatních účtů  vybereme ten s nejvyšším zůstatkem (B).

Poté znovu spustíme tento algoritmus popsaný výše, až na pár změn. Zaprvé, jediný účet, ze kterého budeme předávat peníze, bude účet A. Zadruhé, místo toho, abychom účet A snižovali až na průměr, budeme ho snižovat maximálně na hodnotu účtu B.

Jestli i poté budeme mít peníze na transakce, sloučíme účty A a B. Výsledný účet A' bude mít počet peněz pořád stejný a ceny transakcí A + B.

A znovu opakujeme. Pokud je více účtů nad průměrem, sloučíme je. Pokud je jenom jeden, najdeme nejlevnější transakce a uskutečníme je.

Na konci bychom měli mít optimální řešení - až na jeden malý detail. Může se stát, především když máme malý rozpočet, že by se vyplatilo zvýšit zůstatek nějakého účtu, který má levné transakční poplatky, nad průměr zůstatků. Proto přidáme na konec následující kontrolu. Vezmeme účty s nejlevnějším a nejdražším transakčním poplatkem. Následně, pokud jsme přidávali do drahého účtu nějaké peníze, můžeme tuto platbu stornovat a místo toho začít posílat peníze na levnější účet. Toto můžeme dělat tak dlouho dokud by se nestalo, že by levný účet převýšil zůstatek původního účtu, ze kterého posíláme peníze. Následně nám může ještě zůstat nějaký rozpočet, takže můžeme převést peníze na nějaký středně drahý účet. 

Po implementaci této kontroly už bychom měli mít skutečně optimální řešení.

Základní algoritmus má složitost řádově `O(n*m)`, kde n je počet účtů a m je maximální zůstatek na libovolném účtu. Protože z n účtů vybíráme jeden na který převádíme peníze, a to provádíme m krát.


Dále mě ještě napadly dvě další možnosti řešení, ale bohužel se mi je nepodařilo dotáhnout do konce. Jedna z možností je převést si tento problém na problém dávání předmětů do batohu. Není totiž rozdíl mezi zjišťováním, na jaké účty dát peníze, a jaké předměty dát do batohu. Bohužel cena za převedený kredit (místo za transakci) toto dělá opravdu těžké, a museli bychom použít takovou implementaci problému s batohem, kdy vybíráme do batohu jeden předmět z každé kategorie (a máme více batohů). (Každá kategorie by byla jeden účet, třeba kdybychom mohli na účet převést až pět kreditů, byla by to kategorie s pěti předměty). Ale bylo by to nejspíš příliš pomalé a obtížné na implementaci.

Další možnost, která mě opravdu zaujala by bylo použít toky v sítích. Bohužel jsem nepřišel na žádný způsob jak to provést, je možné vůbec tento způsob použít? Toky v sítích jsem už používal když jsem potřeboval nějaké věci přiřazovat k sobě, což by mělo fungovat i pro tento problém, ale nevymyslel jsem způsob, který by fungoval vždy. Také je zde problém, že toky v sítích maximalizují využití (zde: našeho rozpočtu), místo maximalizace hodnoty (jako u batohu), proto bychom nejspíše museli použít nějakou implementaci s váženými vrcholy. Nepodařilo se mi na to ale vymyslet žádný spolehlivý algoritmus.

Petr Šťastný.
