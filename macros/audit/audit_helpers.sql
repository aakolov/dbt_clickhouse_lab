-- Audit helper macros

{% macro get_audit_columns() %}
    HK_CUSTOMER,
    LD_CUSTOMER,
    LOAD_DATE,
    SOURCE,
    HASHDIFF,
    C_CUSTKEY,
    C_NAME,
    C_ADDRESS,
    C_NATIONKEY,
    C_PHONE,
    C_ACCTBAL,
    C_MKTSEGMENT,
    C_COMMENT,
    dbt_updated_at,
    dbt_invocation_id
{% endmacro %}

{% macro get_audit_join_condition() %}
    HK_CUSTOMER
{% endmacro %}

{% macro get_audit_table_name(model_name) %}
    audit_{{ model_name }}
{% endmacro %}
