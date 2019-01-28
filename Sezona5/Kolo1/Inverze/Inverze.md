# Inverze

Nejjednodušší způsob, jak vytvořit řetězec čísel o požadovaném počtu inerzí, je prostě vytvořit řetězec, co obsahuje co nejvíce inverzí, a potom zleva doplňovat čísla abychom dosáhli požadované délky řetězce.

Nejdříve tedy potřebujeme zjistit: s počtem N unikátních čísel a délkou M, kolik inverzí dokážeme vytvořit?

## Maximální počet inverzí

Pokud bychom vzali úplně ten nejjednodušší případ a pro N=4, M=12, udělali toto:

`4321 4321 4321`

Budeme mít celkem 36 inverzí.

To můžeme spočítat jako `suma(1..pocet_skupin) * suma(1..(n-1))`, kde počet skupin je číslo, které udává kolikrát se opakuje řetězec 4321.

Pokud nemáme celý řetězec, můžeme jeho počet inverzí později přičíst. Počet inverzí v řetězci na pozici a se počítá `a*(suma(1..(max_cislo-1)))` - tedy u 321 4321 4321 spočítáme počet inverzí v řetězci 321 jako `3*(1+2)` - tedy 9.

Počet inverzí v řetězci 4321 4321 4321 je tedy `(1+2+3) * (1+2+3) = 6*6 = 36`. 

Toto ale není maximální počet inverzí, který můžeme vytvořit. Například následující řetězec: 4432 4321 4321 má inverzí více.

(...)

## Algoritmus

