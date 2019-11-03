-- https://www.mimuw.edu.pl/~fmurlak/bd/2015/klasowka1-2015.html

-- 1. Dla każdego gracza (id) wypisz liczbę wygranych partii
SELECT gz.id, NVL(COUNT(g.wynik), 0) 
FROM gracz gz
LEFT JOIN gra g
ON gz.id = g.gracz1id AND g.wynik = 1
  OR gz.id = g.gracz2id AND g.wynik = 2
GROUP BY gz.id;

-- 2. Posortuj graczy (wszystkie kolumny) według średniego czasu wygranej 
--    (nie patrzymy na przegrane partie)

SELECT gz.id
FROM gracz gz
LEFT JOIN gra g
ON gz.id = g.gracz1id AND g.wynik = 1
  OR gz.id = g.gracz2id AND g.wynik = 2
GROUP BY gz.id
ORDER BY AVG(g.czas);

-- 3. Wypisz graczy (imie, nazwisko), których ranking jest niższy niż 
--    średni ranking graczy, z którymi wygrali

SELECT gz.imie, gz.nazwisko
FROM gracz gz
WHERE gz.ranking < (
  SELECT AVG(ranking)
  FROM gra g
  JOIN gracz gzi
  ON gzi.id = g.gracz1id AND gz.id = g.gracz2id AND g.wynik = 2
    OR gzi.id = g.gracz2id AND gz.id = g.gracz1id AND g.wynik = 1
);

-- wzor
SELECT wygrany.imie, wygrany.nazwisko
FROM gracz wygrany, gracz przegrany, gra
WHERE ((wygrany.id=gracz1id AND przegrany.id=gracz2id AND wynik=1) 
	OR 
       (wygrany.id=gracz2id AND przegrany.id=gracz1id AND wynik=2)) 
GROUP BY wygrany.imie, wygrany.nazwisko, wygrany.ranking
HAVING wygrany.ranking < AVG(przegrany.ranking);

-- 4. Wypisz graczy (wszystkie kolumny), ktorzy sa pojedynczymi reprezentantami 
--    swojego kraju.
SELECT gz.*
FROM gracz gz
WHERE NOT EXISTS (
  SELECT *
  FROM gracz
  WHERE gz.id != gracz.id AND gz.kraj = gracz.kraj
);

-- 5. Wypisz graczy (imie,nazwisko), którzy wygrali co najwyzej dwa razy 
--    z graczami lepszymi od siebie w sensie rankingu
SELECT wygrany.imie, wygrany.nazwisko
FROM gracz wygrany
LEFT JOIN gra g
ON (wygrany.id = g.gracz1id AND g.wynik = 1)
  OR (wygrany.id = g.gracz2id AND g.wynik = 2)
LEFT JOIN gracz przegrany
ON ((przegrany.id = g.gracz2id AND g.wynik = 1)
  OR (przegrany.id = g.gracz1id AND g.wynik = 2))
  AND wygrany.ranking < przegrany.ranking
GROUP BY wygrany.imie, wygrany.nazwisko
HAVING COUNT(przegrany.id) <= 2;

-- wzorce

-- Michał Błaziak
SELECT a.imie, a.nazwisko 
FROM gracz a 
WHERE 
2 >= (SELECT COUNT(*) 
      FROM gra b 
      WHERE (b.gracz1id = a.id AND b.wynik = 1 AND
      	     a.ranking < (SELECT c.ranking FROM gracz c WHERE c.id = b.gracz2id)) 
         OR (b.gracz2id = a.id AND b.wynik = 2 AND
 	     a.ranking < (SELECT c.ranking FROM gracz c WHERE c.id = b.gracz1id)));

--Ewelina Krakowiak 
SELECT gracz1.imie, gracz1.nazwisko 
FROM gracz gracz1 
WHERE
2 >= (SELECT COUNT(gracz2.ranking) 
      	   FROM gracz gracz2, gra 
	   WHERE gracz1.ranking < gracz2.ranking AND
	    ((gra.wynik = 1 AND gra.gracz1id = gracz1.id AND gra.gracz2id = gracz2.id) OR		
	     (gra.wynik = 2 AND gra.gracz1id = gracz2.id AND gra.gracz2id = gracz1.id))) 
ORDER BY gracz1.imie, gracz1.nazwisko; 

-- 6. Wypisz kraje z których pochodzi co najmniej trzech graczy, 
--    którzy są w pierwszej dwudziestce w sensie rankingu
WITH najlepsi AS (
  SELECT A.id
  FROM gracz A
  LEFT JOIN gracz B
  ON A.ranking < B.ranking OR A.id = B.id
  GROUP BY A.id
  HAVING COUNT(*) <= 20
  ORDER BY COUNT(*)
)
SELECT kraj
FROM gracz g
WHERE g.id IN (SELECT * FROM najlepsi)
GROUP BY g.kraj
HAVING COUNT(g.id) > 3;

-- wzor
SELECT kraj 
FROM (SELECT * FROM gracz WHERE rownum <=20 ORDER BY ranking)
GROUP BY kraj
HAVING count(*)>=3;

-- 7. Znajdź wszystkich graczy(imie, nazwisko), którzy od 2014-09-01 
--    wygrali przynajmniej dwie partie z graczami, którzy są od nich młodsi

WITH partie_po AS (
  SELECT *
  FROM gra
  WHERE gra.data >= TO_DATE('2014-09-01', 'YYYY-MM-DD')
)
SELECT wygrany.imie, wygrany.nazwisko
FROM gracz wygrany
JOIN gra gra
ON wygrany.id = gra.gracz1id AND gra.wynik = 1 OR wygrany.id = gra.gracz2id AND gra.wynik = 2
JOIN gracz przegrany
ON (przegrany.id = gra.gracz2id AND gra.wynik = 1 AND przegrany.dataur < wygrany.dataur)
  OR (przegrany.id = gra.gracz1id AND gra.wynik = 2 AND przegrany.dataur < wygrany.dataur)
GROUP BY wygrany.imie, wygrany.nazwisko
HAVING COUNT(przegrany.id) >= 2;

-- wzor

SELECT wygrany.imie, wygrany.nazwisko
FROM gracz wygrany, gracz przegrany, gra
WHERE ((wygrany.id=gracz1id AND przegrany.id=gracz2id AND wynik=1) 
       OR (wygrany.id=gracz2id AND przegrany.id=gracz1id AND wynik=2)) 
      AND data >= DATE '2014-09-01'
      AND wygrany.dataur < przegrany.dataur
GROUP BY wygrany.imie, wygrany.nazwisko
HAVING count(*) >= 2;

-- 8. Dla każdego miesiąca roku 2014 wypisz wszystkich graczy, 
--    którzy wygrali najwięcej partii w danym miesiącu 
--    (null, jeśli w danym miesiącu nie było żadnych rozgrywek nieremisowych).

WITH partie_2014 AS (
  SELECT d.*, (SELECT EXTRACT(MONTH FROM g.data) miesiac FROM gra g WHERE g.id = d.id) miesiac
  FROM gra d
  WHERE EXTRACT(YEAR FROM data) = 2014 AND wynik IS NOT NULL
)
SELECT z.miesiac, z.id
FROM (
  SELECT p.miesiac, g.id, dense_rank() OVER (PARTITION BY g.id, p.miesiac ORDER BY COUNT(*)) rank
  FROM partie_2014 p
  LEFT JOIN gracz g
  ON g.id = p.gracz1id AND p.wynik = 1 OR g.id = p.gracz2id AND p.wynik = 2
) z
WHERE rank = 1;


-- wzor

WITH statystyki AS
     (SELECT miesiac, zwyciezca, COUNT(idgry) ile
      FROM	      
      	(SELECT 
      	 	(CASE wynik WHEN 1 THEN gracz1id WHEN 2 THEN gracz2id END) zwyciezca, 
	      	EXTRACT(month FROM data) miesiac,  
	      	id idgry
 	 FROM gra
         WHERE data >= DATE '2014-01-01' AND wynik IS NOT NULL) 
      GROUP BY miesiac, zwyciezca)
SELECT miesiace.miesiac, gracz.imie, gracz.nazwisko
FROM 
  (SELECT rownum miesiac FROM dual CONNECT BY level <=12) miesiace 
  LEFT JOIN statystyki ON miesiace.miesiac = statystyki.miesiac 
  JOIN gracz ON gracz.id=statystyki.zwyciezca
WHERE ile >= ALL (SELECT ile FROM statystyki s WHERE s.miesiac = statystyki.miesiac)
ORDER BY miesiac;