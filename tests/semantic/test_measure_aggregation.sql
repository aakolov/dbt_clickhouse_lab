{{ config(enabled=true) }}

-- Test: Валидация measures в semantic models
-- Проверка, что все measures имеют корректные параметры

WITH semantic_models AS (
    SELECT 
        value:name::STRING AS sm_name,
        value:measures AS measures
    FROM read_yaml_auto('{{ this_directory }}/../models/semantic/semantic_models.yml')
    , LATERAL flatten(input => parse_json(json_extract_path_text(text, '$.semantic_models'), true)) AS sm
),

measures AS (
    SELECT 
        sm_name,
        measure.value:name::STRING AS measure_name,
        measure.value:agg::STRING AS agg_func
    FROM semantic_models
    , LATERAL flatten(input => measures) AS measure
)

SELECT sm_name, measure_name, agg_func
FROM measures
WHERE agg_func NOT IN ('sum', 'count', 'avg', 'min', 'max', 'approx_percentile')
