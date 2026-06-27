# 🏦 Banking Database Management & Analytics System

A comprehensive SQL-based Banking Database Management System designed to simulate real-world banking operations while demonstrating advanced database design, SQL programming, automation, and analytical reporting.

This project focuses on designing a fully normalized relational database that supports customers, accounts, branches, loans, employees, and banking transactions. It also includes advanced SQL reports, stored procedures, triggers, and business analytics commonly used in financial institutions.

---

# 📌 Project Overview

The goal of this project is to build a robust banking database capable of handling day-to-day banking operations while maintaining data integrity, consistency, and scalability.

The project demonstrates:

* Relational Database Design
* Database Normalization (3NF)
* Referential Integrity using Foreign Keys
* Advanced SQL Queries
* Stored Procedures
* Database Triggers
* Business Reporting & Analytics
* Query Optimization using Indexes
* Database Views

---

# 🚀 Features

### Customer Management

* Register new customers
* Store customer personal information
* Maintain customer account relationships

### Account Management

* Savings and Current accounts
* Account opening and closing
* Balance management

### Transaction Management

* Deposit money
* Withdraw money
* Transfer funds
* Transaction history

### Loan Management

* Apply for loans
* Loan repayment tracking
* Outstanding balance calculation

### Branch Management

* Multiple bank branches
* Branch-wise customer management
* Branch performance reporting

### Employee Management

* Employee records
* Branch assignment

---

# 🛠 Technologies Used

* SQL
* PostgreSQL / MySQL
* DBMS Concepts
* ER Modeling
* Normalization (1NF, 2NF, 3NF)
* Stored Procedures
* Triggers
* Views
* Indexes
* CTEs
* Window Functions
* Aggregate Functions

---

# 🗂 Database Schema

The database consists of the following major entities:

* Customer
* Account
* Branch
* Employee
* Transaction
* Loan
* Loan Payment

### Relationship Summary

Customer → Account (1:M)

Account → Transaction (1:M)

Customer → Loan (1:M)

Loan → Loan Payment (1:M)

Branch → Account (1:M)

Branch → Employee (1:M)

---

# 📊 Entity Relationship Diagram

The complete ER Diagram can be found inside:

```
diagrams/
    ER_Diagram.png
```

---

# 📁 Project Structure

```
Banking-Database-System/

database/
procedures/
triggers/
reports/
analytics/
diagrams/
screenshots/
```

---

# 🗄 Database Design

The database has been normalized up to Third Normal Form (3NF).

The schema includes:

* Primary Keys
* Foreign Keys
* Unique Constraints
* Check Constraints
* NOT NULL Constraints

Indexes have also been created to improve query performance.

---

# ⚙ Stored Procedures

The project includes reusable stored procedures for common banking operations.

### Deposit Money

* Validates account
* Adds balance
* Records transaction

---

### Withdraw Money

* Checks available balance
* Prevents overdraft
* Updates account balance
* Records transaction

---

### Transfer Money

* Debits sender account
* Credits receiver account
* Maintains transaction consistency

---

### Apply Loan

* Creates loan record
* Assigns loan information
* Initializes repayment tracking

---

# 🔄 Database Triggers

Triggers automate repetitive operations inside the database.

### Balance Update Trigger

Automatically updates account balance after every successful transaction.

### Transaction Log Trigger

Stores every transaction inside a transaction log table.

### Negative Balance Validation

Prevents withdrawals that exceed the available account balance.

---

# 📈 Business Reports

The project includes several analytical reports.

## Monthly Transaction Report

Shows

* Total Deposits
* Total Withdrawals
* Monthly Transaction Count

---

## Customer Lifetime Value

Calculates

* Total Deposits
* Total Withdrawals
* Current Balance
* Loan Amount
* Estimated Customer Value

---

## Branch Performance Report

Displays

* Number of Customers
* Total Deposits
* Active Loans
* Branch-wise Revenue

---

## Top Customers

Ranks customers according to

* Account Balance
* Total Deposits
* Total Transactions

---

## Loan Default Risk Report

Identifies

* Pending Loan Payments
* Missed Installments
* High Risk Customers

---

# 📊 Advanced SQL Concepts

This project demonstrates several advanced SQL techniques.

## Common Table Expressions (CTEs)

Used for

* Monthly reports
* Customer summaries
* Loan analysis

---

## Window Functions

Implemented

* ROW_NUMBER()
* RANK()
* DENSE_RANK()
* SUM() OVER()
* AVG() OVER()

---

## Aggregate Functions

Used extensively throughout the reports.

Examples

* SUM()
* AVG()
* COUNT()
* MAX()
* MIN()

---

## Joins

The project makes use of

* INNER JOIN
* LEFT JOIN
* RIGHT JOIN
* SELF JOIN

---

## Subqueries

Nested queries are used to generate customer summaries and analytical reports.

---

# 📂 Folder Description

## database/

Contains

* Database creation scripts
* Table creation
* Constraints
* Views
* Indexes
* Sample data

---

## procedures/

Contains all stored procedures implementing banking operations.

---

## triggers/

Contains database triggers used for automation and validation.

---

## reports/

Contains analytical SQL queries used for business reporting.

---

## analytics/

Contains examples demonstrating advanced SQL concepts such as

* CTEs
* Window Functions
* Ranking
* Aggregations

---

## diagrams/

Contains

* ER Diagram
* Schema Diagram

---

## screenshots/

Contains screenshots of

* Tables
* Query Outputs
* Stored Procedure Results
* Reports

---

# ▶️ Running the Project

### Step 1

Create the database.

```sql
SOURCE database/create_database.sql;
```

### Step 2

Create all tables.

```sql
SOURCE database/create_tables.sql;
```

### Step 3

Apply constraints and indexes.

```sql
SOURCE database/constraints.sql;

SOURCE database/indexes.sql;
```

### Step 4

Insert sample data.

```sql
SOURCE database/sample_data.sql;
```

### Step 5

Create stored procedures.

Run every SQL file inside

```
procedures/
```

### Step 6

Create triggers.

Run every SQL file inside

```
triggers/
```

### Step 7

Execute report queries.

Run SQL files inside

```
reports/
```

---

# 📸 Sample Outputs

The repository contains screenshots demonstrating

* Table Creation
* ER Diagram
* Stored Procedure Execution
* Trigger Execution
* Report Outputs
* Advanced SQL Queries

---

# 🎯 Learning Outcomes

Through this project, I gained hands-on experience in:

* Relational Database Design
* Database Normalization
* Referential Integrity
* SQL Programming
* Advanced SQL Analytics
* Window Functions
* CTEs
* Stored Procedures
* Database Triggers
* Business Reporting
* Query Optimization
* Database Documentation

---

# 🔮 Future Improvements

Possible future enhancements include:

* Web-based Banking Dashboard
* REST API Integration
* User Authentication
* Role-Based Access Control
* Transaction Fraud Detection
* Power BI Dashboard
* Real-time Banking Analytics



---

# If you found this project helpful

Feel free to fork the repository, explore the SQL scripts, and use the project for learning and practice.
