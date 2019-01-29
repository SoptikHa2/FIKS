# Inverze

Nejjednodušší způsob, jak vytvořit řetězec čísel o požadovaném počtu inerzí, je prostě vytvořit řetězec, co obsahuje co nejvíce inverzí, a potom zleva doplňovat čísla abychom dosáhli požadované délky řetězce.

Nejdříve tedy potřebujeme zjistit: kolik inverzí dokážeme vytvořit s počtem N unikátních čísel a délkou řetězce M?

## Maximální počet inverzí

*Poznámka: `suma(x..y)` znamená součet všech čísel od `x` do `y` včetně, v krocích po 1. Například `suma(1..5) = 1+2+3+4+5`.*

Pokud bychom vzali úplně ten nejjednodušší případ a pro N=4, M=12, udělali toto:

`4321 4321 4321`

Budeme mít celkem 36 inverzí.

To můžeme spočítat jako `suma(1..pocet_skupin) * suma(1..(n-1))`, kde počet skupin je číslo, které udává kolikrát se opakuje řetězec 4321. (Předpokládám, že nejnižší použité číslo je 1).

Konkrétně pro určitou skupinu čísel spočítáme počet inverzí jako `a*(suma((min_cislo)..(max_cislo - 1)))`, kde a je pozice skupiny (zprava doleva). Například v řetězci 432 4321 4321 by byl počet inverzí, které jsou vygenerované skupinou 432, `3*suma(2..3) = 3*(2+3) = 3*5 = 15`.

Počet inverzí v řetězci 4321 4321 4321 je tedy `(1+2+3) * (1+2+3) = 6*6 = 36`. 

Toto ale není maximální počet inverzí, který můžeme vytvořit. Například následující řetězec: 4432 4321 4321 má inverzí více.

V každé skupině totiž můžeme inkrementovat číslo (z `a` na `b`), díky čemuž ztratíme (počet_čísel_vlevo_rovných_b) a získáme (počet_čísel_vpravo_rovných_a) inverzí.

Čísla se vyplatí takovýmto způsobem inkrementovat, dokud získáme víc inverzí než kolik ztratíme. Jakmile máme vytvořenou řadu takovou, že už se nevyplatí dále inkrementovat, máme maximální počet inverzí.

## Algoritmus

Obecně to uděláme následovně: Nejdříve vytvoříme co nejdelší řadu inverzí typu 4321 4321. Uděláme ji tak dlouhou, abychom nám zbývalo udělat co nejméně inverzí (ale v žádném případě se nesmí stát, že bych vytvořil víc inverzí než potřebujeme).

Potom doplním řádu jedničkami (budu je přidávat doleva), abych dosáhl cílové délky řetězce (třeba 111 4321 4321).

Následně budeme inkrementovat dokud nedosáhneme požadovaného počtu inverzí. Když se nám po inkrementaci nepodaří dosáhnout požadovaného počtu inverzí, výsledku nelze dosáhnout.

Inkrementace probíhá tak, že postupujeme zleva doprava a hledáme číslo, které po inkrementaci přidá inverze - ale ne tolik, abychom měli víc inverzí než kolik potřebujeme. Jakmile takové číslo najdeme, tak ho zkoušíme inkrementovat. Inkrementace čísla zvýší jeho hodnotu o 1.

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
    pocetInverziZiskanyToutoInkrementaci = pocetDalsichSkupinVpravo + pocetNoveDoplnenychJednicekVpravo - pocetVetsichCiselVlevo // pocetNoveDoplnenychJednicekVpravo je pocet cisel 1 doplnenych v minulem kroku
    if pocetInverziZiskanyToutoInkrementaci > zbyvajiciPocetInverzi:
        pozice += 1 // Kdyz bychom vytvorili vic inverzi nez kolik potrebujeme, jdi doprava
    if pocetInverziZiskanyToutoInkrementace > 0:
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

Časovou složitost odhaduji na řádově lineární. Oba dva cykly totiž nejsou vnořené a nebudou běžet déle než lineárně.

Petr Šťastný