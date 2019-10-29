-- 1 W jakim miescie pracuja sprzedawcy (salesman?)

SELECT DISTINCT loc
FROM emp
INNER JOIN dept
ON emp.deptno = dept.deptno
WHERE emp.job = 'SALESMAN';

-- 2 dla kazdego pracownika podaj miasto 
-- w jakim pracuje jego przelozony (lub null jezeli nie ma szefa)

SELECT e1.ename AS worker, boss.ename AS boss
FROM emp e1
LEFT JOIN emp boss
ON e1.mgr = boss.empno;

-- 3 dla kazdego pracownika podaj miasto  jakim pracuje jego przelozony (lub null
-- jesli nie ma szefa)

SELECT e.ename AS worker, loc
FROM emp e
LEFT JOIN emp boss
ON e.mgr = boss.empno
LEFT JOIN dept
ON boss.deptno = dept.deptno;

-- 4 w ktorym departamencie nikt nie pracuje?

SELECT loc
FROM dept
LEFT JOIN emp
ON emp.deptno = dept.deptno
WHERE empno IS NULL;

-- 5 dla kazdego pracownika wypisz imie jego szefa jezeli (ten szef) 
-- zarabia wiecej niz 3000 (lub null jezeli nie ma takiego szefa)

SELECT boss.ename AS BOSS_NAME
FROM emp e1
JOIN emp boss
ON e1.empno = boss.empno
WHERE boss.sal >= 3000;

-- 6 ktory pracownik pracuje w firmie najdluzej?

SELECT e1.ename, e1.hiredate, e2.ename, e2.hiredate
FROM emp e1
LEFT JOIN emp e2
ON e1.hiredate > e2.hiredate
WHERE e2.hiredate IS NULL;

---------------------------------
-- to samo ale bez joinow a z podzapytaniami
-- 1

SELECT loc
FROM dept
WHERE dept.deptno IN (
  SELECT DISTINCT deptno
  FROM emp
  WHERE emp.job = 'SALESMAN'
);

-- 2 ??
SELECT e.ename AS worker, CASE
    WHEN mgr IN (SELECT mgr FROM emp) THEN
        (SELECT m.ename FROM emp m WHERE m.empno = e.mgr)
    ELSE NULL
    END
FROM emp e;

-- alternatywnie
WITH emp2 as (select * from emp)
SELECT emp.ename AS worker,
    (SELECT emp2.ename FROM emp2 WHERE  emp.mgr = emp2.empno) AS boss
FROM emp;


-- 3
SELECT e.ename as worker, CASE
    WHEN mgr IN (SELECT mgr FROM emp) THEN
        (SELECT loc FROM dept WHERE dept.deptno = e.deptno)
    ELSE NULL
    END AS boss_city
FROM emp e;
-- 4

SELECT loc
FROM dept
WHERE dept.deptno NOT IN (
    SELECT DISTINCT deptno FROM emp
);

-- 5

SELECT ename, (SELECT loc FROM dept WHERE e1.deptno = dept.deptno) AS loc
FROM emp e1
WHERE e1.mgr IN (
    SELECT e2.ename FROM emp e2 WHERE e2.sal >= 3000
);

-- 6

SELECT ename AS NAME
FROM (SELECT ename FROM emp ORDER BY hiredate ASC)
WHERE rownum <= 1;







