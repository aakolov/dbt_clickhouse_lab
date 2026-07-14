# Generic Data Vault Satellite

This macro creates a Data Vault satellite table for history tracking.

## Usage

```sql
{{ generic_dv_satellite(sat_name, source_model, hub_ref, attributes, hashdiff_field='hashdiff', load_date_field='load_date', source_field='source') }}
```

## Parameters

- `sat_name`: Name of the satellite (used as table name)
- `source_model`: Source model reference
- `hub_ref`: Reference to hub table (e.g., 'customer' for HK_CUSTOMER)
- `attributes`: List of attribute fields to track
- `hashdiff_field`: Name of the hashdiff field (default: hashdiff)
- `load_date_field`: Name of the load date field (default: load_date)
- `source_field`: Name of the source indicator field (default: source)

## Example

```sql
{{ generic_dv_satellite(
    sat_name='sat_customer_details',
    source_model='stg_customer',
    hub_ref='customer',
    attributes=['C_NAME', 'C_ADDRESS', 'C_PHONE', 'C_ACCTBAL']
) }}
```

## Output

The macro produces a table with:

- `HK_*`: Hash key from hub
- Attribute fields
- `hashdiff`: MD5 of attributes for change detection
- `load_date`: Timestamp when data was loaded
- `source`: Source indicator (default: 'TPCH')

## Best Practices

1. Use hashdiff for change detection
2. Include load_date for historical tracking
3. Mark source for data lineage
4. Incremental loading recommended
