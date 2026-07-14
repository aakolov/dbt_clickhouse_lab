{% macro generic_s3_loader(source_name, table_name, s3_url, format='CustomSeparated', delimiter='|') %}
    {{ config(
        materialized='table',
        engine='MergeTree()',
        order_by=[table_name ~ '_key'],
        partition_by='toYear(load_date)'
    ) }}

    SELECT *,
        '{{ invocation_id }}' AS dbt_invocation_id,
        now64(3) AS dbt_updated_at
    FROM s3(
        '{{ s3_url }}',
        '{{ var('s3_access_key') }}',
        '{{ var('s3_secret_key') }}',
        '{{ format }}'
    )
{% endmacro %}
