-- Zadanie 2
-- Wypisz wszystkie projekty,
-- które trwają dłużej niż łączna liczba osobodni składających się na nie zadań. 
WITH trwanie_projektow AS (
    SELECT projekt, MIN(poczatek) min_poczatek, MAX(koniec) max_koniec,
        SUM((koniec - poczatek) * osoby) osobodni
    FROM zadanie
    GROUP BY projekt
)
SELECT projekt
FROM trwanie_projektow
-- jeden dzien ma 24h, a dzien pracy wynosi 8h. Zakladam, ze pracuja 7 dni w tygodniu
WHERE osobodni * 8 < (max_koniec - min_poczatek) * 24;
