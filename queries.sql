-- How can you isolate (or group) the transactions of each cardholder?
	-- First, create a view joining tables on like IDs
	create view holder_tx as
	select ch.holder_name, ch.card_id, tx.transaction_id
	from card_holder as ch
	left join credit_card as cc
		on ch.card_id = cc.cardholder_id
	left join transaction as tx
		on cc.card_number = tx.card_number;
	
	-- Second, query this view by cardholder ID to view transactions
	select holder_name, transaction_id
	from holder_tx
	where card_id = 3;

-- Consider the time period 7:00 a.m. to 9:00 a.m.

	-- What are the top 100 highest transactions during this time period?
	select *
	from transaction
	where transaction_datetime::time between '7:00:00' and '9:00:00'
	order by amount desc
	limit 100;

	-- Do you see any fraudulent or anomalous transactions?
	-- YES

	-- If you answered yes to the previous question, explain why you think there might be fraudulent transactions during this time frame.
	-- TRANSACTION #2451 HAS A VERY SMALL DECIMAL - THIS SEEMS SUSPICIOUS

-- Some fraudsters hack a credit card by making several small payments (generally less than $2.00), which are typically ignored by cardholders. 
-- Count the transactions that are less than $2.00 per cardholder. Is there any evidence to suggest that a credit card has been hacked? Explain your rationale.
	
	-- First, create a view joining tables on like IDs
	create view small_charges as
	select ch.holder_name, ch.card_id, tx.amount, tx.transaction_id
	from card_holder as ch
	left join credit_card as cc
		on ch.card_id = cc.cardholder_id
	left join transaction as tx
		on cc.card_number = tx.card_number
	where amount < 2;

	-- Second, query the view
	select holder_name, count(amount) as "Transactions < $2"
	from small_charges
	group by holder_name
	order by "Transactions < $2" desc;

-- What are the top 5 merchants prone to being hacked using small transactions?
	create view merch_hack as
	select tx.amount, tx.merchant_id, merchant.merchant_name
	from merchant
	left join transaction as tx
		on tx.merchant_id = merchant.merchant_id
	where amount < 2;
	
	select merchant_name, count(amount) as "Transactions < $2"
	from merch_hack
	group by merchant_name
	order by "Transactions < $2" desc
	limit 5;

-- Once you have a query that can be reused, create a view for each of the previous queries.