{{ config(enabled=true) }}

-- Test: Проверка наличия описаний для всех измерений
-- Все измерения в semantic models должны иметь описание

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
        dim.value:description::STRING AS description
    FROM semantic_models
    , LATERAL flatten(input => dimensions) AS dim
)

SELECT sm_name, dim_name
FROM dimensions
WHERE description IS NULL OR description = ''
