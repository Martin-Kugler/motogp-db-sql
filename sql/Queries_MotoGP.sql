-- QUERIES MOTOGP --

USE motogp_db;

-- 1 --

-- Nombre y apellidos del piloto que ha resultado campeón del mundo del año más reciente de la 
-- base de datos en la categoría MotoGP

SELECT r.first_name, r.last_name
FROM (SELECT re.id_rider, ra.year, SUM(points) as suma
		FROM results re JOIN races ra ON re.id_race = ra.id_race
        WHERE ra.id_category = "MotoGP" AND ra.year = (SELECT MAX(ra.year) FROM races ra WHERE ra.id_category = "MotoGP")
        GROUP BY re.id_rider, ra.year
        HAVING SUM(re.points) > 0) as total_points
JOIN riders r ON total_points.id_rider = r.id_rider
WHERE suma >= ALL (SELECT SUM(re.points) 
					FROM results re JOIN races ra ON re.id_race = ra.id_race
					WHERE ra.id_category = "MotoGP" AND ra.year= (SELECT MAX(ra.year) FROM races ra WHERE ra.id_category = "MotoGP")
					GROUP BY re.id_rider, ra.year
					HAVING SUM(re.points) > 0);

-- 2 --

-- País o países con mayor número de pilotos diferentes en la década de los 2010 (de 2010 a 2019
-- inclusive) en categorías distintas a MotoE. Muestra tanto las siglas del país como en número de 
-- pilotos diferentes que han competido en al menos una carrera.

SELECT r.id_country, COUNT(DISTINCT r.id_rider) as count_riders
FROM riders r
    INNER JOIN results re ON re.id_rider = r.id_rider
    INNER JOIN races ra ON ra.id_race = re.id_race
WHERE year BETWEEN 2010 AND 2019 
	AND ra.id_category <> 'MotoE'
GROUP BY r.id_country
HAVING count_riders >= ALL(
	SELECT COUNT(DISTINCT r2.id_rider)
	FROM riders r2
		INNER JOIN results re2 ON re2.id_rider = r2.id_rider
		INNER JOIN races ra2 ON ra2.id_race = re2.id_race
	WHERE year BETWEEN 2010 AND 2019 
		AND ra2.id_category <> 'MotoE'
	GROUP BY r2.id_country
);

-- 3 --

-- Nombre y apellidos de los pilotos que han ganado carreras en las categorías de MotoGP, Moto2 y Moto 3

SELECT DISTINCT r.first_name, r.last_name
FROM riders r
	INNER JOIN results re ON re.id_rider = r.id_rider
    INNER JOIN races ra ON ra.id_race = re.id_race
WHERE ra.id_category IN ("MotoGP", "Moto2", "Moto3") 
   AND re.position = 1
GROUP BY r.id_rider
HAVING COUNT(DISTINCT ra.id_category) = 3;
   
-- 4 --

-- Nombre y apellidos de los pilotos que, habiendo sido campeones del mundo en la categoríaa Moto2
-- y Moto3, no lo han sido en MotoGP.

-- Definimos una tabla virtual con todos los campeones anuales por categoría que reutilizaremos en la consulta principal: 
WITH Champions AS (
    SELECT ra.year, ra.id_category, re.id_rider, SUM(re.points) as total_puntos
    FROM results re
		INNER JOIN races ra ON re.id_race = ra.id_race
    GROUP BY ra.year, ra.id_category, re.id_rider
    HAVING (ra.year, ra.id_category, total_puntos) IN (
        -- Subconsulta para encontrar la puntuación máxima de cada año+categoría:
        SELECT ra2.year, ra2.id_category, MAX(anual_points)
        FROM (
			-- Subconsulta para encontrar la puntuación total de cada año+categoría+piloto:
            SELECT ra3.year, ra3.id_category, re3.id_rider, SUM(re3.points) AS anual_points
            FROM results re3
				INNER JOIN races ra3 ON re3.id_race = ra3.id_race
            GROUP BY ra3.year, ra3.id_category, re3.id_rider
        ) AS ra2
        GROUP BY year, id_category
    )
)

-- Ahora aplicamos la lógica del enunciado mediante una consulta principal reutilizando la tabla virtual definida: 
SELECT first_name, last_name
FROM riders
WHERE id_rider IN (SELECT id_rider FROM Champions WHERE id_category = 'Moto2') 
  AND id_rider IN (SELECT id_rider FROM Champions WHERE id_category = 'Moto3')
  AND id_rider NOT IN (SELECT id_rider FROM Champions WHERE id_category = 'MotoGP');  

-- 5 --

-- Nombre de los equipos y número de veces en las que alguno de los pilotos ha ganado un mundial en la categoría
-- MotoGP ordenado de mayor a menor número de victorias

SELECT t.team_name, COUNT(*) AS wins
FROM (SELECT p.id_rider, p.year, p.total_points
	FROM (SELECT re.id_rider, ra.year, SUM(points) AS total_points 
			FROM results re JOIN races ra ON re.id_race = ra.id_race
			WHERE ra.id_category = "MotoGP" 
			GROUP BY id_rider, ra.year
			HAVING SUM(re.points) > 0) as p
	WHERE p.total_points >= ALL (SELECT SUM(points) as total_points
								FROM results re JOIN races ra ON re.id_race = ra.id_race
								WHERE ra.id_category = "MotoGP"  AND ra.year = p.year
								GROUP BY id_rider, ra.year
								HAVING SUM(re.points) > 0)) as champions
	INNER JOIN (SELECT x.id_rider, x.year, x.id_team, x.team_points
				FROM (SELECT re.id_rider, ra.year, re.id_team, SUM(re.points) as team_points
					  FROM results re JOIN races ra ON re.id_race = ra.id_race
                      WHERE ra.id_category = "MotoGP"
                      GROUP BY re.id_rider, ra.year, re.id_team) as x
				WHERE x.team_points >= ALL(SELECT SUM(re.points) as team_points
										   FROM results re
                                           JOIN races ra ON re.id_race = ra.id_race
                                           WHERE ra.id_category = "MotoGP" AND ra.year = x.year AND re.id_rider = x.id_rider
                                           GROUP BY re.id_team)) as champ_team
				ON champ_team.id_rider = champions.id_rider AND champ_team.year = champions.year
	INNER JOIN teams t ON t.id_team = champ_team.id_team
    GROUP BY t.id_team, t.team_name
    ORDER BY wins DESC;

-- 6 -- 

-- Listado de circuitos donde jamás ha ganado un piloto cuya nacionalidad coincida con el país del
-- trazado, en ninguna de las categorías registradas.

SELECT id_circuit, circuit_name
FROM circuits
WHERE id_circuit NOT IN (
	-- Subconsulta para encontrar aquellos circuitos donde haya ganado al menos un piloto con la misma nacionalidad que el circuito respectivo: 
	SELECT DISTINCT c.id_circuit
	FROM riders r
		INNER JOIN results re ON re.id_rider = r.id_rider
		INNER JOIN races ra ON ra.id_race = re.id_race
		INNER JOIN circuits c ON c.id_circuit = ra.id_circuit
	WHERE position = 1 AND r.id_country = c.id_country
);
			