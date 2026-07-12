{{ config(enabled=true) }}

-- Test: Проверка наличия measures во всех semantic models
-- Все semantic models должны иметь measures (кроме календаря и справочников)

WITH semantic_models AS (
    SELECT 
        value:name::STRING AS sm_name,
        value:measures AS measures
    FROM read_yaml_auto('{{ this_directory }}/../models/semantic/semantic_models.yml')
    , LATERAL flatten(input => parse_json(json_extract_path_text(text, '$.semantic_models'), true)) AS sm
),

sm_with_measures AS (
    SELECT sm_name
    FROM semantic_models
    WHERE measures IS NOT NULL
)

SELECT sm_name
FROM semantic_models
WHERE sm_name NOT IN (SELECT sm_name FROM sm_with_measures)
  AND sm_name NOT IN ('calendar', 'customer_history', 'order_history')
