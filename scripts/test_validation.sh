#!/bin/bash
# Test scripts for CI validation

echo "Testing validate_metrics.py..."
python scripts/validate_metrics.py
echo "Metrics validation passed!"

echo ""
echo "Testing validate_semantic_models.py..."
python scripts/validate_semantic_models.py
echo "Semantic models validation passed!"
