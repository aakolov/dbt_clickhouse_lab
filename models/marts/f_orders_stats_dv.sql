-- Data Vault based materialized table for backward compatibility with f_orders_stats
-- This table aggregates data by order year, status, and priority

{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by=['O_ORDERYEAR', 'O_ORDERSTATUS', 'O_ORDERPRIORITY'],
    partition_by='toYear(O_ORDERYEAR)'
) }}

SELECT
    toYear(o.O_ORDERDATE) AS O_ORDERYEAR,
    o.O_ORDERSTATUS,
    o.O_ORDERPRIORITY,
    COUNT(DISTINCT o.O_ORDERKEY) AS num_orders,
    COUNT(DISTINCT c.C_CUSTKEY) AS num_customers,
    SUM(l.L_EXTENDEDPRICE * (1 - l.L_DISCOUNT)) AS revenue
FROM {{ ref('sat_order_details') }} o
INNER JOIN {{ ref('link_order_customer') }} oc ON o.ORDER_HK = oc.ORDER_HK
INNER JOIN {{ ref('sat_customer_details') }} c ON oc.CUSTOMER_HK = c.CUSTOMER_HK
INNER JOIN {{ ref('link_order_lineitem') }} ll ON o.ORDER_HK = ll.ORDER_HK
INNER JOIN {{ ref('sat_lineitem_details') }} l ON ll.ORDER_LINEITEM_HK = l.ORDER_LINEITEM_HK
GROUP BY
    toYear(o.O_ORDERDATE),
    o.O_ORDERSTATUS,
    o.O_ORDERPRIORITY
