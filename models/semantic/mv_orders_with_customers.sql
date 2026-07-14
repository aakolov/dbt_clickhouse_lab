{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by=['O_ORDERKEY'],
    partition_by='toYear(O_ORDERDATE)'
) }}

SELECT
    o.O_ORDERKEY,
    o.O_CUSTKEY,
    o.O_ORDERSTATUS,
    o.O_TOTALPRICE,
    o.O_ORDERDATE,
    o.O_ORDERPRIORITY,
    o.O_CLERK,
    o.O_SHIPPRIORITY,
    o.O_COMMENT,
    c.C_CUSTKEY,
    c.C_NAME AS customer_name,
    c.C_ADDRESS AS customer_address,
    c.C_NATIONKEY AS customer_nationkey,
    c.C_PHONE AS customer_phone,
    c.C_ACCTBAL AS customer_acctbal,
    c.C_MKTSEGMENT AS customer_segment,
    c.C_COMMENT AS customer_comment
FROM {{ ref('sat_order_details') }} o
INNER JOIN {{ ref('link_order_customer') }} oc ON o.ORDER_HK = oc.ORDER_HK
INNER JOIN {{ ref('sat_customer_details') }} c ON oc.CUSTOMER_HK = c.CUSTOMER_HK
