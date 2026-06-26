# План рефакторинга staging-слоя под Data Vault 2.0 для проекта dbt-clickhouse

## Текущее состояние

### Архитектура
Текущая структура соответствует **звездообразной схеме (star schema)**:
- **Факты**: stg_orders, stg_lineitem
- **Измерения**: stg_customer, stg_part, stg_supplier
- Прямые JOIN-ы между таблицами в marts (f_lineorder_flat)

### Проблемы текущего подхода

1. **Негибкость при изменении бизнес-требований**
   - Изменения в измерениях требуют перестройки всей схемы
   - Сложность добавления новых атрибутов без рефакторинга всех зависимостей

2. **Неполная историзация**
   - Текущая структура не поддерживает SCD (Slowly Changing Dimensions) тип 2
   - Невозможно отслеживать изменения атрибутов во времени

3. **Проблемы с производительностью**
   - Wide tables (f_lineorder_flat) имеют большой размер
   - Сложные JOIN-ы при каждом запросе к data mart

4. **Ограничения TPCH**
   - Искусственный датасет с фиксированными данными
   - Не отражает реальные бизнес-процессы с историей изменений

## Предлагаемая архитектура Data Vault 2.0

### 1. Hubs (ядро бизнес-процессов)

#### hub_customer
```sql
-- models/dv/hub_customer.sql
SELECT
    MD5(C_CUSTKEY::TEXT) AS CUSTOMER_HK,  -- hash key
    C_CUSTKEY AS CUSTOMER_ID,             -- business key
    CURRENT_TIMESTAMP AS LOAD_DATE,       -- load date
    'TPCH' AS SOURCE                      -- source indicator
FROM {{ source('dbgen', 'customer') }}
```

#### hub_order
```sql
-- models/dv/hub_order.sql
SELECT
    MD5(O_ORDERKEY::TEXT) AS ORDER_HK,
    O_ORDERKEY AS ORDER_ID,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'orders') }}
```

#### hub_part
```sql
-- models/dv/hub_part.sql
SELECT
    MD5(P_PARTKEY::TEXT) AS PART_HK,
    P_PARTKEY AS PART_ID,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'part') }}
```

#### hub_supplier
```sql
-- models/dv/hub_supplier.sql
SELECT
    MD5(S_SUPPKEY::TEXT) AS SUPPLIER_HK,
    S_SUPPKEY AS SUPPLIER_ID,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'supplier') }}
```

### 2. Links (связи между хабами)

#### link_order_customer
```sql
-- models/dv/link_order_customer.sql
SELECT
    MD5(O_ORDERKEY::TEXT || '-' || O_CUSTKEY::TEXT) AS ORDER_CUSTOMER_HK,
    MD5(O_ORDERKEY::TEXT) AS ORDER_HK,
    MD5(O_CUSTKEY::TEXT) AS CUSTOMER_HK,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'orders') }}
```

#### link_order_lineitem
```sql
-- models/dv/link_order_lineitem.sql
SELECT
    MD5(L_ORDERKEY::TEXT || '-' || L_LINENUMBER::TEXT) AS ORDER_LINEITEM_HK,
    MD5(L_ORDERKEY::TEXT) AS ORDER_HK,
    MD5(L_PARTKEY::TEXT) AS PART_HK,
    MD5(L_SUPPKEY::TEXT) AS SUPPLIER_HK,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'lineitem') }}
```

### 3. Satellites (историзированные атрибуты)

#### sat_customer_details
```sql
-- models/dv/sat_customer_details.sql
SELECT
    MD5(C_CUSTKEY::TEXT) AS CUSTOMER_HK,
    C_NAME,
    C_ADDRESS,
    C_NATIONKEY,
    C_PHONE,
    C_ACCTBAL,
    C_MKTSEGMENT,
    C_COMMENT,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    MD5(
        C_NAME || '-' || 
        C_ADDRESS || '-' || 
        C_PHONE || '-' || 
        C_ACCTBAL || '-' || 
        C_MKTSEGMENT || '-' || 
        C_COMMENT
    ) AS HASHDIFF,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'customer') }}
```

#### sat_order_details
```sql
-- models/dv/sat_order_details.sql
SELECT
    MD5(O_ORDERKEY::TEXT) AS ORDER_HK,
    O_ORDERSTATUS,
    O_TOTALPRICE,
    O_ORDERDATE,
    O_ORDERPRIORITY,
    O_CLERK,
    O_SHIPPRIORITY,
    O_COMMENT,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    MD5(
        O_ORDERSTATUS || '-' || 
        O_TOTALPRICE || '-' || 
        O_ORDERDATE || '-' || 
        O_ORDERPRIORITY || '-' || 
        O_CLERK || '-' || 
        O_SHIPPRIORITY
    ) AS HASHDIFF,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'orders') }}
```

#### sat_lineitem_details
```sql
-- models/dv/sat_lineitem_details.sql
SELECT
    MD5(L_ORDERKEY::TEXT || '-' || L_LINENUMBER::TEXT) AS ORDER_LINEITEM_HK,
    L_PARTKEY,
    L_SUPPKEY,
    L_QUANTITY,
    L_EXTENDEDPRICE,
    L_DISCOUNT,
    L_TAX,
    L_RETURNFLAG,
    L_LINESTATUS,
    L_SHIPDATE,
    L_COMMITDATE,
    L_RECEIPTDATE,
    L_SHIPINSTRUCT,
    L_SHIPMODE,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    MD5(
        L_PARTKEY::TEXT || '-' || 
        L_SUPPKEY::TEXT || '-' || 
        L_QUANTITY::TEXT || '-' || 
        L_EXTENDEDPRICE::TEXT || '-' || 
        L_DISCOUNT::TEXT || '-' || 
        L_TAX::TEXT || '-' || 
        L_RETURNFLAG || '-' || 
        L_LINESTATUS || '-' || 
        L_SHIPDATE || '-' || 
        L_COMMITDATE || '-' || 
        L_RECEIPTDATE || '-' || 
        L_SHIPINSTRUCT || '-' || 
        L_SHIPMODE
    ) AS HASHDIFF,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'lineitem') }}
```

#### sat_part_details
```sql
-- models/dv/sat_part_details.sql
SELECT
    MD5(P_PARTKEY::TEXT) AS PART_HK,
    P_NAME,
    P_MFGR,
    P_BRAND,
    P_TYPE,
    P_SIZE,
    P_CONTAINER,
    P_RETAILPRICE,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    MD5(
        P_NAME || '-' || 
        P_MFGR || '-' || 
        P_BRAND || '-' || 
        P_TYPE || '-' || 
        P_SIZE || '-' || 
        P_CONTAINER || '-' || 
        P_RETAILPRICE::TEXT
    ) AS HASHDIFF,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'part') }}
```

#### sat_supplier_details
```sql
-- models/dv/sat_supplier_details.sql
SELECT
    MD5(S_SUPPKEY::TEXT) AS SUPPLIER_HK,
    S_NAME,
    S_ADDRESS,
    S_NATIONKEY,
    S_PHONE,
    S_ACCTBAL,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    MD5(
        S_NAME || '-' || 
        S_ADDRESS || '-' || 
        S_PHONE || '-' || 
        S_ACCTBAL::TEXT
    ) AS HASHDIFF,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'supplier') }}
```

## Особенности реализации для ClickHouse

### 1. Параметры движка MergeTree

```sql
{{ config(
    engine='MergeTree()',
    order_by=['LOAD_DATE', 'HASHDIFF'],
    partition_by='toYear(LOAD_DATE)'
) }}
```

### 2. Оптимизация хранения

- Использовать `LowCardinality(String)` для повторяющихся значений
- Добавить материализованные представления для частых запросов
- Использовать TTL для старых данных

### 3. Индексация

```sql
{{ config(
    engine='MergeTree()',
    order_by=['LOAD_DATE', 'HASHDIFF'],
    primary_key='LOAD_DATE'
) }}
```

## Пошаговый план миграции

### Этап 1: Подготовка (1-2 дня)
1. Создать структуру директорий `models/dv/`
2. Настроить命名 для Data Vault объектов
3. Создать макросы для генерации hash keys и hashdiffs
4. Подготовить тестовые данные

### Этап 2: Реализация хабов (2-3 дня)
1. Создать все hub-модели
2. Добавить уникальные тесты
3. Проверить целостность бизнес-ключей

### Этап 3: Реализация линков (2-3 дня)
1. Создать все link-модели
2. Проверить связи между хабами
3. Добавить тесты на внешние ключи

### Этап 4: Реализация сателлитов (3-4 дня)
1. Создать все satellite-модели
2. Добавить hashdiff для обнаружения изменений
3. Настроить partitioning и TTL

### Этап 5: Миграция marts (3-4 дня)
1. Создать представления/модели для backward compatibility
2. Обновить существующие модели marts для работы с DV
3. Проверить производительность

### Этап 6: Оптимизация и тестирование (2-3 дня)
1. Оптимизация запросов к Data Vault
2. Создание materialized views для частых запросов
3. Финальное тестирование и сравнение производительности

## Ожидаемые результаты

### Преимущества
- **Гибкость**: Легко добавлять новые атрибуты без рефакторинга
- **Историзация**: Возможность отслеживать изменения во времени
- **Масштабируемость**: Независимое развитие хабов и сателлитов
- **Воспроизводимость**: Четкое разделение ответственности

### Потенциальные недостатки
- **Сложность**: Больше таблиц и JOIN-ов для простых запросов
- **Производительность**: Может потребоваться больше ресурсов для ETL
- **Обучение**: Команда должна освоить концепции Data Vault

## Рекомендации

1. **Постепенная миграция**: Не удаляйте старые модели сразу, создайте параллельные модели
2. **Тестирование**: Внедрите comprehensive тесты на каждом этапе
3. **Документация**: Поддерживайте документацию по Data Vault схеме
4. **Мониторинг**: Отслеживайте производительность и размеры таблиц

## Заключение

Для проекта с TPCH (тестовый датасет) миграция на Data Vault может не дать немедленных бизнес-преимуществ, но является отличной практикой для:

1. Изучения методологии Data Vault 2.0
2. Подготовки к реальным проектам с историческими данными
3. Построения гибкой и расширяемой архитектуры

Для production-проектов Data Vault особенно ценна при:
- Частых изменениях бизнес-требований
- Необходимости отслеживания истории изменений
- Интеграции данных из множества источников
