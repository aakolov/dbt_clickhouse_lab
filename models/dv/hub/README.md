# Hubs Documentation

## Overview

Hubs store business keys and serve as the central point of integration for different systems. Each hub represents a core business entity.

## Available Hubs

### hub_customer

**Business Key**: `C_CUSTKEY`

**Description**: Customer identifier from the TPCH dataset.

**Fields**:
- `CUSTOMER_HK` - Hash key for unique identification
- `C_CUSTKEY` - Business key (customer ID)
- `LOAD_DATE` - Timestamp when data was loaded

### hub_order

**Business Key**: `O_ORDERKEY`

**Description**: Order identifier from the TPCH dataset.

**Fields**:
- `ORDER_HK` - Hash key for unique identification
- `O_ORDERKEY` - Business key (order ID)
- `LOAD_DATE` - Timestamp when data was loaded

### hub_part

**Business Key**: `L_PARTKEY`

**Description**: Part identifier from the TPCH dataset.

**Fields**:
- `PART_HK` - Hash key for unique identification
- `L_PARTKEY` - Business key (part ID)
- `LOAD_DATE` - Timestamp when data was loaded

### hub_supplier

**Business Key**: `L_SUPPKEY`

**Description**: Supplier identifier from the TPCH dataset.

**Fields**:
- `SUPPLIER_HK` - Hash key for unique identification
- `L_SUPPKEY` - Business key (supplier ID)
- `LOAD_DATE` - Timestamp when data was loaded

## Usage Examples

### Get all customers

```sql
SELECT * FROM {{ ref('hub_customer') }}
```

### Get customer by business key

```sql
SELECT * FROM {{ ref('hub_customer') }}
WHERE C_CUSTKEY = '12345'
```

### Check for duplicate business keys

```sql
SELECT C_CUSTKEY, COUNT(*) 
FROM {{ ref('hub_customer') }}
GROUP BY C_CUSTKEY 
HAVING COUNT(*) > 1
```

## Best Practices

1. **Unique Business Keys**: Ensure business keys are unique across source systems
2. **Hash Key Generation**: Use MD5 for hash key generation
3. **Load Date**: Always track when data was loaded for audit purposes
