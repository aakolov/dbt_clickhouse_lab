# Data Contracts README

## Overview

This document describes data contracts in the dbt-clickhouse-lab project.

## Contract Levels

### 1. Source Contract
- Defines expected structure of source data
- Includes data types, required fields, and format specifications

### 2. Staging Contract
- Defines expected structure after initial transformation
- Includes data validation rules and transformation specifications

### 3. Data Vault Contract
- Defines expected structure of Data Vault models
- Includes hash key specifications, load date requirements, and history tracking

### 4. Mart Contract
- Defines expected structure of data marts
- Includes aggregations, calculated fields, and reporting specifications

## Contract Elements

### Schema
- Field names
- Data types
- Nullability
- Default values

### Business Rules
- Valid values
- Calculations
- Transformations

### Quality Requirements
- Uniqueness constraints
- Referential integrity
- Data completeness

## Implementation

Contracts are implemented using:

1. **YAML definitions** in `models/contracts/`
2. **Validation scripts** in `scripts/validate_data_contracts.py`
3. **dbt tests** for data quality

## Maintenance

- Review contracts quarterly
- Update contracts as source data changes
- Validate contracts in CI/CD pipeline
