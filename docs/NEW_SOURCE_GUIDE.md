# New Source Guide

This guide explains how to add a new source to the dbt-clickhouse-lab project.

## Overview

The project uses a standardized approach for adding new sources. Follow these steps to add a new source.

## Steps

### 1. Create Source Folder

Create a new folder in `models/sources/` with your source name:

```bash
mkdir -p models/sources/my_new_source
```

### 2. Copy Template

Copy the template files from `models/sources/new_source_template/`:

```bash
cp models/sources/new_source_template/* models/sources/my_new_source/
```

### 3. Update Source Model

Edit `stg_my_new_source.sql` to:

1. Replace `SOURCE_NAME` with your source name
2. Map source fields to staging fields
3. Add appropriate transformations

### 4. Define Source

Edit `my_new_source.yml` to:

1. Update source name and description
2. Define table names and descriptions
3. Add column definitions

### 5. Create Data Contract

Create `models/contracts/my_new_source_source.yml` with:

1. Field definitions with types and nullability
2. Validation rules (unique, not_null, foreign_key)
3. Description of source

### 6. Document Source

Create `docs/MY_NEW_SOURCE.md` with:

1. Source description
2. Field definitions
3. Data quality rules
4. Contact information

### 7. Update Sources Configuration

Add source to `models/sources/sources.yml`:

```yaml
version: 2

sources:
  - name: my_new_source
    description: "Description of my_new_source"
    tables:
      - name: raw_table
        description: "Raw table from my_new_source"
```

### 8. Test Source

Run tests to verify source model:

```bash
dbt run --models my_new_source
dbt test --models my_new_source
```

## Data Contract Requirements

All sources must have a data contract that includes:

- Field definitions with types
- Nullability specifications
- Validation rules
- Data quality requirements

## Examples

See existing sources for examples:

- `models/sources/tpch/`
- `models/sources/customer/`
- `models/sources/orders/`

## Contact

For questions about adding sources, contact the Analytics Team at analytics@company.com.
