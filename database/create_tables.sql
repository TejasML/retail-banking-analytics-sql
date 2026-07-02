-- create_database.sql
CREATE DATABASE IF NOT EXISTS banking_system;
USE banking_system;



-- 1. BRANCH 

CREATE TABLE Branch (
    branch_id     VARCHAR(10) PRIMARY KEY,
    branch_code   VARCHAR(10) NOT NULL,
    branch_name   VARCHAR(100) NOT NULL,
    city          VARCHAR(50) NOT NULL,
    state         VARCHAR(50) NOT NULL,
    address       VARCHAR(200),
    phone         VARCHAR(20)
);


-- 2. EMPLOYEE 

CREATE TABLE Employee (
    employee_id   VARCHAR(10) PRIMARY KEY,
    branch_id     VARCHAR(10) NOT NULL,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    designation   VARCHAR(50) NOT NULL,
    email         VARCHAR(100) UNIQUE NOT NULL,
    phone         VARCHAR(20) UNIQUE NOT NULL,
    hire_date     DATE NOT NULL,
    salary        DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
);


-- 3. CUSTOMER 

CREATE TABLE Customer (
    customer_id        VARCHAR(10) PRIMARY KEY,
    first_name         VARCHAR(50) NOT NULL,
    last_name           VARCHAR(50) NOT NULL,
    gender              CHAR(1) NOT NULL,
    dob                 DATE NOT NULL,
    email               VARCHAR(100) UNIQUE NOT NULL,
    phone               VARCHAR(20) UNIQUE NOT NULL,
    address             VARCHAR(200),
    city                VARCHAR(50),
    state               VARCHAR(50),
    occupation          VARCHAR(50),
    registration_date   DATE NOT NULL,
    branch_id           VARCHAR(10) NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
);


-- 4. ACCOUNT 

CREATE TABLE Account (
    account_id     VARCHAR(10) PRIMARY KEY,
    customer_id    VARCHAR(10) NOT NULL,
    branch_id      VARCHAR(10) NOT NULL,
    account_type   VARCHAR(20) NOT NULL,
    balance        DECIMAL(15,2) NOT NULL DEFAULT 0,
    open_date      DATE NOT NULL,
    status         VARCHAR(20) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
);


-- 5. LOAN 

CREATE TABLE Loan (
    loan_id         VARCHAR(10) PRIMARY KEY,
    customer_id     VARCHAR(10) NOT NULL,
    branch_id       VARCHAR(10) NOT NULL,
    loan_type       VARCHAR(30) NOT NULL,
    loan_amount     DECIMAL(15,2) NOT NULL,
    interest_rate   DECIMAL(5,2) NOT NULL,
    tenure_months   INT NOT NULL,
    issue_date      DATE NOT NULL,
    loan_status     VARCHAR(20) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
);


-- 6. TRANSACTION 

CREATE TABLE Transaction (
    transaction_id     VARCHAR(10) PRIMARY KEY,
    account_id         VARCHAR(10) NOT NULL,
    transaction_type   VARCHAR(20) NOT NULL,
    amount             DECIMAL(15,2) NOT NULL,
    payment_mode       VARCHAR(20),
    transaction_date   DATETIME NOT NULL,
    remarks            VARCHAR(100),
    FOREIGN KEY (account_id) REFERENCES Account(account_id)
);