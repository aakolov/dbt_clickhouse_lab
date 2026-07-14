#!/usr/bin/env python3
"""
Validate dbt metrics.yml configuration file.
Checks for:
- Unique metric names
- Valid measure references
- Valid parent metrics for derived metrics
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


def validate_metrics(metrics_data: dict) -> list:
    """Validate metrics configuration."""
    errors = []
    warnings = []
    
    if not metrics_data or 'metrics' not in metrics_data:
        errors.append("No 'metrics' section found in file")
        return errors, warnings
    
    metrics = metrics_data['metrics']
    metric_names = set()
    
    for idx, metric in enumerate(metrics):
        metric_name = metric.get('name', f'metric_{idx}')
        
        # Check for duplicate names
        if metric_name in metric_names:
            errors.append(f"Duplicate metric name: '{metric_name}'")
        metric_names.add(metric_name)
        
        # Validate required fields
        if not metric.get('name'):
            errors.append(f"Metric at index {idx} is missing 'name' field")
        
        if not metric.get('description'):
            errors.append(f"Metric '{metric_name}' is missing 'description' field")
        
        if not metric.get('type'):
            errors.append(f"Metric '{metric_name}' is missing 'type' field")
        
        # Validate measure references for simple metrics
        if metric.get('type') == 'simple':
            type_params = metric.get('type_params', {})
            measure = type_params.get('measure')
            
            if not measure:
                errors.append(f"Metric '{metric_name}' (type: simple) is missing 'measure' in type_params")
        
        # Validate parent metrics for derived metrics
        if metric.get('type') == 'derived':
            type_params = metric.get('type_params', {})
            parents = type_params.get('parents', [])
            
            if not parents:
                errors.append(f"Metric '{metric_name}' (type: derived) is missing 'parents' in type_params")
            
            # Check if parent metrics exist
            for parent in parents:
                parent_name = parent.get('name') if isinstance(parent, dict) else parent
                if parent_name and parent_name not in metric_names:
                    errors.append(f"Metric '{metric_name}' references non-existent parent metric: '{parent_name}'")
        
        # Validate metadata
        metadata = metric.get('metadata', {})
        if metadata:
            if not metadata.get('owner'):
                warnings.append(f"Metric '{metric_name}' is missing 'owner' in metadata")
            if not metadata.get('sensitivity'):
                warnings.append(f"Metric '{metric_name}' is missing 'sensitivity' in metadata")
        
        # Check for measure filters
        filters = type_params.get('filters', [])
        if filters:
            for filter_item in filters:
                if isinstance(filter_item, dict):
                    dimension = filter_item.get('dimension')
                    if not dimension:
                        errors.append(f"Metric '{metric_name}' has filter without 'dimension' field")
    
    return errors, warnings


def main():
    """Main validation function."""
    metrics_file = 'models/semantic/metrics.yml'
    
    if not Path(metrics_file).exists():
        print(f"ERROR: Metrics file not found: {metrics_file}")
        sys.exit(1)
    
    metrics_data = load_yaml_file(metrics_file)
    errors, warnings = validate_metrics(metrics_data)
    
    # Print warnings
    for warning in warnings:
        print(f"WARNING: {warning}")
    
    # Print errors
    if errors:
        print(f"\nFound {len(errors)} error(s) in {metrics_file}:")
        for error in errors:
            print(f"  - {error}")
        sys.exit(1)
    else:
        print(f"✓ All metrics validated successfully!")
        sys.exit(0)


if __name__ == '__main__':
    main()
