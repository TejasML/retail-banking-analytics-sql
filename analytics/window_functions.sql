-- WINDOW FUNCTIONS

-- Example 1: ROW_NUMBER()
-- Assign a unique rank to each account by balance within its own branch (top account per branch).

SELECT
    branch_id,
    account_id,
    customer_id,
    balance,
    ROW_NUMBER() OVER (PARTITION BY branch_id ORDER BY balance DESC) AS rank_in_branch
FROM Account;


-- Example 2: RANK() and DENSE_RANK()
-- Rank customers by their total account balance. RANK() skips rank numbers after ties, while DENSE_RANK() assigns consecutive ranks.

WITH CustomerBalance AS (
    SELECT customer_id, SUM(balance) AS total_balance
    FROM Account
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_balance,
    RANK()       OVER (ORDER BY total_balance DESC) AS rank_position,
    DENSE_RANK() OVER (ORDER BY total_balance DESC) AS dense_rank_position
FROM CustomerBalance
ORDER BY total_balance DESC
LIMIT 20;


-- Example 3: LAG() and LEAD()
-- Display the previous and next transaction amount for each account to compare consecutive transactions.

SELECT
    account_id,
    transaction_id,
    transaction_date,
    amount,
    LAG(amount)  OVER (PARTITION BY account_id ORDER BY transaction_date) AS previous_amount,
    LEAD(amount) OVER (PARTITION BY account_id ORDER BY transaction_date) AS next_amount
FROM Transaction
ORDER BY account_id, transaction_date;


-- Example 4: SUM() OVER() — Running Total
-- Calculate the total transaction amount after each transaction for every account.

SELECT
    account_id,
    transaction_id,
    transaction_date,
    amount,
    SUM(amount) OVER (PARTITION BY account_id ORDER BY transaction_date
                       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_balance
FROM Transaction
ORDER BY account_id, transaction_date;


-- Example 5: NTILE() — Segment customers into buckets
-- SDivide customers into four groups based on their total account balance for customer segmentation (e.g., Platinum, Gold, Silver, and Standard).

WITH CustomerBalance AS (
    SELECT customer_id, SUM(balance) AS total_balance
    FROM Account
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_balance,
    NTILE(4) OVER (ORDER BY total_balance DESC) AS balance_quartile
FROM CustomerBalance;