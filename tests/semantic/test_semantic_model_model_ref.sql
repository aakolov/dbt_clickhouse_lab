{{ config(enabled=true) }}

-- Test: Проверка, что все semantic models ссылаются на существующие dbt модели
-- Проверка model ref() в semantic_models.yml

WITH semantic_models AS (
    SELECT 
        value:name::STRING AS sm_name,
        value:model::STRING AS model_ref
    FROM read_yaml_auto('{{ this_directory }}/../models/semantic/semantic_models.yml')
    , LATERAL flatten(input => parse_json(json_extract_path_text(text, '$.semantic_models'), true)) AS sm
)

SELECT sm_name, model_ref
FROM semantic_models
WHERE model_ref IS NULL OR model_ref = ''
