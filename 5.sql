-- Zadanie 5
-- Wypisz zadania malejąco wg liczby zadań, od których zależą
-- (nie tylko bezpośrednio); w przypadku remisów wypisać alfabetycznie wg nazw. 

WITH zalezne AS (
    SELECT co, COUNT(*) od_ilu
    FROM zalezy
    START WITH co IS NOT NULL
    CONNECT BY PRIOR co = od
    GROUP BY co
)
SELECT zadanie.nazwa, (
    CASE
        WHEN zalezne.od_ilu IS NULL THEN 0
        ELSE zalezne.od_ilu
    END) od_ilu
FROM zadanie
LEFT JOIN zalezne
ON zadanie.nazwa = zalezne.co
ORDER BY od_ilu DESC, zadanie.nazwa ASC;
