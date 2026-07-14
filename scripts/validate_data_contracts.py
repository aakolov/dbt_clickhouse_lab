#!/usr/bin/env python3
"""Validate data contracts against models."""

import json
import yaml
import sys
from pathlib import Path
from typing import Dict, List, Any


def load_contract(filepath: Path) -> Dict[str, Any]:
    """Load a contract YAML file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)


def load_schema(filepath: Path) -> Dict[str, Any]:
    """Load JSON schema."""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)


def validate_contract(contract: Dict[str, Any], schema: Dict[str, Any]) -> List[str]:
    """Validate contract against schema."""
    errors = []
    
    try:
        jsonschema_validate(instance=contract, schema=schema)
    except Exception as e:
        errors.append(f"Schema validation failed: {e}")
    
    return errors


def validate_field(field: Dict[str, Any]) -> List[str]:
    """Validate a single field definition."""
    errors = []
    
    required_fields = ['name', 'type', 'nullable', 'description']
    for field_name in required_fields:
        if field_name not in field:
            errors.append(f"Missing required field: {field_name}")
    
    if 'type' in field:
        valid_types = ['UInt32', 'UInt64', 'String', 'Date', 'Decimal(15,2)', 
                      'LowCardinality(String)']
        if field['type'] not in valid_types:
            errors.append(f"Invalid field type: {field['type']}")
    
    return errors


def validate_validation(validation: Dict[str, Any]) -> List[str]:
    """Validate a validation rule."""
    errors = []
    
    valid_types = ['unique', 'not_null', 'foreign_key']
    if validation.get('type') not in valid_types:
        errors.append(f"Invalid validation type: {validation.get('type')}")
    
    if validation.get('type') == 'unique' and 'fields' not in validation:
        errors.append("Unique validation requires 'fields' array")
    
    if validation.get('type') == 'not_null' and 'fields' not in validation:
        errors.append("Not null validation requires 'fields' array")
    
    if validation.get('type') == 'foreign_key':
        if 'field' not in validation:
            errors.append("Foreign key validation requires 'field'")
        if 'reference' not in validation:
            errors.append("Foreign key validation requires 'reference'")
    
    return errors


def validate_all_contracts(contracts_dir: Path, schema_path: Path) -> bool:
    """Validate all contracts in directory."""
    schema = load_schema(schema_path)
    all_valid = True
    
    for contract_file in contracts_dir.glob('*.yml'):
        print(f"Validating {contract_file.name}...")
        
        try:
            contract = load_contract(contract_file)
        except yaml.YAMLError as e:
            print(f"  YAML parse error: {e}")
            all_valid = False
            continue
        
        errors = validate_contract(contract, schema)
        
        if errors:
            print(f"  Schema validation errors:")
            for error in errors:
                print(f"    - {error}")
            all_valid = False
        
        # Validate fields
        if 'contract' in contract and 'fields' in contract['contract']:
            for field in contract['contract']['fields']:
                field_errors = validate_field(field)
                if field_errors:
                    print(f"  Field '{field.get('name', 'unknown')}' errors:")
                    for error in field_errors:
                        print(f"    - {error}")
                    all_valid = False
        
        # Validate validations
        if 'contract' in contract and 'validations' in contract['contract']:
            for validation in contract['contract']['validations']:
                val_errors = validate_validation(validation)
                if val_errors:
                    print(f"  Validation errors:")
                    for error in val_errors:
                        print(f"    - {error}")
                    all_valid = False
        
        if not errors:
            print(f"  ✓ Valid")
    
    return all_valid


def main():
    """Main entry point."""
    contracts_dir = Path(__file__).parent.parent / 'models' / 'contracts'
    schema_path = contracts_dir / 'contract_schema.json'
    
    if not contracts_dir.exists():
        print(f"Contracts directory not found: {contracts_dir}")
        sys.exit(1)
    
    if not schema_path.exists():
        print(f"Schema file not found: {schema_path}")
        sys.exit(1)
    
    print(f"Validating contracts in {contracts_dir}")
    print("=" * 50)
    
    if validate_all_contracts(contracts_dir, schema_path):
        print("=" * 50)
        print("All contracts are valid! ✓")
        sys.exit(0)
    else:
        print("=" * 50)
        print("Some contracts have errors! ✗")
        sys.exit(1)


if __name__ == '__main__':
    main()
