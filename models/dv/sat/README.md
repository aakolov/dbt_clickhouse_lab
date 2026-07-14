# Satellites Documentation

## Overview

Satellites store descriptive attributes with history tracking. Each satellite is associated with a hub or link and captures the changing attributes of the business entity over time.

## Available Satellites

### sat_customer_details

**Associated Hub**: `hub_customer`

**Description**: Customer attributes with history tracking.

**Fields**:
- `CUSTOMER_HK` - Hash key referencing `hub_customer`
- `LOAD_DATE` - Timestamp when data was loaded
- `C_CUSTKEY` - Customer ID
- `C_NAME` - Customer name
- `C_ADDRESS` - Customer address
- `C_NATIONKEY` - Nation key
- `C_PHONE` - Phone number
- `C_ACCTBAL` - Account balance
- `C_MKTSEGMENT` - Market segment
- `C_COMMENT` - Comments
- `EFFECTIVE_FROM` - Start date of record validity
- `EFFECTIVE_TO` - End date of record validity
- `IS_CURRENT` - Flag indicating current record (1/0)
- `HASHDIFF` - Hash of attributes for change detection

### sat_order_details

**Associated Hub**: `hub_order`

**Description**: Order attributes with history tracking.

**Fields**:
- `ORDER_HK` - Hash key referencing `hub_order`
- `LOAD_DATE` - Timestamp when data was loaded
- `O_ORDERKEY` - Order ID
- `O_CUSTKEY` - Customer ID
- `O_ORDERSTATUS` - Order status
- `O_TOTALPRICE` - Total price
- `O_ORDERDATE` - Order date
- `O_ORDERPRIORITY` - Order priority
- `O_CLERK` - Clerk ID
- `O_SHIPPRIORITY` - Shipping priority
- `O_COMMENT` - Comments
- `EFFECTIVE_FROM` - Start date of record validity
- `EFFECTIVE_TO` - End date of record validity
- `IS_CURRENT` - Flag indicating current record (1/0)
- `HASHDIFF` - Hash of attributes for change detection

### sat_lineitem_details

**Associated Link**: `link_order_lineitem`

**Description**: Line item attributes with history tracking.

**Fields**:
- `ORDER_LINEITEM_HK` - Hash key referencing `link_order_lineitem`
- `LOAD_DATE` - Timestamp when data was loaded
- `L_ORDERKEY` - Order ID
- `L_PARTKEY` - Part ID
- `L_SUPPKEY` - Supplier ID
- `L_LINENUMBER` - Line number
- `L_QUANTITY` - Quantity
- `L_EXTENDEDPRICE` - Extended price
- `L_DISCOUNT` - Discount
- `L_TAX` - Tax
- `L_RETURNFLAG` - Return flag
- `L_LINESTATUS` - Line status
- `L_SHIPDATE` - Ship date
- `L_COMMITDATE` - Commit date
- `L_RECEIPTDATE` - Receipt date
- `L_SHIPINSTRUCT` - Ship instruction
- `L_SHIPMODE` - Ship mode
- `L_COMMENT` - Comments
- `EFFECTIVE_FROM` - Start date of record validity
- `EFFECTIVE_TO` - End date of record validity
- `IS_CURRENT` - Flag indicating current record (1/0)
- `HASHDIFF` - Hash of attributes for change detection

### sat_part_details

**Associated Hub**: `hub_part`

**Description**: Part attributes with history tracking.

**Fields**:
- `PART_HK` - Hash key referencing `hub_part`
- `LOAD_DATE` - Timestamp when data was loaded
- Part attributes (name, type, size, etc.)
- `EFFECTIVE_FROM` - Start date of record validity
- `EFFECTIVE_TO` - End date of record validity
- `IS_CURRENT` - Flag indicating current record (1/0)
- `HASHDIFF` - Hash of attributes for change detection

### sat_supplier_details

**Associated Hub**: `hub_supplier`

**Description**: Supplier attributes with history tracking.

**Fields**:
- `SUPPLIER_HK` - Hash key referencing `hub_supplier`
- `LOAD_DATE` - Timestamp when data was loaded
- Supplier attributes (name, address, phone, etc.)
- `EFFECTIVE_FROM` - Start date of record validity
- `EFFECTIVE_TO` - End date of record validity
- `IS_CURRENT` - Flag indicating current record (1/0)
- `HASHDIFF` - Hash of attributes for change detection

## SCD Type 2 Support

Satellites support Slowly Changing Dimension Type 2:

- **EFFECTIVE_FROM**: Start date of record validity
- **EFFECTIVE_TO**: End date of record validity
- **IS_CURRENT**: Flag indicating current record (1/0)

## Usage Examples

### Get current customer information

```sql
SELECT * FROM {{ ref('sat_customer_details') }}
WHERE CUSTOMER_ID = '12345'
  AND IS_CURRENT = 1
```

### Get history of customer changes

```sql
SELECT
    CUSTOMER_ID,
    C_NAME,
    C_ADDRESS,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    HASHDIFF
FROM {{ ref('sat_customer_details') }}
WHERE CUSTOMER_ID = '12345'
ORDER BY EFFECTIVE_FROM
```

### Get order with all attributes at a specific point in time

```sql
SELECT * FROM {{ ref('sat_order_details') }}
WHERE ORDER_HK = 'hash_value'
  AND EFFECTIVE_FROM <= '2023-01-01'
  AND EFFECTIVE_TO > '2023-01-01'
```

## Best Practices

1. **History Tracking**: Always track effective dates for accurate history
2. **Hashdiff Validation**: Regularly validate hashdiff for data integrity
3. **Current Flag**: Maintain IS_CURRENT flag for easy filtering
