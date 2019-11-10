-- Zadanie 4
-- Dla każdego projektu wypisz liczbę niezrealizowanych zadań,
-- które nie zależą bezposrednio od żadnego niezrealizowanego zadania. 
SELECT projekt, COUNT(*) AS niezrealizowane
FROM zadanie
LEFT JOIN zalezy
ON nazwa = co
WHERE procent < 100 AND od IS NULL
GROUP BY projekt;