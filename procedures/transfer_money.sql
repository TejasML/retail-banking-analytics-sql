-- PROCEDURE: transfer_money
-- Business use: move money from one account to another.
-- Validates both accounts and sufficient balance, then inserts
-- TWO linked transaction rows (Transfer-Debit on sender,
-- Transfer-Credit on receiver) — matching the same pattern
-- used in the synthetic dataset. Triggers handle balance
-- updates and audit logging automatically for both rows.

DELIMITER $$

CREATE PROCEDURE transfer_money (
    IN p_from_account VARCHAR(10),
    IN p_to_account VARCHAR(10),
    IN p_amount DECIMAL(15,2),
    IN p_payment_mode VARCHAR(20),
    IN p_remarks VARCHAR(100)
)
BEGIN
    DECLARE v_from_status VARCHAR(20);
    DECLARE v_to_status VARCHAR(20);
    DECLARE v_from_balance DECIMAL(15,2);
    DECLARE v_debit_txn_id VARCHAR(10);
    DECLARE v_credit_txn_id VARCHAR(10);
    DECLARE v_next_num INT;

    -- Validate sender account
    SELECT status, balance INTO v_from_status, v_from_balance
    FROM Account WHERE account_id = p_from_account;

    -- Validate receiver account
    SELECT status INTO v_to_status
    FROM Account WHERE account_id = p_to_account;

    IF p_from_account = p_to_account THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer failed: sender and receiver accounts must be different.';

    ELSEIF v_from_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer failed: sender account does not exist.';

    ELSEIF v_to_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer failed: receiver account does not exist.';

    ELSEIF v_from_status = 'Closed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer failed: sender account is closed.';

    ELSEIF v_to_status = 'Closed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer failed: receiver account is closed.';

    ELSEIF p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer failed: amount must be positive.';

    ELSEIF p_amount > v_from_balance THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer failed: insufficient balance.';

    ELSE
        -- Generate the next available transaction number (numeric IDs only)
        SELECT IFNULL(MAX(CAST(SUBSTRING(transaction_id, 4) AS UNSIGNED)), 0) + 1
        INTO v_next_num
        FROM Transaction
        WHERE transaction_id REGEXP '^TXN[0-9]+$';

        SET v_debit_txn_id = CONCAT('TXN', LPAD(v_next_num, 6, '0'));
        SET v_credit_txn_id = CONCAT('TXN', LPAD(v_next_num + 1, 6, '0'));

        -- Row 1: Debit from sender
        INSERT INTO Transaction (transaction_id, account_id, transaction_type, amount, payment_mode, transaction_date, remarks)
        VALUES (v_debit_txn_id, p_from_account, 'Transfer-Debit', -p_amount, p_payment_mode, NOW(), p_remarks);

        -- Row 2: Credit to receiver
        INSERT INTO Transaction (transaction_id, account_id, transaction_type, amount, payment_mode, transaction_date, remarks)
        VALUES (v_credit_txn_id, p_to_account, 'Transfer-Credit', p_amount, p_payment_mode, NOW(), p_remarks);

        SELECT CONCAT('Transfer successful. Debit ID: ', v_debit_txn_id, ', Credit ID: ', v_credit_txn_id) AS result;
    END IF;
END$$

DELIMITER ;



SELECT account_id, balance FROM Account WHERE account_id IN ('ACC00001', 'ACC00002');

CALL transfer_money('ACC00001', 'ACC00002', 1500, 'UPI', 'Test transfer');

SELECT account_id, balance FROM Account WHERE account_id IN ('ACC00001', 'ACC00002');
-- ACC00001 should be 1050 lower, ACC00002 should be 1500 higher

-- Test the safety checks
-- Test Case 1: Transfer to the same account (Expected: Fail)
CALL transfer_money('ACC00001', 'ACC00001', 100, 'UPI', 'Same account transfer test');
-- Expected Result: Error - Source and destination accounts cannot be the same.

-- Test Case 2: Transfer amount exceeds available balance (Expected: Fail)
CALL transfer_money('ACC00001', 'ACC00002', 999999999, 'UPI', 'Insufficient balance test');
-- Expected Result: Error - Insufficient account balance to complete the transaction.
