"""
generate_dataset.py
--------------------
Generates a fully synthetic, internally consistent Indian Banking dataset
for a MySQL-based Banking Database Management & Analytics System project.

Outputs (in ./output/):
    branches.csv, employees.csv, customers.csv,
    accounts.csv, loans.csv, transactions.csv

Uses only: pandas, numpy, random, datetime, os, time
(No external 'faker' dependency — realistic Indian name/city pools are
 hand-built below so the script runs anywhere with no extra installs.)
"""

import os
import time
import random
import numpy as np
import pandas as pd
from datetime import date, timedelta, datetime as dt


# CONFIG — change these to resize the dataset

SEED = 42
N_BRANCHES = 25
N_EMPLOYEES = 100
N_CUSTOMERS = 650
N_LOANS = 200
N_TRANSACTIONS = 7500

OUTPUT_DIR = "output"
TODAY = date(2026, 7, 1)  # fixed "today" so results are reproducible

random.seed(SEED)
np.random.seed(SEED)


# REFERENCE DATA POOLS


INDIAN_CITIES = [
    ("Mumbai", "Maharashtra", 18), ("Pune", "Maharashtra", 10),
    ("Nagpur", "Maharashtra", 5), ("Nashik", "Maharashtra", 4),
    ("Delhi", "Delhi", 15), ("Bangalore", "Karnataka", 12),
    ("Hyderabad", "Telangana", 8), ("Ahmedabad", "Gujarat", 7),
    ("Surat", "Gujarat", 5), ("Jaipur", "Rajasthan", 5),
    ("Lucknow", "Uttar Pradesh", 5), ("Chennai", "Tamil Nadu", 8),
    ("Kolkata", "West Bengal", 6), ("Indore", "Madhya Pradesh", 4),
    ("Bhopal", "Madhya Pradesh", 3), ("Patna", "Bihar", 3),
    ("Chandigarh", "Punjab", 3), ("Kochi", "Kerala", 3),
    ("Coimbatore", "Tamil Nadu", 3), ("Nagpur East", "Maharashtra", 2),
]
# expand weighted city pool to 25 branch-city assignments (some repeat, metros more)
CITY_WEIGHTS = [c[2] for c in INDIAN_CITIES]

FIRST_NAMES_M = ["Aarav", "Vivaan", "Aditya", "Vihaan", "Arjun", "Sai", "Reyansh",
                 "Krishna", "Ishaan", "Rohan", "Karan", "Aman", "Rahul", "Suresh",
                 "Ramesh", "Manoj", "Sanjay", "Vikram", "Anil", "Deepak", "Gaurav",
                 "Nikhil", "Pankaj", "Rajesh", "Sandeep", "Ashok", "Vinod", "Yash",
                 "Kunal", "Abhishek"]
FIRST_NAMES_F = ["Aadhya", "Ananya", "Diya", "Isha", "Kavya", "Meera", "Pooja",
                  "Priya", "Riya", "Sneha", "Anjali", "Divya", "Neha", "Shreya",
                  "Swati", "Kiran", "Lata", "Sunita", "Rekha", "Geeta", "Nisha",
                  "Radha", "Sonal", "Vidya", "Alka", "Bhavna", "Chitra", "Deepa",
                  "Falguni", "Jyoti"]
FIRST_NAMES_O = ["Aryan", "Kiran", "Alex", "Sam", "Riya", "Noor"]
LAST_NAMES = ["Sharma", "Verma", "Gupta", "Patel", "Shah", "Mehta", "Kumar",
              "Singh", "Reddy", "Rao", "Nair", "Iyer", "Joshi", "Desai", "Kulkarni",
              "Chauhan", "Yadav", "Mishra", "Pandey", "Agarwal", "Bhatt", "Trivedi",
              "Malhotra", "Kapoor", "Chopra", "Bansal", "Saxena", "Tiwari", "Naik",
              "Pillai"]

OCCUPATIONS = ["Salaried - Private", "Salaried - Government", "Self-Employed",
               "Business Owner", "Student", "Retired", "Homemaker", "Freelancer",
               "Farmer", "Professional (Doctor/Lawyer/CA)"]

DESIGNATIONS = ["Branch Manager", "Assistant Manager", "Loan Officer",
                "Cashier", "Customer Service Executive"]
SALARY_RANGES = {
    "Branch Manager": (70000, 95000),
    "Assistant Manager": (50000, 70000),
    "Loan Officer": (40000, 55000),
    "Cashier": (25000, 35000),
    "Customer Service Executive": (25000, 35000),
}

ACCOUNT_TYPES = ["Savings", "Current"]
ACCOUNT_TYPE_WEIGHTS = [0.8, 0.2]
ACCOUNT_STATUS = ["Active", "Dormant", "Closed"]
ACCOUNT_STATUS_WEIGHTS = [0.85, 0.10, 0.05]

LOAN_TYPES = ["Home", "Car", "Personal", "Education", "Business"]
LOAN_INTEREST_RANGE = {
    "Home": (8.0, 9.5), "Car": (9.0, 11.0), "Personal": (11.0, 16.0),
    "Education": (8.5, 11.5), "Business": (10.0, 14.0),
}
LOAN_TENURE_RANGE = {
    "Home": (120, 240), "Car": (24, 84), "Personal": (12, 60),
    "Education": (36, 120), "Business": (24, 96),
}
LOAN_STATUS = ["Active", "Closed", "Defaulted"]
LOAN_STATUS_WEIGHTS = [0.70, 0.20, 0.10]

PAYMENT_MODES = ["Cash", "UPI", "Debit Card", "NEFT", "RTGS"]
DEPOSIT_REMARKS = ["Salary Credit", "Cash Deposit", "Cheque Deposit", "Interest Credit"]
WITHDRAWAL_REMARKS = ["ATM Withdrawal", "Cash Withdrawal", "Bill Payment", "Shopping"]
TRANSFER_REMARKS = ["Fund Transfer", "Rent Payment", "Loan EMI Payment", "Family Transfer"]



# BANKING WORKING CALENDAR


def build_working_day_set(start_year=2015, end_year=2027):
    """Return a set of all valid banking working days between given years.
    Rule: exclude Sundays, 2nd Saturday, 4th Saturday of every month."""
    working_days = set()
    d = date(start_year, 1, 1)
    end = date(end_year, 12, 31)
    saturday_counter = {}

    while d <= end:
        if d.weekday() == 6:  # Sunday
            d += timedelta(days=1)
            continue
        if d.weekday() == 5:  # Saturday
            key = (d.year, d.month)
            saturday_counter[key] = saturday_counter.get(key, 0) + 1
            occurrence = saturday_counter[key]
            if occurrence in (2, 4):
                d += timedelta(days=1)
                continue
        working_days.add(d)
        d += timedelta(days=1)

    return working_days


WORKING_DAYS = build_working_day_set()
WORKING_DAYS_SORTED = sorted(WORKING_DAYS)


def random_working_day(start_date, end_date):
    """Pick a random valid banking working day between start_date and end_date."""
    candidates = [d for d in WORKING_DAYS if start_date <= d <= end_date]
    if not candidates:
        # fallback: just nudge end_date forward until a working day is found
        d = start_date
        while d not in WORKING_DAYS and d <= end_date + timedelta(days=14):
            d += timedelta(days=1)
        return d
    return random.choice(candidates)



# STEP 1: BRANCHES


def generate_branches(n):
    print(f"Generating {n} branches...")
    records = []
    # build a pool of city assignments weighted toward metros, size n
    cities_pool = random.choices(
        population=[(c[0], c[1]) for c in INDIAN_CITIES],
        weights=CITY_WEIGHTS,
        k=n
    )
    street_names = ["MG Road", "Station Road", "Ring Road", "Civil Lines",
                     "Market Street", "Church Street", "Gandhi Nagar",
                     "Nehru Chowk", "Sector 12", "Model Town"]

    for i in range(1, n + 1):
        branch_id = f"BR{i:03d}"
        city, state = cities_pool[i - 1]
        branch_name = f"{city} {random.choice(['Main', 'Central', 'City', 'Metro', 'Regional'])} Branch"
        branch_code = branch_id
        address = f"{random.randint(1, 200)}, {random.choice(street_names)}, {city}"
        phone = f"0{random.randint(11,99)}-{random.randint(2000000,9999999)}"
        records.append({
            "branch_id": branch_id,
            "branch_code": branch_code,
            "branch_name": branch_name,
            "city": city,
            "state": state,
            "address": address,
            "phone": phone,
        })

    return pd.DataFrame(records)



# STEP 2: EMPLOYEES


def random_name(gender=None):
    if gender is None:
        gender = random.choice(["M", "F"])
    if gender == "M":
        first = random.choice(FIRST_NAMES_M)
    elif gender == "F":
        first = random.choice(FIRST_NAMES_F)
    else:
        first = random.choice(FIRST_NAMES_O)
    last = random.choice(LAST_NAMES)
    return first, last


def generate_employees(n, branches_df):
    print(f"Generating {n} employees...")
    records = []
    used_emails = set()
    branch_ids = branches_df["branch_id"].tolist()

    # Step A: guarantee exactly one Branch Manager per branch
    assignments = []
    for bid in branch_ids:
        assignments.append((bid, "Branch Manager"))

    remaining = n - len(branch_ids)
    other_designations = [d for d in DESIGNATIONS if d != "Branch Manager"]
    for _ in range(remaining):
        bid = random.choice(branch_ids)
        desig = random.choice(other_designations)
        assignments.append((bid, desig))

    random.shuffle(assignments)

    for i, (branch_id, designation) in enumerate(assignments, start=1):
        employee_id = f"EMP{i:04d}"
        gender = random.choice(["M", "F"])
        first, last = random_name(gender)

        email = f"{first.lower()}.{last.lower()}{i}@bankcorp.com"
        while email in used_emails:
            email = f"{first.lower()}.{last.lower()}{i}{random.randint(1,999)}@bankcorp.com"
        used_emails.add(email)

        phone = f"9{random.randint(100000000, 999999999)}"

        min_hire = date(2015, 1, 1)
        max_hire = TODAY - timedelta(days=180)
        hire_date = random_working_day(min_hire, max_hire)

        low, high = SALARY_RANGES[designation]
        salary = random.randint(low, high)

        records.append({
            "employee_id": employee_id,
            "branch_id": branch_id,
            "first_name": first,
            "last_name": last,
            "designation": designation,
            "email": email,
            "phone": phone,
            "hire_date": hire_date,
            "salary": salary,
        })

    return pd.DataFrame(records)



# STEP 3: CUSTOMERS


def generate_customers(n, branches_df):
    print(f"Generating {n} customers...")
    records = []
    used_emails = set()
    used_phones = set()

    branch_ids = branches_df["branch_id"].tolist()
    branch_cities = branches_df.set_index("branch_id")[["city", "state"]].to_dict("index")

    # weighted branch assignment so metro branches naturally get more customers
    branch_weights = []
    for bid in branch_ids:
        city = branch_cities[bid]["city"]
        w = next((c[2] for c in INDIAN_CITIES if c[0] == city), 3)
        branch_weights.append(w)

    for i in range(1, n + 1):
        customer_id = f"CUST{i:04d}"
        gender = random.choices(["M", "F", "O"], weights=[0.52, 0.47, 0.01])[0]
        first, last = random_name(gender)

        # age 18-75
        age = random.randint(18, 75)
        dob_year = TODAY.year - age
        dob = date(dob_year, random.randint(1, 12), random.randint(1, 28))

        email = f"{first.lower()}.{last.lower()}{i}@gmail.com"
        while email in used_emails:
            email = f"{first.lower()}.{last.lower()}{i}{random.randint(1,9999)}@gmail.com"
        used_emails.add(email)

        phone = f"9{random.randint(100000000, 999999999)}"
        while phone in used_phones:
            phone = f"9{random.randint(100000000, 999999999)}"
        used_phones.add(phone)

        branch_id = random.choices(branch_ids, weights=branch_weights, k=1)[0]
        city = branch_cities[branch_id]["city"]
        state = branch_cities[branch_id]["state"]
        address = f"{random.randint(1, 500)}, {random.choice(['Gandhi Nagar','Shivaji Road','Lake View','Park Street','Green Colony'])}, {city}"
        occupation = random.choice(OCCUPATIONS)

        # registration date: must be after they turned 18, and a working day, before today
        min_reg = max(date(dob_year + 18, 1, 1), date(2016, 1, 1))
        max_reg = TODAY - timedelta(days=30)
        if min_reg > max_reg:
            min_reg = max_reg - timedelta(days=365)
        registration_date = random_working_day(min_reg, max_reg)

        records.append({
            "customer_id": customer_id,
            "first_name": first,
            "last_name": last,
            "gender": gender,
            "dob": dob,
            "email": email,
            "phone": phone,
            "address": address,
            "city": city,
            "state": state,
            "occupation": occupation,
            "registration_date": registration_date,
            "branch_id": branch_id,
        })

    return pd.DataFrame(records)



# STEP 4: ACCOUNTS


def sample_balance():
    r = random.random()
    if r < 0.70:
        return round(random.uniform(5000, 50000), 2)
    elif r < 0.90:
        return round(random.uniform(50000, 200000), 2)
    elif r < 0.98:
        return round(random.uniform(200000, 2000000), 2)
    else:
        return round(random.uniform(2000000, 5000000), 2)


def generate_accounts(customers_df):
    print("Generating accounts...")
    records = []
    acc_counter = 1

    # decide accounts-per-customer: 80% -> 1, 15% -> 2, 5% -> 3
    n_customers = len(customers_df)
    counts = np.random.choice([1, 2, 3], size=n_customers, p=[0.80, 0.15, 0.05])

    for (_, cust), n_acc in zip(customers_df.iterrows(), counts):
        for _ in range(n_acc):
            account_id = f"ACC{acc_counter:05d}"
            acc_counter += 1

            account_type = random.choices(ACCOUNT_TYPES, weights=ACCOUNT_TYPE_WEIGHTS)[0]
            status = random.choices(ACCOUNT_STATUS, weights=ACCOUNT_STATUS_WEIGHTS)[0]
            balance = sample_balance()

            min_open = cust["registration_date"]
            max_open = TODAY - timedelta(days=10)
            if isinstance(min_open, str):
                min_open = dt.strptime(min_open, "%Y-%m-%d").date()
            if min_open >= max_open:
                min_open = max_open - timedelta(days=30)
            open_date = random_working_day(min_open, max_open)

            records.append({
                "account_id": account_id,
                "customer_id": cust["customer_id"],
                "branch_id": cust["branch_id"],
                "account_type": account_type,
                "balance": balance,
                "open_date": open_date,
                "status": status,
            })

    return pd.DataFrame(records)



# STEP 5: LOANS


def generate_loans(n, customers_df, accounts_df):
    print(f"Generating ~{n} loans...")
    records = []

    # only ~30% of customers get a loan
    eligible_customers = customers_df.sample(frac=0.30, random_state=SEED)
    # if more eligible than n, trim; if fewer, allow repeats (some customers 2 loans)
    cust_pool = eligible_customers["customer_id"].tolist()

    acc_open_by_cust = accounts_df.groupby("customer_id")["open_date"].min().to_dict()

    loan_i = 1
    attempts = 0
    while loan_i <= n and attempts < n * 5:
        attempts += 1
        cust_id = random.choice(cust_pool)
        cust_row = customers_df.loc[customers_df["customer_id"] == cust_id].iloc[0]

        if cust_id not in acc_open_by_cust:
            continue  # customer must have an account first

        loan_id = f"LOAN{loan_i:04d}"
        loan_type = random.choice(LOAN_TYPES)
        low_rate, high_rate = LOAN_INTEREST_RANGE[loan_type]
        interest_rate = round(random.uniform(low_rate, high_rate), 2)
        low_ten, high_ten = LOAN_TENURE_RANGE[loan_type]
        tenure_months = random.randint(low_ten, high_ten)

        loan_amount_map = {
            "Home": (1500000, 8000000), "Car": (300000, 1500000),
            "Personal": (50000, 500000), "Education": (200000, 2000000),
            "Business": (500000, 5000000),
        }
        low_amt, high_amt = loan_amount_map[loan_type]
        loan_amount = round(random.uniform(low_amt, high_amt), 2)

        loan_status = random.choices(LOAN_STATUS, weights=LOAN_STATUS_WEIGHTS)[0]

        min_issue = acc_open_by_cust[cust_id]
        if isinstance(min_issue, str):
            min_issue = dt.strptime(min_issue, "%Y-%m-%d").date()
        max_issue = TODAY - timedelta(days=5)
        if min_issue >= max_issue:
            min_issue = max_issue - timedelta(days=60)
        issue_date = random_working_day(min_issue, max_issue)

        records.append({
            "loan_id": loan_id,
            "customer_id": cust_id,
            "branch_id": cust_row["branch_id"],
            "loan_type": loan_type,
            "loan_amount": loan_amount,
            "interest_rate": interest_rate,
            "tenure_months": tenure_months,
            "issue_date": issue_date,
            "loan_status": loan_status,
        })
        loan_i += 1

    return pd.DataFrame(records)



# STEP 6: TRANSACTIONS  (transfers = two linked rows, same account_id column)


def random_time_between_9_and_18():
    hour = random.randint(9, 17)
    minute = random.randint(0, 59)
    second = random.randint(0, 59)
    return hour, minute, second


def generate_transactions(n, accounts_df):
    print(f"Generating ~{n} transactions...")
    records = []
    txn_counter = 1

    active_accounts = accounts_df[accounts_df["status"] != "Closed"].copy()
    account_ids = active_accounts["account_id"].tolist()
    open_dates = active_accounts.set_index("account_id")["open_date"].to_dict()

    # give each account a random "activity weight" so distribution isn't uniform
    activity_weights = np.random.exponential(scale=2.0, size=len(account_ids))
    activity_weights = activity_weights / activity_weights.sum()

    # running balance tracker (approximate, starting from generated balance)
    balances = active_accounts.set_index("account_id")["balance"].to_dict()

    n_transfers = int(n * 0.20)
    n_deposits = int(n * 0.45)
    n_withdrawals = n - n_transfers - n_deposits  # remainder ~35%

    def make_date_for_account(acc_id):
        min_d = open_dates[acc_id]
        if isinstance(min_d, str):
            min_d = dt.strptime(min_d, "%Y-%m-%d").date()
        max_d = TODAY - timedelta(days=1)
        span_start = max(min_d, max_d - timedelta(days=365))
        if span_start >= max_d:
            span_start = max_d - timedelta(days=30)
        return random_working_day(span_start, max_d)

    # ---- Deposits ----
    dep_accounts = np.random.choice(account_ids, size=n_deposits, p=activity_weights)
    for acc_id in dep_accounts:
        amount = round(random.uniform(500, 100000), 2)
        balances[acc_id] = balances.get(acc_id, 0) + amount
        d = make_date_for_account(acc_id)
        h, mi, s = random_time_between_9_and_18()
        records.append({
            "transaction_id": f"TXN{txn_counter:06d}",
            "account_id": acc_id,
            "transaction_type": "Deposit",
            "amount": amount,
            "payment_mode": random.choice(PAYMENT_MODES),
            "transaction_date": dt(d.year, d.month, d.day, h, mi, s),
            "remarks": random.choice(DEPOSIT_REMARKS),
        })
        txn_counter += 1

    # ---- Withdrawals ----
    wd_accounts = np.random.choice(account_ids, size=n_withdrawals, p=activity_weights)
    for acc_id in wd_accounts:
        current_balance = balances.get(acc_id, 10000)
        max_withdraw = max(500, min(current_balance * 0.5, 80000))
        if max_withdraw < 500:
            continue
        amount = round(random.uniform(500, max_withdraw), 2)
        balances[acc_id] = current_balance - amount
        d = make_date_for_account(acc_id)
        h, mi, s = random_time_between_9_and_18()
        records.append({
            "transaction_id": f"TXN{txn_counter:06d}",
            "account_id": acc_id,
            "transaction_type": "Withdrawal",
            "amount": amount,
            "payment_mode": random.choice(PAYMENT_MODES),
            "transaction_date": dt(d.year, d.month, d.day, h, mi, s),
            "remarks": random.choice(WITHDRAWAL_REMARKS),
        })
        txn_counter += 1

    # ---- Transfers: two linked rows per transfer (debit + credit), same account_id column ----
    n_transfer_events = n_transfers // 2
    for _ in range(n_transfer_events):
        sender, receiver = np.random.choice(account_ids, size=2, replace=False, p=activity_weights)
        sender_balance = balances.get(sender, 10000)
        max_transfer = max(500, min(sender_balance * 0.4, 50000))
        if max_transfer < 500:
            continue
        amount = round(random.uniform(500, max_transfer), 2)

        d = make_date_for_account(sender)
        h, mi, s = random_time_between_9_and_18()
        ts = dt(d.year, d.month, d.day, h, mi, s)
        remark = random.choice(TRANSFER_REMARKS)
        mode = random.choice(["UPI", "NEFT", "RTGS"])

        balances[sender] = sender_balance - amount
        balances[receiver] = balances.get(receiver, 10000) + amount

        # Row 1: Debit from sender
        records.append({
            "transaction_id": f"TXN{txn_counter:06d}",
            "account_id": sender,
            "transaction_type": "Transfer-Debit",
            "amount": -amount,
            "payment_mode": mode,
            "transaction_date": ts,
            "remarks": remark,
        })
        txn_counter += 1

        # Row 2: Credit to receiver (same timestamp, same remark = linked pair)
        records.append({
            "transaction_id": f"TXN{txn_counter:06d}",
            "account_id": receiver,
            "transaction_type": "Transfer-Credit",
            "amount": amount,
            "payment_mode": mode,
            "transaction_date": ts,
            "remarks": remark,
        })
        txn_counter += 1

    df = pd.DataFrame(records)
    df = df.sort_values("transaction_date").reset_index(drop=True)
    # renumber transaction_id after sorting for clean sequential IDs
    df["transaction_id"] = [f"TXN{i+1:06d}" for i in range(len(df))]
    return df, balances



# DELIBERATE EDGE CASES (guaranteed, not left to random chance)


def inject_edge_cases(customers_df, accounts_df, loans_df, transactions_df, final_balances):
    print("Injecting deliberate edge cases (VIPs, defaulters, dormant, low-balance)...")

    # --- 15 VIP customers: balance > 20,00,000 and 15+ transactions ---
    acct_by_cust = accounts_df.groupby("customer_id")["account_id"].apply(list).to_dict()
    eligible_custs = [c for c, accs in acct_by_cust.items() if len(accs) >= 1]
    vip_customers = random.sample(eligible_custs, min(15, len(eligible_custs)))

    for cust_id in vip_customers:
        acc_id = acct_by_cust[cust_id][0]
        accounts_df.loc[accounts_df["account_id"] == acc_id, "balance"] = round(
            random.uniform(2100000, 6000000), 2
        )
        accounts_df.loc[accounts_df["account_id"] == acc_id, "status"] = "Active"

        # ensure at least 15 transactions on this account
        existing_count = (transactions_df["account_id"] == acc_id).sum()
        needed = max(0, 15 - existing_count)
        open_date = accounts_df.loc[accounts_df["account_id"] == acc_id, "open_date"].iloc[0]
        if isinstance(open_date, str):
            open_date = dt.strptime(open_date, "%Y-%m-%d").date()
        extra_rows = []
        for _ in range(needed):
            d = random_working_day(open_date, TODAY - timedelta(days=1))
            h, mi, s = random_time_between_9_and_18()
            extra_rows.append({
                "transaction_id": "TEMP",
                "account_id": acc_id,
                "transaction_type": random.choice(["Deposit", "Withdrawal"]),
                "amount": round(random.uniform(10000, 200000), 2),
                "payment_mode": random.choice(PAYMENT_MODES),
                "transaction_date": dt(d.year, d.month, d.day, h, mi, s),
                "remarks": random.choice(DEPOSIT_REMARKS + WITHDRAWAL_REMARKS),
            })
        if extra_rows:
            transactions_df = pd.concat([transactions_df, pd.DataFrame(extra_rows)], ignore_index=True)

    # --- 10 guaranteed loan defaulters ---
    if len(loans_df) > 0:
        n_default = min(10, len(loans_df))
        default_idx = random.sample(list(loans_df.index), n_default)
        loans_df.loc[default_idx, "loan_status"] = "Defaulted"

    # --- 10 dormant accounts with zero transactions in the last 6 months ---
    non_vip_accounts = accounts_df[~accounts_df["account_id"].isin(
        [acct_by_cust[c][0] for c in vip_customers]
    )]
    dormant_pool = non_vip_accounts["account_id"].tolist()
    dormant_choices = random.sample(dormant_pool, min(10, len(dormant_pool)))

    six_months_ago = TODAY - timedelta(days=182)
    accounts_df.loc[accounts_df["account_id"].isin(dormant_choices), "status"] = "Dormant"
    # remove any recent transactions for these accounts (keep only older ones)
    mask_recent_dormant = (
        transactions_df["account_id"].isin(dormant_choices)
        & (transactions_df["transaction_date"] >= pd.Timestamp(six_months_ago))
    )
    transactions_df = transactions_df[~mask_recent_dormant].reset_index(drop=True)

    # --- 5 accounts with very low balance (< 500) ---
    remaining_pool = [a for a in accounts_df["account_id"].tolist() if a not in dormant_choices]
    low_balance_choices = random.sample(remaining_pool, min(5, len(remaining_pool)))
    for acc_id in low_balance_choices:
        accounts_df.loc[accounts_df["account_id"] == acc_id, "balance"] = round(random.uniform(10, 490), 2)

    # renumber transaction_id cleanly after edits
    transactions_df = transactions_df.sort_values("transaction_date").reset_index(drop=True)
    transactions_df["transaction_id"] = [f"TXN{i+1:06d}" for i in range(len(transactions_df))]

    return accounts_df, loans_df, transactions_df



# MAIN


def main():
    start_time = time.time()
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print("=" * 60)
    print("BANKING DATASET GENERATOR — starting")
    print("=" * 60)

    branches_df = generate_branches(N_BRANCHES)
    employees_df = generate_employees(N_EMPLOYEES, branches_df)
    customers_df = generate_customers(N_CUSTOMERS, branches_df)
    accounts_df = generate_accounts(customers_df)
    loans_df = generate_loans(N_LOANS, customers_df, accounts_df)
    transactions_df, _ = generate_transactions(N_TRANSACTIONS, accounts_df)

    accounts_df, loans_df, transactions_df = inject_edge_cases(
        customers_df, accounts_df, loans_df, transactions_df, {}
    )

    # ---- Save all CSVs ----
    print("\nSaving CSV files...")
    branches_df.to_csv(f"{OUTPUT_DIR}/branches.csv", index=False, encoding="utf-8")
    employees_df.to_csv(f"{OUTPUT_DIR}/employees.csv", index=False, encoding="utf-8")
    customers_df.to_csv(f"{OUTPUT_DIR}/customers.csv", index=False, encoding="utf-8")
    accounts_df.to_csv(f"{OUTPUT_DIR}/accounts.csv", index=False, encoding="utf-8")
    loans_df.to_csv(f"{OUTPUT_DIR}/loans.csv", index=False, encoding="utf-8")
    transactions_df.to_csv(f"{OUTPUT_DIR}/transactions.csv", index=False, encoding="utf-8")

    elapsed = time.time() - start_time

    print("\n" + "=" * 60)
    print("GENERATION COMPLETE")
    print("=" * 60)
    print(f"branches.csv      : {len(branches_df)} records")
    print(f"employees.csv     : {len(employees_df)} records")
    print(f"customers.csv     : {len(customers_df)} records")
    print(f"accounts.csv      : {len(accounts_df)} records")
    print(f"loans.csv         : {len(loans_df)} records")
    print(f"transactions.csv  : {len(transactions_df)} records")
    print(f"\nTotal execution time: {elapsed:.2f} seconds")
    print(f"All files saved to ./{OUTPUT_DIR}/")
    print("SUCCESS ✅")


if __name__ == "__main__":
    main()
