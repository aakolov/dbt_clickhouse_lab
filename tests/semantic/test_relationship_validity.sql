{{ config(enabled=true) }}

-- Test: Валидация связей между semantic models
-- Проверка, что все relationships определены корректно

WITH semantic_models AS (
    SELECT 
        value:name::STRING AS sm_name,
        value:relationships AS relationships
    FROM read_yaml_auto('{{ this_directory }}/../models/semantic/semantic_models.yml')
    , LATERAL flatten(input => parse_json(json_extract_path_text(text, '$.semantic_models'), true)) AS sm
),

relationships AS (
    SELECT 
        sm_name,
        rel.value:name::STRING AS rel_name,
        rel.value:to::STRING AS target_sm
    FROM semantic_models
    , LATERAL flatten(input => relationships) AS rel
)

SELECT sm_name, rel_name, target_sm
FROM relationships
WHERE target_sm NOT IN (SELECT sm_name FROM semantic_models)
