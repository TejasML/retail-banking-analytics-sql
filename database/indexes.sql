-- INDEXES: speed up FK lookups, joins, and common filters
-- (Primary Keys are already indexed automatically by MySQL)


-- ---- Employee ----
CREATE INDEX idx_employee_branch ON Employee(branch_id);

-- ---- Customer ----
CREATE INDEX idx_customer_branch ON Customer(branch_id);
CREATE INDEX idx_customer_registration_date ON Customer(registration_date);

-- ---- Account ----
CREATE INDEX idx_account_customer ON Account(customer_id);
CREATE INDEX idx_account_branch ON Account(branch_id);
CREATE INDEX idx_account_status ON Account(status);

-- ---- Loan ----
CREATE INDEX idx_loan_customer ON Loan(customer_id);
CREATE INDEX idx_loan_branch ON Loan(branch_id);
CREATE INDEX idx_loan_status ON Loan(loan_status);

-- ---- Transaction ----
CREATE INDEX idx_transaction_account ON Transaction(account_id);
CREATE INDEX idx_transaction_date ON Transaction(transaction_date);
CREATE INDEX idx_transaction_type ON Transaction(transaction_type);