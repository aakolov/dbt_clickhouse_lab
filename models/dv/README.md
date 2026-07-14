# Data Vault Models Documentation

## Overview

This directory contains the Data Vault 2.0 implementation for the dbt-clickhouse project. Data Vault is a methodology for building enterprise data warehouses that emphasizes flexibility, scalability, and auditability.

## Structure

```
dv/
├── hub/        # Business keys storage
├── link/       # Relationships between hubs
└── sat/        # History and attributes storage
```

## Components

### Hubs

Hubs contain business keys and serve as the integration point for different systems.

| Hub | Business Key | File | Description |
|------|--------------|------|-------------|
| `hub_customer` | `C_CUSTKEY` | `hub_customer.sql` | Customer identifier |
| `hub_order` | `O_ORDERKEY` | `hub_order.sql` | Order identifier |
| `hub_part` | `L_PARTKEY` | `hub_part.sql` | Part identifier |
| `hub_supplier` | `L_SUPPKEY` | `hub_supplier.sql` | Supplier identifier |

### Links

Links represent business processes and connect hubs.

| Link | Hubs Connected | File | Description |
|------|---------------|------|-------------|
| `link_order_customer` | `hub_order` ↔ `hub_customer` | `link_order_customer.sql` | Order placed by customer |
| `link_order_lineitem` | `hub_order` ↔ `hub_part` ↔ `hub_supplier` | `link_order_lineitem.sql` | Order line items |

### Satellites

Satellites store descriptive attributes with history tracking.

| Satellite | Hub/Link | File | Description |
|-----------|----------|------|-------------|
| `sat_customer_details` | `hub_customer` | `sat_customer_details.sql` | Customer attributes with history |
| `sat_order_details` | `hub_order` | `sat_order_details.sql` | Order attributes with history |
| `sat_lineitem_details` | `link_order_lineitem` | `sat_lineitem_details.sql` | Line item attributes with history |
| `sat_part_details` | `hub_part` | `sat_part_details.sql` | Part attributes with history |
| `sat_supplier_details` | `hub_supplier` | `sat_supplier_details.sql` | Supplier attributes with history |

## Implementation Details

### Hash Keys

- **Hub Hash Key (HK)**: `MD5(business_key)`
- **Link Hash Key (HK)**: `MD5(hub1_hk || '-' || hub2_hk || ...)`
- **Satellite Hash Key (HK)**: Same as associated link or hub
- **Hashdiff**: `MD5(attribute1 || attribute2 || ...)` for change detection

### Loading Process

Each Data Vault model includes:
- `LOAD_DATE`: Timestamp when data was loaded
- `SOURCE`: Indicator of data source ('TPCH')
- `HASHDIFF`: Hash of attributes for change detection

### SCD Type 2 Support

Satellites support Slowly Changing Dimension Type 2:
- `EFFECTIVE_FROM`: Start date of record validity
- `EFFECTIVE_TO`: End date of record validity
- `IS_CURRENT`: Flag indicating current record (1/0)

## Usage

### Run all Data Vault models

```bash
dbt run -s tag:datavault
```

### Run specific hub

```bash
dbt run --models hub_customer
```

### Run all satellites

```bash
dbt run --models 'tag:satellite'
```

## Best Practices

### Naming Conventions

- Hubs: `hub_<entity>`
- Links: `link_<relationship>`
- Satellites: `sat_<entity>_<description>`

### Performance

- Use appropriate partitioning for large tables
- Consider materialized views for reporting
- Monitor query performance

### Maintenance

- Regular hash key validation
- Monitor satellite growth
- Archive old data when appropriate
