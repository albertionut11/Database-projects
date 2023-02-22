-- ex 6
-- afisam toti arbitrii de la o anumita federatie
-- asociative arrays (index-by tables) si cu varrays
CREATE OR REPLACE PROCEDURE show_referees(federation_id IN NUMBER)
IS
    TYPE arbitri_t IS TABLE OF arbitri.nume%TYPE;
    var_arbitri arbitri_t;
    TYPE arbitri_varray_t IS VARRAY(100) OF arbitri.prenume%TYPE;
    var_arbitri_2 arbitri_varray_t;
BEGIN
    SELECT nume BULK COLLECT INTO var_arbitri FROM arbitri WHERE federation_id = federation_id;
    SELECT prenume BULK COLLECT INTO var_arbitri_2 FROM arbitri WHERE federation_id = federation_id;
    DBMS_OUTPUT.PUT_LINE('Nume arbitri:');
    FOR i IN 1 .. var_arbitri.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(var_arbitri(i));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Prenume arbitri');
    FOR i IN 1 .. var_arbitri_2.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(var_arbitri_2(i));
    END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occured: '|| SQLERRM);
END;
BEGIN
  show_referees(1);
END;

-- ex 7
-- afisam jucatorul si antrenorul cu care se antreneaza in functie de id-ul jucatorului

CREATE OR REPLACE PROCEDURE show_player_and_coach(p_jucator_id IN NUMBER)
IS
    CURSOR c1 (p_jucator_id_in IN NUMBER) IS 
        SELECT jucator_id, nume, prenume, pozitie, numar_tricou FROM Jucatori WHERE jucator_id = p_jucator_id_in;
    CURSOR c2 (p_jucator_id_in IN NUMBER) IS 
        SELECT nume, prenume, specializare FROM Antrenori JOIN Antreneaza ON (Antreneaza.antrenor_id = Antrenori.antrenor_id) WHERE jucator_id = p_jucator_id_in;
    player_data Jucatori%ROWTYPE;
    TYPE coach_data_type IS RECORD(nume VARCHAR(20), prenume VARCHAR(20), specializare VARCHAR(20));
    coach_data coach_data_type;

BEGIN
    OPEN c1(p_jucator_id);
    FETCH c1 INTO player_data;
    CLOSE c1;
    DBMS_OUTPUT.PUT_LINE('Jucatorul:');
    DBMS_OUTPUT.PUT_LINE('----------------');
    DBMS_OUTPUT.PUT_LINE(player_data.nume || ' ' || player_data.prenume);
    DBMS_OUTPUT.PUT_LINE('Pozitie: ' || player_data.pozitie);
    DBMS_OUTPUT.PUT_LINE('Numar tricou: ' || player_data.numar_tricou);
    OPEN c2(p_jucator_id);
    FETCH c2 INTO coach_data;
    CLOSE c2;
    DBMS_OUTPUT.PUT_LINE('Antrenorul:');
    DBMS_OUTPUT.PUT_LINE('----------------');
    DBMS_OUTPUT.PUT_LINE(coach_data.nume || ' ' || coach_data.prenume);
    DBMS_OUTPUT.PUT_LINE('Specializare: ' || coach_data.specializare);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Jucatorul sau antrenorul nu exista.');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('A aparut o eroare: '|| SQLERRM);
END;

BEGIN
  show_player_and_coach(2);
END;

-- ex 8
-- afisam mai multe informatii despre o echipa: nume stadion, nr trofee, antrenor, patron
-- imbinam 4 tabele, (echipe, antreneaza, antrenori, patron)
-- avem 2 exceptii (nu gasim numele echipei, mai multe echipe cu acelasi nume)
CREATE OR REPLACE FUNCTION get_team_info(p_team_name IN VARCHAR2)
RETURN VARCHAR2 IS
    l_stadion VARCHAR2(100);
    l_trofeu NUMBER;
    l_antrenor VARCHAR2(100);
    l_patron VARCHAR2(100);
    CURSOR c1 (p_team_name_in VARCHAR2) IS
        SELECT e.stadion, e.nr_trofee, a.nume || ' ' || a.prenume, p.nume || ' ' || p.prenume
        FROM Echipe e
        JOIN Antreneaza ant ON (e.echipa_id = ant.echipa_id)
        JOIN Antrenori a ON (ant.antrenor_id = a.antrenor_id)
        JOIN Patron p ON (e.patron_id = p.patron_id)
        WHERE e.nume = p_team_name_in;
BEGIN
    OPEN c1(p_team_name);
    FETCH c1 INTO l_stadion, l_trofeu, l_antrenor, l_patron;
    CLOSE c1;
    RETURN 'Team '||p_team_name||' information: '||l_stadion||' - '||l_trofeu||' trophies - Coach: '||l_antrenor||' - Owner: '||l_patron;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Team not found';
    WHEN TOO_MANY_ROWS THEN
        RETURN 'Multiple teams found with the same name';
END;

BEGIN
    DBMS_OUTPUT.PUT_LINE(get_team_info('DINAMO BUCURESTI'));
END;

SET SERVEROUTPUT ON;

-- ex9
-- afisam numele jucatorului, echipa, numele patronului, tipul antrenamentului si antrenorul, unind 5 tabele
-- adaugat si exceptii
CREATE OR REPLACE PROCEDURE show_player_and_others(p_jucator_id IN NUMBER)
IS 
    TYPE_MISMATCH EXCEPTION;
    INVALID_INPUT EXCEPTION;
  v_nume_jucator JUCATORI.nume%type;
  v_prenume_jucator JUCATORI.prenume%type;
  v_nume_echipa ECHIPE.nume%type;
  v_nume_patron PATRON.nume%type;
  v_tip_antrenament ANTRENEAZA.tip_antrenament%type;
  v_nume_coach ANTRENORI.nume%type;
  v_prenume_coach ANTRENORI.prenume%type;

    CURSOR c1(p_jucator_id IN NUMBER) IS
    SELECT j.nume, j.prenume, e.nume, p.nume, a.tip_antrenament, coach.prenume, coach.nume FROM JUCATORI j
    JOIN LEGITIMEAZA l ON j.jucator_id = l.jucator_id
    JOIN ECHIPE e ON l.echipa_id = e.echipa_id
    JOIN PATRON p ON p.patron_id = e.patron_id
    JOIN ANTRENEAZA a ON a.echipa_id = e.echipa_id
    JOIN ANTRENORI coach ON coach.antrenor_id = a.antrenor_id
    WHERE j.jucator_id = p_jucator_id;
    
BEGIN
    OPEN c1(p_jucator_id);   
    FETCH c1 INTO v_nume_jucator, v_prenume_jucator, v_nume_echipa, v_nume_patron, v_tip_antrenament, v_nume_coach, v_prenume_coach;
    DBMS_OUTPUT.PUT_LINE('Player Name: ' || v_nume_jucator || ' '|| v_prenume_jucator);
    DBMS_OUTPUT.PUT_LINE('Team Name: ' || v_nume_echipa);
    DBMS_OUTPUT.PUT_LINE('Patron Name: ' || v_nume_patron);
    DBMS_OUTPUT.PUT_LINE('Type of Training: ' || v_tip_antrenament);
    DBMS_OUTPUT.PUT_LINE('Coach Name: ' || v_prenume_coach || ' '|| v_nume_coach);
    CLOSE c1;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No player with the ID ' || p_jucator_id || ' found.');
    WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('More than one player with the ID ' || p_jucator_id || ' found.');
    WHEN TYPE_MISMATCH THEN
    DBMS_OUTPUT.PUT_LINE('Ati gresit un tip de date!');
    RETURN;
    WHEN INVALID_INPUT THEN
    DBMS_OUTPUT.PUT_LINE('Id-ul jucatorului trebuie sa fie de tip int si nu poate fi NULL!');
    RETURN;
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;

BEGIN
show_player_and_others(1);
END;

--ex 10
CREATE OR REPLACE TRIGGER prevent_edit_on_working_days
BEFORE INSERT OR DELETE OR UPDATE ON FEDERATII
BEGIN
  IF (TO_CHAR(SYSDATE,'DY') IN ('FRI','SAT','SUN')) THEN
    RAISE_APPLICATION_ERROR(-20001,'Operations on the table are only allowed during Fridays, Saturdays or Sundays!');
  END IF; 
END;

INSERT INTO FEDERATII (federatie_id, nume, presedinte)
VALUES (3, 'Federatia Italiana de Fotbal', 'Gabriele Gravina');

INSERT INTO FEDERATII (federatie_id, nume, presedinte)
VALUES (4, 'Federatia Spaniola', 'Sefu Spaniolu');


--ex 11

CREATE OR REPLACE TRIGGER prevent_delete_played_matches
BEFORE DELETE ON Joaca_Meciuri
FOR EACH ROW
BEGIN
  IF :old.data_meci < SYSDATE THEN
    raise_application_error(-20001, 'Cannot delete matches that have already taken place');
  END IF;
END;

SELECT * FROM JOACA_MECIURI;
DELETE FROM Joaca_Meciuri
WHERE etapa_id = 5;

--ex 12

CREATE TABLE log_history
(
    username VARCHAR2(20),
    log_date DATE,
    db_name VARCHAR2(20),
    event VARCHAR2(100),
    obj_name VARCHAR2(100)
);

CREATE OR REPLACE TRIGGER log_events
    AFTER CREATE OR DROP OR ALTER ON SCHEMA
BEGIN
    INSERT INTO log_history VALUES(SYS.LOGIN_USER, SYSDATE, SYS.DATABASE_NAME, SYS.SYSEVENT, SYS.DICTIONARY_OBJ_NAME);
END;

SELECT * FROM log_history;


--ex 13 Creare pachet
CREATE OR REPLACE PACKAGE Pachet_Proiect AS
    PROCEDURE show_referees(federation_id IN NUMBER);
    PROCEDURE show_player_and_coach(p_jucator_id IN NUMBER);
    FUNCTION get_team_info(p_team_name IN VARCHAR2) RETURN VARCHAR2;
    PROCEDURE show_player_and_others(p_jucator_id IN NUMBER);
END Pachet_Proiect;
--ex 6
CREATE OR REPLACE PACKAGE BODY Pachet_Proiect AS PROCEDURE show_referees(federation_id IN NUMBER)
IS
    TYPE arbitri_t IS TABLE OF arbitri.nume%TYPE;
    var_arbitri arbitri_t;
    TYPE arbitri_varray_t IS VARRAY(100) OF arbitri.prenume%TYPE;
    var_arbitri_2 arbitri_varray_t;
BEGIN
    SELECT nume BULK COLLECT INTO var_arbitri FROM arbitri WHERE federation_id = federation_id;
    SELECT prenume BULK COLLECT INTO var_arbitri_2 FROM arbitri WHERE federation_id = federation_id;
    DBMS_OUTPUT.PUT_LINE('Nume arbitri:');
    FOR i IN 1 .. var_arbitri.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(var_arbitri(i));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Prenume arbitri');
    FOR i IN 1 .. var_arbitri_2.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(var_arbitri_2(i));
    END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occured: '|| SQLERRM);
END;
--ex 7
    PROCEDURE show_player_and_coach(p_jucator_id IN NUMBER)
IS
    CURSOR c1 (p_jucator_id_in IN NUMBER) IS 
        SELECT jucator_id, nume, prenume, pozitie, numar_tricou FROM Jucatori WHERE jucator_id = p_jucator_id_in;
    CURSOR c2 (p_jucator_id_in IN NUMBER) IS 
        SELECT nume, prenume, specializare FROM Antrenori JOIN Antreneaza ON (Antreneaza.antrenor_id = Antrenori.antrenor_id) WHERE jucator_id = p_jucator_id_in;
    player_data Jucatori%ROWTYPE;
    TYPE coach_data_type IS RECORD(nume VARCHAR(20), prenume VARCHAR(20), specializare VARCHAR(20));
    coach_data coach_data_type;

BEGIN
    OPEN c1(p_jucator_id);
    FETCH c1 INTO player_data;
    CLOSE c1;
    DBMS_OUTPUT.PUT_LINE('Jucatorul:');
    DBMS_OUTPUT.PUT_LINE('----------------');
    DBMS_OUTPUT.PUT_LINE(player_data.nume || ' ' || player_data.prenume);
    DBMS_OUTPUT.PUT_LINE('Pozitie: ' || player_data.pozitie);
    DBMS_OUTPUT.PUT_LINE('Numar tricou: ' || player_data.numar_tricou);
    OPEN c2(p_jucator_id);
    FETCH c2 INTO coach_data;
    CLOSE c2;
    DBMS_OUTPUT.PUT_LINE('Antrenorul:');
    DBMS_OUTPUT.PUT_LINE('----------------');
    DBMS_OUTPUT.PUT_LINE(coach_data.nume || ' ' || coach_data.prenume);
    DBMS_OUTPUT.PUT_LINE('Specializare: ' || coach_data.specializare);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Jucatorul sau antrenorul nu exista.');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('A aparut o eroare: '|| SQLERRM);
END;
-- ex 8
    FUNCTION get_team_info(p_team_name IN VARCHAR2) RETURN VARCHAR2 
    IS
    l_stadion VARCHAR2(100);
    l_trofeu NUMBER;
    l_antrenor VARCHAR2(100);
    l_patron VARCHAR2(100);
    CURSOR c1 (p_team_name_in VARCHAR2) IS
        SELECT e.stadion, e.nr_trofee, a.nume || ' ' || a.prenume, p.nume || ' ' || p.prenume
        FROM Echipe e
        JOIN Antreneaza ant ON (e.echipa_id = ant.echipa_id)
        JOIN Antrenori a ON (ant.antrenor_id = a.antrenor_id)
        JOIN Patron p ON (e.patron_id = p.patron_id)
        WHERE e.nume = p_team_name_in;
BEGIN
    OPEN c1(p_team_name);
    FETCH c1 INTO l_stadion, l_trofeu, l_antrenor, l_patron;
    CLOSE c1;
    RETURN 'Team '||p_team_name||' information: '||l_stadion||' - '||l_trofeu||' trophies - Coach: '||l_antrenor||' - Owner: '||l_patron;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Team not found';
    WHEN TOO_MANY_ROWS THEN
        RETURN 'Multiple teams found with the same name';
END;

-- ex 9
 PROCEDURE show_player_and_others(p_jucator_id IN NUMBER)
IS 

    TYPE_MISMATCH EXCEPTION;
    INVALID_INPUT EXCEPTION;
  v_nume_jucator JUCATORI.nume%type;
  v_prenume_jucator JUCATORI.prenume%type;
  v_nume_echipa ECHIPE.nume%type;
  v_nume_patron PATRON.nume%type;
  v_tip_antrenament ANTRENEAZA.tip_antrenament%type;
  v_nume_coach ANTRENORI.nume%type;
  v_prenume_coach ANTRENORI.prenume%type;

    CURSOR c1(p_jucator_id IN NUMBER) IS
    SELECT j.nume, j.prenume, e.nume, p.nume, a.tip_antrenament, coach.prenume, coach.nume FROM JUCATORI j
    JOIN LEGITIMEAZA l ON j.jucator_id = l.jucator_id
    JOIN ECHIPE e ON l.echipa_id = e.echipa_id
    JOIN PATRON p ON p.patron_id = e.patron_id
    JOIN ANTRENEAZA a ON a.echipa_id = e.echipa_id
    JOIN ANTRENORI coach ON coach.antrenor_id = a.antrenor_id
    WHERE j.jucator_id = p_jucator_id;
    
BEGIN
    OPEN c1(p_jucator_id);   
    FETCH c1 INTO v_nume_jucator, v_prenume_jucator, v_nume_echipa, v_nume_patron, v_tip_antrenament, v_nume_coach, v_prenume_coach;
    DBMS_OUTPUT.PUT_LINE('Player Name: ' || v_nume_jucator || ' '|| v_prenume_jucator);
    DBMS_OUTPUT.PUT_LINE('Team Name: ' || v_nume_echipa);
    DBMS_OUTPUT.PUT_LINE('Patron Name: ' || v_nume_patron);
    DBMS_OUTPUT.PUT_LINE('Type of Training: ' || v_tip_antrenament);
    DBMS_OUTPUT.PUT_LINE('Coach Name: ' || v_prenume_coach || ' '|| v_nume_coach);
    CLOSE c1;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No player with the ID ' || p_jucator_id || ' found.');
    WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('More than one player with the ID ' || p_jucator_id || ' found.');
    WHEN TYPE_MISMATCH THEN
    DBMS_OUTPUT.PUT_LINE('Ati gresit un tip de date!');
    RETURN;
WHEN INVALID_INPUT THEN
    DBMS_OUTPUT.PUT_LINE('Id-ul jucatorului trebuie sa fie de tip int si nu poate fi NULL!');
            RETURN;
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
END Pachet_Proiect;


BEGIN
DBMS_OUTPUT.PUT_LINE(Pachet_Proiect.get_team_info('DINAMO BUCURESTI'));
DBMS_OUTPUT.PUT_LINE(Pachet_Proiect.get_team_info('FCSB'));
DBMS_OUTPUT.PUT_LINE('---------------------------------');
pachet_proiect.show_player_and_coach(1);
pachet_proiect.show_player_and_coach(2);
DBMS_OUTPUT.PUT_LINE('---------------------------------');
pachet_proiect.show_player_and_others(1);
pachet_proiect.show_player_and_others(2);
DBMS_OUTPUT.PUT_LINE('---------------------------------');
pachet_proiect.show_referees(1);
END;


