-- TRIGGER: update_balance
-- Fires AFTER any INSERT into Transaction.
-- Automatically adjusts the linked account's balance
-- based on the transaction type — no manual balance
-- update needed anywhere else in the system.


DELIMITER $$

CREATE TRIGGER trg_update_balance
AFTER INSERT ON Transaction
FOR EACH ROW
BEGIN
    IF NEW.transaction_type = 'Deposit' THEN
        UPDATE Account
        SET balance = balance + NEW.amount
        WHERE account_id = NEW.account_id;

    ELSEIF NEW.transaction_type = 'Withdrawal' THEN
        UPDATE Account
        SET balance = balance - NEW.amount
        WHERE account_id = NEW.account_id;

    ELSEIF NEW.transaction_type = 'Transfer-Debit' THEN
        -- amount is already stored as negative for debit rows
        UPDATE Account
        SET balance = balance + NEW.amount
        WHERE account_id = NEW.account_id;

    ELSEIF NEW.transaction_type = 'Transfer-Credit' THEN
        UPDATE Account
        SET balance = balance + NEW.amount
        WHERE account_id = NEW.account_id;
    END IF;
END$$

DELIMITER ;