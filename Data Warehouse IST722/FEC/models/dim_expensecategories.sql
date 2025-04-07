-- models/dim_expense_categories.sql

SELECT
    EXPENSECATEGORYCODE AS expense_category_code,
    EXPENSECATEGORYLABEL AS expense_category_label,
    EXPENSECATEGORYDESC AS expense_category_desc
FROM {{ source('STAGED', 'STA_EXPENSE_CATEGORIES') }}