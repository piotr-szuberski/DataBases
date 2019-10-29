/* https://www.mimuw.edu.pl/~oski/bd/lab04.php */

-- 1 
/* wypisz dla każdej osoby ile posiada żywych zwierząt (nawet jak ta wartość jest równa 0) */

SELECT p.imiewlasciciela, count(z.idzwierzecia)
FROM posiadanie p
LEFT JOIN zwierze z
ON z.datasmierci IS NULL AND z.idzwierzecia = p.idzwierzecia
GROUP BY p.imiewlasciciela;

-- 2
/* dla każdego gatunku wypisz ile jest maksymalnie zwierząt o tym samym imieniu */

SELECT DISTINCT gatunek, MAX(imie) AS imie, MAX(ile) AS ile
FROM (
    SELECT gatunek, imie, COUNT(*) AS ile
    FROM zwierze
    GROUP BY gatunek, imie
)
GROUP BY gatunek;

-- 3
/* wypisz dla każdej matki jej imię, nazwisko, ilość dzieci ze znanym ojcem i ilość dzieci z nieznanym ojcem */

SELECT m.imie, m.nazwisko, COUNT(d.tata) AS znany, COUNT(*) - COUNT(d.tata) AS nieznany
FROM osoba m
JOIN osoba d
ON m.imie = d.mama
GROUP BY m.imie, m.nazwisko;

-- 4
/* wypisz wszystkie różne imiona kotów osoby o nazwisku 'Makota' oraz jej dzieci */

SELECT DISTINCT z.imie
FROM osoba o
JOIN posiadanie p
ON p.imiewlasciciela = imie
JOIN zwierze z
ON p.idzwierzecia = z.idzwierzecia AND z.gatunek = 'kot'
WHERE LEVEL <= 2
START WITH o.nazwisko = 'Makota'
CONNECT BY PRIOR o.imie = o.mama OR PRIOR o.imie = o.tata;
