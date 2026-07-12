{{ config(enabled=true) }}

-- Test: Проверка уникальности имен semantic models
-- Все имена semantic models должны быть уникальными

WITH semantic_models AS (
    SELECT 
        value:name::STRING AS sm_name,
        ROW_NUMBER() OVER (PARTITION BY value:name::STRING ORDER BY value:name::STRING) AS rn
    FROM read_yaml_auto('{{ this_directory }}/../models/semantic/semantic_models.yml')
    , LATERAL flatten(input => parse_json(json_extract_path_text(text, '$.semantic_models'), true)) AS sm
)

SELECT sm_name, COUNT(*) AS occurrences
FROM semantic_models
GROUP BY sm_name
HAVING COUNT(*) > 1
