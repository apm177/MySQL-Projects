# It seems that there may be a fraudulent transaction pertaining to card holder 25.

# Start by getting all the information on card holder 25:
CALL get_card_holder_information(25);
# Name of card holder is Nancy Contreras, with 2 credit cards and a high transaction total.
 
# Let's see all the transactions of card holder 25:
CALL get_card_holder_transactions(25);
# Seems to mostly transact with food trucks or restaurants.

# Let's see of there is any small transactions that may seem suspicious.
CALL get_small_card_holder_transactions(25);
# Nothing suspicious with these transactions, these are with merchants card holder id 25 seems to frequently transact with.

# Let's find large transaction amounts:
CALL get_large_card_holder_transactions(25);
# There are quite a few large transactions with restaurants/bars/coffee shops and food trucks.

# Let's find early morning transactions:
CALL get_morning_card_holder_transactions(25);
# There seems to be one suspiciously large transaction in the morning with merchant ID 87, which is a bar.

# Let's find which merchants card holder 25 frequents most:
CALL get_merchant_frequency(25);
# Card Holder 25 seems to visit other bars more than merchant ID 87. 

# Now let's find all the transactions between card holder ID 25 and merchant ID 87.
CALL get_card_holder_merchant_transactions(25, 87);
# There is only one transaction amount larger than $1000, while the rest are small charges that are not in the morning.
# That large transaction is most likely a fraudulent one.