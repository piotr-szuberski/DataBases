-- https://www.mimuw.edu.pl/~fmurlak/bd/2018/klasowka1-2018B.html

/*
W tabeli produkuje są dane o ilościach towarów produkowanych przez różne kraje, natomiast w tabeli sprzedaje dane o ilościach towarów sprzedawanych jednym krajom przez inne kraje.
Jeśli dla jakiegoś kraju i produktu brak odpowiedniego wiersza w tabeli produkuje, to przyjmujemy, że produjca wynosi 0. Podobnie w przypadku przepływu towarów.
*/

-- 1
/* Ile krajów kupuje towar, który produkuje. */

SELECT COUNT(DISTINCT p.kto) AS kupujecosprzedaje
FROM produkuje p
JOIN sprzedaje s
ON p.kto = s.komu AND p.co = s.co;


-- 2
/* Wypisz wszystkie pary krajów, między którymi zachodzi przepływ jakiegoś towaru
w obie strony. Nie wypisuj dwukrotnie tej samej pary w dwóch różnych kolejnosciach. */

SELECT DISTINCT p.kto, p.komu
FROM sprzedaje p
JOIN sprzedaje p2
ON p.kto = p2.komu AND p.komu = p2.kto AND p.co = p2.co AND p.kto < p.komu;

-- 3. Wypisz producentów niezerowej ilości węgla w kolejności malejącego łącznego eksportu węgla. 

SELECT p.kto, SUM(s.ile) suma
FROM sprzedaje s
JOIN produkuje p
ON s.kto = p.kto AND s.co = 'wegiel'
WHERE p.co = 'wegiel' AND p.ile > 0
GROUP BY p.kto
ORDER BY suma DESC;

-- 4. Wypisz wszystkie kraje, które sprzedają jakiegoś towaru więcej niż go produkują.

SELECT DISTINCT p.kto
FROM sprzedaje s
LEFT JOIN produkuje p
ON p.kto = s.kto AND p.co = s.co
GROUP BY p.kto, p.co, p.ile
HAVING SUM(s.ile) > NVL(p.ile, 0);

-- 5 Dla każdego towaru wypisz jego największych importerow. W przypadku remisow wypisz wszystkich.
SELECT co, komu
FROM (
    SELECT co, komu, dense_rank() OVER (PARTITION BY co ORDER BY SUM(ile) DESC) AS rank
    FROM sprzedaje s
    GROUP BY komu, co
)
WHERE rank = 1;

-- 6 Dla każdego eksportera A i eksportowanego przez niego towaru T wypisz kraj B, który jest
-- następny na liście głównych eksporterów towaru T. Jeśli takiego nie ma, wypisz null (puste pole). Jeśli jest kilku ex-aequo, wypisz wszystkich. 
WITH ranking_eksportu AS(
  SELECT kto, co, dense_rank() OVER (PARTITION BY co ORDER BY SUM(ile) DESC) AS rank
  FROM sprzedaje s
  GROUP BY kto, co
)
SELECT r1.kto AS pierwszy, r1.co, r2.kto as drugi
FROM ranking_eksportu r1
LEFT JOIN ranking_eksportu r2
ON r1.rank = 1 AND r2.rank = 2 AND r1.co = r2.co
WHERE r1.rank = 1;

-- 7 Posortuj kraje malejąco wg. konsumpcji węgla, przy czym za konsumpcję danego towaru w danym kraju uznajemy sumę produkcji i importu pomniejszoną o eksport.
WITH import AS(
  SELECT komu as kraj, SUM(ile) AS ile
  FROM sprzedaje
  WHERE co = 'wegiel'
  GROUP BY komu, co
),
eksport AS(
  SELECT kto as kraj, SUM(ile) AS ile
  FROM sprzedaje
  WHERE co = 'wegiel'
  GROUP BY kto, co
),
produkcja AS(
  SELECT kto as kraj, ile
  FROM produkuje
  WHERE co = 'wegiel'
)
SELECT NVL(i.kraj, NVL(e.kraj, p.kraj)) AS kraj, NVL(i.co, NVL(e.co, p.co)) AS co, NVL(p.ile, 0) + NVL(i.ile, 0) - NVL(e.ile, 0) AS ile
FROM produkcja p
FULL JOIN import i
ON p.kraj = i.kraj
FULL JOIN eksport e
ON p.kraj = e.kraj
ORDER BY ile DESC;




