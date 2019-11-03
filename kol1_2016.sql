/*
Klasówka z SQLa 2016/2017 (wersja B)
https://www.mimuw.edu.pl/~fmurlak/bd/2016/klasowka1-2016B.html
*/

-- 1 Ilu jest producentów oleju rzepakowego?

SELECT COUNT(DISTINCT p.kto) ilu_rzepakowcow
FROM produkuje p
JOIN konsumuje k
ON p.kto = k.kto
WHERE p.co = 'olej' AND k.co = 'rzepak'

-- 2 Wypisz wszystkich producentow, ktorzy nic nie konsumują.

SELECT DISTINCT p.kto
FROM produkuje p
LEFT JOIN konsumuje k
ON p.kto = k.kto
WHERE k.kto IS NULL;

-- wzorzec

(SELECT kto FROM produkuje)
MINUS
(SELECT kto FROM konsumuje);

-- 3  Posortuj zakłady malejąco wg. wielkości odpadów, tzn. różnicy między
--    łączną konsumpcją a łączną produkcją.
WITH suma_produkcji AS (
  SELECT kto, SUM(NVL(ile, 0)) suma
  FROM produkuje
  GROUP BY kto
),
suma_konsumpcji AS (
  SELECT kto, SUM(NVL(ile, 0)) suma
  FROM konsumuje
  GROUP BY kto
)
SELECT NVL(p.kto, k.kto), NVL(k.suma, 0) - NVL(p.suma, 0) AS odpady
FROM suma_produkcji p
FULL JOIN suma_konsumpcji k
ON p.kto = k.kto
ORDER BY odpady DESC;

-- 4. Wypisz zakłady wykorzystujące choć jeden surowiec, którego łączna
--    produkcja jest mniejsza niż łączne zapotrzebowanie na niego.

WITH suma_produkcji AS (
  SELECT co, SUM(NVL(ile, 0)) suma
  FROM produkuje
  GROUP BY co
),
suma_konsumpcji AS (
  SELECT co, SUM(NVL(ile, 0)) suma
  FROM konsumuje
  GROUP BY co
)
SELECT DISTINCT kto
FROM konsumuje k
WHERE k.co IN (
  SELECT sp.co
  FROM suma_produkcji sp
  FULL JOIN suma_konsumpcji sk
  ON sp.co = sk.co
  WHERE NVL(sp.suma, 0) < NVL(sk.suma, 0)
);

-- wzorzec

SELECT DISTINCT kto
FROM konsumuje 
WHERE
	(SELECT NVL(SUM(ile),0) FROM produkuje p where p.co = konsumuje.co) <
	(SELECT NVL(SUM(ile),0) FROM konsumuje k where k.co = konsumuje.co);

-- 5. Wypisz wszystkie pary zakładów, które korzystają z tych samych
--    surowców i kazdy cos produkuje.

-- wzorzec
WITH pary AS (
  SELECT DISTINCT A.kto pierwszy, B.kto drugi
  FROM produkuje A
  JOIN produkuje B
  ON A.kto < B.kto
)
SELECT pierwszy, drugi
FROM pary
WHERE NOT EXISTS
   (((SELECT co FROM konsumuje WHERE kto=pierwszy) MINUS
     (SELECT co FROM konsumuje WHERE kto=drugi)) UNION ALL
    ((SELECT co FROM konsumuje WHERE kto=drugi) MINUS
     (SELECT co FROM konsumuje WHERE kto=pierwszy)));


-- 6. Wypisz wszystkie towary, które są surowcem (w pewnym zakładzie) dla
--    pewnego swojego surowca (w być moze innym zakładzie). 

-- wzorzec

WITH wymaga AS (
     SELECT produkuje.co co, konsumuje.co czego
     FROM produkuje JOIN konsumuje ON produkuje.kto=konsumuje.kto
)
SELECT DISTINCT a.co
FROM wymaga a, wymaga b
WHERE a.czego=b.co AND a.co=b.czego;

-- 7. Efektywność produkcji towaru mierzymy stosunkiem wyprodukowanej ilosci tego
--    towaru do łącznej ilości towarów konsumowanych. Wypisz wszystkie zakłady,
--    które w produkcji każdego swojego produktu są mniej efektywne, niż jakis inny
--    zakład (nie koniecznie ten sam dla wszystkich produktów).

-- WITH suma_konsumpcji AS (
--   SELECT kto, NVL(SUM(ile), 0) suma
--   FROM konsumuje
--   GROUP BY kto
-- )
-- SELECT p.kto, p.co, DENSE_RANK() OVER (PARTITION BY p.co ORDER BY NVL(NVL(p.ile, 0) / sk.suma, 0), 0) rank
-- FROM produkuje p
-- LEFT JOIN suma_konsumpcji sk
-- ON p.kto = sk.kto
-- WHERE rank = ;

-- wzorzec

WITH
efektywnosc AS (
	SELECT
		kto,
		co,
		ile/(SELECT SUM(ile) FROM konsumuje WHERE konsumuje.kto = produkuje.kto) ile
	FROM produkuje
)
SELECT DISTINCT kto
FROM produkuje
WHERE kto NOT IN
		(SELECT kto
		FROM efektywnosc a
		WHERE ile IS NULL OR
	              -- wpp. porownanie z nullem da falsz, i dobrze bo null to nieskonczonosc
		      ile >= ALL (SELECT b.ile FROM efektywnosc b WHERE b.co=a.co)
		);