-- find-duplicates.sql
-- Identifies duplicate rows in a given table using a GROUP BY pattern
-- Adapt the column list to match the table being audited
-- Replace <database_name> and <table_name> with actual values

-- Pattern 1: Find duplicate rows across all columns (small tables)
SELECT
    *,
    COUNT(*) AS duplicate_count
FROM
    <database_name>.<table_name>
GROUP BY
    -- List all columns here
    col1, col2, col3
HAVING
    COUNT(*) > 1
ORDER BY
    duplicate_count DESC;

-- Pattern 2: Count total duplicates in a table
SELECT
    COUNT(*) - COUNT(DISTINCT col1, col2, col3) AS duplicate_row_count,
    COUNT(*) AS total_rows,
    ROUND(
        (COUNT(*) - COUNT(DISTINCT col1, col2, col3)) / COUNT(*) * 100, 2
    ) AS duplicate_pct
FROM
    <database_name>.<table_name>;

-- Pattern 3: Safe deduplication — keep the row with the lowest id
DELETE FROM <database_name>.<table_name>
WHERE id NOT IN (
    SELECT MIN(id)
    FROM <database_name>.<table_name>
    GROUP BY col1, col2, col3
);
