DELIMITER //


CREATE DEFINER=`polyweb`@`%` PROCEDURE `new_project`(
    IN st VARCHAR(10),
    IN PROJECT_TYPE INTEGER,
    IN DESCR VARCHAR(150)
)
BEGIN
    DECLARE nb INT DEFAULT 1;
    DECLARE nbname VARCHAR(32) DEFAULT '';
    DECLARE stname VARCHAR(32);
    DECLARE ll INT;


    -- Stocker le préfixe original dans stname
    SET stname = st;


    -- Créer le pattern pour la recherche dans les noms de projet
    SET st = CONCAT(st, '%');


    -- Longueur du préfixe
    SET ll = CHAR_LENGTH(stname);


    -- Trouver le numéro maximum existant après le préfixe
    SELECT MAX(CAST(SUBSTRING(name, ll + 6) AS UNSIGNED)) + 1
    INTO nb
    FROM PolyprojectNGS.projects
    WHERE name LIKE st;


    -- S'il n'y a pas encore de projet, commencer à 1
    IF nb IS NULL THEN
        SET nb = 1;
    END IF;


    -- Formater le numéro avec des zéros (ex : 0001)
    SET nbname = LPAD(nb, 4, '0');


    -- Créer le nom final du projet
    SET nbname = CONCAT(stname, YEAR(CURDATE()), '_', nbname);


    -- Insérer le projet
    INSERT INTO PolyprojectNGS.projects(name, type_project_id, description)
    VALUES (nbname, PROJECT_TYPE, DESCR);


    -- Retourner l'ID et le nom du projet
    SELECT project_id AS project_id, name AS name
    FROM PolyprojectNGS.projects
    WHERE name = nbname;
END //


DELIMITER ;