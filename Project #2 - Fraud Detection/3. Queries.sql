# Read the data from all the tables:
SELECT * FROM card_holder;
SELECT * FROM credit_card;
SELECT * FROM merchant;
SELECT * FROM merchant_category;
SELECT * FROM transactions;

# Part A - Retrieving General Data about Card Holders, Merchants and Merchant Categories such as:

# Overall distribution of transaction amounts across all cardholders/merchants/merchant categories.
# Average transaction amount per cardholder/merchant/merchant category.
# Number of transactions each cardholder/merchant/merchant category makes.

# Card Holders:
CREATE VIEW Card_Holders AS
SELECT ch.id AS "Card Holder ID", ch.name AS "Card Holder", COUNT(t.id) AS "Number of Transactions", SUM(t.amount) AS "Total Transaction Amount", AVG(t.amount) AS "Average Transaction Amount"
FROM card_holder as ch
JOIN credit_card as c ON ch.id = c.card_holder_id
JOIN transactions as t ON t.card = c.card
GROUP BY ch.id, ch.name;

# Merchant Categories:
CREATE VIEW Merchant_Categories AS
SELECT mc.id AS "Merchant Category ID", mc.name AS "Merchant Category", COUNT(t.id) AS "Number of Transactions", SUM(t.amount) AS "Total Transaction Amount", AVG(t.amount) AS "Average Transaction Amount"
FROM merchant_category as mc
JOIN merchant as m ON m.merchant_category_id = mc.id
JOIN transactions as t ON t.merchant_id = m.id
GROUP by mc.id, mc.name;

# Merchants:
CREATE VIEW Merchants AS
SELECT m.id AS "Merchant ID", m.name AS "Merchant", COUNT(t.id) AS "Number of Transactions", SUM(t.amount) AS "Total Transaction Amount", AVG(t.amount) AS "Average Transaction Amount"
FROM merchant as m
JOIN transactions as t ON t.merchant_id = m.id
GROUP BY m.id, m.name;

# Can access this data by running these views:
SELECT * FROM Card_Holders;
SELECT * FROM Merchant_Categories;
SELECT * FROM Merchants;

# Part B - Queries that retrieve information that might be specific to fraud detection:

# Create indexes for the transaction amount and date columns, so SELECT will take less time when searching through these columns.
CREATE INDEX transaction_amount_idx
ON transactions(amount);

CREATE INDEX transaction_date_idx
ON transactions(date);

# Fraudulent credit card transactions frequently occur in morning hours, so find top 100 highest transactions that occurred during early morning hours (between 7:00 AM and 10:00 AM):
CREATE VIEW Early_Transactions AS
SELECT ch.id AS "Card Holder ID", ch.name AS "Card Holder", m.id AS "Merchant ID", m.name AS "Merchant", mc.name as "Merchant Category", t.id AS "Transaction ID", t.amount AS "Transaction Amount", t.date as "Date"
FROM transactions as t
JOIN credit_card as c ON t.card = c.card
JOIN merchant as m ON t.merchant_id = m.id
JOIN card_holder as ch ON ch.id = c.card_holder_id
JOIN merchant_category as mc ON mc.id = m.merchant_category_id
WHERE TIME(t.date) BETWEEN '07:00:00' AND '10:00:00'
ORDER BY t.amount DESC
LIMIT 100;

# Some fraudsters hack a credit card by making several small payments (generally less than $2.00), which are typically ignored by cardholders. 
# So count the transactions that are less than $2.00 per cardholder:
CREATE VIEW Number_of_small_payments_per_card_holder AS
SELECT ch.id AS "Card Holder ID", ch.name AS "Card Holder", COUNT(t.id) AS "Number of Transactions Under $2.00"
FROM card_holder as ch
JOIN credit_card as c ON ch.id = c.card_holder_id
JOIN transactions as t ON t.card = c.card
WHERE t.amount < 2
GROUP BY ch.id, ch.name;

# Find which merchants appear most or least frequently in suspiciously small transactions:
CREATE VIEW Number_of_small_payments_per_merchant AS
SELECT m.id AS "Merchant ID", m.name AS "Merchant", mc.name as "Merchant Category", COUNT(t.id) AS "Number of Transactions Under $2.00"
FROM merchant as m 
JOIN transactions as t ON m.id = t.merchant_id
JOIN merchant_category as mc ON mc.id = m.merchant_category_id
WHERE t.amount < 2
GROUP BY m.id, m.name
ORDER BY COUNT(t.id) DESC;

# Find which merchants appear most or least frequently in early-hour transactions?
CREATE VIEW Number_of_early_transactions_per_merchant AS
SELECT m.id AS "Merchant ID", m.name AS "Merchant", mc.name as "Merchant Category", COUNT(t.id) AS "Number of Transactions between 7 AM and 10 AM"
FROM merchant as m
JOIN transactions t ON t.merchant_id = m.id
JOIN merchant_category as mc ON mc.id = m.merchant_category_id
WHERE TIME(t.date) BETWEEN '07:00:00' AND '10:00:00'
GROUP BY m.id, m.name
ORDER BY COUNT(t.id) DESC;

# Can access this data by running these views:
SELECT * FROM Early_Transactions;
SELECT * FROM Number_of_small_payments_per_card_holder;
SELECT * FROM Number_of_small_payments_per_merchant;
SELECT * FROM Number_of_early_transactions_per_merchant;

# Part C - Create stored procedures to retrieve information about specific card holders that may seem suspicious:

# Find basic information on a specific card holder: 
DELIMITER $$ 
CREATE PROCEDURE get_card_holder_information(IN id INT)
BEGIN
	SELECT ch.id AS "Card Holder ID", ch.name AS "Card Holder", COUNT(DISTINCT c.card) AS "Number of Credit Cards", COUNT(t.id) AS "Number of Transactions", SUM(t.amount) AS "Total Transaction Amount", AVG(t.amount) AS "Average Transaction Amount"
	FROM card_holder as ch
	JOIN credit_card as c ON ch.id = c.card_holder_id
	JOIN transactions as t ON t.card = c.card
    WHERE ch.id = id
	GROUP BY ch.id, ch.name;
END $$

# Find all the transactions of a specific card holder:
DELIMITER $$ 
CREATE PROCEDURE get_card_holder_transactions(IN id INT)
BEGIN
	SELECT t.id AS "Transaction ID", t.date AS "Date", t.amount AS "Transaction Amount", t.card as "Credit Card", m.id AS "Merchant ID", m.name AS "Merchant Name", mc.name AS "Merchant Category"
    FROM transactions as t
    JOIN credit_card as c ON t.card = c.card
    JOIN merchant as m ON m.id = t.merchant_id
    JOIN merchant_category as mc ON mc.id = m.merchant_category_id
    WHERE c.card_holder_id = id
    ORDER BY t.date;
END $$
DELIMITER ;

# Find which transactions a card holder makes that is suspiciously large:
DELIMITER $$ 
CREATE PROCEDURE get_large_card_holder_transactions(IN id INT)
BEGIN
	SELECT t.id AS "Transaction ID", t.date AS "Date", t.amount AS "Transaction Amount", t.card as "Credit Card", m.id AS "Merchant ID", m.name AS "Merchant Name", mc.name AS "Merchant Category"
    FROM transactions as t
    JOIN credit_card as c ON t.card = c.card
    JOIN merchant as m ON m.id = t.merchant_id
    JOIN merchant_category as mc ON mc.id = m.merchant_category_id
    WHERE c.card_holder_id = id 
    AND t.amount >= (SELECT AVG(t2.amount)
					 FROM transactions as t2
                     JOIN credit_card as c2 ON t2.card = c2.card
                     WHERE c2.card_holder_id = id)
    ORDER BY t.date;
END $$
DELIMITER ;

# Find which transactions are made in morning hours:
DELIMITER $$ 
CREATE PROCEDURE get_morning_card_holder_transactions(IN id INT)
BEGIN
	SELECT t.id AS "Transaction ID", t.date AS "Date", t.amount AS "Transaction Amount", t.card as "Credit Card", m.id AS "Merchant ID", m.name AS "Merchant Name", mc.name AS "Merchant Category"
    FROM transactions as t
    JOIN credit_card as c ON t.card = c.card
    JOIN merchant as m ON m.id = t.merchant_id
    JOIN merchant_category as mc ON mc.id = m.merchant_category_id
    WHERE c.card_holder_id = id AND TIME(t.date) BETWEEN '07:00:00' AND '10:00:00'
    ORDER BY t.date;
END $$
DELIMITER ;

# See which transactions a card holder makes that is under $2.00:
DELIMITER $$ 
CREATE PROCEDURE get_small_card_holder_transactions(IN id INT)
BEGIN
	SELECT t.id AS "Transaction ID", t.date AS "Date", t.amount AS "Transaction Amount", t.card as "Credit Card", m.id AS "Merchant ID", m.name AS "Merchant Name", mc.name AS "Merchant Category"
    FROM transactions as t
    JOIN credit_card as c ON t.card = c.card
    JOIN merchant as m ON m.id = t.merchant_id
    JOIN merchant_category as mc ON mc.id = m.merchant_category_id
    WHERE c.card_holder_id = id AND t.amount < 2
    ORDER BY t.date;
END $$
DELIMITER ;

# See which merchants the card holder visits most and least frequently:
DELIMITER $$ 
CREATE PROCEDURE get_merchant_frequency(IN id INT)
BEGIN
	SELECT m.id AS "Merchant ID", m.name AS "Merchant Name", mc.name AS "Merchant Category", COUNT(t.id) AS "Number of Transactions"
    FROM merchant as m
    JOIN merchant_category as mc ON m.merchant_category_id = mc.id
    JOIN transactions as t ON m.id = t.merchant_id
    JOIN credit_card as c ON c.card = t.card
    WHERE c.card_holder_id = id
    GROUP BY m.id
    ORDER BY COUNT(t.id) DESC;
END $$
DELIMITER ;

# Find all transactions between a specific card holder and a specific merchant:
DELIMITER $$ 
CREATE PROCEDURE get_card_holder_merchant_transactions(IN ch_id INT, m_id INT)
BEGIN
	SELECT t.id AS "Transaction ID", t.date AS "Date", t.amount AS "Transaction Amount", t.card as "Credit Card"
    FROM transactions as t
    JOIN credit_card as c ON t.card = c.card
    JOIN merchant as m ON m.id = t.merchant_id
    WHERE c.card_holder_id = ch_id AND m.id = m_id
    ORDER BY t.date;
END $$
DELIMITER ;