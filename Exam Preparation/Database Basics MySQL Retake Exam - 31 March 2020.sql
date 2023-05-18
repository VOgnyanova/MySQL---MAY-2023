USE `insta_influencers`;

CREATE TABLE `users` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `username` VARCHAR(30) NOT NULL UNIQUE,
    `password` VARCHAR(30) NOT NULL,
    `email` VARCHAR(50) NOT NULL,
    `gender` CHAR(1) NOT NULL,
    `age` INT NOT NULL,
    `job_title` VARCHAR(40) NOT NULL,
    `ip` VARCHAR(30) NOT NULL
);

CREATE TABLE `addresses` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `address` VARCHAR(30) NOT NULL,
    `town` VARCHAR(30) NOT NULL,
    `country` VARCHAR(30) NOT NULL,
    `user_id` INT NOT NULL,
    CONSTRAINT fk_addresses_users FOREIGN KEY (user_id)
        REFERENCES users (id)
);
CREATE TABLE `photos` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `description` TEXT NOT NULL,
    `date` DATETIME NOT NULL,
    `views` INT DEFAULT 0 NOT NULL
);

CREATE TABLE `comments` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `comment` VARCHAR(255) NOT NULL,
    `date` DATETIME NOT NULL,
    `photo_id` INT,
    CONSTRAINT fk_comments_photos FOREIGN KEY (photo_id)
        REFERENCES photos (id)
);



CREATE TABLE `users_photos` (
    `user_id` INT NOT NULL,
    `photo_id` INT NOT NULL,
    CONSTRAINT fk_users_photos FOREIGN KEY (user_id)
        REFERENCES users (id),
    CONSTRAINT fk_users_users_photos FOREIGN KEY (photo_id)
        REFERENCES photos (id)
);

CREATE TABLE `likes` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `photo_id` INT,
    `user_id` INT,
    CONSTRAINT fk_users_likes FOREIGN KEY (user_id)
        REFERENCES users (id),
    CONSTRAINT fk_photos_likes FOREIGN KEY (photo_id)
        REFERENCES photos (id)
);

# 02. Insert
INSERT INTO `addresses`(address,town,country,user_id)
select u.username,u.password,u.ip,u.age from users as u
where u.gender = 'M';


# 03. Update

UPDATE addresses AS a
SET country = (
    CASE 
		WHEN country LIKE 'B%' THEN 'Blocked'
        WHEN country LIKE 'T%' THEN 'Test'
        WHEN country LIKE 'P%' THEN 'In Progress'
        ELSE country
	END
);

# 04.Delete

DELETE a FROM addresses AS a 
WHERE
    a.id % 3 = 0;

# 05. Users
SELECT 
    username, gender, age
FROM
    users
ORDER BY age DESC , username;



# 06. Extract 5 most commented photos

SELECT 
    p.id,
    p.date AS 'date_and_time',
    p.description,
    COUNT(c.id) AS commentsCount
FROM
    photos AS p
        JOIN
    comments AS c ON p.id = c.photo_id
GROUP BY p.id
ORDER BY commentsCount DESC , p.id
LIMIT 5;

# 07. Lucky users
SELECT 
    CONCAT(id, ' ', username) AS id_username, email
FROM
    insta_influencers.users AS u
        JOIN
    users_photos AS up ON u.id = up.user_id
WHERE
    up.user_id = up.photo_id
ORDER BY u.id;


#08. Count likes and comments
SELECT 
    p.id AS 'photo_id',
    COUNT(DISTINCT l.id) AS 'likes_count',
    COUNT(DISTINCT c.id) AS 'comments_count'
FROM
    photos AS p
        LEFT JOIN
    comments AS c ON p.id = c.photo_id
        LEFT JOIN
    likes AS l ON p.id = l.photo_id
GROUP BY p.id
ORDER BY likes_count DESC , comments_count DESC , p.id ASC;
 
 # 09. The photo on the tenth day of the month

SELECT 
    CONCAT(LEFT(p.description, 30), '...') AS summary, p.date
FROM
    photos AS p
WHERE
    DAY(p.date) = 10
ORDER BY p.date DESC; 
 
 
 # 10. Get user’s photos count
 DELIMITER $$
 CREATE FUNCTION udf_users_photos_count(username VARCHAR(30))
 RETURNS int
 DETERMINISTIC
 BEGIN
 RETURN (
 select count(*) as 'photosCount' from users as u
 join users_photos as up on u.id = up.user_id
 where u.username = username);
 END$$
 DELIMITER ;
 
 
 SELECT udf_users_photos_count('ssantryd') AS photosCount;
 
 # 11.	Increase User Age
DELIMITER $$
CREATE PROCEDURE udp_modify_user (address VARCHAR(30), town VARCHAR(30))
BEGIN
	IF((SELECT a.address FROM addresses AS a WHERE address = a.address) IS NOT NULL)
    THEN UPDATE users AS u
    JOIN addresses AS aa ON u.id = aa.user_id
    SET u.age = u.age + 10
    WHERE aa.address = address AND aa.town = town;
    END IF;
END $$
DELIMITER ;

CALL udp_modify_user ('97 Valley Edge Parkway', 'Divinópolis');
 
 
 
 
 