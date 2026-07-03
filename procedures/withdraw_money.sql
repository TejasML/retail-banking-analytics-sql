-- PROCEDURE: withdraw_money
-- Business use: standard way to withdraw money from an account.
-- Validates account status and sufficient balance before allowing
-- the transaction. Inserts a Transaction row — the update_balance
-- and transaction_log triggers automatically handle the rest.
-- prevent_negative_balance trigger acts as a final safety net.

DELIMITER $$

CREATE PROCEDURE withdraw_money (
    IN p_account_id VARCHAR(10),
    IN p_amount DECIMAL(15,2),
    IN p_payment_mode VARCHAR(20),
    IN p_remarks VARCHAR(100)
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_balance DECIMAL(15,2);
    DECLARE v_new_txn_id VARCHAR(10);

    -- Validate account exists, get status and current balance
    SELECT status, balance INTO v_status, v_balance
    FROM Account
    WHERE account_id = p_account_id;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Withdrawal failed: account does not exist.';
    ELSEIF v_status = 'Closed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Withdrawal failed: account is closed.';
    ELSEIF p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Withdrawal failed: amount must be positive.';
    ELSEIF p_amount > v_balance THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Withdrawal failed: insufficient balance.';
    ELSE
        -- Generate next transaction_id (only considers properly formatted TXN###### IDs)
        SELECT CONCAT('TXN', LPAD(
            (SELECT IFNULL(MAX(CAST(SUBSTRING(transaction_id, 4) AS UNSIGNED)), 0) + 1
             FROM Transaction
             WHERE transaction_id REGEXP '^TXN[0-9]+$'),
            6, '0'))
        INTO v_new_txn_id;

        INSERT INTO Transaction (transaction_id, account_id, transaction_type, amount, payment_mode, transaction_date, remarks)
        VALUES (v_new_txn_id, p_account_id, 'Withdrawal', p_amount, p_payment_mode, NOW(), p_remarks);

        SELECT CONCAT('Withdrawal successful. Transaction ID: ', v_new_txn_id) AS result;
    END IF;
END$$

DELIMITER ;


SELECT balance FROM Account WHERE account_id = 'ACC00001';

CALL withdraw_money('ACC00001', 500, 'Cash', 'Test withdrawal');

SELECT balance FROM Account WHERE account_id = 'ACC00001';
-- Reduce the  500 balance

-- test the safety check 
CALL withdraw_money('ACC00001', 4972135445459, 'Cash', 'fail withdrawal');


