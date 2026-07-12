{{ config(enabled=true) }}

-- Test: Валидация временных измерений
-- Проверка, что все time-измерения имеют time_granularity

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
        dim.value:name::STRING AS dim_name,
        dim.value:type::STRING AS dim_type,
        dim.value:type_params.time_granularity::STRING AS time_granularity
    FROM semantic_models
    , LATERAL flatten(input => dimensions) AS dim
)

SELECT sm_name, dim_name, dim_type, time_granularity
FROM dimensions
WHERE dim_type = 'time' 
  AND (time_granularity IS NULL OR time_granularity = '')
