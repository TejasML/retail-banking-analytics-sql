-- PROCEDURE: apply_loan
-- Business Use:
-- Provides a standardized way to process new loan applications for existing customers. 
-- The procedure verifies that the customer exists and has at least one active account before allowing a loan request.
-- It also validates the loan type against the supported loan categories,automatically generates a unique loan ID, records the current issue
-- date, and initializes the loan with an 'Active' status. 
-- These validations help maintain data integrity and ensure that loans are issued only to eligible customers.


DELIMITER $$

CREATE PROCEDURE apply_loan (
    IN p_customer_id VARCHAR(10),
    IN p_loan_type VARCHAR(30),
    IN p_loan_amount DECIMAL(15,2),
    IN p_interest_rate DECIMAL(5,2),
    IN p_tenure_months INT
)
BEGIN
    DECLARE v_customer_exists INT;
    DECLARE v_branch_id VARCHAR(10);
    DECLARE v_has_account INT;
    DECLARE v_new_loan_id VARCHAR(10);
    DECLARE v_next_num INT;

    -- Check customer exists and get their branch
    SELECT COUNT(*), MAX(branch_id) INTO v_customer_exists, v_branch_id
    FROM Customer WHERE customer_id = p_customer_id;

    -- Check customer has at least one account (required before a loan)
    SELECT COUNT(*) INTO v_has_account
    FROM Account WHERE customer_id = p_customer_id;

    IF v_customer_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Loan application failed: customer does not exist.';

    ELSEIF v_has_account = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Loan application failed: customer must have an active account first.';

    ELSEIF p_loan_type NOT IN ('Home', 'Car', 'Personal', 'Education', 'Business') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Loan application failed: invalid loan type.';

    ELSEIF p_loan_amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Loan application failed: loan amount must be positive.';

    ELSEIF p_interest_rate <= 0 OR p_interest_rate > 20 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Loan application failed: interest rate out of valid range.';

    ELSEIF p_tenure_months <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Loan application failed: tenure must be positive.';

    ELSE
        -- Generate next loan_id
        SELECT IFNULL(MAX(CAST(SUBSTRING(loan_id, 5) AS UNSIGNED)), 0) + 1
        INTO v_next_num
        FROM Loan
        WHERE loan_id REGEXP '^LOAN[0-9]+$';

        SET v_new_loan_id = CONCAT('LOAN', LPAD(v_next_num, 4, '0'));

        INSERT INTO Loan (loan_id, customer_id, branch_id, loan_type, loan_amount,
                           interest_rate, tenure_months, issue_date, loan_status)
        VALUES (v_new_loan_id, p_customer_id, v_branch_id, p_loan_type, p_loan_amount,
                p_interest_rate, p_tenure_months, CURDATE(), 'Active');

        SELECT CONCAT('Loan application successful. Loan ID: ', v_new_loan_id) AS result;
    END IF;
END$$

DELIMITER ;



-- Test Case 1: Apply for a valid loan (Expected: Success)
CALL apply_loan('CUST0001', 'Personal', 200000, 12.5, 36);

-- Verify that the loan record was created successfully
SELECT *
FROM Loan
WHERE customer_id = 'CUST0001'
ORDER BY issue_date DESC
LIMIT 1;

-- Test Case 2: Apply for a loan using a non-existent customer ID (Expected: Fail)
CALL apply_loan('CUST9999', 'Home', 500000, 8.5, 120);

-- Expected Result: Error - Customer does not exist.