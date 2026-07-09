# Семантический слой (Semantic Layer) в проекте dbt ClickHouse

## Обзор

Семантический слой — это абстракция поверх данных, которая переводит технические термины на язык бизнеса. Он обеспечивает единое понимание метрик, измерений и их расчетов для всех пользователей системы.

## Текущее состояние

### Что уже реализовано

- **Базовые описания источников**: `models/sources/sources.yml`
- **Описания моделей**: `models/marts/marts.yml` (минимальные)
- **Тесты данных**: `models/staging/staging.yml`
- **Документация архитектуры**: `docs/DATA_VAULT.md`, `docs/TPCH.md`, `docs/dv_concept_new.md`

### Критические пробелы

- ❌ Отсутствует `semantic_models.yml` с определениями семантических моделей
- ❌ Отсутствует `metrics.yml` с бизнес-метриками
- ❌ Отсутствуют описания измерений (dimensions)
- ❌ Нет документации по бизнес-глоссарию
- ❌ Существующие витрины не описаны как семантические модели

## Рекомендуемая структура

```
models/
├── semantic/
│   ├── semantic_models.yml
│   ├── metrics.yml
│   └── dimensions.yml
```

## Примеры конфигурации

### 1. semantic_models.yml

```yaml
version: 2

semantic_models:
  - name: orders_analysis
    model: ref('f_orders_stats_dv')
    description: "Агрегированная статистика по заказам для анализа"
    defaults:
      agg_time: O_ORDERDATE
    dimensions:
      - name: order_year
        expr: O_ORDERYEAR
        description: "Год заказа"
        type: time
        type_params:
          time_granularity: year
      - name: order_status
        expr: O_ORDERSTATUS
        description: "Статус заказа"
        type: categorical
      - name: order_priority
        expr: O_ORDERPRIORITY
        description: "Приоритет заказа"
        type: categorical
    measures:
      - name: num_orders
        expr: num_orders
        agg: sum
      - name: num_customers
        expr: num_customers
        agg: sum
      - name: revenue
        expr: revenue
        agg: sum

  - name: lineitem_details
    model: ref('f_lineorder_flat_dv')
    description: "Детальная информация о позициях заказов"
    dimensions:
      - name: order_date
        expr: O_ORDERDATE
        description: "Дата заказа"
        type: time
        type_params:
          time_granularity: day
      - name: return_flag
        expr: L_RETURNFLAG
        description: "Флаг возврата"
        type: categorical
      - name: line_status
        expr: L_LINESTATUS
        description: "Статус позиции"
        type: categorical
      - name: ship_mode
        expr: L_SHIPMODE
        description: "Способ доставки"
        type: categorical
    measures:
      - name: quantity
        expr: L_QUANTITY
        agg: sum
      - name: extended_price
        expr: L_EXTENDEDPRICE
        agg: sum
      - name: discount_amount
        expr: L_EXTENDEDPRICE * L_DISCOUNT
        agg: sum
      - name: tax_amount
        expr: L_TAX
        agg: sum
```

### 2. metrics.yml

```yaml
version: 2

metrics:
  # Агрегированные метрики
  - name: total_revenue
    description: "Общая выручка от продаж"
    type: simple
    type_params:
      measure: revenue
      agg: sum

  - name: order_count
    description: "Количество заказов"
    type: simple
    type_params:
      measure: num_orders
      agg: sum

  - name: customer_count
    description: "Уникальное количество заказчиков"
    type: simple
    type_params:
      measure: num_customers
      agg: sum

  - name: avg_order_value
    description: "Средний чек"
    type: derived
    type_params:
      expr: total_revenue / order_count

  # Метрики с фильтрацией
  - name: revenue_by_status
    description: "Выручка по статусу заказа"
    type: simple
    type_params:
      measure: revenue
      agg: sum
      filters:
        - dimension: order_status
          value: "O"

  # Метрики со временем
  - name: monthly_revenue
    description: "Выручка по месяцам"
    type: simple
    type_params:
      measure: revenue
      agg: sum
      window: 1 month

  - name: revenue_growth_rate
    description: "Темп роста выручки (YOY)"
    type: derived
    type_params:
      expr: ((monthly_revenue - monthly_revenue_previous_year) / monthly_revenue_previous_year) * 100

  # Метрики по категориям
  - name: revenue_by_ship_mode
    description: "Выручка по способу доставки"
    type: simple
    type_params:
      measure: revenue
      agg: sum
      group_by:
        - ship_mode
```

"### 3. dimensions.yml\n\n```yaml\nversion: 2\n\ndimensions:\n  # Временные измерения\n  - name: time_period\n    description: \"Период времени\"\n    type: time\n    sql: O_ORDERDATE\n    type_params:\n      time_granularity: day\n      time_granularity_values:\n        - day\n        - week\n        - month\n        - quarter\n        - year\n    references:\n      - semantic_model: orders_analysis\n        dimension: order_date\n      - semantic_model: customer_history\n        dimension: load_date\n      - semantic_model: order_history\n        dimension: load_date\n\n  # Измерения заказа\n  - name: order_status_dim\n    description: \"Статус заказа\"\n    type: categorical\n    sql: O_ORDERSTATUS\n    values:\n      - value: \"O\"\n        label: \"Open\"\n      - value: \"F\"\n        label: \"Filled\"\n      - value: \"P\"\n        label: \"Pending\"\n    references:\n      - semantic_model: orders_analysis\n        dimension: order_status\n      - semantic_model: order_history\n        dimension: order_status\n\n  - name: order_priority_dim\n    description: \"Приоритет заказа\"\n    type: categorical\n    sql: O_ORDERPRIORITY\n    values:\n      - value: \"1-URGENT\"\n        label: \"Ургент\"\n      - value: \"2-HIGH\"\n        label: \"Высокий\"\n      - value: \"3-MEDIUM\"\n        label: \"Средний\"\n      - value: \"4-NOT SPECIFIED\"\n        label: \"Не указан\"\n      - value: \"5-LOW\"\n        label: \"Низкий\"\n    references:\n      - semantic_model: orders_analysis\n        dimension: order_priority\n      - semantic_model: order_history\n        dimension: order_priority\n\n  # Измерения клиента\n  - name: customer_segment_dim\n    description: \"Сегмент клиента\"\n    type: categorical\n    sql: C_MKTSEGMENT\n    values:\n      - value: \"AUTOMOBILE\"\n        label: \"Автомобили\"\n      - value: \"BUILDING\"\n        label: \"Строительство\"\n      - value: \"FURNITURE\"\n        label: \"Мебель\"\n      - value: \"HOUSEHOLD\"\n        label: \"Товары для дома\"\n      - value: \"MACHINERY\"\n        label: \"Машины и оборудование\"\n    references:\n      - semantic_model: customer_history\n        dimension: customer_segment\n\n  # Измерения товара\n  - name: product_type_dim\n    description: \"Тип товара\"\n    type: categorical\n    sql: P_TYPE\n    references:\n      - semantic_model: lineitem_details\n        dimension: product_type\n\n  - name: product_size_dim\n    description: \"Размер товара\"\n    type: categorical\n    sql: P_SIZE\n    references:\n      - semantic_model: lineitem_details\n        dimension: product_size\n\n  # Измерения доставки\n  - name: ship_mode_dim\n    description: \"Способ доставки\"\n    type: categorical\n    sql: L_SHIPMODE\n    references:\n      - semantic_model: lineitem_details\n        dimension: ship_mode\n\n  - name: return_flag_dim\n    description: \"Флаг возврата\"\n    type: categorical\n    sql: L_RETURNFLAG\n    values:\n      - value: \"R\"\n        label: \"Возвращен\"\n      - value: \"N\"\n        label: \"Не возвращен\"\n    references:\n      - semantic_model: lineitem_details\n        dimension: return_flag\n\n  - name: line_status_dim\n    description: \"Статус позиции\"\n    type: categorical\n    sql: L_LINESTATUS\n    values:\n      - value: \"F\"\n        label: \"Завершена\"\n      - value: \"O\"\n        label: \"В процессе\"\n    references:\n      - semantic_model: lineitem_details\n        dimension: line_status\n\n  # Временные измерения с разными гранулярностями\n  - name: order_month\n    description: \"Месяц заказа\"\n    type: time\n    sql: toYearMonth(O_ORDERDATE)\n    type_params:\n      time_granularity: month\n    references:\n      - semantic_model: orders_analysis\n        dimension: order_month\n      - semantic_model: lineitem_details\n        dimension: order_month\n\n  - name: order_quarter\n    description: \"Квартал заказа\"\n    type: time\n    sql: toStartOfQuarter(O_ORDERDATE)\n    type_params:\n      time_granularity: quarter\n    references:\n      - semantic_model: orders_analysis\n        dimension: order_quarter\n      - semantic_model: lineitem_details\n        dimension: order_quarter\n\n  - name: order_week\n    description: \"Неделя заказа\"\n    type: time\n    sql: toStartOfWeek(O_ORDERDATE, 1)\n    type_params:\n      time_granularity: week\n    references:\n      - semantic_model: orders_analysis\n        dimension: order_week\n      - semantic_model: lineitem_details\n        dimension: order_week\n\n  - name: order_year_month\n    description: \"Год и месяц заказа\"\n    type: categorical\n    sql: toString(toYear(O_ORDERDATE)) + '-' + lpad(toString(toMonth(O_ORDERDATE)), 2, '0')\n    references:\n      - semantic_model: orders_analysis\n        dimension: order_year_month\n      - semantic_model: lineitem_details\n        dimension: order_year_month\n\n  - name: order_quarter_name\n    description: \"Название квартала\"\n    type: categorical\n    sql: toString(toYear(O_ORDERDATE)) + '-Q' + toString(toQuarter(O_ORDERDATE))\n    references:\n      - semantic_model: orders_analysis\n        dimension: order_quarter_name\n      - semantic_model: lineitem_details\n        dimension: order_quarter_name\n\n  - name: season\n    description: \"Время года\"\n    type: categorical\n    sql: CASE WHEN toMonth(O_ORDERDATE) BETWEEN 3 AND 5 THEN 'Spring' WHEN toMonth(O_ORDERDATE) BETWEEN 6 AND 8 THEN 'Summer' WHEN toMonth(O_ORDERDATE) BETWEEN 9 AND 11 THEN 'Autumn' ELSE 'Winter' END\n    references:\n      - semantic_model: orders_analysis\n        dimension: season\n      - semantic_model: lineitem_details\n        dimension: season\n\n  - name: half_year\n    description: \"Полугодие\"\n    type: categorical\n    sql: 'H' + toString(intDiv(toMonth(O_ORDERDATE) - 1, 6) + 1)\n    references:\n      - semantic_model: orders_analysis\n        dimension: half_year\n      - semantic_model: lineitem_details\n        dimension: half_year\n\n  - name: day_of_week\n    description: \"День недели\"\n    type: categorical\n    sql: toDayOfWeek(O_ORDERDATE)\n    values:\n      - value: 1\n        label: \"Понедельник\"\n      - value: 2\n        label: \"Вторник\"\n      - value: 3\n        label: \"Среда\"\n      - value: 4\n        label: \"Четверг\"\n      - value: 5\n        label: \"Пятница\"\n      - value: 6\n        label: \"Суббота\"\n      - value: 7\n        label: \"Воскресенье\"\n    references:\n      - semantic_model: orders_analysis\n        dimension: day_of_week\n      - semantic_model: lineitem_details\n        dimension: day_of_week\n\n  - name: is_weekend\n    description: \"Выходной день\"\n    type: categorical\n    sql: if(toDayOfWeek(O_ORDERDATE) IN (1, 7), true, false)\n    values:\n      - value: true\n        label: \"Выходной\"\n      - value: false\n        label: \"Рабочий\"\n    references:\n      - semantic_model: orders_analysis\n        dimension: is_weekend\n      - semantic_model: lineitem_details\n        dimension: is_weekend\n\n  - name: is_business_day\n    description: \"Рабочий день\"\n    type: categorical\n    sql: if(toDayOfWeek(O_ORDERDATE) NOT IN (1, 7), true, false)\n    values:\n      - value: true\n        label: \"Рабочий\"\n      - value: false\n        label: \"Не рабочий\"\n    references:\n      - semantic_model: orders_analysis\n        dimension: is_business_day\n      - semantic_model: lineitem_details\n        dimension: is_business_day\n```"}

## Практические рекомендации

### 1. Использование Data Vault компонентов

Satellites в Data Vault 2.0 идеально подходят для создания семантических моделей:

```yaml
semantic_models:
  - name: customer_history
    model: ref('sat_customer_details')
    description: "История изменений данных клиентов"
    dimensions:
      - name: load_date
        expr: LOAD_DATE
        description: "Дата загрузки"
        type: time
      - name: customer_name
        expr: C_NAME
        description: "Имя клиента"
      - name: customer_address
        expr: C_ADDRESS
        description: "Адрес клиента"
    measures:
      - name: is_active
        expr: 1
        agg: max
```

### 2. BI интеграция

Для BI инструментов (Tableau, Metabase, Redash) семантический слой обеспечивает:

- Единые определения метрик
- Предварительно агрегированные данные
- Готовые измерения и иерархии
- Понятные названия полей

### 3. ClickHouse-специфичные оптимизации

```yaml
# Для часто используемых метрик создайте materialized views
# Вместо сложных JOINов используйте предварительно агрегированные данные

# Пример: предварительно агрегированная метрика по месяцам
{{ config(
    materialized='materialized_view',
    engine='SummingMergeTree()',
    order_by=['O_ORDERMONTH']
) }}

SELECT
    toStartOfMonth(O_ORDERDATE) AS O_ORDERMONTH,
    COUNT(DISTINCT O_ORDERKEY) AS num_orders,
    SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT)) AS revenue
FROM {{ ref('sat_order_details') }}
GROUP BY O_ORDERMONTH
```

"## План реализации\n\n### Фаза 1 (2-3 дня): Базовая семантика\n\n1. Создать `models/semantic/` директорию\n2. Создать `semantic_models.yml` с описанием `f_orders_stats_dv`\n3. Создать `metrics.yml` с ключевыми метриками\n4. Создать `dimensions.yml` с основными измерениями\n\n### Фаза 2 (1-2 дня): Расширение\n\n1. Добавить семантические модели для `f_lineorder_flat_dv`\n2. Добавить метрики со временем (time intelligence)\n3. Добавить описания Data Vault компонентов\n4. Добавить `dim_calendar` для унификации временных измерений\n5. Добавить новые измерения (order_month, order_quarter, order_week, season, half_year, day_of_week, is_weekend, is_business_day)\n\n### Фаза 2.5 (1 день): Улучшение dimensions.yml\n\n1. Добавить параметр `sql` для каждого измерения\n2. Добавить параметр `references` для связывания измерений с semantic_models\n3. Добавить недостающие временные измерения с разными гранулярностями\n\n### Фаза 3 (постоянно): Улучшение\n\n1. Постепенно добавлять новые метрики\n2. Создать документацию по бизнес-глоссарию\n3. Внедрить CI проверки для валидации семантических моделей"}

## Преимущества реализации семантического слоя

✅ **Для бизнеса:** Единый словарь данных, прозрачность расчетов  
✅ **Для аналитиков:** Самообслуживание данных, быстрое создание отчетов  
✅ **Для разработчиков:** Упрощенная интеграция BI инструментов  
✅ **Для инфраструктуры:** Оптимизированные запросы, предсказуемая производительность

## Заключение

Семантический слой — это не просто набор YAML файлов, а фундаментальная часть архитектуры данных. Он обеспечивает:

- Единую версию правды для всех метрик
- Упрощение доступа к данным для нетехнических пользователей
- Снижение риска ошибок при расчете метрик
- Простоту интеграции с BI инструментами

Начните с малого, постепенно расширяйте и улучшайте — это инвестиция в будущее вашей аналитической инфраструктуры.
