# Banking Database Design & Analytics System

A MySQL-based banking database I built from scratch to get serious about relational database design — not just writing queries, but thinking through how a real system should be structured, what rules it should enforce, and how to make the database do work automatically instead of relying on the application to remember things.

---

## Why I Built This

Most SQL portfolio projects stop at "write a few SELECT queries against a flat table." I wanted to go deeper — actually design a normalized schema, wire up foreign keys, write stored procedures, build triggers, and produce reports that answer real questions a bank would care about.

The banking domain made sense because it naturally forces you to think about data integrity. Money moving between accounts can't be approximate — every transaction needs to be traceable, every balance needs to stay accurate, and the database itself should reject bad data rather than hoping whoever's writing the application gets it right.

---

## What I Wanted to Learn

- How to design a normalized schema (3NF) from a real-world domain
- How foreign keys actually enforce referential integrity, not just look good on a diagram
- How stored procedures create a controlled, validated entry point for business operations
- How triggers can automate consequences — so inserting a transaction automatically updates a balance, every time, no matter how the data gets modified
- How views eliminate repeated join logic across reports
- How to write CTEs, window functions, and aggregations against a real multi-table schema

---

## Schema Overview

Six core tables, each with a clear, single responsibility:

| Table | What it holds |
|---|---|
| `Branch` | Bank branch locations and contact details |
| `Employee` | Staff records, each belonging to one branch |
| `Customer` | Customer profiles, each linked to one branch |
| `Account` | Savings or Current accounts, linked to Customer and Branch |
| `Loan` | Loan applications (Home, Car, Personal, Education, Business) |
| `Transaction` | Every deposit, withdrawal, and transfer on an account |

A seventh table — `TransactionLog` — is populated automatically by a trigger. It's a separate audit trail that records what happened and when, independent of the operational Transaction table.

The hierarchy flows naturally: Branch sits at the top, Employee and Customer belong to a Branch, Account and Loan belong to Customer and Branch, and Transaction belongs to Account.

---

## Design Decisions

These are the choices that aren't obvious from just looking at the schema.

**Transfers create two transaction rows, not two extra columns.**
The first instinct when designing transfers is to add `from_account_id` and `to_account_id` columns to the Transaction table. But that means every deposit and withdrawal row has two NULL columns sitting there doing nothing — which is a normalization issue. Instead, each transfer generates two linked rows: a `Transfer-Debit` on the sender's account and a `Transfer-Credit` on the receiver's. The schema stays consistent, and the pattern actually mirrors how real banking ledgers work (double-entry bookkeeping).

**IDs are formatted strings, not plain integers.**
`CUST0001`, `ACC00001`, `TXN000001` — these are VARCHAR primary keys, not auto-increment integers. In a real banking system, IDs need to be readable and identifiable at a glance, not just database-internal row numbers. This also makes the data look like actual banking records in reports and queries.

**Business logic lives inside stored procedures.**
A stored procedure for `deposit_money` might seem like overkill when you could just write an INSERT. But the point is that validation — checking the account exists, isn't closed, and the amount is positive — happens at the database level, not the application level. Any client that connects to this database (an app, a script, a manual query) has to go through the same checks. The database enforces correctness, not the developer's memory.

**Triggers update balances automatically.**
When a transaction row is inserted, a trigger fires and updates the linked account's balance. This means the balance column is never manually touched — it stays in sync with transaction history automatically. A second trigger (`prevent_negative_balance`) acts as a final safety net, blocking any update that would push a balance below zero, even if the procedure-level check somehow missed it. Two layers of protection instead of one.

**Views eliminate repeated join logic.**
Four views (`vw_branch_summary`, `vw_customer_account_summary`, `vw_active_loans`, `vw_transaction_summary`) hold commonly needed join logic in one place. Reports and queries reference the views instead of rewriting the same joins every time. If the logic ever needs to change, it changes in one place.

---

## Features

### Stored Procedures

| Procedure | What it does |
|---|---|
| `deposit_money` | Validates account status, inserts a deposit |
| `withdraw_money` | Checks available balance before allowing withdrawal |
| `transfer_money` | Validates both accounts, creates the linked debit/credit pair |
| `apply_loan` | Validates customer eligibility, creates a new loan record |

### Triggers

| Trigger | What it does |
|---|---|
| `trg_update_balance` | Adjusts account balance after every transaction insert |
| `trg_prevent_negative_balance` | Blocks any balance update that would go below zero |
| `trg_transaction_log` | Writes an audit entry to `TransactionLog` after every insert |

### Views

| View | What it holds |
|---|---|
| `vw_customer_account_summary` | Each customer's total accounts and combined balance |
| `vw_active_loans` | Active and defaulted loans with customer and branch context |
| `vw_branch_summary` | Aggregated customers, accounts, deposits, and loans per branch |
| `vw_transaction_summary` | Transactions joined with customer context for audit queries |

---

## SQL Skills

Working across this schema meant regularly using:

- Multi-table JOINs (up to 4 tables in a single query)
- `GROUP BY` with `HAVING` for filtered aggregations
- CTEs for breaking complex queries into readable steps
- Window functions — `RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`, `LAG()`, `LEAD()`, `SUM() OVER()`, `NTILE()`
- Conditional aggregation with `CASE` inside `COUNT()` and `SUM()`
- `DATE_FORMAT()` for monthly trend grouping
- Stored procedures with input validation and custom error signaling
- Triggers with `NEW`/`OLD` row references
- Subqueries inside window function expressions

The `analytics/` folder has isolated examples of CTEs, window functions, and aggregations specifically so they're easy to reference — rather than digging through report files to find a particular technique.

---

## Reports

Five reports in the `reports/` folder, each answering a specific question:

**`monthly_transactions.sql`**
Breaks down transaction count and total value by month and type. Helps identify whether activity is growing, which months are busiest, and how the deposit/withdrawal/transfer mix shifts over time.

**`customer_lifetime_value.sql`**
Combines account balances and transaction activity per customer into a single ranked view. Customers with high balances and frequent transactions are the ones worth prioritizing for retention.

**`branch_performance.sql`**
Pulls directly from `vw_branch_summary` to rank branches by total deposits and loan volume. Highlights which branches are the strongest performers and which might need attention.

**`top_customers.sql`**
Shows the top 20 customers by total balance, their rank, and what percentage of the bank's total deposits each one represents. The concentration metric matters — if five customers hold 30% of all deposits, that's a real risk if any of them leave.

**`loan_default_risk.sql`**
Calculates the default rate per branch (defaulted loans ÷ total loans × 100). Sorted highest to lowest, it immediately surfaces which branches are carrying the most lending risk.

---

## Challenges

**Designing the transfer flow.**
The two-row approach for transfers sounds simple in hindsight, but getting the trigger to correctly handle `Transfer-Debit` (amount stored as negative) and `Transfer-Credit` (positive) without double-counting required careful thought about how `update_balance` calculates the adjustment.

**Trigger interaction.**
Two triggers fire on the same event — `AFTER INSERT ON Transaction`. Getting `trg_update_balance` and `trg_transaction_log` to coexist correctly (in the right creation order) and understanding that the `prevent_negative_balance` trigger fires on `Account UPDATE`, not Transaction INSERT, took some debugging.

**Generating realistic data.**
The synthetic dataset needed to respect foreign key relationships in creation order (Branch → Employee → Customer → Account → Loan → Transaction), use a banking working calendar (no Sundays, no 2nd/4th Saturdays), and enforce date consistency (account opening always after registration, loan issue always after account opening). Getting all of this right in a single Python script took more planning than the actual SQL.

**Preventing negative balances at two layers.**
The procedure checks balance before attempting a withdrawal. The trigger checks after the UPDATE would take effect. Both layers need to work together without one making the other redundant — understanding when each fires (before vs. after, on Transaction vs. on Account) was a useful lesson in how triggers actually work.

---

## Lessons Learned

Building this made a few things concrete that were previously just concepts:

- Normalization isn't just about avoiding duplication — it's about making sure each fact lives in exactly one place, so updates don't create inconsistencies.
- Foreign keys don't just prevent orphan records — they also communicate intent. The schema diagram tells you the entire data model just from the relationship lines.
- Triggers are powerful but need to be understood carefully. A trigger that fires in the wrong order, or on the wrong event, produces subtle bugs that are hard to trace.
- Views are underused. Once you have `vw_branch_summary` defined, five different queries can use it without rewriting joins — and if the logic changes, it changes once.

---

## What's Next

A few things I'd add with more time:

- **Power BI dashboard** — connect directly to the MySQL views and build live visualizations for branch performance and transaction trends
- **Loan repayment table** — track installment-level repayments, so the system can flag missed payments rather than just marking loans as "Defaulted" after the fact
- **Scheduled events** — use MySQL Event Scheduler to run monthly interest calculations automatically
- **Role-based access** — add MySQL user roles so tellers, loan officers, and managers each see only what they need

---

## Screenshots

Five images in the `screenshots/` folder, each showing a different part of the system actually running:

- **branch_performance.png** — the branch performance report, ranking branches by deposits and loan volume.
- **customer_lifetime_value.png** — the CLV report, showing balance and transaction activity per customer.
- **loan_default_risk.png** — default rate per branch, sorted highest to lowest.
- **transfer_validation.png** — `transfer_money` rejecting a same-account transfer and an insufficient-balance transfer.
- **apply_loan_success.png** — a new loan record created by `apply_loan`, with the auto-generated loan ID visible.
 
--- 

## Diagrams

The `diagrams/` folder has two views of the schema:

- **`ER_Diagram.png`** — full detail, every table with column names and data types, generated by MySQL Workbench's reverse-engineer tool directly from the live database
- **`Schema_Diagram.png`** — collapsed version showing just table names and relationship lines, useful for a quick overview of how the tables connect

---

## Author

**Tejas Salunkhe**
Aspiring Data Engineer
[LinkedIn](https://www.linkedin.com/in/tejas-salunkhe05) · [GitHub](https://github.com/TejasML)