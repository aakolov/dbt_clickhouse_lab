-- Generic source definition template
-- Replace SOURCE_NAME with actual source name

{{ config(
    materialized='external',
    format='CustomSeparated',
    format_custom_delimiter='|'
) }}

SELECT *
FROM s3(
    '{{ var('s3_url') }}',
    '{{ var('s3_access_key') }}',
    '{{ var('s3_secret_key') }}',
    'CustomSeparated'
)
