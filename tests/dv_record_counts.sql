-- Test: dv_record_counts
-- Description: Проверка количества записей в хабах против источников
-- Проверяет, что количество записей в хабах соответствует количеству уникальных бизнес-ключей в источниках

-- Проверка hub_customer: количество записей должно совпадать с количеством уникальных клиентов в источнике
SELECT
    'hub_customer' AS test_table,
    (SELECT COUNT(*) FROM {{ ref('hub_customer') }}) AS hub_count,
    (SELECT COUNT(*) FROM {{ source('dbgen', 'customer') }}) AS source_count,
    ABS((SELECT COUNT(*) FROM {{ ref('hub_customer') }}) - (SELECT COUNT(*) FROM {{ source('dbgen', 'customer') }})) AS difference
HAVING assert(difference = 0, 'Customer count mismatch between hub_customer and source')

-- Проверка hub_order: количество записей должно совпадать с количеством уникальных заказов в источнике
SELECT
    'hub_order' AS test_table,
    (SELECT COUNT(*) FROM {{ ref('hub_order') }}) AS hub_count,
    (SELECT COUNT(*) FROM {{ source('dbgen', 'orders') }}) AS source_count,
    ABS((SELECT COUNT(*) FROM {{ ref('hub_order') }}) - (SELECT COUNT(*) FROM {{ source('dbgen', 'orders') }})) AS difference
HAVING assert(difference = 0, 'Order count mismatch between hub_order and source')

-- Проверка hub_part: количество записей должно совпадать с количеством уникальных деталей в источнике
SELECT
    'hub_part' AS test_table,
    (SELECT COUNT(*) FROM {{ ref('hub_part') }}) AS hub_count,
    (SELECT COUNT(*) FROM {{ source('dbgen', 'part') }}) AS source_count,
    ABS((SELECT COUNT(*) FROM {{ ref('hub_part') }}) - (SELECT COUNT(*) FROM {{ source('dbgen', 'part') }})) AS difference
HAVING assert(difference = 0, 'Part count mismatch between hub_part and source')

-- Проверка hub_supplier: количество записей должно совпадать с количеством уникальных поставщиков в источнике
SELECT
    'hub_supplier' AS test_table,
    (SELECT COUNT(*) FROM {{ ref('hub_supplier') }}) AS hub_count,
    (SELECT COUNT(*) FROM {{ source('dbgen', 'supplier') }}) AS source_count,
    ABS((SELECT COUNT(*) FROM {{ ref('hub_supplier') }}) - (SELECT COUNT(*) FROM {{ source('dbgen', 'supplier') }})) AS difference
HAVING assert(difference = 0, 'Supplier count mismatch between hub_supplier and source')
