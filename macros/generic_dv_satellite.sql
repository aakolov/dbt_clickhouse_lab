{% macro generic_dv_satellite(sat_name, source_model, hub_ref, attributes, hashdiff_field='hashdiff', load_date_field='load_date', source_field='source') %}
{{ config(
    materialized='incremental',
    unique_key=[hub_ref ~ '_hk', load_date_field],
    clustered_by=hub_ref ~ '_hk'
) }}

WITH source_data AS (
    SELECT
        {{ hub_ref }}_hk,
        {% for attr in attributes %}
        {{ attr }}{% if not loop.last %},{% endif %}
        {% endfor %}
        {% if is_incremental() %}
        ,{{ load_date_field }}
        {% endif %}
    FROM {{ source_model }}
    {% if is_incremental() %}
    WHERE {{ load_date_field }} > (SELECT MAX({{ load_date_field }}) FROM {{ this }})
    {% endif %}
),

hashed_data AS (
    SELECT
        {{ hub_ref }}_hk,
        {% for attr in attributes %}
        {{ attr }}{% if not loop.last %},{% endif %}
        {% endfor %}
        ,MD5(
            {% for attr in attributes %}
            CAST({{ attr }} AS String){% if not loop.last %} || '-' ||{% endif %}
            {% endfor %}
        ) AS {{ hashdiff_field }},
        now64(3) AS {{ load_date_field }},
        'TPCH' AS {{ source_field }}
    FROM source_data
)

SELECT DISTINCT
    {{ hub_ref }}_hk,
    {% for attr in attributes %}
    {{ attr }}{% if not loop.last %},{% endif %}
    {% endfor %}
    ,{{ hashdiff_field }},
    {{ load_date_field }},
    {{ source_field }}
FROM hashed_data

{% endmacro %}
