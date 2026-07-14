{{ config(
    meta={
        'data_quality': {
            'owner': 'analytics_team',
            'classification': 'internal',
            'description': 'Staging model for customer data'
        },
        'data_governance': {
            'owner': 'analytics_team',
            'classification': 'internal',
            'pii': False,
            'sensitive': False
        }
    }
) }}

{{ dbt_audit.audit_model() }}

SELECT
    c_custkey,
    c_name,
    c_address,
    c_nationkey,
    c_phone,
    c_acctbal,
    c_mktsegment,
    c_comment,
    '{{ invocation_id }}' AS dbt_invocation_id,
    now64(3) AS dbt_updated_at
FROM {{ source('tpch', 'customer') }}
