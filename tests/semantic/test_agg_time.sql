{{ config(enabled=true) }}

-- Test: Проверка наличия defaults.agg_time во всех semantic models
-- Все semantic models должны иметь agg_time для агрегации

WITH semantic_models AS (
    SELECT 
        value:name::STRING AS sm_name,
        value:defaults.agg_time::STRING AS agg_time
    FROM read_yaml_auto('{{ this_directory }}/../models/semantic/semantic_models.yml')
    , LATERAL flatten(input => parse_json(json_extract_path_text(text, '$.semantic_models'), true)) AS sm
)

SELECT sm_name, agg_time
FROM semantic_models
WHERE agg_time IS NULL OR agg_time = ''
