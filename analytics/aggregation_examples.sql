-- AGGREGATION EXAMPLES
-- Standard aggregate functions (COUNT, SUM, AVG, MIN, MAX) combined with GROUP BY and HAVING to summarize data across groups of rows.


-- Example 1: Basic aggregation
-- Total number of accounts and total deposits per branch.

SELECT
    branch_id,
    COUNT(account_id)   AS total_accounts,
    SUM(balance)         AS total_deposits,
    AVG(balance)         AS avg_balance,
    MIN(balance)         AS min_balance,
    MAX(balance)         AS max_balance
FROM Account
GROUP BY branch_id
ORDER BY total_deposits DESC;


-- Example 2: GROUP BY with HAVING
-- Find branches where total deposits exceed 50,00,000 (5 Laak)
-- HAVING filters on the aggregated result, unlike WHERE which filters rows before grouping.

SELECT
    branch_id,
    SUM(balance) AS total_deposits
FROM Account
GROUP BY branch_id
HAVING SUM(balance) > 5000000
ORDER BY total_deposits DESC;


-- Example 3: Aggregation across multiple grouping columns
-- Count of accounts by account_type and status combination —
-- useful for spotting how many Savings/Current accounts are
-- Active, Dormant, or Closed.

SELECT
    account_type,
    status,
    COUNT(*) AS account_count
FROM Account
GROUP BY account_type, status
ORDER BY account_type, status;


-- Example 4: Aggregation with JOIN
-- Total loan amount and average interest rate per 
-- loan type, only counting Active loans.

SELECT
    loan_type,
    COUNT(loan_id)         AS total_loans,
    SUM(loan_amount)       AS total_loan_amount,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate
FROM Loan
WHERE loan_status = 'Active'
GROUP BY loan_type
ORDER BY total_loan_amount DESC;



-- Example 5: Conditional aggregation (CASE + aggregate)
-- Count how many Active, Closed, and Defaulted loans each
-- branch has — all in a single row per branch instead of separate queries.

SELECT
    branch_id,
    COUNT(CASE WHEN loan_status = 'Active' THEN 1 END)     AS active_loans,
    COUNT(CASE WHEN loan_status = 'Closed' THEN 1 END)     AS closed_loans,
    COUNT(CASE WHEN loan_status = 'Defaulted' THEN 1 END)  AS defaulted_loans,
    COUNT(*)                                                AS total_loans
FROM Loan
GROUP BY branch_id
ORDER BY defaulted_loans DESC;



-- Example 6: Monthly aggregation using DATE functions
-- Group transactions by month and transaction type
-- to see monthly transaction activity..

SELECT
    DATE_FORMAT(transaction_date, '%Y-%m') AS transaction_month,
    transaction_type,
    COUNT(*)      AS transaction_count,
    SUM(amount)   AS total_amount
FROM Transaction
GROUP BY DATE_FORMAT(transaction_date, '%Y-%m'), transaction_type
ORDER BY transaction_month, transaction_type;