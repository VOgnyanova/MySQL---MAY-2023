CREATE DATABASE `restaurant`;
CREATE TABLE `products` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(30) NOT NULL UNIQUE,
    `type` VARCHAR(30) NOT NULL,
    `price` DECIMAL(10 , 2 ) NOT NULL
);

CREATE TABLE `clients` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(50) NOT NULL,
    `last_name` VARCHAR(50) NOT NULL,
    `birthdate` DATE NOT NULL,
    `card` VARCHAR(50),
    `review` TEXT
);


CREATE TABLE `tables` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `floor` INT NOT NULL,
    `reserved` BOOLEAN,
    `capacity` INT NOT NULL
);

CREATE TABLE `waiters` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(50) NOT NULL,
    `last_name` VARCHAR(50) NOT NULL,
    `email` VARCHAR(50) NOT NULL,
    `phone` VARCHAR(50),
    `salary` DECIMAL(10 , 2 )
);

CREATE TABLE `orders` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `table_id` INT NOT NULL,
    `waiter_id` INT NOT NULL,
    `order_time` TIME NOT NULL,
    `payed_status` BOOLEAN,
    CONSTRAINT fk_orders_waiters FOREIGN KEY (`waiter_id`)
        REFERENCES `waiters` (`id`),
    CONSTRAINT fk_orders_tables FOREIGN KEY (`table_id`)
        REFERENCES `tables` (`id`)
);

CREATE TABLE `orders_clients` (
    `order_id` INT,
    `client_id` INT,
    CONSTRAINT fk_orders_clients_orders FOREIGN KEY (`order_id`)
        REFERENCES `orders` (`id`),
    CONSTRAINT fk_orders_clients_clients FOREIGN KEY (`client_id`)
        REFERENCES `clients` (`id`)
);

CREATE TABLE `orders_products` (
    `order_id` INT,
    `product_id` INT,
    CONSTRAINT fk_orders_products_orders FOREIGN KEY (`order_id`)
        REFERENCES `orders` (`id`),
    CONSTRAINT fk_orders_products_products FOREIGN KEY (`product_id`)
        REFERENCES `products` (`id`)
);

# 02. Insert

INSERT INTO products (name, type, price)
SELECT CONCAT(w.last_name, ' ', 'specialty'),
	"Cocktail" AS type,
    CEIL(w.salary * 0.01) AS price
FROM waiters AS w
WHERE w.id > 6;

UPDATE orders 
SET 
    table_id = table_id - 1
WHERE
    `id` BETWEEN 12 AND 23;

DELETE FROM waiters 
WHERE
    id NOT IN (SELECT DISTINCT
        (waiter_id)
    FROM
        orders);
        
SELECT 
    *
FROM
    clients
ORDER BY birthdate DESC , id DESC;

SELECT 
    c.first_name, c.last_name, c.birthdate, c.review
FROM
    clients AS c
WHERE
    c.birthdate BETWEEN '1978-01-01' AND '1993-01-01'
        AND c.card IS NULL
ORDER BY c.last_name DESC , c.id ASC
LIMIT 5;


SELECT 
    CONCAT(last_name,
            first_name,
            CHAR_LENGTH(first_name),
            'Restaurant') AS `username`,
    REVERSE(SUBSTR(email, 2, 12)) AS `password`
FROM
    waiters
WHERE
    salary > 0
ORDER BY password DESC;

SELECT 
    p.id, p.name, COUNT(op.product_id) AS count
FROM
    products AS p
        LEFT JOIN
    orders_products AS op ON p.id = op.product_id
GROUP BY p.id
HAVING count >= 5
ORDER BY count DESC , p.name ASC;


 # 09. Availability
SELECT 
    t.id AS 'table_id',
    t.capacity,
    COUNT(oc.client_id) AS 'count_clients',
    (CASE
        WHEN COUNT(oc.client_id) > t.capacity THEN 'Extra seats'
        WHEN COUNT(oc.client_id) < t.capacity THEN 'Free seats'
        WHEN COUNT(oc.client_id) = t.capacity THEN 'Full'
    END) AS 'availability'
FROM
    tables AS t
        JOIN
    orders AS o ON t.id = o.table_id
        JOIN
    orders_clients AS oc ON oc.order_id = o.id
WHERE
    t.floor = 1
GROUP BY o.table_id
ORDER BY t.id DESC;

# 10. Extract bill
DELIMITER $$
CREATE FUNCTION udf_client_bill(full_name VARCHAR(50))
RETURNS DECIMAL(19, 2)
DETERMINISTIC
BEGIN
	DECLARE bill DECIMAL(19, 2);
	SET bill := (SELECT SUM(p.price) FROM clients AS c
    JOIN orders_clients AS oc ON c.id = oc.client_id
    JOIN orders AS o ON oc.order_id = o.id
    JOIN orders_products AS op ON o.id = op.order_id
    JOIN products AS p ON op.product_id = p.id
    WHERE CONCAT(c.first_name, ' ', last_name) = full_name);
    RETURN bill;
END$$

SELECT 
    c.first_name,
    c.last_name,
    UDF_CLIENT_BILL('Silvio Blyth') AS 'bill'
FROM
    clients c
WHERE
    c.first_name = 'Silvio'
        AND c.last_name = 'Blyth';


#11. Happy hour
DELIMITER $$
CREATE PROCEDURE udp_happy_hour (type VARCHAR(50))
BEGIN
	START TRANSACTION;
		UPDATE products AS p1 SET p1.price = p1.price * 0.8
		WHERE p1.type = type AND p1.price >= 10;
        COMMIT;
END$$



CALL udp_happy_hour ('Cognac');






