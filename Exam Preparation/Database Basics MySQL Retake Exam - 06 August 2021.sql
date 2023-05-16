USE `softUni_game_dev_branch`;

CREATE TABLE `addresses` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL
);

CREATE TABLE `categories` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(10) NOT NULL
);

CREATE TABLE `offices` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `workspace_capacity` INT NOT NULL,
    `website` VARCHAR(50) NOT NULL,
    `address_id` INT,
    CONSTRAINT fk_offices_addreses FOREIGN KEY (address_id)
        REFERENCES addresses (`id`)
);
CREATE TABLE `employees` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(30) NOT NULL,
    `last_name` VARCHAR(30) NOT NULL,
    `age` INT NOT NULL,
    `salary` DECIMAL(10 , 2 ) NOT NULL,
    `job_title` VARCHAR(20) NOT NULL,
    `happiness_level` CHAR(1)
);

CREATE TABLE `teams` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(40) NOT NULL,
    `office_id` INT NOT NULL,
    `leader_id` INT NOT NULL UNIQUE,
    CONSTRAINT fk_teams_offices FOREIGN KEY (`office_id`)
        REFERENCES offices (`id`),
    CONSTRAINT fk_leader_id FOREIGN KEY (leader_id)
        REFERENCES employees (id)
);


CREATE TABLE `games`(
   `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL UNIQUE,
    `description` TEXT,
    `rating` FLOAT DEFAULT(5.5) NOT NULL,
    `budget` DECIMAL(10,2) NOT NULL,
    `release_date` DATE,
    `team_id` INT,
        CONSTRAINT fk_games_teams 
    FOREIGN KEY (`team_id`)
    REFERENCES teams (`id`)

);
 
CREATE TABLE `games_categories` (
    `game_id` INT NOT NULL,
    `category_id` INT NOT NULL,
    CONSTRAINT pk_game_category PRIMARY KEY (game_id , category_id),
    CONSTRAINT fk_game FOREIGN KEY (game_id)
        REFERENCES games (id),
    CONSTRAINT fk_category FOREIGN KEY (category_id)
        REFERENCES categories (id)
);

# 02. Insert

INSERT INTO `games`(`name`,`rating`,`budget`,`team_id`)
SELECT lower(reverse(substr(`name`,2))), `id`, `leader_id` * 1000, `id`
FROM `teams`
WHERE `id` between 1 AND 9;


UPDATE `employees` AS e
        LEFT JOIN
    `teams` AS t ON e.`id` = t.`leader_id` 
SET 
    e.`salary` = e.`salary` + 1000
WHERE
    t.`leader_id` IS NOT NULL
        AND e.`salary` < 5000
        AND e.`age` <= 40;


DELETE g FROM `games` AS g
        LEFT JOIN
    `games_categories` AS gc ON g.`id` = gc.`game_id` 
WHERE
    gc.`game_id` IS NULL
    AND g.`release_date` IS NULL;

SELECT 
    `first_name`,
    `last_name`,
    `age`,
    `salary`,
    `happiness_level`
FROM
    `employees`
ORDER BY `salary` , `id`;

SELECT 
    t.`name`, a.`name`, LENGTH(a.`name`)
FROM
    teams AS t
        JOIN
    offices AS o ON t.office_id = o.id
        JOIN
    addresses AS a ON o.address_id = a.id
WHERE
    o.website IS NOT NULL
ORDER BY t.`name` , a.`name`;

SELECT 
    c.`name`,
    COUNT(gc.game_id) AS games_count,
    ROUND(AVG(g.budget), 2) AS avg_budget,
    MAX(g.rating) AS max_rating
FROM
    games AS g
        JOIN
    games_categories AS gc ON gc.game_id = g.id
        JOIN
    categories AS c ON gc.category_id = c.id
GROUP BY c.id
HAVING max_rating >= 9.5
ORDER BY games_count DESC , c.`name`;

SELECT 
    g.`name`,
    g.release_date,
    CONCAT(LEFT(g.`description`, 10), '...') AS summary,
    CASE
        WHEN MONTH(g.release_date) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN MONTH(g.release_date) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN MONTH(g.release_date) BETWEEN 7 AND 9 THEN 'Q3'
        ELSE 'Q4'
    END AS `quarter`,
    t.`name`
FROM
    games AS g
        JOIN
    teams AS t ON g.team_id = t.id
WHERE
    RIGHT(g.`name`, 1) = '2'
        AND YEAR(g.release_date) = 2022
        AND MONTH(g.release_date) % 2 = 0
ORDER BY `quarter`;


SELECT 
    g.`name`,
    IF(g.budget < 50000,
        'Normal budget',
        'Insufficient budget') AS budget_level,
    t.`name`,
    a.`name`
FROM
    games AS g
        LEFT JOIN
    games_categories AS gc ON gc.game_id = g.id
        JOIN
    teams AS t ON g.team_id = t.id
        JOIN
    offices AS o ON t.office_id = o.id
        JOIN
    addresses AS a ON o.address_id = a.id
WHERE
    g.release_date IS NULL
        AND gc.category_id IS NULL
ORDER BY g.`name`;

# 10. Find all basic information for a game
DELIMITER $$
create function udf_game_info_by_name (game_name varchar(20))
returns varchar(255)
deterministic
begin
	declare info varchar (255);
	declare team_name varchar (40);
	declare address_text varchar (50);
	
	set team_name := (select t.`name`
		from teams as t join games as g on g.team_id = t.id where g.`name` = game_name);
	
  	set address_text := (select a.`name`
		from addresses as a join offices as o on a.id = o.address_id join teams as t
		on o.id = t.office_id where t.`name` = team_name);
    
  	set info := concat_ws(' ', 'The', game_name, 'is developed by a', team_name, 'in an office with an address', address_text);
  	return info;
end$$

DELIMITER ;

SELECT UDF_GAME_INFO_BY_NAME('Bitwolf') AS info;
SELECT UDF_GAME_INFO_BY_NAME('Fix San') AS info;
SELECT UDF_GAME_INFO_BY_NAME('Job') AS info;

# 11. Update Budget of the Games

DELIMITER $$
create procedure udp_update_budget (min_game_rating float)
begin
	update games AS g left join games_categories as c on g.id = c.game_id
    	set g.budget = g.budget + 100000, 
		g.release_date = adddate(g.release_date, interval 1 year)
	where c.category_id is null and g.release_date IS NOT NULL and g.rating > min_game_rating;
end$$
DELIMITER ;

CALL udp_update_budget (8);








