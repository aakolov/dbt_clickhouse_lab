# Generic Data Vault Hub

This macro creates a Data Vault hub table.

## Usage

```sql
{{ generic_dv_hub(hub_name, source_model, business_keys, hashkey_field='hk') }}
```

## Parameters

- `hub_name`: Name of the hub (used as table name)
- `source_model`: Source model reference
- `business_keys`: List of business key fields
- `hashkey_field`: Name of the hash key field (default: hk)

## Example

```sql
{{ generic_dv_hub(
    hub_name='hub_customer',
    source_model='stg_customer',
    business_keys=['C_CUSTKEY'],
    hashkey_field='HK_CUSTOMER'
) }}
```

## Output

The macro produces a table with:

- `HK_*`: Hash key (MD5 of business keys)
- Business key fields

## Best Practices

1. Use MD5 for hash key calculation
2. Ensure business key uniqueness
3. Handle null values in business keys
