-- zadania na zwierzeta

-- 1
/* wypisz zwierzeta ktore urodzily sie wczesniej niz
ktorys z ich opiekunow zostal zatrudniony
*/

SELECT z.zwrznum
FROM zwierzeta z
JOIN opieka o
ON z.zwrznum = o.zwrztnum
JOIN opiekunowie oe
ON o.opknnum = oe.opknnum
WHERE z.urodzony < oe.zatrudnienie;

-- 2
/* dla kazdego z opiekunow wypisz ilosc miesa, ktore musi
dostarczyc swoim podopiecznym (w przypadku gdy zwierze
ma wiecej niz jednego opiekuna zakladamy, ze dziela
sie swoimi obowiazkami po rowno)
*/
-- chyba ok, ale do sprawdzenia
SELECT o.opknnum, SUM(mieso)
FROM (
    SELECT zwrznum, (MAX(dziennespozycie) * MAX(miesozernosc) / COUNT(opknnum)) AS mieso
    FROM zwierzeta
    JOIN opieka
    ON opieka.zwrztnum = zwierzeta.zwrznum
    GROUP BY zwrznum
) z
JOIN opieka o
ON o.zwrztnum = z.zwrznum
GROUP BY o.opknnum;

-- 3
/* napisz zapytanie wyliczajace podwyzke dla kazdego opiekuna w wysokosci tylu procent jego
pensji ile procent z jego podopiecznych jest calkowicie miesozerne
*/

SELECT a1.opknnum, (a1.ile_miesozernych / a2.ile_razem) AS procent
FROM (
    SELECT o1.opknnum AS opknnum,
    COUNT(z1.zwrznum) AS ile_miesozernych
    FROM zwierzeta z1
    LEFT OUTER JOIN opieka o1
    ON o1.zwrztnum = z1.zwrznum
    WHERE z1.miesozernosc = 1
    GROUP BY o1.opknnum
) a1
JOIN (
    SELECT o2.opknnum AS opknnum, COUNT(z2.zwrznum) AS ile_razem
    FROM zwierzeta z2
    JOIN opieka o2
    ON o2.zwrztnum = z2.zwrznum
    WHERE z2.miesozernosc < 1
    GROUP BY o2.opknnum
) a2
ON a1.opknnum = a2.opknnum;

-- 4
/* Kowalski zginął w nieszczęśliwym wypadku. Zwierzęta, których był jedynym opiekunem, muszą
mieć rzypisanego nowego opiekuna. Aby uniknąć wypadków w przyszłości, kierownictwo
zdecydowało się każdemu "osieroconemu" zwierzęciu przypisać najbardziej doświadczonego
opiekuna. Napisz zapytanie, które dla każdego zwierzęcia X, które było pod wyłączną opieką
Kowalskiego, wypisuje opiekuna najstarszego stażem spośród tych, którzy już zajmują
się jakimś zwierzęciem tego samego gatunku co X. Dla pozostałych zwierząt wypisz NULL
*/

-- Wypisz opknnum Kowalskiego
SELECT opknnum FROM opiekunowie WHERE nazwisko = 'Kowalski';

-- Wypisz zwierzeta pod opieka kowalskiego
SELECT zwrznum, gatunek
FROM zwierzeta z
JOIN opieka o
ON zwrznum = zwrztnum
WHERE opknnum IN (SELECT opknnum FROM opiekunowie WHERE nazwisko = 'Kowalski');

-- Wypisz najstarszych stazem opiekunow z gatunkiem zwierzat
SELECT A.*, COUNT(*)
FROM emp A
LEFT JOIN emp B
ON A.sal < B.sal OR A.empno = B.empno 
GROUP BY A.empno;

SELECT opknnum, gatunek
FROM opiekunowie oe
JOIN opieka oa
ON oe.opknnum = oa.opknnum
JOIN zwierzeta z
ON z.zwrznum = oa.zwrztnum
WHERE oe.nazwisko != 'Kowalski';

























