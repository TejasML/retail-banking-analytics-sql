USE banking_system;

-- DATA IMPORT: load CSVs into tables
-- Load order matters: parents before children
-- (Branch -> Employee/Customer -> Account -> Loan/Transaction)

SHOW VARIABLES LIKE 'secure_file_priv';

-- ---- 1. Branch ----
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/branches.csv'
INTO TABLE Branch
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(branch_id, branch_code, branch_name, city, state, address, phone);

-- ---- 2. Employee ----
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/employees.csv'
INTO TABLE Employee
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(employee_id, branch_id, first_name, last_name, designation, email, phone, hire_date, salary);

-- ---- 3. Customer ----
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customers.csv'
INTO TABLE Customer
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customer_id, first_name, last_name, gender, dob, email, phone, address, city, state,
 occupation, registration_date, branch_id);

-- ---- 4. Account ----
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/accounts.csv'
INTO TABLE Account
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(account_id, customer_id, branch_id, account_type, balance, open_date, status);

-- ---- 5. Loan ----
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/loans.csv'
INTO TABLE Loan
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(loan_id, customer_id, branch_id, loan_type, loan_amount, interest_rate,
 tenure_months, issue_date, loan_status);

-- ---- 6. Transaction ----
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE Transaction
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(transaction_id, account_id, transaction_type, amount, payment_mode, transaction_date, remarks);


-- VERIFICATION: confirm row counts after import

SELECT 'Branch' AS table_name, COUNT(*) AS row_count FROM Branch
UNION ALL
SELECT 'Employee', COUNT(*) FROM Employee
UNION ALL
SELECT 'Customer', COUNT(*) FROM Customer
UNION ALL
SELECT 'Account', COUNT(*) FROM Account
UNION ALL
SELECT 'Loan', COUNT(*) FROM Loan
UNION ALL
SELECT 'Transaction', COUNT(*) FROM Transaction;