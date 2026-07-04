-- This report shows the loan default rate for each branch.
-- It displays how many loans have defaulted and what
-- percentage they make up out of all loans issued by the
-- branch. A high default rate may indicate poor lending,
-- local financial problems, or delayed loan repayments.

SELECT
    branch_id,
    COUNT(*)                                              AS total_loans,
    COUNT(CASE WHEN loan_status = 'Defaulted' THEN 1 END) AS defaulted_loans,
    ROUND(
        COUNT(CASE WHEN loan_status = 'Defaulted' THEN 1 END) / COUNT(*) * 100
    , 2)                                                   AS default_rate_percent
FROM Loan
GROUP BY branch_id
ORDER BY default_rate_percent DESC;
