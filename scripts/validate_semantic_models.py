#!/usr/bin/env python3
"""
Validate dbt semantic_models.yml configuration file.
Checks for:
- Unique semantic model names
- Valid model references
- Valid dimension and measure definitions
- Required metadata fields
"""

import sys
import yaml
from pathlib import Path


def load_yaml_file(file_path: str) -> dict:
    """Load and parse a YAML file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)
    except FileNotFoundError:
        print(f"ERROR: File not found: {file_path}")
        sys.exit(1)
    except yaml.YAMLError as e:
        print(f"ERROR: Invalid YAML syntax in {file_path}: {e}")
        sys.exit(1)


def validate_semantic_models(semantic_models_data: dict) -> list:
    """Validate semantic models configuration."""
    errors = []
    warnings = []
    
    if not semantic_models_data or 'semantic_models' not in semantic_models_data:
        errors.append("No 'semantic_models' section found in file")
        return errors, warnings
    
    semantic_models = semantic_models_data['semantic_models']
    model_names = set()
    
    for idx, model in enumerate(semantic_models):
        model_name = model.get('name', f'model_{idx}')
        
        # Check for duplicate names
        if model_name in model_names:
            errors.append(f"Duplicate semantic model name: '{model_name}'")
        model_names.add(model_name)
        
        # Validate required fields
        if not model.get('name'):
            errors.append(f"Semantic model at index {idx} is missing 'name' field")
        
        if not model.get('model'):
            errors.append(f"Semantic model '{model_name}' is missing 'model' field")
        
        if not model.get('description'):
            errors.append(f"Semantic model '{model_name}' is missing 'description' field")
        
        # Validate measures
        measures = model.get('measures', [])
        if measures:
            measure_names = set()
            for measure in measures:
                measure_name = measure.get('name')
                
                if not measure_name:
                    errors.append(f"Semantic model '{model_name}' has measure without 'name' field")
                
                if measure_name in measure_names:
                    errors.append(f"Semantic model '{model_name}' has duplicate measure name: '{measure_name}'")
                measure_names.add(measure_name)
        
        # Validate dimensions
        dimensions = model.get('dimensions', [])
        if dimensions:
            dimension_names = set()
            for dimension in dimensions:
                dimension_name = dimension.get('name')
                
                if not dimension_name:
                    errors.append(f"Semantic model '{model_name}' has dimension without 'name' field")
                
                if dimension_name in dimension_names:
                    errors.append(f"Semantic model '{model_name}' has duplicate dimension name: '{dimension_name}'")
                dimension_names.add(dimension_name)
        
        # Validate relationships
        relationships = model.get('relationships', [])
        if relationships:
            for relationship in relationships:
                rel_name = relationship.get('name')
                to_model = relationship.get('to')
                
                if not rel_name:
                    errors.append(f"Semantic model '{model_name}' has relationship without 'name' field")
                
                if not to_model:
                    errors.append(f"Relationship '{rel_name}' in '{model_name}' is missing 'to' field")
                
                # Check if referenced model exists
                if to_model and to_model not in model_names:
                    errors.append(f"Relationship '{rel_name}' in '{model_name}' references non-existent model: '{to_model}'")
        
        # Validate metadata
        metadata = model.get('metadata', {})
        if metadata:
            if not metadata.get('owner'):
                warnings.append(f"Semantic model '{model_name}' is missing 'owner' in metadata")
            if not metadata.get('sensitivity'):
                warnings.append(f"Semantic model '{model_name}' is missing 'sensitivity' in metadata")
        
        # Validate defaults
        defaults = model.get('defaults', {})
        agg_time = defaults.get('agg_time')
        if not agg_time:
            warnings.append(f"Semantic model '{model_name}' is missing 'agg_time' in defaults")
    
    return errors, warnings


def main():
    """Main validation function."""
    models_file = 'models/semantic/semantic_models.yml'
    
    if not Path(models_file).exists():
        print(f"ERROR: Semantic models file not found: {models_file}")
        sys.exit(1)
    
    semantic_models_data = load_yaml_file(models_file)
    errors, warnings = validate_semantic_models(semantic_models_data)
    
    # Print warnings
    for warning in warnings:
        print(f"WARNING: {warning}")
    
    # Print errors
    if errors:
        print(f"\nFound {len(errors)} error(s) in {models_file}:")
        for error in errors:
            print(f"  - {error}")
        sys.exit(1)
    else:
        print(f"✓ All semantic models validated successfully!")
        sys.exit(0)


if __name__ == '__main__':
    main()
