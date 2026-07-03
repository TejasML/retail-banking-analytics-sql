-- TRIGGER: transaction_log
-- Fires AFTER any INSERT into Transaction.
-- Automatically records an audit entry — who/what/when —
-- without relying on the application code to remember to log it.


-- First, create the audit table this trigger writes into.
CREATE TABLE IF NOT EXISTS TransactionLog (
    log_id           INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id   VARCHAR(10) NOT NULL,
    account_id       VARCHAR(10) NOT NULL,
    transaction_type VARCHAR(20) NOT NULL,
    amount           DECIMAL(15,2) NOT NULL,
    logged_at        DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE TRIGGER trg_transaction_log
AFTER INSERT ON Transaction
FOR EACH ROW
BEGIN
    INSERT INTO TransactionLog (transaction_id, account_id, transaction_type, amount)
    VALUES (NEW.transaction_id, NEW.account_id, NEW.transaction_type, NEW.amount);
END$$

DELIMITER ;



INSERT INTO Transaction (transaction_id, account_id, transaction_type, amount, payment_mode, transaction_date, remarks)
VALUES ('TXNTEST01', 'ACC00001', 'Deposit', 5000, 'Cash', NOW(), 'Test deposit');

SELECT * FROM TransactionLog WHERE transaction_id = 'TXNTEST01'; 