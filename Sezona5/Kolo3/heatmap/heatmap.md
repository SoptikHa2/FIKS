# Letáková kampaň

Máme mapu města, kde jsou volná pole (cesty) a budovy (překážky).

Dostaneme velké množství záznamů. Každý záznam bude obsahovat startovní a cílové políčko. Budeme hledat nejkratší cestu mezi těmito políčky a výsledek zakreslíme do mapy. Ještě ke všemu budeme muset zařizovat to, že určité záznamy budou, za předpokladu že se vyskytne více stejně krátkých cest, preferovat určité světové strany.

Jak to tedy uděláme? Dostaneme hodně dotazů na stejnou mapu, takže by se vyplatilo ji nějak zpracovat ještě před tou částí, kdy budeme zpracovávat dotazy.

Bohužel se mi nepodařilo najít dobrý způsob, jak to udělat. Takže dělám jenom to, že pomocí BFS floodfillu najdu všechny možné cesty a potom si jednu z nich vyberu na základě skupiny měst. 

## Použité řešení

Začnu od koncového bodu (kvůli hledání trasy podle skupiny měst). Ten si uložím do fronty a spustím floodfill.

Ten funguje tak, že výchozímu bodu přiřadím hodnotu 1. Všem jeho sousedům hodnotu 2 (pomocí fronty se na ně volám jednoho po druhém, používám zde BFS). Z nich opět přiřadím jejich sousedům hodnotu 3. Takto pokračuji, dokud jsem nedosáhl cíle nebo dokud jsem nezaplnil všechny políčka kam dokážu dojít. S jednou drobnou úpravu. Po dosažení cíle neskončím algoritmus hned, ale ještě nechám dojet ostatní cesty se stejnou délku. Díky tomu získám všechny nejkratší cesty. Bude to trvat až kvadraticky dlouho.

Následuje fáze, kdy jdu ze startu (který má nejvyšší číslo) a snažím se jít co nejvíce dolů (na čísle 1 mám konec, kam se chci dostat). Pokud mám víc různých nejmenších čísel na výběr, určím si to podle cílové skupiny měst. 

Při tomto postupu zároveň barvím mapu.

Celkově mám pro každou query kvadratickou složitost (vzhledem k délce strany mapy).

## Rychlé řešení

Napadl mě také tento způsob, který jsem ale nakonec neimplementoval. Zde je jeho popis, i když to pro moje řešení není relevantní.

Jak jsem již psal v úvodu, pro větší rychlost si mapu nějak předzpracovat do lepší podoby.

V této části zpracování mapy (před odpovídáním na dotazy) se můžeme inspirovat z reálného života, když někam jedeme. Nejdřív najdeme cestu do města, a až poté dohledáváme jednotlivé ulice.

Budeme postupovat stejně. Mapu si rozdělíme na regiony. Každý region bude obsahovat nemalé množství vlastních políček. Ke každému regionu si napíšeme, jestli se přes něj dostaneme k jeho sousedům. 

Jakmile tedy budeme hledat cestu z regionu A do regionu B, použijeme opět algoritmus pro hledání nejkratší cesty - ale tentokrát pro regiony, nemusíme se obtěžovat tím, že budeme procházet všechny možná políčka. Prostě zjistíme, kterými regiony musíme projít, abychom se dostali do cílového regionu B co nejrychleji. Poté už konkrétní cestu najdeme klasicky, ale pouze uvnitř regionů, u kterých víme, že je projedeme - budeme díky tomu procházet značně menší část mapy.

Jak rychle by to ale bylo? Pokud vezmeme nejhorší příklad mnou použitého způsobu (prázdná mapa), tak složitost mám přímo `O(N^2)`. Tento postup, který jsem nepoužil, by dokázal na stejné mapě dosáhnout řádově lineární složitosti. Proč?

Čtvercovou mapu o straně `N` si můžeme rozdělit na regiony o straně `sqrt(N)`. Při query nejdříve určíme regiony, které budeme prohledávat, což bude trvat `N` (pokud hledám vyloženě propojené regiony tak, aby jejich počet byl co nejnižší). Tyto regiony mi omezí vyhledávácí oblast na řádově lineární.

Má to ale menší háček. Nevím, jak efektivně rozdělit regiony tak, aby to bylo rychlé a fungovalo vždy. Kdybychom to rozdělovali přesně na `sqrt(N)`, tak to prostě nebude fungovat - to, že nějaké regiony nepůjdou projít na druhou stranu se dá zjistit a zakomponovat do hledacího algoritmu, ale nepodařilo se mi najít důkaz, že cesta přes co nejmíň regionů bude vždy nejkratší. Vlastně si jsem skoro jistý, že to není pravda.

V tuto chvíli se nám tedy hledání regionů komplikuje. Musíme zajistit, že cesta přes nejmenší počet regionů bude nejkratší, a ideálně aby byly regiony co nejvíc průchozí (a zároveň aby se nestalo, že budeme ve stejném regionu jako cíl, ale v našem regionu tam nebude vést cesta). Tím samozřejmě nebudeme mít regiony o stejných rozměrech, a zase se nám to tedy dál komplikuje.

Celkově tedy můžu říct, že ačkoliv mě tato možnost rozdělení na regiony láká, a velmi rád bych ji implementoval, nepodařilo se mi najít stabilní způsob, jak rozdělit mapu na regiony tak, aby vše fungovalo rychle a efektivně.

Petr Šťastný