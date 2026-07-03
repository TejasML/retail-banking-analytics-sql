-- TRIGGER: prevent_negative_balance
-- Fires BEFORE any UPDATE on Account.
-- Blocks the update if it would push balance below zero.
-- This is a safety net that works no matter which procedure or manual query tries to modify the balance.


DELIMITER $$

CREATE TRIGGER trg_prevent_negative_balance
BEFORE UPDATE ON Account
FOR EACH ROW
BEGIN
    IF NEW.balance < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transaction blocked: balance cannot go negative.';
    END IF;
END$$

DELIMITER ;



UPDATE Account SET balance = -100 WHERE account_id = 'ACC00001';