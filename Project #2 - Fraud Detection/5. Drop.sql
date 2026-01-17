# Drop Views:
DROP VIEW Card_Holders;
DROP VIEW Merchant_Categories;
DROP VIEW Merchants;

DROP VIEW Early_Transactions;
DROP VIEW Number_of_small_payments_per_card_holder;
DROP VIEW Number_of_small_payments_per_merchant;
DROP VIEW Number_of_early_transactions_per_merchant;

# Drop Indexes:
ALTER TABLE transactions
DROP INDEX transaction_amount_idx;

ALTER TABLE transactions
DROP INDEX transaction_date_idx;

# Drop stored procedures:
DROP PROCEDURE get_card_holder_information;
DROP PROCEDURE get_card_holder_transactions;
DROP PROCEDURE get_large_card_holder_transactions;
DROP PROCEDURE get_morning_card_holder_transactions;
DROP PROCEDURE get_small_card_holder_transactions;
DROP PROCEDURE get_merchant_frequency;
DROP PROCEDURE get_card_holder_merchant_transactions;

# Drop tables and database:
DROP TABLE card_holder;
DROP TABLE credit_card;
DROP TABLE merchant;
DROP TABLE merchant_category;
DROP TABLE transactions;
DROP DATABASE transaction_database; 
