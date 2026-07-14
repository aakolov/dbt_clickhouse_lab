# Data Vault 2.0 Implementation

## Overview

This document describes the Data Vault 2.0 implementation for the dbt-clickhouse project. Data Vault is a methodology for building enterprise data warehouses that emphasizes flexibility, scalability, and auditability.

The implementation is part of a unified architecture with the dbt Semantic Layer for BI tools.

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
| `hub_customer` | `C_CUSTKEY` | Customer identifier |
| `hub_order` | `O_ORDERKEY` | Order identifier |
| `hub_part` | `L_PARTKEY` | Part identifier |
| `hub_supplier` | `L_SUPPKEY` | Supplier identifier |

### Links

Links represent business processes and connect hubs.

| Link | Hubs Connected | Description |
|------|---------------|-------------|
| `link_order_customer` | `hub_order` ↔ `hub_customer` | Order placed by customer |
| `link_order_lineitem` | `hub_order` ↔ `hub_part` ↔ `hub_supplier` | Order line items |

### Satellites

Satellites store descriptive attributes with history tracking.

| Satellite | Hub/Link | Description |
|-----------|----------|-------------|
| `sat_customer_details` | `hub_customer` | Customer attributes (name, address, phone, segment, etc.) |
| `sat_order_details` | `hub_order` | Order attributes (status, price, date, priority, etc.) |
| `sat_lineitem_details` | `link_order_lineitem` | Line item attributes (quantity, price, dates, etc.) |
| `sat_part_details` | `hub_part` | Part attributes (name, type, size, etc.) |
| `sat_supplier_details` | `hub_supplier` | Supplier attributes (name, address, phone, etc.) |

## Semantic Layer Integration

The Data Vault layer serves as the foundation for the dbt Semantic Layer:

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
│                        Staging Layer                                │
│  stg_orders, stg_customer, stg_part, stg_supplier, stg_lineitem    │
└─────────────────────────────────────────────────────────────────────┘
```

### Semantic Models

The semantic layer is built on top of Data Vault satellites:

| Semantic Model | Source | Description |
|----------------|--------|-------------|
| `orders_analysis` | `sat_order_details` | Detailed order information with history |
| `lineitem_details` | `sat_lineitem_details` | Detailed line item information |
| `customer_history` | `sat_customer_details` | Customer history with segment |
| `order_history` | `sat_order_details` | Order history with status/priority |
| `calendar` | `dim_calendar` | Unified calendar with time dimensions |

### Measures

Measures are defined in semantic models and used by metrics:

| Measure | Semantic Model | Description |
|---------|----------------|-------------|
| `quantity` | `lineitem_details` | SUM(L_QUANTITY) |
| `extended_price` | `lineitem_details` | SUM(L_EXTENDEDPRICE) |
| `discount_amount` | `lineitem_details` | SUM(L_EXTENDEDPRICE * L_DISCOUNT) |
| `tax_amount` | `lineitem_details` | SUM(L_TAX) |

## Implementation Details

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
| `f_lineorder_flat_dv` | `f_lineorder_flat` | Wide table for reporting (legacy deleted) |
| `f_orders_stats_dv` | `f_orders_stats` | Aggregated statistics |

**Note:** Legacy models `f_lineorder_flat` and `f_orders_stats` (old version) have been removed. Use Data Vault-based views for backward compatibility.

### Using Backward Compatible Views

```bash
# Query the Data Vault-based view
SELECT * FROM {{ ref('f_lineorder_flat_dv') }}

# Run tests on the Data Vault model
dbt test -s f_orders_stats_dv
```

### Migration to Semantic Layer

For new reporting, use the dbt Semantic Layer instead of Data Vault views:

```yaml
# metrics.yml
- name: total_revenue
  description: "Общая выручка от продаж"
  type: simple
  type_params:
    measure: revenue
    agg: sum
```

```sql
-- Use semantic layer via BI tool or dbt run
SELECT total_revenue, order_year FROM semantic.total_revenue GROUP BY order_year
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
