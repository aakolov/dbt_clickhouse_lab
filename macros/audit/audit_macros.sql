-- Audit macros for dbt models

{% macro audit_insert(table_name) %}
    INSERT INTO audit.audit_log (action, table_name, record_id, new_value, audit_timestamp)
    SELECT
        'INSERT' AS action,
        '{{ table_name }}' AS table_name,
        toString(HK_CUSTOMER) AS record_id,
        jsonDump(*) AS new_value,
        now64(3) AS audit_timestamp
    FROM {{ ref(table_name) }}
    {% if is_incremental() %}
    WHERE dbt_updated_at > (SELECT MAX(dbt_updated_at) FROM audit.audit_log WHERE table_name = '{{ table_name }}')
    {% endif %}
{% endmacro %}

{% macro audit_update(table_name) %}
    INSERT INTO audit.audit_log (action, table_name, record_id, old_value, new_value, audit_timestamp)
    SELECT
        'UPDATE' AS action,
        '{{ table_name }}' AS table_name,
        toString(HK_CUSTOMER) AS record_id,
        jsonDump(old.*) AS old_value,
        jsonDump(new.*) AS new_value,
        now64(3) AS audit_timestamp
    FROM {{ ref(table_name) }} AS new
    INNER JOIN {{ ref(table_name + '_audit_staging') }} AS old
        ON new.HK_CUSTOMER = old.HK_CUSTOMER
    WHERE new.dbt_updated_at != old.dbt_updated_at
    {% if is_incremental() %}
    AND new.dbt_updated_at > (SELECT MAX(dbt_updated_at) FROM audit.audit_log WHERE table_name = '{{ table_name }}')
    {% endif %}
{% endmacro %}

{% macro audit_delete(table_name) %}
    INSERT INTO audit.audit_log (action, table_name, record_id, old_value, audit_timestamp)
    SELECT
        'DELETE' AS action,
        '{{ table_name }}' AS table_name,
        toString(HK_CUSTOMER) AS record_id,
        jsonDump(*) AS old_value,
        now64(3) AS audit_timestamp
    FROM {{ ref(table_name + '_audit_staging') }}
    WHERE HK_CUSTOMER NOT IN (SELECT HK_CUSTOMER FROM {{ ref(table_name) }})
{% endmacro %}
