-- Zadanie 1
-- Wypisz zadania malejąco wg liczby zadań,
-- od których bezpośrednio zależą; w przypadku remisów wypisać alfabetycznie wg nazw. 

SELECT zd.nazwa, COUNT(zl.co) ile_zaleznych
FROM zadanie zd
LEFT JOIN zalezy zl
ON zd.nazwa = zl.co
GROUP BY zd.nazwa
ORDER BY ile_zaleznych DESC, zd.nazwa ASC;