-- Show the top 20 customers based on their total account balance
-- and the percentage of the bank's total deposits they hold.
-- This helps identify customers who hold a large share of the
-- bank's deposits.

SELECT
    customer_id,
    first_name,
    last_name,
    city,
    total_balance,
    RANK() OVER (ORDER BY total_balance DESC) AS rank_position,
    ROUND(total_balance / (SELECT SUM(total_balance) FROM vw_customer_account_summary) * 100, 2)
        AS percent_of_total_deposits
FROM vw_customer_account_summary
ORDER BY total_balance DESC
LIMIT 20;
