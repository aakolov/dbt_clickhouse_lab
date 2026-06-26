-- Data Vault based view for backward compatibility with f_lineorder_flat
-- This view joins all DV tables to provide the same structure as the original star schema

{{ config(
    materialized='view'
) }}

SELECT
    -- Lineitem fields
    l.L_ORDERKEY * 100 + l.L_LINENUMBER AS L_ITEMKEY,
    l.L_ORDERKEY,
    l.L_PARTKEY,
    l.L_SUPPKEY,
    l.L_LINENUMBER,
    l.L_QUANTITY,
    l.L_EXTENDEDPRICE,
    l.L_DISCOUNT,
    l.L_TAX,
    l.L_RETURNFLAG,
    l.L_LINESTATUS,
    l.L_SHIPDATE,
    l.L_COMMITDATE,
    l.L_RECEIPTDATE,
    l.L_SHIPINSTRUCT,
    l.L_SHIPMODE,
    l.L_COMMENT,

    -- Order fields
    o.O_ORDERKEY,
    o.O_CUSTKEY,
    o.O_ORDERSTATUS,
    o.O_TOTALPRICE,
    o.O_ORDERDATE,
    o.O_ORDERPRIORITY,
    o.O_CLERK,
    o.O_SHIPPRIORITY,
    o.O_COMMENT,

    -- Customer fields
    c.C_CUSTKEY,
    c.C_NAME,
    c.C_ADDRESS,
    c.C_NATIONKEY,
    c.C_PHONE,
    c.C_ACCTBAL,
    c.C_MKTSEGMENT,
    c.C_COMMENT,

    -- Supplier fields
    s.S_SUPPKEY,
    s.S_NAME,
    s.S_ADDRESS,
    s.S_NATIONKEY,
    s.S_PHONE,
    s.S_ACCTBAL,
    s.S_COMMENT,

    -- Part fields
    p.P_PARTKEY,
    p.P_NAME,
    p.P_MFGR,
    p.P_BRAND,
    p.P_TYPE,
    p.P_SIZE,
    p.P_CONTAINER,
    p.P_RETAILPRICE,
    p.P_COMMENT

FROM {{ ref('sat_lineitem_details') }} l
INNER JOIN {{ ref('link_order_lineitem') }} ll ON l.ORDER_LINEITEM_HK = ll.ORDER_LINEITEM_HK
INNER JOIN {{ ref('sat_order_details') }} o ON ll.ORDER_HK = o.ORDER_HK
INNER JOIN {{ ref('link_order_customer') }} oc ON ll.ORDER_HK = oc.ORDER_HK
INNER JOIN {{ ref('sat_customer_details') }} c ON oc.CUSTOMER_HK = c.CUSTOMER_HK
INNER JOIN {{ ref('sat_supplier_details') }} s ON ll.SUPPLIER_HK = s.SUPPLIER_HK
INNER JOIN {{ ref('sat_part_details') }} p ON ll.PART_HK = p.PART_HK
