USE banking_system;

-- Common Table Expressions: temporary named result sets
-- that make complex queries readable by breaking them into logical steps.


-- Example 1: Simple CTE
-- Finding all customers who have at least one account with
-- a balance above 500,000 (high-value customers).

WITH HighBalanceAccounts AS (
    SELECT customer_id, account_id, balance
    FROM Account
    WHERE balance > 500000
)
SELECT c.customer_id, c.first_name, c.last_name, 
		h.account_id, h.balance
FROM HighBalanceAccounts h
JOIN Customer c ON h.customer_id = c.customer_id
ORDER BY h.balance DESC
LIMIT 10;


-- Example 2: CTE with aggregation
-- Calculate total balance per customer, then filter to only customers whose combined balance exceeds 1,000,000.

WITH CustomerTotals AS (
    SELECT customer_id, SUM(balance) AS total_balance
    FROM Account
    GROUP BY customer_id
)
SELECT c.customer_id, c.first_name, c.last_name, ct.total_balance
FROM CustomerTotals ct
JOIN Customer c ON ct.customer_id = c.customer_id
WHERE ct.total_balance > 1000000
ORDER BY ct.total_balance DESC;


-- Example 3: Multiple CTEs
-- Calculate each customer's total deposits and total loans to compare their overall financial position.
-- Show the difference between deposits and loans.

WITH LoanTotals AS (
    SELECT customer_id, SUM(loan_amount) AS total_loans
    FROM Loan
    GROUP BY customer_id
),
AccountTotals AS (
    SELECT customer_id, SUM(balance) AS total_balance
    FROM Account
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COALESCE(lt.total_loans, 0)    AS total_loans,
    COALESCE(at.total_balance, 0)  AS total_balance,
    COALESCE(at.total_balance, 0) - COALESCE(lt.total_loans, 0) AS net_position
FROM Customer c
LEFT JOIN LoanTotals lt ON c.customer_id = lt.customer_id
LEFT JOIN AccountTotals at ON c.customer_id = at.customer_id
ORDER BY net_position ASC
LIMIT 20;


