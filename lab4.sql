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

-- alternatywnie

SELECT DISTINCT z.imie
FROM osoba A, osoba B, posiadanie P, zwierze z
WHERE A.nazwisko = 'MAKOTA'
  AND (A.imie = B.imie OR A.imie = B.mama)
  AND B.imie = P.imiewlasciciela
  AND P.idzwierzecia = Z.idzwierzecia
  AND gatunek = 'kot'

-- 5
/* wypisz dane (imie, nazwisko) ojca osoby z największą ilością (żyjących) zwierząt */

-- wypisanie osoby z najwieksza iloscia zyjacych zwierzat
WITH ilosc_zwierzat AS (
    SELECT o.imie AS imie, o.nazwisko AS nazwisko, MAX(o.tata) AS tata, COUNT(*) AS ilezwierzat
    FROM osoba o
    JOIN posiadanie p
    ON o.imie = p.imiewlasciciela
    JOIN zwierze z
    ON z.idzwierzecia = p.idzwierzecia AND z.datasmierci IS NULL
    GROUP BY o.imie, o.nazwisko
    ORDER BY ilezwierzat DESC
)
SELECT o.imie, o.nazwisko
FROM (
    SELECT imie, nazwisko, tata
    FROM ilosc_zwierzat
    WHERE rownum <= 1
) n
LEFT JOIN osoba o
ON n.tata = o.imie;


--alternatywnie
With X AS (
    SELECT imiewlasciciela, COUNT(*) ile_zywych
    FROM posiadanie
    NATURAL JOIN zwierze 
    WHERE datasmierci IS NULL
    GROUP BY imiewlasciciela
)
SELECT tata
FROM osoba
WHERE imie = (
    SELECT imiewlasciciela
    FROM X
    WHERE ile_zywych = (
        SELECT MAX(ile_zywych)
        FROM X
    )
);

-- 6
/* dla każdej osoby wypisz imię jednego z jego żywych zwierząt lub '-' jeżeli takiego zwięrzęcia nie ma */

SELECT o.imie, NVL(MAX(z.imie), '-') imie_zwierzaka
FROM osoba o
LEFT JOIN posiadanie p
ON o.imie = p.imiewlasciciela
LEFT JOIN zwierze z
ON p.idzwierzecia = z.idzwierzecia AND z.datasmierci IS NULL
GROUP BY o.imie;


-- 7
/* dla każdego bezpańskiego zwierzęcia wypisz jego imię, gatunek oraz ilość żyjących zwierząt w jego gatunku */

-- policzenie liczby osobnikow z gatunkow
WITH osobniki AS (
    SELECT gatunek, COUNT(*) licznosc
    FROM zwierze
    WHERE datasmierci IS NULL
    GROUP BY gatunek
)
SELECT z.imie, z.gatunek, o.licznosc
FROM zwierze z
LEFT JOIN posiadanie p
ON z.idzwierzecia = p.idzwierzecia
JOIN osobniki o
ON z.gatunek = o.gatunek
WHERE p.imiewlasciciela IS NULL AND z.datasmierci IS NULL;

-- alternatywnie

SELECT imie, gatunek, 
    (SELECT COUNT(*)
    FROM zwierze inne
    WHERE inne.gatunek = zwierze.gatunek AND datasmierci IS NULL) inne 
FROM zwierze
WHERE idzwierzecia NOT IN (
    SELECT idzwierzecia
    FROM posiadanie
);

-- lub
SELECT A.imie, A.gatunek, COUNT(B.imie) ile_innych
FROM zwierze A
LEFT JOIN zwierze B
ON A.gatunek = B.gatunek AND B.datasmierci IS NULL
LEFT JOIN posiadanie P
ON A.idzwierzecia = P.idzwierzecia
WHERE P.idzwierzecia IS NULL
GROUP BY A.imie, A.gatunek;

-- 8
/* napisz ilu różnych ojców mają właściciele kotów */
SELECT COUNT(DISTINCT o.tata)
FROM osoba o
JOIN posiadanie p
ON o.imie = p.imiewlasciciela
JOIN zwierze z
ON p.idzwierzecia = z.idzwierzecia
WHERE z.gatunek = 'kot';


-- 9
/* dla każdego zwierzęcia napisz którym zwierzęciem swojego właściciela jest */

SELECT imie, imiewlasciciela, (
    SELECT COUNT(*)
    FROM posiadanie A
    WHERE A.dataprzygarniecia < p.dataprzygarniecia AND A.imiewlasciciela = p.imiewlasciciela
) ktore
FROM zwierze z
JOIN posiadanie p
ON z.idzwierzecia = p.idzwierzecia
ORDER BY imiewlasciciela, ktore ASC;

-- 10 
/* wypisz wszystkie dzieci osoby której zwierze umarło najdawniej */
SELECT imie
FROM osoba
WHERE tata = (
    SELECT MAX(imiewlasciciela)
    FROM posiadanie p
    JOIN (
        SELECT idzwierzecia
        FROM (
            SELECT A.idzwierzecia AS idzwierzecia, COUNT(*) AS ranking
            FROM zwierze A
            JOIN zwierze B
            ON A.datasmierci IS NOT NULL AND (A.datasmierci > B.datasmierci OR A.idzwierzecia = B.idzwierzecia)
            GROUP BY A.idzwierzecia
            ORDER BY ranking
        )
        WHERE ROWNUM <= 1
    ) z
    ON p.idzwierzecia = z.idzwierzecia
);

-- alternatywnie
SELECT imie
FROM osoba
WHERE tata IN (
    SELECT DISTINCT imiewlasciciela
    FROM posiadanie
    NATURAL JOIN zwierze 
    WHERE datasmierci = (
        SELECT MIN(datasmierci)
        FROM zwierze
    )
) OR mama IN (
    SELECT DISTINCT imiewlasciciela
    FROM posiadanie
    NATURAL JOIN zwierze 
    WHERE datasmierci = (
        SELECT MIN(datasmierci)
        FROM zwierze
    )
);
