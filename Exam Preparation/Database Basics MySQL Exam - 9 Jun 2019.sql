USE `royal_united_kingsman_bank`;
# 01. TABLE DESING
CREATE TABLE `branches` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE `employees` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(20) NOT NULL,
    `last_name` VARCHAR(20) NOT NULL,
    `salary` DECIMAL(10 , 2 ) NOT NULL,
    `started_on` DATE NOT NULL,
    `branch_id` INT NOT NULL,
    CONSTRAINT fk_employees_branches FOREIGN KEY (branch_id)
        REFERENCES branches (id)
);

CREATE TABLE `clients` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `full_name` VARCHAR(50) NOT NULL,
    `age` INT NOT NULL
);

CREATE TABLE `employees_clients` (
    `employee_id` INT,
    `client_id` INT,
    CONSTRAINT fk_employees_clients_employees FOREIGN KEY (employee_id)
        REFERENCES employees (id),
    CONSTRAINT fk_employees_clienst_clients FOREIGN KEY (client_id)
        REFERENCES clients (id)
);

CREATE TABLE `bank_accounts` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `account_number` VARCHAR(10) NOT NULL,
    `balance` DECIMAL(10 , 2 ) NOT NULL,
    `client_id` INT NOT NULL UNIQUE,
    CONSTRAINT fk_bank_accounts_clients FOREIGN KEY (client_id)
        REFERENCES clients (id)
);

CREATE TABLE `cards` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `card_number` VARCHAR(19) NOT NULL,
    `card_status` VARCHAR(7) NOT NULL,
    `bank_account_id` INT NOT NULL,
    CONSTRAINT fk_cards_bank_accounts FOREIGN KEY (bank_account_id)
        REFERENCES bank_accounts (id)
);

 #02. INSERT

INSERT INTO  cards(card_number,card_status,bank_account_id)
SELECT reverse(full_name), 'Active', id FROM clients
WHERE id BETWEEN 191 AND 200;


#03. UPDATE

UPDATE employees_clients AS ec 
SET 
    ec.employee_id = (SELECT 
            ecc.employee_id
        FROM
            (SELECT 
                *
            FROM
                employees_clients) AS ecc
        GROUP BY ecc.employee_id
        ORDER BY COUNT(ecc.client_id) ASC , ecc.employee_id ASC
        LIMIT 1)
WHERE
    ec.employee_id = ec.client_id;

#05. DELETE


DELETE e FROM employees AS e
        LEFT JOIN
    employees_clients AS ec ON e.id = ec.employee_id 
WHERE
    ec.employee_id IS NULL;


# 05. CLIENTS
SELECT 
    id, full_name
FROM
    clients
ORDER BY id;


#06. Newbies

SELECT 
    id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    CONCAT('$', salary) AS salary,
    started_on
FROM
    employees
WHERE
    salary >= 100000
        AND DATE(started_on) >= 2018 - 01 - 01
ORDER BY salary DESC , id;


# 07. Cards against Humanity
SELECT 
    c.id,
    CONCAT(c.card_number, ' : ', cl.full_name) AS card_token
FROM
    cards AS c
        JOIN
    bank_accounts AS ba ON c.bank_account_id = ba.id
        JOIN
    clients AS cl ON ba.client_id = cl.id
ORDER BY c.id DESC;


# 08. Top 5 Employees
SELECT 
    CONCAT(first_name, ' ', last_name) AS name,
    started_on,
    COUNT(ec.client_id) AS count_of_clients
FROM
    employees AS e
        LEFT JOIN
    employees_clients AS ec ON e.id = ec.employee_id
GROUP BY e.id
ORDER BY count_of_clients DESC , e.id
LIMIT 5;


# 09. Branch cards
SELECT 
    b.name, COUNT(ca.id) AS count_of_cards
FROM
    branches AS b
        LEFT JOIN
    employees AS e ON b.id = e.branch_id
        LEFT JOIN
    employees_clients AS ec ON e.id = ec.employee_id
        LEFT JOIN
    clients AS c ON ec.client_id = c.id
        LEFT JOIN
    bank_accounts AS bc ON c.id = bc.client_id
        LEFT JOIN
    cards AS ca ON bc.id = ca.bank_account_id
GROUP BY b.id
ORDER BY count_of_cards DESC , b.name ASC;

# 10. Extract card's count
DELIMITER $$
CREATE FUNCTION udf_client_cards_count(name VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
RETURN (
		SELECT COUNT(ca.id) AS count_of_cards FROM clients AS c
		LEFT JOIN bank_accounts AS bc ON c.id = bc.client_id
		LEFT JOIN cards AS ca ON bc.id = ca.bank_account_id
		WHERE c.full_name = name
		GROUP BY c.id);
END$$

DELIMITER ;


SELECT 
    c.full_name, UDF_CLIENT_CARDS_COUNT('Baxy David') AS `cards`
FROM
    clients c
WHERE
    c.full_name = 'Baxy David';



# 11. Client Info

DELIMITER $$
CREATE PROCEDURE udp_clientinfo(name VARCHAR(30))
BEGIN 
	SELECT full_name, age, ba.account_number, concat('$', ba.balance) AS balance FROM clients AS c
	LEFT JOIN bank_accounts AS ba ON c.id = ba.client_id
	WHERE c.full_name = name;
END $$
DELIMITER ;

CALL udp_clientinfo('Hunter Wesgate');
