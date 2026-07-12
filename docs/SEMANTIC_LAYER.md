# Business Glossary

## Метрики

### total_revenue
**Описание:** Общая выручка от продаж  
**Формула:** SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT))  
**Группировка:** order_year, order_status, order_priority  
**Источник:** f_orders_stats, semantic_models (lineitem_details)

### order_count
**Описание:** Количество заказов  
**Формула:** COUNT(DISTINCT ORDER_HK)  
**Группировка:** order_year, order_status, order_priority  
**Источник:** f_orders_stats, semantic_models (orders_analysis)

### customer_count
**Описание:** Уникальное количество заказчиков  
**Формула:** COUNT(DISTINCT CUSTOMER_HK)  
**Группировка:** order_year, order_status  
**Источник:** f_orders_stats, semantic_models (customer_history)

### avg_order_value
**Описание:** Средний чек  
**Формула:** total_revenue / order_count  
**Группировка:** order_year, order_status  
**Источник:** f_orders_stats, semantic models (aggregated metrics)

### fill_rate_percentage
**Описание:** Доля завершенных заказов в процентах  
**Формула:** (filled_order_count / order_count) * 100  
**Группировка:** order_year  
**Источник:** semantic models (derived metrics)

### revenue_by_status
**Описание:** Выручка по статусу заказа  
**Формула:** SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT))  
**Фильтр:** order_status = 'O' (Open)  
**Группировка:** order_year, order_priority  
**Источник:** f_orders_stats, semantic models

### revenue_by_priority
**Описание:** Выручка по приоритету заказа  
**Формула:** SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT))  
**Группировка:** order_priority  
**Источник:** semantic models

### revenue_by_ship_mode
**Описание:** Выручка по способу доставки  
**Формула:** SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT))  
**Группировка:** ship_mode  
**Источник:** semantic_models (lineitem_details)

### revenue_by_season
**Описание:** Выручка по времени года  
**Формула:** SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT))  
**Группировка:** season  
**Источник:** semantic models, calendar

### revenue_by_day_of_week
**Описание:** Выручка по дням недели  
**Формула:** SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT))  
**Группировка:** day_of_week  
**Источник:** semantic models, calendar

### revenue_by_half_year
**Описание:** Выручка по полугодиям  
**Формула:** SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT))  
**Группировка:** half_year  
**Источник:** semantic models, calendar

### revenue_by_customer_segment
**Описание:** Выручка по сегменту клиента  
**Формула:** SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT))  
**Группировка:** customer_segment  
**Источник:** semantic_models (customer_history)

### total_quantity
**Описание:** Общее количество товаров  
**Формула:** SUM(L_QUANTITY)  
**Группировка:** order_year, ship_mode  
**Источник:** semantic_models (lineitem_details)

### total_discount
**Описание:** Общая сумма скидок  
**Формула:** SUM(L_EXTENDEDPRICE * L_DISCOUNT)  
**Группировка:** order_year, ship_mode  
**Источник:** semantic_models (lineitem_details)

### total_tax
**Описание:** Общая сумма налогов  
**Формула:** SUM(L_TAX)  
**Группировка:** order_year, ship_mode  
**Источник:** semantic_models (lineitem_details)

### discount_percentage
**Описание:** Средний процент скидки  
**Формула:** (total_discount / total_revenue) * 100  
**Группировка:** order_year  
**Источник:** semantic models (derived metrics)

### tax_percentage
**Описание:** Средний процент налога  
**Формула:** (total_tax / total_revenue) * 100  
**Группировка:** order_year  
**Источник:** semantic models (derived metrics)

### yearly_revenue_growth_rate
**Описание:** Темп роста выручки (Year-over-Year)  
**Формула:** ((yearly_revenue - lag(yearly_revenue, 1)) / lag(yearly_revenue, 1)) * 100  
**Группировка:** order_year  
**Источник:** semantic models (time series metrics)

### monthly_revenue_growth_rate
**Описание:** Темп роста выручки (Month-over-Month)  
**Формула:** ((monthly_revenue - lag(monthly_revenue, 1)) / lag(monthly_revenue, 1)) * 100  
**Группировка:** order_date  
**Источник:** semantic models (time series metrics)

## Измерения

### order_date
**Описание:** Дата заказа  
**Тип:** time  
**Гранулярность:** day  
**Источник:** semantic_models (orders_analysis), calendar

### order_status
**Описание:** Статус заказа  
**Тип:** categorical  
**Значения:** O (Open), F (Filled), P (Pending)  
**Источник:** semantic_models (orders_analysis, order_history)

### order_priority
**Описание:** Приоритет заказа  
**Тип:** categorical  
**Значения:** 1-URGENT, 2-HIGH, 3-MEDIUM, 4-NOT SPECIFIED, 5-LOW  
**Источник:** semantic_models (orders_analysis, order_history)

### product_type
**Описание:** Тип товара  
**Тип:** categorical  
**Значения:** STANDARD, ECONOMY, PREMIUM и др.  
**Источник:** semantic_models (lineitem_details)

### product_size
**Описание:** Размер товара  
**Тип:** categorical  
**Значения:** от 1 до 50  
**Источник:** semantic_models (lineitem_details)

### return_flag
**Описание:** Флаг возврата  
**Тип:** categorical  
**Значения:** R (Возвращен), N (Не возвращен)  
**Источник:** semantic_models (lineitem_details)

### line_status
**Описание:** Статус позиции  
**Тип:** categorical  
**Значения:** F (Завершена), O (В процессе)  
**Источник:** semantic_models (lineitem_details)

### ship_mode
**Описание:** Способ доставки  
**Тип:** categorical  
**Значения:** AIR, TRUCK, REG AIR, MAIL, SHIP, PIPE, FOB, PUSH  
**Источник:** semantic_models (lineitem_details)

### customer_segment
**Описание:** Сегмент клиента  
**Тип:** categorical  
**Значения:** AUTOMOBILE, BUILDING, FURNITURE, HOUSEHOLD, MACHINERY  
**Источник:** semantic_models (customer_history)

### load_date
**Описание:** Дата загрузки  
**Тип:** time  
**Гранулярность:** day  
**Источник:** semantic_models (customer_history, order_history)

### calendar dimensions
**Описание:** Временные измерения из единого календаря  
**Источник:** semantic_models (calendar)
- date_day, year, month, quarter, week_of_year
- day_of_week, season, half_year
- is_weekend, is_business_day, is_holiday
- month_start, quarter_start, week_start
- quarter_name, month_year, quarter_year

## Data Vault компоненты

### Hub (Хаб)
**Описание:** Хранит бизнес-ключи и служит центром интеграции  
**Примеры:** hub_customer, hub_order, hub_part, hub_supplier

### Link (Связь)
**Описание:** Представляет отношения между хабами (бизнес-процессы)  
**Примеры:** link_order_customer, link_order_lineitem

### Satellite (Сателлит)
**Описание:** Хранит описательные атрибуты с отслеживанием истории  
**Примеры:** sat_customer_details, sat_order_details, sat_lineitem_details

### Миграция семантического слоя
**Описание:** Новая архитектура семантического слоя на основе dbt Semantic Layer

**Фазы реализации:**
1. **Фаза 1:** Унификация semantic models (единый календарь, orders_analysis, lineitem_details)
2. **Фаза 2:** Переписать metrics.yml (ядро бизнес-метрик, удаление дубликатов)
3. **Фаза 3:** Удалить dimensions.yml (миграция в semantic_models.yml)
4. **Фаза 4:** Создать витрины данных (f_orders_stats, legacy витрины удалены)
5. **Фаза 5:** Документация и тестирование

**Преимущества:**
- Единая точка правды для всех метрик и измерений
- Отсутствие дублирования определений
- Прозрачность расчетов метрик
- Упрощенное добавление новых метрик

## SLA

### Время загрузки
- **Staging:** < 5 минут
- **Data Vault:** < 15 минут
- **Data Marts:** < 10 минут
- **Semantic Layer:** Real-time

### Актуальность данных
- **Staging:** Real-time
- **Data Vault:** Hourly
- **Data Marts:** Daily
- **Semantic Layer:** Real-time (через dbt Semantic Layer)

### Доступность
- **Staging:** 99.9%
- **Data Vault:** 99.9%
- **Data Marts:** 99.5%
- **Semantic Layer:** 99.9%

## Data Vault компоненты

### Hub (Хаб)
**Описание:** Хранит бизнес-ключи и служит центром интеграции  
**Примеры:** hub_customer, hub_order, hub_part, hub_supplier

### Link (Связь)
**Описание:** Представляет отношения между хабами (бизнес-процессы)  
**Примеры:** link_order_customer, link_order_lineitem

### Satellite (Сателлит)
**Описание:** Хранит описательные атрибуты с отслеживанием истории  
**Примеры:** sat_customer_details, sat_order_details, sat_lineitem_details

## SLA

### Время загрузки
- **Staging:** < 5 минут
- **Data Vault:** < 15 минут
- **Data Marts:** < 10 минут

### Актуальность данных
- **Staging:** Real-time
- **Data Vault:** Hourly
- **Data Marts:** Daily

### Доступность
- **Staging:** 99.9%
- **Data Vault:** 99.9%
- **Data Marts:** 99.5%
