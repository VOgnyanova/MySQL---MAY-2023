
#0. CREATE DATABASE

CREATE DATABASE `football_scout_database`;

# 01. Table Design

CREATE TABLE `players`(
`id`INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(10) NOT NULL,
`last_name` VARCHAR(20) NOT NULL,
`age` INT not null  DEFAULT(0),
`position` CHAR(1) NOT NULL,
`salary` DECIMAL(10,2) DEFAULT(0),
`hire_date`DATETIME,
`skills_data_id` INT,
`team_id` INT,
CONSTRAINT `fk_players_teams`
FOREIGN KEY (`team_id`)
REFERENCES `teams`(`id`)
);

CREATE TABLE `players_coaches` (
    `player_id` INT,
    `coach_id` INT
);

CREATE TABLE `coaches`(
`id`INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(10) NOT NULL,
`last_name` VARCHAR(20) NOT NULL,
`salary` DECIMAL(10, 2) NOT NULL DEFAULT(0),
`coach_level` INT not null default(0)
);

CREATE TABLE `skills_data`(
`id`INT PRIMARY KEY AUTO_INCREMENT,
`dribbling` INT DEFAULT(0),
`pace` INT DEFAULT(0),
`passing` INT DEFAULT(0),
`shooting` INT DEFAULT(0),
`speed` INT DEFAULT(0),
`strength` INT DEFAULT(0)
);

CREATE TABLE `teams`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
`established` DATE NOT NULL,
`fan_base` BIGINT NOT NULL DEFAULT(0),
`stadium_id` INT NOT NULL,
CONSTRAINT fk_teams_stadiums
FOREIGN KEY (`stadium_id`)
REFERENCES `stadiums`(`id`)

);

CREATE TABLE `stadiums` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(45) NOT NULL,
    `capacity` INT NOT NULL,
    `town_id` INT
);


CREATE TABLE `towns` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(45) NOT NULL,
    `country_id` INT
);

CREATE TABLE `countries` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(45) NOT NULL
);

# 2. Insert

INSERT INTO `coaches`(first_name,last_name,salary,coach_level) (
SELECT p.first_name,p.last_name,p.salary,
char_length(p.first_name) AS coach_level
FROM 
plasyers AS p
WHERE age >= 45

);
# 03. Update
UPDATE coaches AS c 
SET 
    c.coach_level = c.coach_level + 1
WHERE
    c.id IN (SELECT 
            coach_id
        FROM
            players_coaches)
        AND first_name LIKE 'A%';
        

# 04. Delete
DELETE FROM players
WHERE age >= 45;

# 05. Players

SELECT first_name,age,salary
FROM players
ORDER BY salary DESC;

# 06. Young offense players without contract

SELECT 
    p.id,
    CONCAT(p.first_name, ' ', p.last_name) AS 'full_name',
    p.age,
    p.position,
    p.hire_date
FROM
    players AS p
        JOIN
    skills_data AS sd ON p.skills_data_id = sd.id
WHERE
    p.age < 23 AND sd.strength > 50
        AND p.hire_date IS NULL
        AND p.position = 'A'
ORDER BY p.salary , p.age;

# 07. Detail info for all teams

SELECT 
    t.name AS team_name,
    t.established,
    t.fan_base,
    COUNT(p.id) AS players_count
FROM
    teams AS t
        LEFT JOIN
    players AS p ON t.id = p.team_id
GROUP BY t.id
ORDER BY players_count DESC , t.fan_base DESC;

# 08. The fastest player by towns
SELECT 
    MAX(sd.speed) AS max_speed, tw.name AS town_name
FROM
    skills_data AS sd
        RIGHT JOIN
    players AS p ON sd.id = p.skills_data_id
        RIGHT JOIN
    teams AS t ON t.id = p.team_id
        JOIN
    stadiums AS s ON s.id = t.stadium_id
        RIGHT JOIN
    towns AS tw ON tw.id = s.town_id
WHERE
    t.name != 'Devify'
GROUP BY tw.id
ORDER BY max_speed DESC , tw.name;


# 09. Total salaries and players


SELECT 
    c.`name`,
    COUNT(p.`id`) AS `total_count_of_players`,
    SUM(p.`salary`) AS `total_sum_of_salaries`
FROM
    `countries` AS c
        LEFT JOIN
    `towns` AS tw ON c.`id` = tw.`country_id`
        LEFT JOIN
    `stadiums` AS s ON s.`town_id` = tw.`id`
        LEFT JOIN
    `teams` AS t ON t.`stadium_id` = s.`id`
        LEFT JOIN
    `players` AS p ON p.`team_id` = t.`id`
GROUP BY c.`id`
ORDER BY `total_count_of_players` DESC , c.`name`;


# 10 Find all players that play on stadium


DELIMITER $$
CREATE FUNCTION udf_stadium_players_count (stadium_name VARCHAR(30))
RETURNS int DETERMINISTIC
BEGIN
RETURN (
SELECT COUNT(p.id) FROM players AS p
RIGHT JOIN teams AS t ON t.id = p.team_id
RIGHT JOIN stadiums AS s ON s.id = t.stadium_id
WHERE s.name = stadium_name
GROUP BY s.id);
END $$
DELIMITER ;



# 11. Find good playmaker by teams

CREATE PROCEDURE udp_find_playmaker (min_dribble_points INT, team_name VARCHAR(45))
BEGIN
SELECT concat_ws(' ', p.first_name, p.last_name) AS full_name, p.age, p.salary, sd.dribbling, sd.speed, t.name AS team_name FROM players AS p
JOIN skills_data AS sd ON p.skills_data_id = sd.id
JOIN teams AS t ON p.team_id = t.id
WHERE sd.dribbling > min_dribble_points AND t.name = team_name AND sd.speed > (SELECT AVG(speed) FROM skills_data)
ORDER BY sd.speed DESC LIMIT 1;
END $$
DELIMITER ;



