# Source Lineage Documentation

## Overview

This document describes the data lineage from source systems to the final Data Marts. It helps understand how data flows through the warehouse and where transformations occur.

## Data Sources

### Primary Source: TPCH Dataset (S3)

**Location**: Yandex Cloud Storage

**Tables**:
- `orders` - Order headers with customer and order details
- `lineitem` - Order line items with product and shipping information
- `customer` - Customer information
- `part` - Part/product information
- `supplier` - Supplier information

## Lineage Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                    BI Layer (Tableau/Metabase)                      │
│                    Uses dbt Semantic Layer                          │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│              Semantic Layer (single source of truth)                │
│                    metrics.yml + semantic_models.yml                │
│  - Unified definitions                                              │
│  - Consistent naming                                                │
│  - Centralized documentation                                        │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│                      Data Mart Layer                                │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  f_orders_stats (aggregated, optimized for reporting)         │  │
│  │  f_orders_stats_dv (Data Vault-based view)                    │  │
│  │  f_lineorder_flat_dv (wide table)                             │  │
│  └───────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│                  Core Data Store (Data Vault 2.0)                   │
│  Hubs (business keys)                                               │
│  Links (relationships)                                              │
│  Satellites (history + attributes)                                  │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│                       Staging Layer (ODS)                           │
│  stg_orders, stg_customer, stg_part, stg_supplier, stg_lineitem    │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│                    Source Layer (S3 TPCH)                           │
│              src_orders, src_customer, src_lineitem, etc.           │
└─────────────────────────────────────────────────────────────────────┘
```

## Detailed Lineage

### Orders Flow

```
Source: orders (S3)
    ↓
    - Extract all order fields
    - Type casting
    ↓
Staging: stg_orders
    ↓
    - Transform to Data Vault format
    - Generate ORDER_HK
    ↓
DV Hub: hub_order
    ↓
    - Join with customer link
    ↓
DV Link: link_order_customer
    ↓
    - Join with customer satellite
    ↓
DV Satellite: sat_order_details
    ↓
    - Aggregate by year, status, priority
    ↓
Data Mart: f_orders_stats_dv
```

### Line Items Flow

```
Source: lineitem (S3)
    ↓
    - Extract all line item fields
    - Generate L_ITEMKEY surrogate key
    - Type casting
    ↓
Staging: stg_lineitem
    ↓
    - Generate ORDER_LINEITEM_HK
    - Join with order and part/supplier
    ↓
DV Link: link_order_lineitem
    ↓
    - Join with line item satellite
    ↓
DV Satellite: sat_lineitem_details
    ↓
    - Materialized view: mv_lineitem_enriched
    ↓
    - Semantic model: lineitem_details
    ↓
Data Mart: f_lineorder_flat_dv
```

### Customer Flow

```
Source: customer (S3)
    ↓
    - Extract all customer fields
    - Type casting
    ↓
Staging: stg_customer
    ↓
    - Generate CUSTOMER_HK
    ↓
DV Hub: hub_customer
    ↓
    - Join with order links
    ↓
DV Satellite: sat_customer_details
    ↓
    - Semantic model: customer_history
    ↓
Data Mart: f_orders_stats_dv (via link_order_customer)
```

## SQL Queries for Lineage Verification

### Check Orders Lineage

```sql
-- Verify staging to Data Vault transformation
SELECT 
    s.O_ORDERKEY,
    h.ORDER_HK,
    l.ORDER_HK AS LINK_ORDER_HK,
    sat.ORDER_HK AS SAT_ORDER_HK
FROM dbgen.orders s
LEFT JOIN hub_order h ON md5(toString(s.O_ORDERKEY)) = h.ORDER_HK
LEFT JOIN link_order_customer l ON h.ORDER_HK = l.ORDER_HK
LEFT JOIN sat_order_details sat ON h.ORDER_HK = sat.ORDER_HK
WHERE s.O_ORDERKEY = 100000
```

### Check Line Items Lineage

```sql
-- Verify lineitem transformation flow
SELECT 
    s.L_ORDERKEY,
    s.L_LINENUMBER,
    h.ORDER_LINEITEM_HK,
    sat.ORDER_LINEITEM_HK AS SAT_LINEITEM_HK
FROM dbgen.lineitem s
LEFT JOIN link_order_lineitem h ON 
    md5(toString(s.L_ORDERKEY) || '_' || toString(s.L_LINENUMBER)) = h.ORDER_LINEITEM_HK
LEFT JOIN sat_lineitem_details sat ON h.ORDER_LINEITEM_HK = sat.ORDER_LINEITEM_HK
WHERE s.L_ORDERKEY = 100000 AND s.L_LINENUMBER = 1
```

### Check Customer Lineage

```sql
-- Verify customer transformation flow
SELECT 
    s.C_CUSTKEY,
    h.CUSTOMER_HK,
    l.CUSTOMER_HK AS LINK_CUSTOMER_HK,
    sat.CUSTOMER_HK AS SAT_CUSTOMER_HK
FROM dbgen.customer s
LEFT JOIN hub_customer h ON md5(toString(s.C_CUSTKEY)) = h.CUSTOMER_HK
LEFT JOIN link_order_customer l ON h.CUSTOMER_HK = l.CUSTOMER_HK
LEFT JOIN sat_customer_details sat ON h.CUSTOMER_HK = sat.CUSTOMER_HK
WHERE s.C_CUSTKEY = 100000
```

## Data Quality Checks

### Verify Lineage Completeness

```sql
-- Check for missing Data Vault records
SELECT 
    'hub_order' AS component,
    COUNT(*) AS missing_count
FROM dbgen.orders s
LEFT JOIN hub_order h ON md5(toString(s.O_ORDERKEY)) = h.ORDER_HK
WHERE h.ORDER_HK IS NULL
```

### Verify Transformation Integrity

```sql
-- Check transformation integrity for orders
SELECT 
    COUNT(*) AS total_source,
    COUNT(h.ORDER_HK) AS transformed_count,
    COUNT(*) - COUNT(h.ORDER_HK) AS missing_count
FROM dbgen.orders s
LEFT JOIN hub_order h ON md5(toString(s.O_ORDERKEY)) = h.ORDER_HK
```
