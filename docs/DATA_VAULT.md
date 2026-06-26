# Data Vault 2.0 Implementation

## Overview

This document describes the Data Vault 2.0 implementation for the dbt-clickhouse project. Data Vault is a methodology for building enterprise data warehouses that emphasizes flexibility, scalability, and auditability.

## Architecture

### Core Components

Data Vault 2.0 consists of three main components:

1. **Hubs** - Store business keys and serve as the central point of integration
2. **Links** - Represent relationships between hubs (business processes)
3. **Satellites** - Store descriptive attributes with history tracking

### Hubs

Hubs contain business keys and serve as the integration point for different systems.

| Hub | Business Key | Description |
|-----|--------------|-------------|
| `hub_customer` | `CUSTOMER_ID` | Customer identifier |
| `hub_order` | `ORDER_ID` | Order identifier |
| `hub_part` | `PART_ID` | Part identifier |
| `hub_supplier` | `SUPPLIER_ID` | Supplier identifier |

### Links

Links represent business processes and connect hubs.

| Link | Hubs Connected | Description |
|------|---------------|-------------|
| `link_order_customer` | `hub_order` ↔ `hub_customer` | Order placed by customer |
| `link_order_lineitem` | `hub_order` ↔ `hub_part` ↔ `hub_supplier` | Order line items |

### Satellites

Satellites store descriptive attributes with history tracking.

| Satellite | Hub | Description |
|-----------|-----|-------------|
| `sat_customer_details` | `hub_customer` | Customer attributes (name, address, phone, etc.) |
| `sat_order_details` | `hub_order` | Order attributes (status, price, date, etc.) |
| `sat_lineitem_details` | `link_order_lineitem` | Line item attributes (quantity, price, dates, etc.) |
| `sat_part_details` | `hub_part` | Part attributes (name, type, size, etc.) |
| `sat_supplier_details` | `hub_supplier` | Supplier attributes (name, address, phone, etc.) |

## Implementation Details

### Hash Keys

Data Vault uses hash keys for unique identification:

- **Hub Hash Key (HK)**: `MD5(business_key)`
- **Link Hash Key (HK)**: `MD5(hub1_hk || '-' || hub2_hk || ...)`
- **Satellite Hash Key (HK)**: Same as associated link or hub
- **Hashdiff**: `MD5(attribute1 || attribute2 || ...)` for change detection

### Loading Process

Each Data Vault model includes:

- `LOAD_DATE`: Timestamp when data was loaded
- `SOURCE`: Indicator of data source ('TPCH')
- `HASHDIFF`: Hash of attributes for change detection

### ClickHouse Optimizations

The implementation uses ClickHouse-specific optimizations:

- `MergeTree()` engine for efficient storage
- `order_by` on hash keys and load dates
- `partition_by` on year of load date
- Appropriate data types (UInt32, String, Decimal)

## Usage

### Basic Queries

#### Get all orders with customer information

```sql
SELECT
    o.ORDER_ID,
    c.CUSTOMER_ID,
    c.C_NAME,
    o.O_ORDERDATE,
    o.O_TOTALPRICE
FROM {{ ref('hub_order') }} o
JOIN {{ ref('link_order_customer') }} oc ON o.ORDER_HK = oc.ORDER_HK
JOIN {{ ref('hub_customer') }} c ON oc.CUSTOMER_HK = c.CUSTOMER_HK
```

#### Get history of customer changes

```sql
SELECT
    CUSTOMER_ID,
    C_NAME,
    C_ADDRESS,
    LOAD_DATE,
    HASHDIFF
FROM {{ ref('sat_customer_details') }}
WHERE CUSTOMER_ID = '12345'
ORDER BY LOAD_DATE
```

#### Get order with all line items

```sql
SELECT
    o.ORDER_ID,
    l.L_ORDERKEY,
    l.L_PARTKEY,
    l.L_QUANTITY,
    l.L_EXTENDEDPRICE
FROM {{ ref('hub_order') }} o
JOIN {{ ref('link_order_lineitem') }} ll ON o.ORDER_HK = ll.ORDER_HK
JOIN {{ ref('sat_lineitem_details') }} l ON ll.ORDER_LINEITEM_HK = l.ORDER_LINEITEM_HK
WHERE o.ORDER_ID = '100000'
```

### dbt Commands

#### Run all Data Vault models

```bash
dbt run -s tag:datavault
```

#### Run specific hub

```bash
dbt run --models hub_customer
```

#### Run all satellites

```bash
dbt run --models 'tag:satellite'
```

## Backward Compatibility

The implementation includes views for backward compatibility with existing star schema models:

| Data Vault View | Original Model | Description |
|-----------------|----------------|-------------|
| `f_lineorder_flat_dv` | `f_lineorder_flat` | Wide table for reporting |
| `f_orders_stats_dv` | `f_orders_stats` | Aggregated statistics |

### Using Backward Compatible Views

```bash
# Query the Data Vault-based view
SELECT * FROM {{ ref('f_lineorder_flat_dv') }}

# Run tests on the Data Vault model
dbt test -s f_orders_stats_dv
```

## Benefits

### Flexibility

- Add new attributes without changing core structure
- Support multiple source systems
- Handle schema changes gracefully

### Scalability

- Independent loading of hubs, links, and satellites
- Efficient partitioning for large datasets
- Easy to parallelize ETL processes

### Auditability

- Complete history of all changes
- Clear lineage from source to target
- Hash-based integrity checks

## Trade-offs

### Complexity

- More tables to manage
- More complex queries for simple reports
- Learning curve for team members

### Performance

- More JOINs required for reporting
- May require materialized views for performance
- Larger storage footprint due to history

## Migration Guide

### Phase 1: Setup

1. Review Data Vault architecture
2. Understand business keys and relationships
3. Plan migration order

### Phase 2: Implementation

1. Implement hubs (independent of other components)
2. Implement links (require hubs)
3. Implement satellites (require hubs/links)

### Phase 3: Validation

1. Validate hash key uniqueness
2. Validate link relationships
3. Validate satellite history

### Phase 4: Migration

1. Create backward compatible views
2. Update reports to use new structure
3. Monitor performance

## Best Practices

### Naming Conventions

- Hubs: `hub_<entity>`
- Links: `link_<relationship>`
- Satellites: `sat_<entity>_<description>`

### Performance

- Use appropriate partitioning
- Consider materialized views for reporting
- Monitor query performance

### Maintenance

- Regular hash key validation
- Monitor satellite growth
- Archive old data when appropriate

## Troubleshooting

### Common Issues

1. **Duplicate hash keys**: Check business key uniqueness
2. **Missing links**: Verify hub references
3. **Performance issues**: Add appropriate indexes

### Debugging

```sql
-- Check for duplicate business keys
SELECT CUSTOMER_ID, COUNT(*) 
FROM {{ ref('hub_customer') }}
GROUP BY CUSTOMER_ID 
HAVING COUNT(*) > 1

-- Check link integrity
SELECT *
FROM {{ ref('link_order_customer') }}
WHERE ORDER_HK NOT IN (SELECT ORDER_HK FROM {{ ref('hub_order') }})
```

## References

- [Data Vault 2.0 Methodology](https://www.datavault.net/)
- [dbt Documentation](https://docs.getdbt.com/)
- [ClickHouse Documentation](https://clickhouse.com/docs/)
