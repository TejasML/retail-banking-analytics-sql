-- PROCEDURE: deposit_money
-- Business use: standard way to deposit money into an account.
-- Simply inserts a Transaction row — the update_balance and
-- transaction_log triggers automatically handle the rest.


DELIMITER $$

CREATE PROCEDURE deposit_money (
    IN p_account_id VARCHAR(10),
    IN p_amount DECIMAL(15,2),
    IN p_payment_mode VARCHAR(20),
    IN p_remarks VARCHAR(100)
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_new_txn_id VARCHAR(10);

    -- Validate account exists and is not closed
    SELECT status INTO v_status
    FROM Account
    WHERE account_id = p_account_id;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Deposit failed: account does not exist.';
    ELSEIF v_status = 'Closed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Deposit failed: account is closed.';
    ELSEIF p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Deposit failed: amount must be positive.';
    ELSE
        -- Generate next transaction_id
        SELECT CONCAT('TXN', LPAD(
            (SELECT IFNULL(MAX(CAST(SUBSTRING(transaction_id, 4) AS UNSIGNED)), 0) + 1 FROM Transaction),
            6, '0'))
        INTO v_new_txn_id;

        INSERT INTO Transaction (transaction_id, account_id, transaction_type, amount, payment_mode, transaction_date, remarks)
        VALUES (v_new_txn_id, p_account_id, 'Deposit', p_amount, p_payment_mode, NOW(), p_remarks);

        SELECT CONCAT('Deposit successful. Transaction ID: ', v_new_txn_id) AS result;
    END IF;
END$$

DELIMITER ;