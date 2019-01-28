# Inverze

Nejjednodušší způsob, jak vytvořit řetězec čísel o požadovaném počtu inerzí, je prostě vytvořit řetězec, co obsahuje co nejvíce inverzí, a potom zleva doplňovat čísla abychom dosáhli požadované délky řetězce.

Nejdříve tedy potřebujeme zjistit: kolik inverzí dokážeme vytvořit s počtem N unikátních čísel a délkou řetězce M?

## Maximální počet inverzí

Pokud bychom vzali úplně ten nejjednodušší případ a pro N=4, M=12, udělali toto:

`4321 4321 4321`

Budeme mít celkem 36 inverzí.

To můžeme spočítat jako `suma(1..pocet_skupin) * suma(1..(n-1))`, kde počet skupin je číslo, které udává kolikrát se opakuje řetězec 4321.

Pokud nám po vytvoření skupin (4321) ještě několik pozic přebývá, můžeme zbývající počet inverzí později přičíst. Počet inverzí ve skupině na pozici a (počítáno zprava doleva) se počítá `a*(suma((min_cislo)..(max_cislo-1)))` - tedy u 321 4321 4321 spočítáme počet inverzí ve skupině 321 jako `3*(1+2)` - tedy 9. (Případně 432 by se spočítalo `a*suma(2..max_cislo-1)))`, tedy `3*(2+3)`, tedy 15.)

Počet inverzí v řetězci 4321 4321 4321 je tedy `(1+2+3) * (1+2+3) = 6*6 = 36`. 

Toto ale není maximální počet inverzí, který můžeme vytvořit. Například následující řetězec: 4432 4321 4321 má inverzí více.

V každé skupině totiž můžeme inkrementovat číslo (z `a` na `b`), díky čemuž ztratíme (počet_čísel_vlevo_rovných_b) a získáme (počet_čísel_vpravo_rovných_a) inverzí.

Čísla se vyplatí takovýmto způsobem inkrementovat, dokud získáme víc inverzí než kolik ztratíme. Jakmile máme vytvořenou řadu takovou, že už se nevyplatí dále inkrementovat, máme maximální počet inverzí.

## Algoritmus

Obecně to uděláme následovně: Budeme tvořit řetězec s co nejvíce inverzemi. Jestliže přesáhneme při vytváření inverzí délku řetězce, a nedosáhli jsme počtu inverzí, nejde to. Jestliže skončíme s vytvářením inverzí a ještě musíme délku řetězce doplnit, prostě budeme doleva dopisovat nejnižší čísla (zde: 1), aby nevznikaly další inverze a přesto se délka řetězce zvětšovala.

```
velikostSkupiny = pocet_moznych_cisel


// Tady udelame klasickou posloupnost 4321 4321 ...
while zbyvajiciPocetInverzi - inverzeZJedneSkupiny > 0:
    if delkaRetezce + velikostSkupiny >= maximalniDelkaRetezce:
        break
    
    // napriklad pro N=4: retezec = "4321" + retezec;
    pridejDoRetezceDoleva(pocet_moznych_cisel .. 1)

// Ted mame klasickou posloupnost

// Doplnime jednicky (coz je nejnizsi cislo v retezci, takze nezpusobuje dalsi inverze)
// dokud nebudeme splnovat podminku o delce retezce
pridejDoRetezceDoleva("1" * (maximalniDelkaRetezce - delkaRetezce))

// Dokud nebude vyrovnany pocet inverzi, budeme inkrementovat
pozice = nejvicVlevo
while zbyvajiciPocetInverzi > 0:
    if pocetDalsichSkupinVpravo + pocetNoveDoplnenychJednicekVpravo > pocetCiselVlevo:
        // pocetNoveDoplnenychJednicekVpravo je pocet cisel 1 doplnenych v minulem kroku
        inkrementujTohleCislo()
        if tohleCislo == maximalniCislo:
            pozice += 1 // A jdi doprava

// Ted mame inkrementovany retezec
if zbyvajiciPocetInverzi > 0:
    // Ted uz neni moznost jak udelat dostatek inverzi
    return "neexistuje"

// Hotovo!
return retezec
```

## Shrnutí

Nejdříve udělám klasickou posloupnost typu 4321 4321 4321. Zde se pokusím dostat na nulový počet zbývajících inverzí, nebo tak blízko jak je to jenom možné.

Potom doplním zbytek čísel v délce řetězce něčím, co nemění počet inverzí - třeba jedničkou. Abych dosáhl délky 15 čísel, bylo by to 111 4321 4321 4321.

Následně, pokud ještě mám přidávat další inverze, tak přidávám inkrementací - tedy zvyšuji čísla. Tím získávám inverze navíc.

Pokud jsem inkrementoval maximálně (další inkrementace by počet inverzí snižovala), a pořád nějaké inverze potřebuji navíc - nejde to.

Pokud jsem už ale všechny inverze vytvořil, můžu vrátit řetězec.

## Složitost

Časovou složitost odhaduji na řádově lineární.

Petr Šťastný