# Generic S3 Loader

This macro loads data from S3 storage.

## Usage

```sql
{{ generic_s3_loader(source_name, table_name, s3_url, format='CustomSeparated', delimiter='|') }}
```

## Parameters

- `source_name`: Name of the source
- `table_name`: Name of the table
- `s3_url`: URL to S3 bucket
- `format`: Format of the data (default: CustomSeparated)
- `delimiter`: Delimiter for CustomSeparated format (default: |)

## Example

```sql
{{ generic_s3_loader('tpch', 'customer', 'https://bucket.s3.amazonaws.com/customer/') }}
```
