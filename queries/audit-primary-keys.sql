-- audit-primary-keys.sql
-- Finds all tables in the target database with no primary key defined
-- Run against: Aurora MySQL / MySQL 5.7+
-- Replace <database_name> with your actual schema name

SELECT
    t.table_name,
    t.table_rows,
    ROUND(t.data_length / 1024 / 1024, 2)  AS data_mb,
    ROUND(t.index_length / 1024 / 1024, 2) AS index_mb
FROM
    information_schema.tables t
LEFT JOIN
    information_schema.table_constraints tc
    ON  t.table_name   = tc.table_name
    AND t.table_schema = tc.table_schema
    AND tc.constraint_type = 'PRIMARY KEY'
WHERE
    t.table_schema = '<database_name>'
    AND t.table_type = 'BASE TABLE'
    AND tc.constraint_name IS NULL
ORDER BY
    t.data_length DESC;
