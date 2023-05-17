USE `taxi_company`;
CREATE TABLE `addresses` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL
);
    
CREATE TABLE `categories` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(10) NOT NULL
);

CREATE TABLE `clients` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `full_name` VARCHAR(50) NOT NULL,
    `phone_number` VARCHAR(20) NOT NULL
);

CREATE TABLE `drivers` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(30) NOT NULL,
    `last_name` VARCHAR(30) NOT NULL,
    `age` INT NOT NULL,
    `rating` FLOAT DEFAULT 5.5
);


CREATE TABLE `cars`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`make` VARCHAR(20) NOT NULL,
`model` VARCHAR(20),
`year` INT default 0 NOT NULL,
`mileage` INT default(0) NOT NULL,
`condition` CHAR(1) NOT NULL,
`category_id` INT NOT NULL,
CONSTRAINT fk_car_category
foreign key (`category_id`)
REFERENCES `categories`(`id`)
);

CREATE TABLE `courses` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `from_address_id` INT NOT NULL,
    `start` DATETIME NOT NULL,
    `bill` DECIMAL(10 , 2 ) DEFAULT 10,
    `car_id` INT NOT NULL,
    `client_id` INT NOT NULL,
    CONSTRAINT fk_car_courses FOREIGN KEY (`car_id`)
        REFERENCES `cars` (`id`),
    CONSTRAINT fk_courses_clients FOREIGN KEY (`client_id`)
        REFERENCES `clients` (`id`),
    CONSTRAINT fk_courses_addresses FOREIGN KEY (`from_address_id`)
        REFERENCES `addresses` (`id`)
);
CREATE TABLE `cars_drivers` (
    `car_id` INT NOT NULL,
    `driver_id` INT NOT NULL,
    CONSTRAINT pk_car_driver PRIMARY KEY (car_id , driver_id),
    CONSTRAINT fk_car FOREIGN KEY (car_id)
        REFERENCES cars (id),
    CONSTRAINT fk_driver FOREIGN KEY (driver_id)
        REFERENCES drivers (id)
);

# 02. Insert

INSERT INTO `clients` (full_name, phone_number)
SELECT  CONCAT_WS(' ', first_name, last_name),
CONCAT('(088) 9999', `id` * 2)
FROM `drivers` 
WHERE `id` between 10 and 20;


#03. Update
UPDATE cars 
SET 
    `condition` = 'C'
WHERE
    (`mileage` >= 800000 OR NULL)
        AND `year` <= 2010
        AND MAKE NOT LIKE 'Mercedes-Benz';

# 04. Delete

DELETE c FROM `clients` AS c
        LEFT JOIN
    `courses` AS co ON c.id = co.client_id 
WHERE
    co.client_id IS NULL
    AND LENGTH(c.full_name) > 3;


# 05. Cars
SELECT 
    `make`, `model`, `condition`
FROM
    `cars`
ORDER BY id;

# 06. Drivers and Cars
SELECT 
    d.first_name, d.last_name, c.make, c.model, c.mileage
FROM
    drivers AS d
        JOIN
    cars_drivers AS cd ON d.id = cd.driver_id
        JOIN
    cars AS c ON cd.car_id = c.id
WHERE
    mileage IS NOT NULL
ORDER BY mileage DESC , d.first_name;


# 07. Number of courses
SELECT 
    c.id,
    c.make,
    c.mileage,
    COUNT(co.id) AS count_of_courses,
    ROUND(AVG(co.bill), 2) AS avg_bill
FROM
    cars AS c
        LEFT JOIN
    courses AS co ON c.id = co.car_id
GROUP BY c.id
HAVING count_of_courses <> 2
ORDER BY count_of_courses DESC , c.id;


# 08. Regular clients
SELECT 
    c.full_name,
    COUNT(co.id) AS count_of_cars,
    SUM(co.bill) AS total_sum
FROM
    clients AS c
        JOIN
    courses AS co ON c.id = co.client_id
GROUP BY c.id
HAVING count_of_cars > 1
    AND SUBSTR(c.full_name, 2, 1) LIKE 'a'
ORDER BY c.full_name;

# 09. Full information of courses

SELECT 
    a.`name`,
    IF(HOUR(co.`start`) BETWEEN 6 AND 20,
        'Day',
        'Night') AS day_time,
    co.bill,
    c.full_name,
    ca.make,
    ca.model,
    cat.`name` as category_name
FROM
    courses AS co
        JOIN
    addresses AS a ON a.id = co.from_address_id
        LEFT JOIN
    clients AS c ON co.client_id = c.id
        LEFT JOIN
    cars AS ca ON co.car_id = ca.id
        LEFT JOIN
    categories AS cat ON ca.category_id = cat.id
ORDER BY co.id;


# 10. Find all courses by clients phone number

DELIMITER $$
create function udf_courses_by_client (phone_num varchar (20)) 
returns int deterministic
begin
	declare count int;
	set count := (select count(c.id)
	 from courses AS c join clients AS cl on c.client_id = cl.id 
	where cl.phone_number = phone_num);
  	return count;
end;
SELECT udf_courses_by_client ('(803) 6386812') as `count`; 


# 11. Full info for address
DELIMITER $$
create procedure udp_courses_by_address (address_name varchar(100))
begin
	select a.`name`, c.full_name, 
		case
			when co.bill <= 20 then 'Low'
			when co.bill <= 30 then 'Medium'
			else 'High'
        end as level_of_bill, ca.make, ca.condition, cat.`name`
	FROM courses as co join addresses as a on a.id = co.from_address_id
	left join clients as c on co.client_id = c.id
	left join cars as ca on co.car_id = ca.id
	left join categories as cat on ca.category_id = cat.id
	where a.`name` = address_name
	order by ca.make, c.full_name;
end;

CALL udp_courses_by_address('66 Thompson Drive');