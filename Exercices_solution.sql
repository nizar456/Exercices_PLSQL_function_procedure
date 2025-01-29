create table  Employe 
(Num_Emp int primary key,
Nom varchar(25),
Prenom varchar(25),
age int ,
ville varchar(25),
salaire float,
Num_Service int,
FOREIGN KEY (Num_Service)
REFERENCES Service(Num_Service));


create table Service (Num_Service 
int primary key ,
nom_service varchar(25) ,
departement varchar(25)) ;

create or replace procedure ADD_Service
(p_id_service service.Num_Service%TYPE,
p_nom_service service.nom_service%TYPE,
p_departement_service service.departement%TYPE)
IS
BEGIN
INSERT INTO service 
(Num_Service,nom_service,departement)
VALUES 
(p_id_service,p_nom_service,
p_departement_service);
END;

BEGIN
    ADD_Service(101, 'Maintenance', 'IT');
    ADD_Service(102, 'RH', 'Ressources Humaines');
    ADD_Service(103, 'Marketing', 'Ventes');
END;

CREATE OR REPLACE FUNCTION VALID_NoService
(id Service.nom_service%TYPE)RETURN BOOLEAN
IS
v_count Number;
BEGIN
SELECT COUNT(*)
INTO v_count
FROM Service
WHERE num_service= id;
RETURN v_count>0;
END;

SET SERVEROUTPUT ON;
DECLARE 
is_valid BOOLEAN;
BEGIN
    is_valid:=valid_noservice(101);
    IF is_valid THEN
        DBMS_OUTPUT.PUT_LINE
        ('le num est valide');
    ELSE
    DBMS_OUTPUT.PUT_LINE
        ('le num N est pas valide');
    END IF;
END;

CREATE OR REPLACE PROCEDURE ADD_Employe (
    p_num_emp       IN Employe.Num_Emp%TYPE,
    p_nom           IN Employe.Nom%TYPE,
    p_prenom        IN Employe.Prenom%TYPE,
    p_age           IN Employe.Age%TYPE,
    p_ville         IN Employe.Ville%TYPE,
    p_salaire       IN Employe.Salaire%TYPE,
    p_num_service   IN Employe.Num_Service%TYPE
)
IS
    service_valid BOOLEAN;
BEGIN
    service_valid := VALID_NoService(p_num_service);

    IF service_valid THEN
        INSERT INTO Employe (
            Num_Emp, Nom, Prenom, Age, Ville, Salaire, Num_Service
        ) VALUES (
            p_num_emp, p_nom, p_prenom, p_age, p_ville, p_salaire, p_num_service
        );

        DBMS_OUTPUT.PUT_LINE('Employé ajouté avec succès : ' || p_nom || ' ' || p_prenom);
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Le numéro de service ' || p_num_service || ' n''est pas valide.');
    END IF;
END;

BEGIN
    ADD_Employe(1, 'Laarbi', 'chrif', 30, 'Paris', 2500.00, 101);
END; 

--6--
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE Afficher_Employe (
    p_num_emp IN Employe.Num_Emp%TYPE
)
IS
    v_nom        Employe.Nom%TYPE;
    v_prenom     Employe.Prenom%TYPE;
    v_age        Employe.Age%TYPE;
    v_ville      Employe.Ville%TYPE;
    v_salaire    Employe.Salaire%TYPE;
    v_num_service Employe.Num_Service%TYPE;
BEGIN
    SELECT Nom, Prenom, Age, Ville, Salaire, Num_Service
    INTO v_nom, v_prenom, v_age, v_ville, v_salaire, v_num_service
    FROM Employe
    WHERE Num_Emp = p_num_emp;

    DBMS_OUTPUT.PUT_LINE('Informations de l''employé :');
    DBMS_OUTPUT.PUT_LINE('Nom : ' || v_nom);
    DBMS_OUTPUT.PUT_LINE('Prénom : ' || v_prenom);
    DBMS_OUTPUT.PUT_LINE('Âge : ' || v_age);
    DBMS_OUTPUT.PUT_LINE('Ville : ' || v_ville);
    DBMS_OUTPUT.PUT_LINE('Salaire : ' || v_salaire);
    DBMS_OUTPUT.PUT_LINE('Numéro de service : ' || v_num_service);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : Aucun employé trouvé avec le code ' || p_num_emp || '.');
END;
--TEST--
BEGIN
    Afficher_Employe(1);
END;

--7--

CREATE OR REPLACE FUNCTION Salaire_Moyen_Departement (
    p_num_service IN Employe.Num_Service%TYPE
) RETURN NUMBER
IS
    v_salaire_moyen NUMBER;
BEGIN
    SELECT AVG(Salaire)
    INTO v_salaire_moyen
    FROM Employe
    WHERE Num_Service = p_num_service;

    RETURN v_salaire_moyen;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;

--TEST--

DECLARE
    v_salaire_moyen NUMBER;
BEGIN
    v_salaire_moyen := Salaire_Moyen_Departement(101);

    IF v_salaire_moyen IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Salaire moyen pour le département 101 : ' || v_salaire_moyen);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Aucun employé trouvé pour le département 101.');
    END IF;
END;

--8--

CREATE OR REPLACE FUNCTION Salaire_Annuel (
    p_num_emp IN Employe.Num_Emp%TYPE
) RETURN NUMBER
IS
    v_salaire_mensuel Employe.Salaire%TYPE;
    v_salaire_annuel NUMBER;
    v_prime NUMBER;
BEGIN
    SELECT Salaire
    INTO v_salaire_mensuel
    FROM Employe
    WHERE Num_Emp = p_num_emp;
    v_salaire_annuel := v_salaire_mensuel * 12;
    v_prime := v_salaire_annuel * 0.02;
    v_salaire_annuel := v_salaire_annuel + v_prime;
    RETURN v_salaire_annuel;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : Aucun employé trouvé avec le numéro ' || p_num_emp || '.');
        RETURN NULL;
END;

--TEST--

DECLARE
    v_salaire_annuel NUMBER;
BEGIN
    v_salaire_annuel := Salaire_Annuel(1);
    DBMS_OUTPUT.PUT_LINE('SALAIRE ANNUEL EST :' 
    || v_salaire_annuel);
END;

--9--
CREATE OR REPLACE FUNCTION NB_Emp (
    p_num_service IN Employe.Num_Service%TYPE
) RETURN NUMBER
IS
    v_nb_employes NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_nb_employes
    FROM Employe
    WHERE Num_Service = p_num_service;

    RETURN v_nb_employes;
END;

--TEST--
DECLARE
    v_nb_employes NUMBER;
BEGIN
    v_nb_employes := NB_Emp(101);

    DBMS_OUTPUT.PUT_LINE
    ('Nombre d''employés dans le service : '
    || v_nb_employes);
END;

--10--

CREATE OR REPLACE PROCEDURE Liste_Services IS
    TYPE Service_Table_Type IS TABLE OF Service.nom_service%TYPE INDEX BY PLS_INTEGER;
    v_service_table Service_Table_Type;

    CURSOR service_cursor IS
        SELECT s.nom_service
        FROM Service s
        WHERE (
            SELECT COUNT(*)
            FROM Employe e
            WHERE e.Num_Service = s.Num_Service
        ) > 3;

    v_index PLS_INTEGER := 0;
    v_nom_service Service.nom_service%TYPE;

BEGIN
    OPEN service_cursor;
    LOOP
        FETCH service_cursor INTO v_nom_service;
        EXIT WHEN service_cursor%NOTFOUND;

        v_index := v_index + 1;
        v_service_table(v_index) := v_nom_service;
    END LOOP;
    CLOSE service_cursor;

    IF v_index = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Aucun service avec plus de 3 employés trouvé.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Services avec plus de 3 employés :');
        FOR i IN 1 .. v_index LOOP
            DBMS_OUTPUT.PUT_LINE('- ' || v_service_table(i));
        END LOOP;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : Aucun service trouvé.');
    WHEN INVALID_CURSOR THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : Problème avec le curseur.');
END;

--test--
BEGIN
    ADD_Employe(2, 'Martin', 'Paul', 25, 'Lyon', 3000, 101);
    ADD_Employe(3, 'Durand', 'Claire', 35, 'Marseille', 3500, 101);
    ADD_Employe(4, 'Lemoine', 'Sophie', 28, 'Bordeaux', 3200, 102);
    ADD_Employe(5, 'Girard', 'Antoine', 45, 'Nice', 4000, 102);
    ADD_Employe(6, 'SAMIR', 'Rodrygo', 55, 'Nice', 5000, 102);
    ADD_Employe(7, 'Chmaykel', 'Rodrygo', 22, 'Nice', 5500, 102);
    ADD_Employe(8, 'Jilali', 'Amigo', 48, 'Nice', 5300, 101);
END;

BEGIN
    Liste_Services;
END;
















    

