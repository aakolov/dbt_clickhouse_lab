{% macro scd_type2(target_table, source_table, keys, attributes, hashdiff_columns, valid_from_field='valid_from', valid_to_field='valid_to', is_current_field='is_current') %}

WITH source_data AS (
    SELECT
        {{ keys | join(', ') }},
        {{ attributes | join(', ') }},
        now64(3) AS {{ valid_from_field }},
        CAST('9999-12-31 23:59:59' AS DateTime64(3)) AS {{ valid_to_field }},
        1 AS {{ is_current_field }},
        {{ hashdiff_columns | join(', ') }}
    FROM {{ source_table }}
),

existing_data AS (
    SELECT
        *
    FROM {{ target_table }}
    WHERE {{ is_current_field }} = 1
),

new_records AS (
    SELECT
        s.*
    FROM source_data s
    LEFT JOIN existing_data e
        ON {{ keys | join(' AND s. = e.') }}
    WHERE e.{{ keys[0] }} IS NULL
),

updated_records AS (
    SELECT
        s.*
    FROM source_data s
    INNER JOIN existing_data e
        ON {{ keys | join(' AND s. = e.') }}
    WHERE s.{{ hashdiff_columns[0] }} != e.{{ hashdiff_columns[0] }}
),

old_records AS (
    SELECT
        e.*,
        now64(3) AS {{ valid_to_field }},
        0 AS {{ is_current_field }}
    FROM existing_data e
    INNER JOIN updated_records u
        ON {{ keys | join(' AND e. = u.') }}
),

insert_data AS (
    SELECT * FROM new_records
    UNION ALL
    SELECT * FROM updated_records
)

SELECT * FROM insert_data
UNION ALL
SELECT * FROM old_records
WHERE {{ valid_to_field }} > now64(3)

{% endmacro %}
