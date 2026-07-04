-- This report estimates each customer's overall value to the bank
-- by combining how much money they keep with us (account balances)
-- and how active they are (number of transactions). Customers with
-- high balances and frequent activity are the most valuable to retain.

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT a.account_id)   AS total_accounts,
    COALESCE(SUM(DISTINCT a.balance), 0) AS total_balance,
    COUNT(t.transaction_id)        AS total_transactions,
    COALESCE(SUM(ABS(t.amount)), 0) AS total_transaction_value
FROM Customer c
LEFT JOIN Account a ON c.customer_id = a.customer_id
LEFT JOIN Transaction t ON a.account_id = t.account_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_balance DESC, total_transaction_value DESC;