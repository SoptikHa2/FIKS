# Kalendář

*Řešení jsem napsal v [Dartu](https://www.dartlang.org/).*

`$ dart Kalendar-Petr-Stastny.txt`

Cílem je přenést datum z gregoriánského kalendáře do kalendáře Velkého Vůdce.

Ve výstupu má být následující: den v týdnu, den v měsíci, měsíc, rok.

Pro nastavení parametrů používám třídu `Settings`. V metodě `getNewCalendarDate` je možné použít vlastní nastavení (místo `Settings.preset()`). Díky tomu můžeme velmi rychle a jednoduše kdykoliv změnit pravidla kalendáře Velkého Vůdce.

## Popis výpočtu

### Den v týdnu

Nejdříve vypočítáme, kolik dní po dni nula (datum narození Velkého Vůdce) se zrovna nachází zadané datum - toto používáme pro ostatní výpočty.

Jednoduše vezmeme zadané datum a zjistíme rozdíl k začátku kalendáře Velkého Vůdce.

Teď je potřeba zjistit den v týdnu. Ten získáme počtem dní po dni nula (vypočítáno v předchozím kroku) modulo počet dní v týdnu.


### Rok

Rok v kalendáři Velkého Vůdce získáme následovně. Nejdříve si spočítáme počet dní za 3 roky (tedy přestupný cyklus) a za 300 let (přestupný cyklus včetně roku dělitelného 100, který nikdy není přestupný).

Nyní vezmeme počet dní od začátku kalendáře Velkého Vůdce, a zjistíme, kolikrát se opakuje 300-letý cyklus, poté kolikrát je ve zbylém počtu dní 3-letý cyklus a kolik normálních let. Rok 905 tedy bude mít 3 300-leté cykly (905 -> 005), jeden 3-letý cyklus (005 -> 002) a dva normální roky.

Teď můžeme zjistit rok tak, že vezmeme počet 300-leté cyklů, vynásobíme je 300. K tomu přičteme počet 3-letých cyklů vynásobených 3 a k tomu přičteme ještě počet let. Po několika kontrolách (například že den 0 roku 10 je ve skutečnosti poslední den roku 9) máme vypočítaný rok

### Den v roce

Konečně můžeme zjistit den v roce. Tento výpočet budeme potřebovat pro výpočet měsíců.

Toto číslo je počet dní v předchozích rocích (jako kdyby žádné nebyly přestupné) + počet dní navíc v přestupných rocích. 

Počítám to následovně:


<br />

<br />

<br >


```
Počet dní, když žádné roky nejsou přestupné +
Počet dní navíc v přestupných rocích, ignorujeme pravidlo kdy přestupné roky přestupné nejsou -
Počet dní navíc v speciálně nepřestupných rocích (rok dělitelný 100 a zároveň dělitelný 3)
```

### Měsíc a den v měsíci

Nejdřív zjistíme, jestli budeme používat normální počty dní v měsících, nebo speciální počty dní v měsících (během přestupného roku jsou některé měsíce delší).

Následně bude muset použít cyklus. Prostě budeme iterovat přes měsíce a budeme počítat kolik dní v tomto roce ještě zbývá. Takto zjistíme rovnou dvě informace které potřebujeme - měsíc a počet dní v měsíci.

## Složitost

Jediný cyklus je iterování přes měsíce, zbytek programu je konstantní - časová složitost je tedy `O(m)` (m - počet měsíců).



Petr Šťastný