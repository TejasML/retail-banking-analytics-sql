-- This report shows how many transactions happened each month,
-- and how much total money moved, split by transaction type
-- (Deposit, Withdrawal, Transfer). Useful for tracking whether
-- the bank's activity is growing or shrinking over time.

SELECT
    DATE_FORMAT(transaction_date, '%Y-%m') AS transaction_month,
    transaction_type,
    COUNT(*)                       AS total_transactions,
    SUM(ABS(amount))               AS total_amount,
    ROUND(AVG(ABS(amount)), 2)     AS avg_transaction_amount
FROM Transaction
GROUP BY DATE_FORMAT(transaction_date, '%Y-%m'), transaction_type
ORDER BY transaction_month, transaction_type;