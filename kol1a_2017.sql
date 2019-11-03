-- https://www.mimuw.edu.pl/~fmurlak/bd/2017/klasowka1-2017.html
/*
  W tabeli zwierze są dane o mieszkańcach fokarium, gdzie koszt to miesięczny koszt utrzymania.
  W tabeli sponsor mamy dane o osobach chętnych do adopcji zwierzaków,
  gdzie ulubiony to ulubiony gatunek danej osoby. W tabeli datek przechowujemy kontrakty adopcyjne, tj.
  zobowiązania do miesięcznych wpłat określonej kwoty na dane zwierzę. 
*/
--1 Jaki jest łączny miesięczny koszt utrzymania wszystkich mieszkańców fokarium? 
SELECT SUM(koszt)
FROM zwierze;

-- 2 Wypisz zwierzęta, których koszt utrzymania nie jest pokryty przez datki na nie. 

SELECT z.imie imie
FROM zwierze z
LEFT JOIN datek d
ON z.imie = d.komu
GROUP BY z.imie, z.koszt
HAVING SUM(NVL(d.ile, 0)) < z.koszt;

-- 3 Dla każdego gatunku wypisz średnią łączną kwotę wpłat na przedstawiciela; posortuj malejąco wg. tej średniej.

SELECT gatunek, SUM(NVL(d.ile, 0))/COUNT(DISTINCT imie) srednia
FROM zwierze z
LEFT JOIN datek d
ON z.imie = d.komu
GROUP BY z.gatunek
ORDER BY srednia DESC;

-- 4 Wypisz sponsorów, którzy miesięcznie wpłacają najwięcej. 
WITH sponsorzy_wplaty AS (
  SELECT s.id AS id, SUM(NVL(d.ile, 0)) suma
  FROM sponsor s
  LEFT JOIN datek d
  ON s.id = d.kto
  GROUP BY s.id
)
SELECT id
FROM sponsorzy_wplaty
WHERE suma = (SELECT MAX(suma) FROM sponsorzy_wplaty);

-- 5 Wypisz wszystkie kontrakty, które można by rozwiązać przy zachowaniu pokrycia kosztów danego zwierzaka. 
WITH sumy_datkow AS (
  SELECT komu, SUM(ile) suma
  FROM datek
  GROUP BY komu
)
SELECT d.*
FROM zwierze z
LEFT JOIN datek d
ON z.imie = d.komu
JOIN sumy_datkow s
ON s.komu = z.imie
WHERE s.suma - NVL(d.ile, 0) >= z.koszt;

-- 6 Dla każdego sponsora, dla którego istnieje zwierzę jego ulubionego gatunku nie otrzymujące żadnego datku, wypisz liczbę takich zwierząt.

WITH bez_datku AS (
  SELECT gatunek, COUNT(*) liczba
  FROM zwierze
  LEFT JOIN datek
  ON imie = komu
  WHERE ile IS NULL
  GROUP BY gatunek
)
SELECT id, liczba
FROM sponsor
JOIN bez_datku
ON ulubiony = gatunek;
