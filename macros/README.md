# Macros README

This folder contains reusable dbt macros.

## Available Macros

### generic_s3_loader.sql
- Load data from S3 storage

### scd_type2.sql
- Implement SCD Type 2 (Slowly Changing Dimensions)

### generic_dv_hub.sql
- Create Data Vault hubs

### generic_dv_satellite.sql
- Create Data Vault satellites

## Usage

```sql
{{ generic_s3_loader(...) }}
{{ scd_type2(...) }}
{{ generic_dv_hub(...) }}
{{ generic_dv_satellite(...) }}
```

## Best Practices

1. Use macros to reduce code duplication
2. Follow naming conventions
3. Document parameters and return values
4. Test macros thoroughly
