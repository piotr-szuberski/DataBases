-- Grupowanie

-- 1 Dla kazdego stanowiska wyznacz licznbe pracownikow i srednia place

SELECT job, count(*) AS emp_number, AVG(sal)
FROM emp
GROUP BY job; 

-- 2 dla kazdego departamentu z pracownikami wypisz ilu sposrod nich ma prowizje (comm)

SELECT deptno, count(comm) AS emps_with_comm
FROM emp
GROUP BY deptno;

-- 3 znajdz maksymalna pensje na 
-- wszystkich stanowiskach na ktorych pracuje co najmniej 
-- 3 pracownikow zarabiajacych co najmniej 1000

SELECT job, max(sal) AS max_sal
FROM (SELECT job, sal FROM emp WHERE sal >= 1000)
GROUP BY job
HAVING count(*) >= 3;

-- 4 znajdz wszystkie miejsca w ktorych rozpietosc
-- pensji w tym samym departamencie na tym samym stanowisku przekracza 300

SELECT deptno
FROM emp
GROUP BY deptno, job
HAVING max(sal) - min(sal) >= 300;

-- 5 policz srednie zarobki w departamencie w ktorym pracuje
-- szef wszystkich szefow (czyli osoba ktora nie ma szefa)

SELECT deptno, AVG(sal)
FROM emp
WHERE deptno IN (SELECT deptno FROM emp WHERE mgr IS NULL)
GROUP BY deptno;

-- 6 znajdz numer pracownika ktory ma podwladnych w roznych dzialach

SELECT mgr
FROM emp
GROUP BY mgr
HAVING count(DISTINCT deptno) > 1;


-- 7 wypisz imiona oraz pensje wszystkich pracownikow ktorzy nie maja
-- zmiennika (osoby na tym samym stanowisku w tym samym departamencie)
-- i posortuj ich wg pensji malejaco


WITH emp2 AS (
    SELECT job, deptno
)
-- nie dziala
SELECT MIN(ename), MIN(sal) AS salary
FROM emp
GROUP BY job, deptno
HAVING count(*) = 1
ORDER BY salary DESC;








-- Rekurencja
-- 1 wypisz imiona wszystkich podwladnych KING'a (razem z nim)
-- w taki sposob aby uzyskac strukture drzewa

SELECT LPAD(ename, LENGTH(ename) + ((LEVEL - 1) * 2), '  ') AS ename
FROM emp
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr;

-- 2 wypisz wszystkich podwladnych kinga bez niego


SELECT LPAD(ename, LENGTH(ename) + ((LEVEL - 2) * 2), '  ') AS ename
FROM emp
WHERE LEVEL > 1
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr;

-- 3 wypisz wszystkich podwladnych kinga bez blake-a i jego podwladnych

SELECT LPAD(ename, LENGTH(ename) + ((LEVEL - 1) * 2), '  ') AS ename
FROM emp
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr AND ename <> 'BLAKE';

-- 4 wypisz wszystkich pracownikow ktorzy maja "pod soba" SALESMANA

SELECT DISTINCT ename AS salesman_boss
FROM emp
WHERE LEVEL > 1
START WITH job = 'SALESMAN'
CONNECT BY PRIOR job = 'SALESMAN' AND PRIOR mgr = empno;

SELECT ename
FROM emp
WHERE empno IN (SELECT mgr FROM emp WHERE job = 'SALESMAN' AND mgr IS NOT NULL);

-- 5 wypisz dla kazdego pracownika sume zarobkow jego i jego podwladnych
SELECT MAX(CONNECT_BY_ROOT ename) AS name, SUM(sal)
FROM emp
CONNECT BY PRIOR empno = mgr
GROUP BY CONNECT_BY_ROOT ename;
