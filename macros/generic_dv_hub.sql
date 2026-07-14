{% macro generic_dv_hub(hub_name, source_model, business_keys, hashkey_field='hk') %}
{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by=[hashkey_field],
    unique_key=hashkey_field
) }}

WITH source_data AS (
    SELECT
        {% for key in business_keys %}
        {{ key }}{% if not loop.last %},{% endif %}
        {% endfor %}
    FROM {{ source_model }}
),

hashed_data AS (
    SELECT
        MD5(
            {% for key in business_keys %}
            CAST({{ key }} AS String){% if not loop.last %} || '-' ||{% endif %}
            {% endfor %}
        ) AS {{ hashkey_field }},
        {% for key in business_keys %}
        {{ key }}{% if not loop.last %},{% endif %}
        {% endfor %}
    FROM source_data
)

SELECT DISTINCT
    {{ hashkey_field }},
    {% for key in business_keys %}
    {{ key }}{% if not loop.last %},{% endif %}
    {% endfor %}
FROM hashed_data

{% endmacro %}
