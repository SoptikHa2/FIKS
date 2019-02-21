# Meziměstská doprava

Máme několik málo měst, ve kterých žije obrovské množství lidí, každý má přiřazené ID, unikátní pouze v rámci města. Lidé se přepravují mezi městy přepravníky. Každý přepravník veze interval A-B lidí. Kdo zůstal v jiném městě? Víme že vyjel z města 0.

Uděláme to následovně - budeme monitorovat všechna města kromě města 0, o které se nemusíme starat. Pro každé město vytvoříme nějakou vhodnou datovou strukturu - nabízí se segmentový strom, do které budeme zaznamenávat příchozí/odchozí transporty lidí.

Díky tomuto segmentovému stromu zjistíme maximum všech lidí ve městě. Pokud tedy na konci dne v nějakém městě bude existovat maximum 2, víme, že tam je hledaná osoba. Najít ID této osoby je potom triviální. Pokud v žádnem z 24 monitorovaných měst nebudou dva lidé se stejným ID, náš odvážlivec zůstal v městě 0.

Díky zaznamenávání veškeré dopravy jasně zjistíme, kdo je hledaná osoba a v jakém městě.

Jak ale segmentový strom správně implementovat? Ve městě může být až 10^25 lidí, což je obrovské číslo. Proto uděláme následující segmentový strom.

Zaprvé, bude děravý. Místo toho, abychom na začátku celý segmentový strom sestavili, postavíme jenom kořen. Ten bude zastupovat klasicky interval 0-10^25. Ve chvíli, kdy dorazí (nebo odejde) transport, který nebude mít přímo tento interval, budeme pokračovat v budování - například kdyby transport vezl pouze první půlku lidí z města, prostě do stromu přidáme další list - který bude zastupovat první půlku lidí z města. Takhle budeme pokračovat. Prostě budeme strom stavět postupně, když to zrovna bude nutné. Díky tomu ušetříme obrovské množství paměti.

Zadruhé, bude líný. Toto asi není nutné, ale to, že nebudeme muset aktualizovat velkou část stromu při každém transportu nám opravdu hodně urychlí nalezení výsledku. Tedy když nám přijde nebo odejde transport, nebudeme přepočítávat všechny uzly, kterých se to týká. Jenom si poznačíme u daných intervalů "tady přišel/odešel transport". Toto nám strom značně zrychlí, protože ho budeme nějak důkladně aktualizovat a prohledávat pouze jednou, a to na konci dne.

Postup tedy bude vypadat nějak takto:

```
prichoziTransport:
    ziskej nejvetsi interval(y), ktere pojmou interval transportu a jsou/muzou byt primo zaznamenany v segmentovem strome
        pokud nejaky z intervalu neexistuje, vytvor ho
        inktermentuj pocet prichozich transportu na tomto intervalu
odchoziTransport:
    ziskej nejvetsi interval(y), ktere pojmou interval transportu a jsou/muzou byt primo zaznamenany v segmentovem strome
        pokud nejaky z intervalu neexistuje, vytvor ho
        dekrementuj pocet prichozich transportu na tomto intervalu

konecDne:
    pro vsechna mesta s ID 1-24:
        uprav segmentovy strom tak, abychom mohli zjistit maximum
        (tedy odznac vsechny pocty prichozich transportu a pricti/odecti k
        odpocidajicim uzlum toto cislo)
        najdi maximum na celem strome
        pokud je > 1:
            hledana osoba je zde
            pouzij binarni vyhledavani abys v logaritmickem case nasel ID hledane osoby
            konec
    # v tomto miste vime ze nikdo nebyl nalezen
    hledana osoba je ve meste 0
    konec
```

Vybudování a připravení stromu k dotazům stojí až `O(n*log(n))`, kde `n` je počet intervalů přepravených lidí (resp. počet dostavníků). Potom jenom zjistíme ve kterém městě je nachází někdo navíc - což lze zjistit v triviálním čase - a následně, pokud je v nějakém městě, ho binárně najdeme. Takže půjde z vrcholu segmentového stromu dolů, vždy se zeptáme ve které půlce intervalu se nachází a tam sestoupíme - dokud nedorazíme na konec a nenajdeme ID daného člověka. Toto hledání zvládneme v `O(log(n))`. 

Celková složitost by tedy měla být řádově `O(n*log(n))`. 

Petr Šťastný