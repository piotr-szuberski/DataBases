-- seriale
-- kanal, serial, postac

-- 1 Wypisz te seriale które trwają co najmniej 10 lat

SELECT *
FROM serial
WHERE NVL(rokkoniec, 2019) - rokstart >= 10;

-- 2 Wypisz te seriale w których zginęło co najmniej połowa bohaterów

SELECT idserialu
FROM serial
NATURAL JOIN postac
GROUP BY idserialu
HAVING SUM(CASE ginie WHEN 'tak' THEN 1 ELSE 0 END) / COUNT(*) > 0.5;

-- 3 Wypisz nazwy kanałów, które uśmierciły wszystkich bohaterów w jej zakończonych serialach
-- z jakiegos powodu nie dziala
SELECT k.nazwa
FROM kanal k
LEFT JOIN serial s
ON k.idkanalu = s.idkanalu
LEFT JOIN postac p
ON s.idserialu = p.idserialu
WHERE s.rokkoniec IS NOT NULL
GROUP BY k.nazwa
HAVING 'tak' = ALL(p.ginie);

-- 4 Wypisz nazwy kanałów, których każdy serial ma inną ocenę
SELECT DISTINCT k.nazwa
FROM kanal k
LEFT JOIN serial s
ON k.idkanalu = s.idkanalu
GROUP BY k.idkanalu, k.nazwa, s.ocena
HAVING COUNT(s.nazwa) <= 1;

-- 5 Wypisz żywych bohaterów najlepiej ocenianego serialu (lub seriali)

SELECT DISTINCT postac
FROM serial
JOIN postac
ON postac.idserialu = serial.idserialu
WHERE serial.ocena = (SELECT MAX(ocena) FROM serial) AND postac.ginie = 'nie';

-- 6 Dla każdej stacji wypisz jej dziesiąty serial (wg roku powstania), o ile taki istnieje.
--   W przypadku remisu wypisz wszystkie remisujące

WITH ranking AS (
  SELECT idkanalu, nazwa, dense_rank() OVER (PARTITION BY idkanalu ORDER BY rokstart) rank
  FROM serial
)
SELECT r.nazwa
FROM kanal k
LEFT JOIN ranking r
ON k.idkanalu = r.idkanalu
WHERE rank = 2;

-- wzorzec (dziwny)
SELECT kanal.nazwa, s1.nazwa
FROM serial s1
JOIN serial s2
ON s1.idkanalu = s2.idkanalu
JOIN kanal
ON kanal.idkanalu = s1.idkanalu
WHERE s1.ocena <= s2.ocena
GROUP BY s1.idserialu
HAVING COUNT(*) >= 10
MINUS
SELECT kanal.nazwa, s1.nazwa
FROM serial s1
JOIN serial s2
ON s1.idkanalu = s2.idkanalu
JOIN kanal
ON kanal.idkanalu = s1.idkanalu
WHERE s1.ocena < s2.ocena
GROUP BY s1.idserialu
HAVING COUNT(*) >= 10

-- 7 Wypisz nazwy kanałów, które w pewnym momencie nie puszczały żadnego serialu (i.e.
--   w pewnym momencie każdy serial danej stacji był zakończony)

-- wzorzec
