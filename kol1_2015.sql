-- https://www.mimuw.edu.pl/~fmurlak/bd/2015/klasowka1-2015.html

-- 1 Dla każdego komitetu wypisz w ilu okręgach miał kandydatów.

SELECT komitet, COUNT(DISTINCT okreg)
FROM kandydat
GROUP BY komitet;

-- 2 Posortuj kandydatów względem malejącej sumarycznej liczby uzyskanych głosów (wypisz dane kandydata i liczbę głosów). 
SELECT imie, nazwisko, NVL(SUM(ile), 0) AS wynik
FROM kandydat
LEFT JOIN wynik
ON id = na_kogo
GROUP BY id, imie, nazwisko
ORDER BY wynik DESC;

-- 3 Wypisz wszystkie pary (imię, nazwisko), które powtarzają się w ramach jednego okręgu wyborczego wśród kandydatów różnych komitetów. 

WITH pary AS (
  SELECT A.imie imiea, A.nazwisko nazwiskoa, A.okreg okrega, A.komitet komiteta, B.imie imieb, B.nazwisko nazwiskob, B.okreg okregb, B.komitet komitetb
  FROM kandydat A
  LEFT JOIN kandydat B
  ON A.id < B.id
)
SELECT imiea, nazwiskoa, imieb, nazwiskob
FROM pary
WHERE okrega = okregb AND komiteta <> komitetb;

-- wzor
SELECT DISTINCT imie, nazwisko
FROM kandydat
GROUP BY imie, nazwisko, okreg 
HAVING count(id) > 1;

-- 4 Wypisz okregi, w których nie wszystkie lokale przekazały wyniki wszystkich kandydatów. 

SELECT DISTINCT k.okreg okreg
FROM kandydat k
LEFT JOIN lokal l
ON k.okreg = l.okreg
LEFT JOIN wynik w
ON k.id = w.na_kogo
WHERE ile IS NULL;

-- wzor

SELECT DISTINCT lokal.okreg 
FROM kandydat JOIN lokal ON kandydat.okreg=lokal.okreg 
WHERE kandydat.id NOT IN (SELECT na_kogo FROM wynik WHERE gdzie=lokal.id);

-- 5 Dla każdego okręgu wypisz minimalną i maksymalną łączną liczbę głosów oddanych w lokalach tego okręgu.
WITH sumy_lokali AS (
  SELECT gdzie, SUM(ile) suma
  FROM wynik
  GROUP BY gdzie
)
SELECT l.okreg, NVL(MIN(suma), 0), NVL(MAX(suma), 0)
FROM lokal l
LEFT JOIN sumy_lokali sl
ON l.id = sl.gdzie
GROUP BY l.okreg;

-- wzor

SELECT okreg, min(razem), max(razem) 
FROM
	(SELECT id, okreg, sum(ile) razem
	 FROM lokal LEFT JOIN wynik ON id=gdzie
	 GROUP BY id, okreg) glosy_w_lokalach
GROUP BY okreg;

-- 6 Posortuj kandydatów względem procentu głosów uzyskanych w ramach ich okręgu (wypisz dane kandydata i procent głosów).
WITH sumy_kandydatow AS (
  SELECT okreg, na_kogo id, NVL(SUM(ile), 0) suma
  FROM lokal
  LEFT JOIN wynik
  ON id = gdzie
  GROUP BY na_kogo, okreg
),
sumy_okregow AS (
  SELECT okreg, SUM(ile) suma
  FROM lokal
  LEFT JOIN wynik
  ON id = gdzie
  GROUP BY okreg
)
SELECT imie, nazwisko, NVL(sk.suma / so.suma * 100, 0) AS procent
FROM kandydat k
LEFT JOIN sumy_kandydatow sk
ON k.id = sk.id
LEFT JOIN sumy_okregow so
ON k.okreg = so.okreg
ORDER BY procent;

-- 7 Dla każdego kandydata podaj jego pozycję rankingową w ramach jego okręgu, uwzględniając remisy.
--   Na przykład, jeśli Abacki dostał 10 głosów, a Babacki, Cabacki i Dabacki dostali po 8 głosów,
--   to Abacki ma pozycję 1, a pozostali mają pozycję 2. Posortować po okręgach, pozycji rankingowej i nazwisku. 
WITH sumy_kandydatow AS (
  SELECT na_kogo, NVL(SUM(ile), 0) suma
  FROM wynik
  GROUP BY na_kogo
)
SELECT k.*, DENSE_RANK() OVER (PARTITION BY k.okreg ORDER BY sk.suma DESC) rank
FROM kandydat k
LEFT JOIN sumy_kandydatow sk
ON k.id = sk.na_kogo
ORDER BY k.okreg, rank, k.nazwisko;

-- wzorzec
WITH kandydat_wynik AS 
     (SELECT id, imie, nazwisko, komitet, okreg, NVL(SUM(ile),0) ile 
      FROM kandydat LEFT JOIN wynik ON id=na_kogo
      GROUP BY id, imie, nazwisko, komitet, okreg)
SELECT gorszy.id, gorszy.imie, gorszy.nazwisko, gorszy.komitet, gorszy.okreg, 
       count(lepszy.id) miejsce
FROM kandydat_wynik gorszy, kandydat_wynik lepszy
WHERE gorszy.okreg=lepszy.okreg AND 
      (gorszy.ile<lepszy.ile OR gorszy.id=lepszy.id)
GROUP BY gorszy.id, gorszy.imie, gorszy.nazwisko, gorszy.komitet, gorszy.okreg
ORDER BY okreg, count(lepszy.id), nazwisko;
