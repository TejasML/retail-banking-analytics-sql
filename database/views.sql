-- VIEWS: reusable, business-meaningful queries


-- ---- 1. Customer Account Summary ----
-- Business use: quick net-worth / relationship view per customer.
-- Feeds into Customer Lifetime Value reporting.
CREATE OR REPLACE VIEW vw_customer_account_summary AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.city,
    c.state,
    COUNT(a.account_id)      AS total_accounts,
    COALESCE(SUM(a.balance), 0) AS total_balance
FROM Customer c
LEFT JOIN Account a ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.city, c.state;


-- ---- 2. Active Loans (Risk Watchlist) ----
-- Business use: loan officers/risk teams monitor Active and Defaulted loans daily.
CREATE OR REPLACE VIEW vw_active_loans AS
SELECT
    l.loan_id,
    l.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    l.branch_id,
    b.branch_name,
    l.loan_type,
    l.loan_amount,
    l.interest_rate,
    l.tenure_months,
    l.issue_date,
    l.loan_status
FROM Loan l
JOIN Customer c ON l.customer_id = c.customer_id
JOIN Branch b ON l.branch_id = b.branch_id
WHERE l.loan_status IN ('Active', 'Defaulted');


-- ---- 3. Branch Summary ----
-- Business use: branch performance dashboard — customers, deposits, and loans per branch.
CREATE OR REPLACE VIEW vw_branch_summary AS
SELECT
    b.branch_id,
    b.branch_name,
    b.city,
    b.state,
    COUNT(DISTINCT c.customer_id)  AS total_customers,
    COUNT(DISTINCT a.account_id)   AS total_accounts,
    COALESCE(SUM(DISTINCT a.balance), 0) AS total_deposits,
    COUNT(DISTINCT l.loan_id)      AS total_loans,
    COALESCE(SUM(l.loan_amount), 0) AS total_loan_amount
FROM Branch b
LEFT JOIN Customer c ON b.branch_id = c.branch_id
LEFT JOIN Account a ON b.branch_id = a.branch_id
LEFT JOIN Loan l ON b.branch_id = l.branch_id
GROUP BY b.branch_id, b.branch_name, b.city, b.state;


-- ---- 4. Transaction Summary ----
-- Business use: simplifies audit trail queries by attaching customer context
-- to every transaction without repeating the Account/Customer join everywhere.
CREATE OR REPLACE VIEW vw_transaction_summary AS
SELECT
    t.transaction_id,
    t.account_id,
    a.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    t.transaction_type,
    t.amount,
    t.payment_mode,
    t.transaction_date,
    t.remarks
FROM Transaction t
JOIN Account a ON t.account_id = a.account_id
JOIN Customer c ON a.customer_id = c.customer_id;