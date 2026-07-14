{{ config(enabled=true) }}

-- Test: Валидация производных метрик
-- Проверка, что родительские метрики для derived metrics существуют

WITH metrics AS (
    SELECT 
        value:name::STRING AS metric_name,
        value:type::STRING AS metric_type,
        value:type_params AS type_params
    FROM read_yaml_auto('{{ this_directory }}/../models/semantic/metrics.yml')
    , LATERAL flatten(input => parse_json(json_extract_path_text(text, '$.metrics'), true)) AS m
),

derived_metrics AS (
    SELECT 
        metric_name,
        parent.value:name::STRING AS parent_name
    FROM metrics
    , LATERAL flatten(input => type_params:parents) AS parent
    WHERE metric_type = 'derived'
)

SELECT dm.metric_name, dm.parent_name
FROM derived_metrics dm
WHERE dm.parent_name NOT IN (SELECT metric_name FROM metrics)
