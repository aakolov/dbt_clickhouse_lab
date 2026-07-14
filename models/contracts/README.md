# Data Contracts

This folder contains data contract definitions for the dbt-clickhouse-lab project.

## Contracts

### customer_source.yml
- Contract for customer source data

### orders_source.yml
- Contract for orders source data

### lineitem_source.yml
- Contract for lineitem source data

### part_source.yml
- Contract for part source data

### supplier_source.yml
- Contract for supplier source data

## Schema

`contract_schema.json` defines the schema for contract files.

## Validation

Run `scripts/validate_data_contracts.py` to validate all contracts.
