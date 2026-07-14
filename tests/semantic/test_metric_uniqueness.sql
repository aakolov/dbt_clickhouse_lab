{{ config(enabled=true) }}

-- Test: Проверка уникальности метрик
-- Все имена метрик в metrics.yml должны быть уникальными

WITH metrics AS (
    SELECT 
        value:name::STRING AS metric_name,
        ROW_NUMBER() OVER (PARTITION BY value:name::STRING ORDER BY value:name::STRING) AS rn
    FROM read_yaml_auto('{{ this_directory }}/../models/semantic/metrics.yml')
    , LATERAL flatten(input => parse_json(json_extract_path_text(text, '$.metrics'), true)) AS metrics
)

SELECT metric_name, COUNT(*) AS occurrences
FROM metrics
GROUP BY metric_name
HAVING COUNT(*) > 1
