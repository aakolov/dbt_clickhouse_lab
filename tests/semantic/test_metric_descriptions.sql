{{ config(enabled=true) }}

-- Test: Проверка наличия описаний для всех метрик
-- Все метрики должны иметь описание

WITH metrics AS (
    SELECT 
        value:name::STRING AS metric_name,
        value:description::STRING AS description
    FROM read_yaml_auto('{{ this_directory }}/../models/semantic/metrics.yml')
    , LATERAL flatten(input => parse_json(json_extract_path_text(text, '$.metrics'), true)) AS m
)

SELECT metric_name
FROM metrics
WHERE description IS NULL OR description = ''
