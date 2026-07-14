{{
    config(
        engine='MergeTree()',
        order_by=['order_year', 'order_status', 'order_priority'],
        partition_by='toYear(order_year)'
    )
}}

SELECT
    toYear(o.O_ORDERDATE) AS order_year,
    o.O_ORDERSTATUS AS order_status,
    o.O_ORDERPRIORITY AS order_priority,
    COUNT(DISTINCT o.ORDER_HK) AS num_orders,
    COUNT(DISTINCT oc.CUSTOMER_HK) AS num_customers,
    SUM(l.L_EXTENDEDPRICE * (1 - l.L_DISCOUNT)) AS revenue
FROM {{ ref('sat_order_details') }} o
JOIN {{ ref('link_order_customer') }} oc ON o.ORDER_HK = oc.ORDER_HK
JOIN {{ ref('sat_customer_details') }} c ON oc.CUSTOMER_HK = c.CUSTOMER_HK
JOIN {{ ref('link_order_lineitem') }} ll ON o.ORDER_HK = ll.ORDER_HK
JOIN {{ ref('sat_lineitem_details') }} l ON ll.ORDER_LINEITEM_HK = l.ORDER_LINEITEM_HK
GROUP BY
    toYear(o.O_ORDERDATE),
    o.O_ORDERSTATUS,
    o.O_ORDERPRIORITY
