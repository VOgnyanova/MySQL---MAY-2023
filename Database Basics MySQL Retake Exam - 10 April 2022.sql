# 0. create a database called softuni_imdb. 

CREATE DATABASE `softuni_imdb`;

# 01. Table Design
 
CREATE TABLE `countries` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(30) NOT NULL UNIQUE,
    `continent` VARCHAR(30) NOT NULL,
    `currency` VARCHAR(5) NOT NULL
);
 
CREATE TABLE `genres` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL UNIQUE
);
 
 
CREATE TABLE `actors` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(50) NOT NULL,
    `last_name` VARCHAR(50) NOT NULL,
    `birthdate` DATE NOT NULL,
    `height` INT,
    `awards` INT,
    `country_id` INT NOT NULL,
    CONSTRAINT `fk_people_countries` FOREIGN KEY (`country_id`)
        REFERENCES countries (`id`)
);
 
CREATE TABLE `movies_additional_info` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `rating` DECIMAL(10 , 2 ) NOT NULL,
    `runtime` INT NOT NULL,
    `picture_url` VARCHAR(80) NOT NULL,
    `budget` DECIMAL(10 , 2 ),
    `release_date` DATE NOT NULL,
    `has_subtitles` TINYINT(1),
    `description` TEXT
);
 
CREATE TABLE `movies` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `title` VARCHAR(70) UNIQUE NOT NULL,
    `country_id` INT NOT NULL,
    `movie_info_id` INT NOT NULL UNIQUE,
    CONSTRAINT `fk_movies_countries` FOREIGN KEY (`country_id`)
        REFERENCES countries (`id`),
    CONSTRAINT `fk_movies_movie_info` FOREIGN KEY (`movie_info_id`)
        REFERENCES movies_additional_info (id)
);
 
CREATE TABLE `movies_actors` (
    `movie_id` INT,
    `actor_id` INT,
    KEY `pk_movie_actor` (`movie_id` , `actor_id`),
    CONSTRAINT `fk_movies_actors_movies` FOREIGN KEY (`movie_id`)
        REFERENCES movies (id),
    CONSTRAINT `fk_movies_actors_actors` FOREIGN KEY (`actor_id`)
        REFERENCES actors (id)
);
 
CREATE TABLE `genres_movies` (
    `genre_id` INT,
    `movie_id` INT,
    KEY `pk_genre_movies` (`genre_id` , `movie_id`),
    CONSTRAINT `fk_genres_movies_genres` FOREIGN KEY (`genre_id`)
        REFERENCES genres (id),
    CONSTRAINT `fk_genres_movies_movies` FOREIGN KEY (`movie_id`)
        REFERENCES movies (id)
);

# 02. Insert

INSERT INTO `actors`(`first_name`, `last_name`, `birthdate`, `height`, `awards`, `country_id`)
SELECT (REVERSE(a.`first_name`)),
(REVERSE(a.`last_name`)),
(DATE (a.`birthdate` - 2)),
(a.`height` + 10),
(a.`country_id`),(3) 
FROM `actors` a
WHERE a.`id` <= 10;


# 3. Udate

UPDATE `movies_additional_info` AS m 
SET 
    m.`runtime` = m.`runtime` - 10
WHERE
    m.`id` BETWEEN 15 AND 25;
    
# 4. Delete

DELETE c, m
FROM `countries` AS c 
LEFT JOIN `movies` AS m
ON c.`id` =  m.`country_id`
WHERE m.`country_id` IS NULL;


# 05. Countries

SELECT `id`,`name`,`continent`,`currency`
FROM `countries`
ORDER BY `currency` DESC, `id`;

# 06. Old movies

SELECT 
    m.`id`,
    m2.`title`,
    m.`runtime`,
    m.`budget`,
    m.`release_date`
FROM
    `movies_additional_info` AS m
        JOIN
    `movies` m2 ON m.`id` = m2.`movie_info_id`
WHERE
    YEAR(m.`release_date`) BETWEEN 1996 AND 1999
ORDER BY m.`runtime` , m.`id`
LIMIT 20;


# 07. Movie casting

SELECT 
    CONCAT(`first_name`, ' ', `last_name`) AS `full_name`,
    CONCAT(REVERSE(`last_name`),
            LENGTH(`last_name`),
            '@cast.com') AS `email`,
    2022 - YEAR(`birthdate`) AS `age`,
    `height`
FROM
    `actors`
WHERE
    `id` NOT IN (SELECT 
            `actor_id`
        FROM
            `movies_actors`)
ORDER BY `height`; 

# 08. International festival
SELECT 
    c.`name`, COUNT(m.`id`) AS `movies_count`
FROM
    `movies` AS m
        JOIN
    `countries` AS c ON c.`id` = m.`country_id`
GROUP BY c.`name`
HAVING `movies_count` >= 7
ORDER BY `name` DESC;


# 09. Rating system
SELECT 
    m.`title`,
    (CASE
        WHEN mi.`rating` <= 4 THEN 'poor'
        WHEN mi.`rating` <= 7 THEN 'good'
        WHEN mi.`rating` > 7 THEN 'excellent'
    END) AS `rating`,
    IF(mi.`has_subtitles` = 1,
        'english',
        '-') AS 'subtitles',
    mi.`budget`
FROM
    `movies` AS m
        JOIN
    `movies_additional_info` AS mi ON m.`movie_info_id` = mi.`id`
ORDER BY mi.`budget` DESC;

# Programmability 
# 10. History movies
DELIMITER $$
CREATE FUNCTION udf_actor_history_movies_count(full_name VARCHAR(50))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE movies_count INT;
    SET movies_count := (
        SELECT COUNT(g.name) movies
        FROM actors a
                 JOIN movies_actors ma on a.id = ma.actor_id
                 JOIN genres_movies gm on ma.movie_id = gm.movie_id
                 JOIN genres g on g.id = gm.genre_id
        WHERE CONCAT(a.first_name, ' ', a.last_name) = full_name AND g.name = 'History'
        GROUP BY  g.name);
    RETURN movies_count;
END$$ 

SELECT udf_actor_history_movies_count('Stephan Lundberg')  AS 'history_movies';

SELECT udf_actor_history_movies_count('Jared Di Batista')  AS 'history_movies';


# 11. Movie awards

DELIMITER $$
CREATE PROCEDURE udp_award_movie(movie_title VARCHAR(50))
BEGIN
	UPDATE actors AS a
    JOIN movies_actors AS ma ON a.id = ma.actor_id
    JOIN movies AS m ON ma.movie_id = m.id
    SET a.awards = a.awards + 1
    WHERE m.title = movie_title;
END$$

DELIMITER ;











