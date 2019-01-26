# Páska

Nejdříve musím vybrat ze zadaných bodů takové, které se budou určitě nacházet ve výsledném mnohoúhelníku. Takové body se budou určitě nacházet na kraji, takže vyberu dva až čtyři body, které budou zastupovat extrémy - nejnižší, nejvyšší, nejvíc vpravo a nejvíc vlevo. Bylo by hezké kdyby se mi podařilo získat všechny čtyři body, ale stačí dva a nebude to dělat moc velký rozdíl - nevyplatí se se ujišťovat, že byla vybrána optimální varianta a že není náhodou možnost jak zvolit místo dvou bodů tři.

Mezi těmito body natáhnu n-úhelník. Poté vymažu (případně ozančím jako "tohle nebudu zpracovávat") všechny body, které se nachází uvnitř daného n-úhelníka - to proto, že určitě nebude ve výsledku.

Poté vezmu všechny zbývající body, a přiřadím je k jedné ze stran n-úhelníka, a to k té nejbližší. Potom pro každou stranu vyberu jeden bod, který do ní zařadím, a to ten nejvzdálenější možný z přiřazených bodů.

Tímto se mi n-úhelník rozšířil, a tak můžu zase pokračovat od začátku - vymažu body unvitř n-úhelníka, a zase n-úhelník rozšiřuji.

Toto opakuji, dokud nejsou všechny body zpracované. V ten okamžik mám nejkratší možný konvexní n-úhelník, a můžu jednoduše spočítat jeho obvod.



V podstatě to tedy funguje tak, že udělám odhad jak by mohl výsledek vypadat a potom ho postupně rozšiřuji na všechny strany dokud není hotovo.

## Složitost

Na začátku vybírám extrémy, čemuž odhaduji složitost na `O(N)`.

Následně začínám cyklus, který při každém průchodu odstraní velký počet bodů, které ještě musím zpracovávat - přesný počet závisí na vstupu, ale především ze začátku odstraním obrovské množství vstupních bodů. Proto odhaduji složitost zhruba logaritmickou.

V cyklu pro počet stran N-úhelníka (`h`) přiřazuji zbývající body a poté vybírám ten nejvzdálenější, složitost tohoto úkonu bude zhruba `O(n*h)` (`n` je zbývající počet bodů, které mohou být součástí řešení).

A následně vymažu (v mé implementaci pouze označím jako vymazané) body uvnitř n-úhelníka. Podívat se, jestli bod leží uvnitř n-úhelníka, trvá v nejhorším případě `h`. Složitost u tohoto úkonu by měla být řádově `O(n*h)`, kde `n` je počet zbývajících bodů, které mohou být součástí řešení.

Časovou složitost tedy celkově odhaduji na `O(n+log(n)*h)`.

Paměťovou složitost odhaduji na lineární.
