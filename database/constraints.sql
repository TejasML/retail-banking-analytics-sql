-- CONSTRAINTS: additional data validation rules
-- (PK, FK, UNIQUE, NOT NULL already defined in create_tables.sql)


-- ---- Customer ----
ALTER TABLE Customer
    ADD CONSTRAINT chk_customer_gender
        CHECK (gender IN ('M', 'F', 'O'));

-- ---- Account ----
ALTER TABLE Account
    ADD CONSTRAINT chk_account_type
        CHECK (account_type IN ('Savings', 'Current'));

ALTER TABLE Account
    ADD CONSTRAINT chk_account_status
        CHECK (status IN ('Active', 'Dormant', 'Closed'));

ALTER TABLE Account
    ADD CONSTRAINT chk_account_balance_non_negative
        CHECK (balance >= 0);

-- ---- Loan ----
ALTER TABLE Loan
    ADD CONSTRAINT chk_loan_type
        CHECK (loan_type IN ('Home', 'Car', 'Personal', 'Education', 'Business'));

ALTER TABLE Loan
    ADD CONSTRAINT chk_loan_status
        CHECK (loan_status IN ('Active', 'Closed', 'Defaulted'));

ALTER TABLE Loan
    ADD CONSTRAINT chk_loan_amount_positive
        CHECK (loan_amount > 0);

ALTER TABLE Loan
    ADD CONSTRAINT chk_loan_interest_rate
        CHECK (interest_rate > 0 AND interest_rate <= 20);

ALTER TABLE Loan
    ADD CONSTRAINT chk_loan_tenure_positive
        CHECK (tenure_months > 0);

-- ---- Transaction ----
ALTER TABLE Transaction
    ADD CONSTRAINT chk_transaction_type
        CHECK (transaction_type IN ('Deposit', 'Withdrawal', 'Transfer-Debit', 'Transfer-Credit'));

ALTER TABLE Transaction
    ADD CONSTRAINT chk_transaction_payment_mode
        CHECK (payment_mode IN ('Cash', 'UPI', 'Debit Card', 'NEFT', 'RTGS'));

-- Note: amount can be negative for Transfer-Debit rows (money leaving the account),
-- so we don't force amount > 0 globally. Instead we ensure it's never zero.
ALTER TABLE Transaction
    ADD CONSTRAINT chk_transaction_amount_not_zero
        CHECK (amount <> 0);

-- ---- Employee ----
ALTER TABLE Employee
    ADD CONSTRAINT chk_employee_designation
        CHECK (designation IN ('Branch Manager', 'Assistant Manager', 'Loan Officer',
                                'Cashier', 'Customer Service Executive'));

ALTER TABLE Employee
    ADD CONSTRAINT chk_employee_salary_positive
        CHECK (salary > 0);