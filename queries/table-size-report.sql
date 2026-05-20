-- table-size-report.sql
-- Ranks all tables by size (rows + data) in the target database
-- Replace <database_name> with your actual schema name

SELECT
    table_name,
    table_rows                                          AS estimated_rows,
    ROUND(data_length  / 1024 / 1024, 2)               AS data_mb,
    ROUND(index_length / 1024 / 1024, 2)               AS index_mb,
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS total_mb,
    table_collation,
    create_time
FROM
    information_schema.tables
WHERE
    table_schema = '<database_name>'
    AND table_type = 'BASE TABLE'
ORDER BY
    (data_length + index_length) DESC;
