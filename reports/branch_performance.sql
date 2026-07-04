-- This report shows the number of customers, total deposits,
-- and total loan amount for each branch.

SELECT *
FROM vw_branch_summary
ORDER BY total_deposits DESC;
 
