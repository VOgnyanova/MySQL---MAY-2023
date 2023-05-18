USE`softuni_stores_system`;
CREATE TABLE `pictures` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `url` VARCHAR(100) NOT NULL,
    `added_on` DATETIME NOT NULL
);
CREATE TABLE `category` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE `products` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(40) NOT NULL,
    `best_before` DATE,
    `price` DECIMAL(10 , 2 ) NOT NULL,
    `description` TEXT,
    `category_id` INT NOT NULL,
    `picture_id` INT NOT NULL,
    CONSTRAINT fk_category_products FOREIGN KEY (`category_id`)
        REFERENCES `category` (`id`),
    CONSTRAINT fk_pictures_products FOREIGN KEY (`picture_id`)
        REFERENCES `pictures` (`id`)
);
CREATE TABLE `towns` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(20) NOT NULL
);

CREATE TABLE `addresses` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `town_id` INT NOT NULL,
    CONSTRAINT fk_towns_addresses FOREIGN KEY (`town_id`)
        REFERENCES `towns` (`id`)
);

CREATE TABLE `stores` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(20) NOT NULL,
    `rating` FLOAT NOT NULL,
    `has_parking` BOOLEAN,
    `address_id` INT NOT NULL,
    CONSTRAINT fk_stores_addresses FOREIGN KEY (`address_id`)
        REFERENCES `addresses` (`id`)
);
CREATE TABLE `products_stores` (
    `product_id` INT NOT NULL,
    `store_id` INT NOT NULL,
    CONSTRAINT pk_product_store PRIMARY KEY (product_id , store_id),
    CONSTRAINT fk_product FOREIGN KEY (`product_id`)
        REFERENCES `products` (`id`),
    CONSTRAINT fk_stores FOREIGN KEY (`store_id`)
        REFERENCES `stores` (`id`)
);
CREATE TABLE `employees` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(15) NOT NULL,
    `middle_name` CHAR(1),
    `last_name` VARCHAR(20) NOT NULL,
    `salary` DECIMAL(19 , 2 ) DEFAULT 0,
    `hire_date` DATE NOT NULL,
    `manager_id` INT,
    `store_id` INT NOT NULL,
    CONSTRAINT fk_employee_manager FOREIGN KEY (manager_id)
        REFERENCES employees (id),
    CONSTRAINT fk_employee_store FOREIGN KEY (store_id)
        REFERENCES stores (id)
);

# 02.Insert
INSERT INTO products_stores (product_id, store_id) 
(SELECT p.id, 1 FROM products AS p
		WHERE p.id NOT IN 
        (SELECT product_id FROM products_stores));


UPDATE `employees` AS e 
SET 
    e.salary = e.salary - 500,
    e.manager_id = 3
WHERE
    YEAR(e.hire_date) >= 2003
        AND e.store_id NOT IN (SELECT 
            s.id
        FROM
            stores AS s
        WHERE
            s.name = 'Cardguard'
                OR s.name = 'Veribet');
DELETE FROM employees 
WHERE
    salary >= 6000
    AND manager_id IS NOT NULL;



SELECT 
    first_name, middle_name, last_name, salary, hire_date
FROM
    employees
ORDER BY hire_date DESC;

SELECT 
    p.name AS product_name,
    p.price,
    p.best_before,
    CONCAT(LEFT(p.description, 10), '...') AS short_description,
    pic.url
FROM
    products AS p
        JOIN
    pictures AS pic ON p.picture_id = pic.id
WHERE
    YEAR(pic.added_on) < 2019
        AND LENGTH(p.description) > 100
        AND price > 20
ORDER BY price DESC;

SELECT 
    s.name,
    COUNT(p.id) AS product_count,
    ROUND(AVG(p.price), 2) AS avg
FROM
    stores AS s
        LEFT JOIN
    products_stores AS ps ON s.id = ps.store_id
        LEFT JOIN
    products AS p ON ps.product_id = p.id
GROUP BY s.id
ORDER BY product_count DESC , avg DESC , s.id;


SELECT 
    CONCAT(first_name, ' ', last_name) AS 'Full name',
    s.name AS 'Store_name',
    a.name AS address,
    e.salary
FROM
    employees AS e
        JOIN
    stores AS s ON e.store_id = s.id
        JOIN
    addresses AS a ON s.address_id = a.id
WHERE
    e.salary < 4000 AND a.name LIKE '%5%'
        AND CHAR_LENGTH(s.name) > 8
        AND e.last_name LIKE '%n';


SELECT 
    REVERSE(s.name) AS reversed_name,
    CONCAT(UPPER(t.name), '-', a.name) AS full_address,
    (SELECT 
            COUNT(e.id)
        FROM
            employees AS e
        WHERE
            e.store_id = s.id) AS employees_count
FROM
    stores AS s
        JOIN
    addresses AS a ON s.address_id = a.id
        JOIN
    towns AS t ON t.id = a.town_id
WHERE
    (SELECT 
            COUNT(e.id)
        FROM
            employees AS e
        WHERE
            e.store_id = s.id) > 0
ORDER BY full_address;

# 10. Find name of top paid employee by store name
DELIMITER $$
CREATE FUNCTION udf_top_paid_employee_by_store(store_name VARCHAR(50))
RETURNS VARCHAR(255)
BEGIN
RETURN (SELECT concat(e.first_name, " ", e.middle_name, ". ", e.last_name, " works in store for ", 2020 - YEAR(e.hire_date), " years") 
					AS full_info FROM employees AS e
JOIN stores AS s ON e.store_id = s.id
WHERE s.name = store_name
ORDER BY e.salary DESC
LIMIT 1);
END $$

DELIMITER ;
SELECT UDF_TOP_PAID_EMPLOYEE_BY_STORE('Stronghold') AS 'full_info';
SELECT UDF_TOP_PAID_EMPLOYEE_BY_STORE('Keylex') AS 'full_info';



# 11. Update product price by address


DELIMITER $$
CREATE PROCEDURE udp_update_product_price (address_name VARCHAR (50))
BEGIN
	DECLARE increase_level INT;
    IF address_name LIKE '0%' THEN SET increase_level = 100;
    ELSE SET increase_level = 200;
    END IF;
UPDATE products AS p SET price = price + increase_level
WHERE p.id IN (SELECT ps.product_id FROM addresses AS a
				JOIN stores AS s ON a.id = s.address_id
                JOIN products_stores AS ps ON ps.store_id = s.id
                WHERE a.name = address_name);
END$$

DELIMITER ;

CALL udp_update_product_price('07 Armistice Parkway');
SELECT 
    name, price
FROM
    products
WHERE
    id = 15;
CALL udp_update_product_price('1 Cody Pass');
SELECT 
    name, price
FROM
    products
WHERE
    id = 17;