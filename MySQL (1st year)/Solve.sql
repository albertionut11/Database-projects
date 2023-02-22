--11

-- 1
--Afisati numele, prenumele si id-ul jucatorilor transferati pe o suma mai mare 
--de 10000 de euro si care joaca la o echipa de pe primele 3 locuri
SELECT j.jucator_id, j.nume, j.prenume
FROM jucatori j
JOIN transfera t ON j.jucator_id = t.jucator_id
JOIN legitimeaza l ON j.jucator_id = l.jucator_id
WHERE t.suma_transfer >= 10000
AND l.echipa_id IN (
    SELECT p.echipa_id 
    FROM participa p
    WHERE p.poz_clasament <= 3
)
ORDER BY j.nume ASC;

--2
--Afisati daca un arbitru este platit bine, ok sau putin.
WITH detalii_contract as (SELECT a.arbitru_id, a.salariu, a.ani_contract FROM angajeaza a)
SELECT dc.arbitru_id,
CASE 
    WHEN dc.salariu >= 3500 THEN 'Arbitru platit bine'
    WHEN dc.salariu >= 3000 THEN 'Arbitru platit ok'
    WHEN dc.salariu >= 2000 THEN 'Arbitru platit putin'
END
FROM detalii_contract dc;


--3
--Afiseaza numarul de jucatori de la fiecare echipa care are minim 5 jucatori
SELECT COUNT(l.jucator_id), l.echipa_id
FROM legitimeaza l
JOIN echipe e ON l.echipa_id = e.echipa_id
JOIN jucatori j ON l.jucator_id = j.jucator_id
GROUP BY l.echipa_id
HAVING COUNT(l.jucator_id) > 5;


--4
--Afisaeza numele, prenumele jucatorilor si numele echipei care are mai multe puncte decat media de puncte din campionat
SELECT LOWER(j.nume), LOWER(j.prenume), UPPER(e.nume)
FROM jucatori j
JOIN legitimeaza l ON l.jucator_id = j.jucator_id
JOIN echipe e ON l.echipa_id = e.echipa_id
JOIN participa p ON p.echipa_id = e.echipa_id
WHERE p.puncte >= (
    SELECT((SELECT MAX(p1.puncte) FROM participa p1) + (SELECT MIN(p2.puncte) FROM participa p2))/2 FROM SYS.dual
);

SELECT * FROM PARTICIPA;

--5
--Utilizarea lui NVL, inlocuieste pentru jucatorii neplatiti, valoarea 500
SELECT l.jucator_id, j.nume, j.prenume, NVL(l.salariu,500)
FROM legitimeaza l
JOIN jucatori j ON j.jucator_id = l.jucator_id;


--12
UPDATE jucatori SET jucator_id = 100 WHERE nume = 'BALAUTA';
DELETE FROM legitimeaza WHERE salariu IS NULL;
UPDATE legitimeaza l SET l.salariu = 1000 WHERE l.jucator_id = (
    SELECT j.jucator_id
    FROM jucatori j
    WHERE j.nume = 'HORDILA'   
);
SELECT * FROM legitimeaza;
SELECT * FROM jucatori;
ROLLBACK;

--13

CREATE SEQUENCE secventa
   START WITH 1
   INCREMENT BY 1;
   
CREATE TABLE Exemplu(
    nume VARCHAR(20),
    prenume VARCHAR(20),
    idd NUMBER(10)
);

INSERT INTO Exemplu
values('Albert','Balauta',secventa.nextval);

INSERT INTO Exemplu
values('Haulica','Tudor',secventa.nextval);

INSERT INTO Exemplu
values('Alistar','Vlad',secventa.nextval);

SELECT * FROM Exemplu;

--14

CREATE OR REPLACE VIEW echipe_jucatori(echipa, nume_jucator, prenume_jucator)
AS (
SELECT e.nume, j.nume, j.prenume
FROM jucatori j
JOIN legitimeaza l ON l.jucator_id = j.jucator_id
JOIN echipe e ON e.echipa_id = l.echipa_id
);   

SELECT * FROM echipe_jucatori;
UPDATE echipe_jucatori SET echipa = 'FC VASLUI' WHERE nume_jucator = 'BALAUTA';
UPDATE echipe_jucatori SET echipa = 'FCSB', nume_jucator = '3fun' WHERE nume_jucator = 'TRIFAN';



