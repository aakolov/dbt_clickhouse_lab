{{ config(
    materialized='view',
    tags=['semantic_view']
) }}

SELECT
    l.L_ORDERKEY,
    l.L_LINENUMBER,
    l.L_PARTKEY,
    l.L_SUPPKEY,
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
    l.L_ITEMKEY,
    o.O_ORDERDATE AS order_date_from_orders,
    o.O_ORDERSTATUS,
    o.O_ORDERPRIORITY,
    o.O_TOTALPRICE,
    o.O_CLERK,
    o.O_SHIPPRIORITY,
    o.O_COMMENT AS order_comment,
    c.C_CUSTKEY,
    c.C_NAME AS customer_name,
    c.C_MKTSEGMENT AS customer_segment,
    p.P_PARTKEY,
    p.P_NAME AS part_name,
    p.P_MFGR AS part_mfgr,
    p.P_BRAND AS part_brand,
    p.P_TYPE AS part_type,
    p.P_SIZE AS part_size,
    p.P_CONTAINER AS part_container,
    p.P_RETAILPRICE AS part_retailprice,
    s.S_SUPPKEY,
    s.S_NAME AS supplier_name,
    s.S_ADDRESS AS supplier_address,
    s.S_PHONE AS supplier_phone,
    s.S_ACCTBAL AS supplier_acctbal
FROM {{ ref('sat_lineitem_details') }} l
INNER JOIN {{ ref('link_order_lineitem') }} ll ON l.ORDER_LINEITEM_HK = ll.ORDER_LINEITEM_HK
INNER JOIN {{ ref('sat_order_details') }} o ON ll.ORDER_HK = o.ORDER_HK
INNER JOIN {{ ref('link_order_customer') }} oc ON ll.ORDER_HK = oc.ORDER_HK
INNER JOIN {{ ref('sat_customer_details') }} c ON oc.CUSTOMER_HK = c.CUSTOMER_HK
INNER JOIN {{ ref('sat_part_details') }} p ON ll.PART_HK = p.PART_HK
INNER JOIN {{ ref('sat_supplier_details') }} s ON ll.SUPPLIER_HK = s.SUPPLIER_HK
