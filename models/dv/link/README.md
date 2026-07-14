# Links Documentation

## Overview

Links represent business processes and connect hubs. Each link captures a relationship between two or more business entities.

## Available Links

### link_order_customer

**Hubs Connected**: `hub_order` ↔ `hub_customer`

**Description**: Captures the relationship between orders and customers (order placed by customer).

**Fields**:
- `ORDER_HK` - Hash key referencing `hub_order`
- `CUSTOMER_HK` - Hash key referencing `hub_customer`
- `LOAD_DATE` - Timestamp when data was loaded

**Business Logic**: Each order is placed by exactly one customer.

### link_order_lineitem

**Hubs Connected**: `hub_order` ↔ `hub_part` ↔ `hub_supplier`

**Description**: Captures the relationship between orders and line items.

**Fields**:
- `ORDER_HK` - Hash key referencing `hub_order`
- `ORDER_LINEITEM_HK` - Hash key for line item (composite of order key and line number)
- `LOAD_DATE` - Timestamp when data was loaded

**Business Logic**: Each order can have multiple line items, each containing a part and supplier information.

## Usage Examples

### Get all orders with customer information

```sql
SELECT
    o.ORDER_HK,
    c.CUSTOMER_HK,
    o.O_ORDERKEY,
    c.C_CUSTKEY
FROM {{ ref('link_order_customer') }} lc
JOIN {{ ref('hub_order') }} o ON lc.ORDER_HK = o.ORDER_HK
JOIN {{ ref('hub_customer') }} c ON lc.CUSTOMER_HK = c.CUSTOMER_HK
```

### Get order with all line items

```sql
SELECT
    o.O_ORDERKEY,
    l.L_ORDERKEY,
    l.L_LINENUMBER
FROM {{ ref('link_order_lineitem') }} ll
JOIN {{ ref('hub_order') }} o ON ll.ORDER_HK = o.ORDER_HK
```

### Check link integrity

```sql
SELECT *
FROM {{ ref('link_order_customer') }}
WHERE ORDER_HK NOT IN (SELECT ORDER_HK FROM {{ ref('hub_order') }})
   OR CUSTOMER_HK NOT IN (SELECT CUSTOMER_HK FROM {{ ref('hub_customer') }})
```

## Best Practices

1. **Referential Integrity**: Always verify that hub keys exist in their respective hubs
2. **Hash Key Uniqueness**: Ensure link hash keys are unique
3. **Loading Date**: Track when relationships were established
