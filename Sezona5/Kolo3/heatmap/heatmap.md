# Letáková kampaň

Máme mapu města, kde jsou volná pole (cesty) a budovy (překážky).

Dostaneme velké množství záznamů. Každý záznam bude obsahovat startovní a cílové políčko. Budeme hledat nejkratší cestu mezi těmito políčky a výsledek zakreslíme do mapy. Ještě ke všemu budeme muset zařizovat to, že určité záznamy budou, za předpokladu že se vyskytne více stejně krátkých cest, preferovat určité světové strany.

Jak to tedy uděláme? Dostaneme hodně dotazů na stejnou mapu, takže by se vyplatilo ji nějak zpracovat ještě před tou částí, kdy budeme zpracovávat dotazy.

Bohužel se mi nepodařilo najít dobrý způsob, jak to udělat. Takže dělám jenom to, že pomocí BFS floodfillu najdu všechny možné cesty a potom si jednu z nich vyberu na základě skupiny měst. 

Floodfill vždycky najde všechny nejkratší cesty. Do fronty ukládám souřadnice na zpracování a postupně se roztahuji do šířky, dokud jsem nenašel cíl a všechny ostatní cesty už tam nedojdou tak, aby tam byly stejně rychle. Poté jenom jdu zpátky a dávám pozor na to, abych šel na správnou světovou stranu. Celkově mám složitost pro jednu query až `O(n^2)`.

Napadl mě také tento způsob, který jsem ale nakonec neimplementoval. Zde je jeho popis, i když to pro moje řešení není relevantní:

V části zpracování mapy (před odpovídáním na dotazy) se můžeme inspirovat z reálného života, když někam jedeme. Nejdřív najdeme cestu do města, a až poté dohledáváme jednotlivé ulice.

Budeme postupovat stejně. Mapu si rozdělíme na regiony. Každý region bude obsahovat nemalé množství vlastních políček. Ke každému regionu si napíšeme, jestli se přes něj dostaneme k jeho sousedům. 

Jakmile tedy budeme hledat cestu z regionu A do regionu B, použijeme opět algoritmus pro hledání nejkratší cesty - ale tentokrát pro regiony, nemusíme se obtěžovat tím, že budeme procházet všechny možná políčka. Prostě zjistíme, kterými regiony musíme projít, abychom se dostali do cílového regionu B co nejrychleji. Poté už konkrétní cestu najdeme klasicky.

Máme zde ovšem problém. Některé regiony mohou být postaveny tak, že sice projdeme nejmenším počtem regionů, ale nebude to nejkratší cesta. Budeme si tedy muset u regionů zároveň říct, jak dlouho zabere cesta k jinému regionu. To nám algoritmus zpomalí, ale zároveň zjistíme, přes které regiony je cesta opravdu nejkratší. Zároveň je vhodné volit regiony tak, abychom měli jistotu, že všechna políčka v regionu jsou spolu propojená. Pokud zároveň zvolíme regiony tak, aby všechna políčka na jedné straně byla spojena (tedy stěny regionu jsou buď všechny průchozí, nebo všechny neprůchozí), máme jistotu, že zvolená cesta regiony bude ta nejkratší.

Jak konkrétně budeme hledat nejkratší cestu? Použijeme floodfill, kde budeme upřednostňovat políčka, která jsou blíže cílovému políčku, což by mělo zrychlit vyhledávání. 

Jakmile tedy najdeme nejkratší cestu regiony, můžeme se pustit do hledání nejkratší obecné cesty. Zde využijeme toho, že víme přes jaké regiony budeme procházet a můžeme ignorovat políčka mimo tyto regiony.

Petr Šťastný