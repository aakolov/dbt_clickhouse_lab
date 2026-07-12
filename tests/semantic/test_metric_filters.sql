{{ config(enabled=true) }}

-- Test: Валидация фильтров метрик
-- Проверка, что фильтры ссылаются на существующие измерения

WITH semantic_models AS (
    SELECT 
        value:name::STRING AS sm_name,
        value:dimensions AS dimensions
    FROM read_yaml_auto('{{ this_directory }}/../models/semantic/semantic_models.yml')
    , LATERAL flatten(input => parse_json(json_extract_path_text(text, '$.semantic_models'), true)) AS sm
),

dimensions AS (
    SELECT 
        sm_name,
        dim.value:name::STRING AS dim_name
    FROM semantic_models
    , LATERAL flatten(input => dimensions) AS dim
),

metrics AS (
    SELECT 
        value:name::STRING AS metric_name,
        value:type_params.filters AS filters
    FROM read_yaml_auto('{{ this_directory }}/../models/semantic/metrics.yml')
    , LATERAL flatten(input => parse_json(json_extract_path_text(text, '$.metrics'), true)) AS m
    WHERE value:type_params.filters IS NOT NULL
),

metric_filters AS (
    SELECT 
        metric_name,
        filter.value:dimension::STRING AS filter_dimension
    FROM metrics
    , LATERAL flatten(input => filters) AS filter
)

SELECT mf.metric_name, mf.filter_dimension
FROM metric_filters mf
WHERE mf.filter_dimension NOT IN (SELECT dim_name FROM dimensions)
