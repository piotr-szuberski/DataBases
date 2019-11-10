-- Zadanie 3
-- Dla każdego projektu
-- wypisz ilu maksymalnie pracowników pracuje równocześnie nad zadaniami tego projektu. 

WITH sumy_pracownikow AS(
    SELECT A.nazwa AS nazwa, A.projekt AS projekt,
    -- suma z innych zadan plus osoby z obecnego projektu
    (SUM(B.osoby) + A.osoby) AS suma
    FROM zadanie A, zadanie B
    WHERE NOT (A.poczatek > B.koniec OR A.koniec < B.poczatek)
        AND A.nazwa <> B.nazwa
        AND A.projekt = B.projekt
    GROUP BY A.nazwa, A.projekt, A.osoby
)
SELECT z.projekt, NVL(MAX(s.suma), MAX(z.osoby)) AS suma_w_projektach
FROM zadanie z
LEFT JOIN sumy_pracownikow s
ON z.projekt = s.projekt
GROUP BY z.projekt;