# SCD Type 2 Macro

This macro implements SCD Type 2 (Slowly Changing Dimensions) for versioning dimension data.

## Usage

```sql
{{ scd_type2(target_table, source_table, keys, attributes, hashdiff_columns) }}
```

## Parameters

- `target_table`: Name of the target table
- `source_table`: Name of the source table
- `keys`: List of business key fields
- `attributes`: List of attribute fields
- `hashdiff_columns`: List of fields for hashdiff calculation

## Example

```sql
{{ scd_type2(
    target_table='sat_customer',
    source_table='stg_customer',
    keys=['HK_CUSTOMER', 'LD_CUSTOMER'],
    attributes=['C_NAME', 'C_ADDRESS', 'C_PHONE'],
    hashdiff_columns=['C_NAME', 'C_ADDRESS', 'C_PHONE']
) }}
```

## Output

The macro produces a table with:

- Business keys
- Attributes
- `valid_from`: Start date of validity
- `valid_to`: End date of validity
- `is_current`: Flag for current record
