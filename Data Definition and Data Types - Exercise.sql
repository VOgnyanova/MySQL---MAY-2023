 USE `minions`;
#01. Create Tables
CREATE TABLE `minions` (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255), 
    age INT
);
 
CREATE TABLE `towns` (
    town_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);
#2. Alter Minions Table
ALTER TABLE `minions` 
ADD COLUMN `town_id` INT NOT NULL,
ADD CONSTRAINT fk_minions_towns
FOREIGN KEY (`town_id`)
REFERENCES 	`towns`(`id`);

#03. Insert Records in Both Tablestowns
INSERT INTO `towns`(`id`, `name`)
VALUES (1, 'Sofia'), (2, "Plovdiv"), (3, "Varna");
  
INSERT INTO `minions` (`id`, `name`, `age`, `town_id`)
VALUES (1, "Kevin", 22, 1),
        (2, "Bob", 15, 3),
        (3, "Steward", NULL, 2);
        
#04. Truncate Table Minions
TRUNCATE TABLE `minions`;

#05. Drop All Tables
DROP TABLE `minions`;
DROP TABLE `towns`;





#06. Create Table People
CREATE TABLE `people` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(200) NOT NULL,
    `picture` BLOB,
    `height` DOUBLE(10, 2),
    `weight` DOUBLE(10, 2),
    `gender` CHAR(1) NOT NULL, 
    `birthdate` DATE NOT NULL, 
    `biography` TEXT
);

INSERT INTO  `people`(`name`, `gender`, `birthdate`)
VALUES 
("Boris",'m', DATE(NOW())),
("Aleksandar",'m',DATE(NOW())),
("Dancho",'m',DATE(NOW())),
("Peter",'m',DATE(NOW())),
("Desi",'f',DATE(NOW()));


#07. Create Table Users
CREATE TABLE `users`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`username` VARCHAR(30) NOT NULL,
`password` VARCHAR(30) NOT NULL,
`profile_pucture` BLOB,
`last_login_time` TIME,
`is_deleted` BOOLEAN
);

 
INSERT INTO `users` (`username`, `password`)
VALUES 
("pesho1", "1234"),
("ivan2", "gotinsam"),
("test", "tEST1234"),
("test1", "tEST1"),
("test4", "tEST5");

#08. Change Primary Key

ALTER TABLE `users`
DROP PRIMARY KEY,
ADD PRIMARY KEY (`id`, `username`);

#09. Set Default Value of a Field
ALTER TABLE `users`
MODIFY COLUMN `last_login_time` DATETIME DEFAULT NOW();

#10. Set Unique Field

ALTER TABLE `users`
DROP PRIMARY KEY,
ADD CONSTRAINT `id`
PRIMARY KEY `users` (`id`),
MODIFY COLUMN `username` VARCHAR(30) UNIQUE;

#11. Movies Database
CREATE TABLE `directors`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`director_name` VARCHAR(50) NOT NULL,
`notes` TEXT
);

INSERT INTO `directors`(`director_name`, `notes`)
VALUES
("Ivan", "TestNotes1"),
("Georgi", "TestNotes2"),
("Desi",  "TestNotes3"),
("Bob", "TestNotes4"),
("Eli", "TestNotes5");


CREATE TABLE `genres` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `genre_name` VARCHAR(50) NOT NULL,
    `notes` TEXT
);

INSERT INTO `genres`(`genre_name`, `notes`)
VALUES
("Gergana", "Notes1"),
("Iva", "Notes2"),
("Tom",  "Notes3"),
("Boby", "Notes4"),
("Eliza", "Notes5");



CREATE TABLE `categories`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`category_name` VARCHAR(50) NOT NULL,
`notes` TEXT
);

INSERT INTO `categories`(`category_name`, `notes`)
VALUES
("Gosho", "Test1"),
("Pesho", "Test2"),
("Michael", "Test3"),
("Boryana", "Test4"),
("Lora", "Test5");


CREATE TABLE `movies` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `title` VARCHAR(50) NOT NULL,
    `director_id` INT,
    `copyright_year` INT,
    `length` INT,
    `genre_id` INT,
    `category_id` INT,
    `rating` DOUBLE,
    `notes` TEXT
);
INSERT INTO `movies`(`title`)
VALUES
('Rocky1'),
('Rocky2'),
('Rocky3'),
('Rocky4'),
('Rocky5');


#12. Car Rental Database
USE `cars`;
CREATE TABLE `categories` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `category` VARCHAR(20),
    `daily_rate` DOUBLE,
    `weekly_rate` DOUBLE,
    `monthly_rate` DOUBLE,
    `weekend_rate` DOUBLE
);

INSERT INTO `categories`(`category`)
VALUES
('Car1'),
('Car2'),
('Car3');


CREATE TABLE `cars` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `plate_number` VARCHAR(20),
    `make` VARCHAR(20),
    `model` VARCHAR(20),
    `car_year` INT,
    `category_id` INT,
    `doors` INT,
    `picture` BLOB,
    `car_condition` VARCHAR(30),
    `available` BOOLEAN
);
INSERT INTO `cars`(`plate_number`)
VALUES
('B5577'),
('B3695'),
('B7892');


CREATE TABLE `employees` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(50),
    `last_name` VARCHAR(50),
    `title` VARCHAR(50),
    `notes` TEXT
);
INSERT INTO `employees` (`first_name`, `last_name`)
VALUES 
('Victoria', 'Krasimirova'),
('Lora', 'Ivanova'),
('Georgi', 'Dimitrov');
 


CREATE TABLE `customers`(
 `id` INT PRIMARY KEY AUTO_INCREMENT,
    `driver_license` VARCHAR(20),
    `full_name` VARCHAR(50),
    `address` VARCHAR(50),
    `city` VARCHAR(10),
    `zip_code` VARCHAR(10),
    `notes` TEXT
);

INSERT INTO `customers` (`driver_license`, `full_name`)
VALUES 
('Boris', 'Petrov'),
('Petar', 'Georgiev'),
('Aleksandar', 'Dimitrov');


CREATE TABLE `rental_orders`(
 `id` INT PRIMARY KEY AUTO_INCREMENT,
    `employee_id` INT,
    `customer_id` INT,
    `car_id` INT,
    `car_condition` VARCHAR(50),
    `tank_level` VARCHAR(20),
    `kilometrage_start` INT,
    `kilometrage_end` INT,
    `total_kilometrage` INT,
    `start_date` DATE, 
    `end_date` DATE, 
    `total_days` INT,
    `rate_applied` DOUBLE,
    `tax_rate` DOUBLE,
    `order_status` VARCHAR(20),
    `notes` TEXT);


INSERT INTO `rental_orders` (`employee_id`, `customer_id`)
VALUES 
(1, 2),
(2, 3),
(3, 1);


USE `soft_uni`;
#13. Basic Insert

CREATE TABLE `towns`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL
);


CREATE TABLE `addresses`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`address_text` VARCHAR(255) NOT NULL,
`town_id` INT NOT NULL
);

CREATE TABLE `departments`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL
);

CREATE TABLE `employees` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(255) NOT NULL,
    `middle_name` VARCHAR(255) NOT NULL,
    `last_name` VARCHAR(255) NOT NULL,
    `job_title` VARCHAR(255) NOT NULL,
    `department_id` INT NOT NULL,
    `hire_date` DATE,
    `salary` DECIMAL,
    `address_id` INT NOT NULL
);
INSERT INTO `towns`(`name`)
VALUES ("Sofia"),("Plovdiv"),("Varna"),("Burgas");

INSERT INTO `departments` (`name`)
VALUES ("Engineering"), ("Sales"), ("Marketing"), ("Software Development"), ("Quality Assurance");

INSERT INTO `employees` (`first_name`, `middle_name`, `last_name`, `job_title`, `department_id`, `hire_date`, `salary`)
VALUES
('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '2013-02-01', 3500.00),
('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '2004-03-02', 4000.00),
('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '2016-08-28', 525.25),
('Georgi', 'Terziev', 'Ivanov', 'CEO', 2, '2007-12-09', 3000.00),
('Peter', 'Pan', 'Pan', 'Intern', 3, '2016-08-28', 599.88);


#14. Basic Select All Fields
SELECT * FROM `towns`;


SELECT * FROM `departments`;


SELECT * FROM `employees`;



#15. Basic Select All Fields and Order Them
SELECT * FROM `towns`
ORDER BY `name`;

SELECT * FROM `departments`
ORDER BY `name`;

SELECT * FROM `employees`
ORDER BY `salary` DESC;

#16. Basic Select Some Fields
SELECT `name` FROM `towns`
ORDER BY `name`;

SELECT `name` FROM `departments`
ORDER BY `name`;

SELECT `first_name`,`last_name`,`job_title`,`salary` FROM `employees`
ORDER BY `salary` DESC;

#17. Increase Employees Salary

UPDATE `employees`
SET `salary` = `salary` * 1.10;
SELECT `salary` FROM `employees`;


