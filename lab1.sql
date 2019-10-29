/*
 Zadanie 1.

    1wybierz wszystkich urzędników (clerk)
    2wybierz miasta w których firma ma swoje departamenty
    3wybierz imiona, pensje i stanowisko wszystkich pracowników którzy: albo mają imię zaczynające się na literę T i zarabiają więcej niż 1500 i mniej niż 2000, albo są analistami
    4wybierz imiona pracowników którzy nie mają szefów (mgr = manager)
    5wybierz numery wszystkich pracowników którzy mają podwładnych sortując je malejąco
    6wybierz wszystkich pracowników i dla każdego wypisz w dodatkowej kolumnie o nazwie 'starszy' 1 jeżeli ma wcześniejsze id niż jego szef, 0 jeżeli ma późniejsze, oraz '-1' jeżeli nie ma szefa
    7wylicz sinus liczby 3.14
*/

-- 1
SELECT *
FROM emp
WHERE job = 'CLERK';

-- 2
SELECT DISTINCT loc
FROM emp e, dept d
WHERE e.deptno = d.deptno;

-- 3
SELECT ename AS name, sal AS salary, job
FROM emp
WHERE (ename LIKE 'T%' AND sal >= 1500 AND sal <= 2000) OR job = 'ANALYST';

-- 4
SELECT ename AS name
FROM emp
WHERE mgr is NULL; 

-- 5
SELECT DISTINCT mgr as empno
FROM emp
ORDER BY empno DESC;

-- 6
SELECT ename AS name,
  (CASE
    WHEN mgr IS NULL THEN -1
    WHEN empno > mgr THEN 0
    WHEN empno < mgr THEN 1
  END) AS starszy
FROM emp;

-- 7
SELECT sin(3.14)
FROM emp WHERE rownum <= 1;

/*
 Zadanie 4.

    1do tabeli z departamentami wstaw departament IT z Warszawy
    2dodaj siebie jako informatyka w tym departamencie bez przełożonego z pensją 2000
    3daj sobie podwyżkę o kwotę podatku 23%
    4skasuj wszystkich którzy zarabiają więcej niż Ty (więcej niż 2460)
    5okazało się, że Miller ma brata bliźniaka i przychodzą do pracy na zmianę; wstaw jego 
      brata jako nowego pracownika z tymi samymi danymi i 
      numerem 8015 (nie przepisuj ich jednak do zapytania)
      po czym osobnym zapytaniem podziel ich pensje na pół
*/

-- 1
INSERT INTO dept
VALUES (50, 'IT', 'WARSAW');

--2 
INSERT INTO emp
VALUES (7999, 'SZUBERSKI', 'INFORMAT', NULL, sysdate, 2000, NULL, 50);

-- 3
UPDATE emp
SET sal = sal * 1.23
WHERE ename = 'SZUBERSKI';

-- 4
DELETE FROM emp
WHERE sal > 2460;

-- 5
INSERT INTO emp
  (SELECT 8015, ename, job, mgr, hiredate, sal, comm, deptno 
  FROM emp WHERE ename = 'MILLER');

UPDATE emp
SET sal = sal/2
WHERE ename = 'MILLER';

/*
  Zadanie 4.
Stwórz tabele Student(imie, nazwisko, nr_indeksu, plec, aktywny, data_przyjecia) 
nie zapominając o odpowiednich warunkach na kolumny. 
*/
CREATE TABLE Student (
    imie VARCHAR2(20) NOT NULL,
    nazwisko VARCHAR2(30) NOT NULL,
    nr_indeksu NUMBER(6) PRIMARY KEY,
    pesel VARCHAR2(11) UNIQUE NOT NULL,
    plec CHAR(1) NOT NULL CHECK (plec = 'M' OR plec = 'F'),
    aktywny NUMBER(1) NOT NULL,
    data_przyjecia DATE NOT NULL
);