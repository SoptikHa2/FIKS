# Kód

Máme komunikační linku mezi dvěma body a chceme převést zprávu o délce N. Na komunikační lince se mohou vyskytovat chyby.

Dále víme, že každá chyba flipne všechny bity až do konce zprávy, že mezi chybami je vždy lichý počet bitů, a že mezi chybami je alespoň k bitů.

Základ tedy bude si zprávu rozdělit na jednotlivé "pakety" - úseky, o kterých víme, že v nich bude maximálně jedna chyba. Na konec každého "paketu" přidáme bit 0 - takto budeme vědět, jestli nastala chyba. 

*Pozn: funkce zn(N) zaokrouhlí číslo N nahoru.*

Délka paketu bude `2*zn(k/2)`. Tímto vzorcem získám nejbližší vyšší sudé číslo od k - což je nejvzdálenější místo, na kterém ještě nemůže být chyba.

Jakmile si zprávu pomyslně rozdělíme na pakety, můžeme za každý paket připsat kontrolní bit 0. Tímto pro `m` chybných paketů bude výsledná délka této zprávy n+m.

Co uděláme, pokud bude některý z paketů špatně? Příjemce po každém přijatém paketu pošle dva bity - první, který označuje jestli paket přišel správně, a druhý, který by měl být vždy 0. Odesílatel po přijmutí paketu zkontroluje kontrolní (druhý) bit a případně flipne bit první. Pokud bude první bit 1 (paket přišel s chybou), bude nutné odeslat paket náhradní. (Pozn: pokud by bylo zadané, že zprávy nedorazí okamžitě, nebo nemáme záruku že pakety dorazí ve správném pořadí, je triviální s každým paketem stejným způsobem poslat i identifikační číslo paketu.)

Jak tedy odešleme chybný paket? Prostě ho poslat znova nestačí - může se vloudit další chyba a to by bylo - především při vyšší chybovosti - příliš drahé.

Proto do paketu přidáme další kontrolní bity. Konkrétně tak, že paket rozdělíme na dva menší, tedy s dvěma kontrolnímy bity (dva bity navíc (jeden u odesílatele, druhý u příjemce), které v tomto kroku použijeme, je dle mého při nestabilní síti lepší řešení, než kdybychom museli několikrát posílat celý paket znovu). Pakety pošleme, a zase si je příjemce zkontroluje. Pokud je některá z půlek špatně, opět se to stejným způsobem dozví odesílatel, který opět půlku pokud možno rozdělí na dvě menší a postup se opakuje. Náhradních paketu se při extrémně špatných podmínkách pošle `log(délka_paketu)` (protože v opravném paketu nemohou být dvě chyby).

Ještě chybí jedna drobnost: pokud příjemce zjistí přijetí chybného paketu, musí přirozeně u dalších paketů chybu kompenzovat flipnutím bitů.

## Zakódování zprávy

```
velikostPaketu = 2*zn(k/2)-1
dokud jsou nějaké neodeslané bity zprávy:
    pošli 2*zn(k/2)-1 bitů zprávy a přidej bit 0
    přijmi dva bity
    pokud je druhý bit 1, flipni první bit
    pokud je první bit 0:
        pokračuj
    pokud je první bit 1:
        pošliOpravnýPaket(původněOdeslanéBity)

def pošliOpravnýPaket(původněOdeslanéBity)
    pošli první polovinu z původněOdeslanéBity
    pošli bit 0

    pokud původněOdeslanéBity.délka = 1
        konec (vrať se z funkce)
        
    pošli druhou polovinu z původněOdeslanéBity
    pošli bit 0
   
    přijmi 3 bity
    pokud je 3. bit 1, flipni 1. a 2. bit
    pokud je 1. bit 1:
        pošliOpravnýPaket(1. polovina původně odeslaných bitů)
    pokud je 2. bit 1:
        pošliOpravnýPaket(2. polovina původně odeslaných bitů)
    
    konec (vrať se z funkce)
```

Posíláme tedy zprávu, do které na vhodná místa umístíme kontrolní bity co jsou vždy 0. Jakmile příjemce zjistí, že se nějaký z paketů poškodil, řekne nám to, a mi mu pošleme opravný bit. Opravný bit má dva kontrolní bity - tedy pokud se opravný bit znovu poškodí, pošleme znovu jenom poškozenou půlku. (poznámka: pokud odesíláme opravný bit o délce 1, prostě ho pošleme s kontrolním bitem a ani nečekáme na odpověď, která není potřeba.) Takto odešleme celou zprávu.

## Dekódování zprávy

```
dokud ještě zbývá přijmout nějaké bity zprávy:
    přijmi jeden paket
    pokud je poslední bit 1:
        odešli 10
        uložPaket <- přijmiOpravnýPaket(paket.délka+1)
        flipovat = negace(flipovat)
    jinak:
        odešli 00
        uložPaket <- přijatý paket


def přijmiOpravnýPaket(délka)
    přijmi "délka" bitů
    pokud je délka 2:
        pokud je 2. bit 1: flipni 1. bit
        vrať 1. bit

    pokud je bit uprostřed 1:
        ulož si druhou polovinu přijatých bitů
        odešli 100
        flipni druhou polovinu přijatých bitů
        vrať přijmiOpravenýPaket(délka/2+1) + druhá polovina přijatých bitů
    pokud je bit na konci 1:
        ulož si první polovinu přijatých bitů
        odešli 010
        vrať první polovina přijatých bitů + přijmiOpravnýPaket(délka/2+1)
    jinak:
        odešli 000
        vrať přijaté bity
```

Přijmeme tedy jeden paket. Pokud není chybný (poslední bit je 0), odešleme 00 (přijato v pořádku) a jdeme dál. Pokud je chybný, odešleme 10 a přijmeme opravný paket. Opravný paket má o jeden bit víc. Přijmeme ho, a podíváme se na kontrolní bity. Pokud je některý z nich v nepořádku, řekneme to odesílateli a přijmeme danou půlku paketu pomocí rekurzivního volání funkce, která přijímá opravné pakety. Jakmile některý z těchto opravných paketů dorazí v pořádku (nebo přijmeme pouze 2 bity, což už dokážeme opravit samostatně), můžeme uložit přijatá data a pokračujeme dále.

Poznámka: protože každá chyba flipuje všechny další bity, budeme muset modifikovat funkce `odešli` a `přijmi` (které se starají o odesílání a příjímání dat ze sítě). Jednoduše budeme po každé chybě flipovat všechny odesláné i přijaté bity. Toto flipování budeme zapínat a vypínat po každé chybě. Nechtěl jsem toto chování psát z důvodu přehlednosti do pseudokódu.

## Proč to funguje

V každém paketu nebude nikdy chyba více než jedna - díky omezení dle zadáného k. Proto pokud detekujeme kontrolní bit 0, víme, že paket je určitě správny. Pokud 1, požádáme o opravný paket.

Opravný paket je o 1 bit delší, než původní paket, ale také určitě nebude obsahovat dvě chyby. Navíc, pokud se v něm chyba vyskytuje, příjemce urči ve které polovině. Poté uloží tu správnou polovinu (díky kontrolnímu bitu víme, že je určitě bez chyby). Opět požádáme o opravný paket, a pokračujeme dokud nedosáhneme celé zprávy bezchybné.

Petr Šťastný
