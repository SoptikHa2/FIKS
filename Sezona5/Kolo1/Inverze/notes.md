(N=4 -> 4321)

Pokud mam radu cisel 4321 4321 4321 ..., celkovy pocet inverzi pro kazdou skupinu bude (cislo_skupiny_odzadu)*suma(1..(n-1)).

Tzn treti skupina odkonce (tady 1.) bude celkove vytvaret 3*suma(1..3) => 3\*6 => 18 inverzi

Pocet inverzi pro tyto skupiny tedy bude 18 12 6

Pocet inverzi celkove muzeme ziskat pomoci (3+2+1)*6 => 6\*6=36

Obecne, celkovy pocet inverzi jde ziskat jako (1+..+pocet_skupin)*suma(1..(n-1))

---

Tohle ale neni optimalni - z daneho poctu cisel jde ziskat vic inverzi.

Postup pro tohle mam na papire


!!! POZOR !!!

Inkrementace muze zvysit inverze nad zadany pocet