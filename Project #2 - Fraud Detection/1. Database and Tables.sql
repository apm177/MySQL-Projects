#**************************************************************************************************************************#
# Create transaction database:
CREATE DATABASE transaction_database; 
USE transaction_database; 

#**************************************************************************************************************************#

# Create tables:
CREATE TABLE card_holder(
	id INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE credit_card(
	card VARCHAR(50) NOT NULL PRIMARY KEY,
    card_holder_id INT NOT NULL
);

CREATE TABLE merchant(
	id INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    merchant_category_id INT NOT NULL
);

CREATE TABLE merchant_category(
	id INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    name varchar(50) NOT NULL
);

CREATE TABLE transactions(
	id INT NOT NULL PRIMARY KEY,
    date TIMESTAMP NOT NULL,
    amount FLOAT NOT NULL,
    card VARCHAR(50) NOT NULL,
    merchant_id INT NOT NULL
);

#**************************************************************************************************************************#

#Add Foreign Key Constraints:

ALTER TABLE credit_card 
ADD CONSTRAINT fk_card_holder_id 
FOREIGN KEY(card_holder_id) REFERENCES card_holder(id);

ALTER TABLE merchant
ADD CONSTRAINT fk_merchant_category_id
FOREIGN KEY(merchant_category_id) REFERENCES merchant_category(id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transaction_card
FOREIGN KEY(card) REFERENCES credit_card(card);

ALTER TABLE transactions
ADD CONSTRAINT fk_merchant_id
FOREIGN KEY(merchant_id) REFERENCES merchant(id);


