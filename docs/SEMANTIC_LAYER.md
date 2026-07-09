# Business Glossary

## Метрики

### total_revenue
**Описание:** Общая выручка от продаж  
**Формула:** SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT))  
**Группировка:** order_year, order_status, order_priority, ship_mode  
**Источник:** f_orders_stats_dv

### order_count
**Описание:** Количество заказов  
**Формула:** COUNT(DISTINCT O_ORDERKEY)  
**Группировка:** order_year, order_status, order_priority  
**Источник:** f_orders_stats_dv

### customer_count
**Описание:** Уникальное количество заказчиков  
**Формула:** COUNT(DISTINCT C_CUSTKEY)  
**Группировка:** order_year, order_status  
**Источник:** f_orders_stats_dv

### avg_order_value
**Описание:** Средний чек  
**Формула:** total_revenue / order_count  
**Группировка:** order_year, order_status  
**Источник:** f_orders_stats_dv

### revenue_by_status
**Описание:** Выручка по статусу заказа  
**Формула:** SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT))  
**Фильтр:** order_status = 'O' (Open)  
**Группировка:** order_year, order_priority  
**Источник:** f_orders_stats_dv

### monthly_revenue
**Описание:** Выручка по месяцам  
**Формула:** SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT))  
**Группировка:** order_month  
**Источник:** f_orders_stats_dv

### revenue_growth_rate
**Описание:** Темп роста выручки (YOY)  
**Формула:** ((monthly_revenue - monthly_revenue_previous_year) / monthly_revenue_previous_year) * 100  
**Группировка:** order_month  
**Источник:** f_orders_stats_dv

### revenue_by_ship_mode
**Описание:** Выручка по способу доставки  
**Формула:** SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT))  
**Группировка:** ship_mode  
**Источник:** f_lineorder_flat_dv

### total_quantity
**Описание:** Общее количество товаров  
**Формула:** SUM(L_QUANTITY)  
**Группировка:** order_year, ship_mode  
**Источник:** f_lineorder_flat_dv

### total_discount
**Описание:** Общая сумма скидок  
**Формула:** SUM(L_EXTENDEDPRICE * L_DISCOUNT)  
**Группировка:** order_year, ship_mode  
**Источник:** f_lineorder_flat_dv

### total_tax
**Описание:** Общая сумма налогов  
**Формула:** SUM(L_TAX)  
**Группировка:** order_year, ship_mode  
**Источник:** f_lineorder_flat_dv

## Измерения

### order_year
**Описание:** Год заказа  
**Тип:** time  
**Гранулярность:** year  
**Источник:** f_orders_stats_dv

### order_status
**Описание:** Статус заказа  
**Тип:** categorical  
**Значения:** O (Open), F (Filled), P (Pending)  
**Источник:** f_orders_stats_dv, f_lineorder_flat_dv

### order_priority
**Описание:** Приоритет заказа  
**Тип:** categorical  
**Значения:** 1-URGENT, 2-HIGH, 3-MEDIUM, 4-NOT SPECIFIED, 5-LOW  
**Источник:** f_orders_stats_dv, f_lineorder_flat_dv

### order_date
**Описание:** Дата заказа  
**Тип:** time  
**Гранулярность:** day  
**Источник:** f_lineorder_flat_dv

### return_flag
**Описание:** Флаг возврата  
**Тип:** categorical  
**Значения:** R (Возвращен), N (Не возвращен)  
**Источник:** f_lineorder_flat_dv

### line_status
**Описание:** Статус позиции  
**Тип:** categorical  
**Значения:** F (Завершена), O (В процессе)  
**Источник:** f_lineorder_flat_dv

### ship_mode
**Описание:** Способ доставки  
**Тип:** categorical  
**Источник:** f_lineorder_flat_dv

### customer_segment
**Описание:** Сегмент клиента  
**Тип:** categorical  
**Значения:** AUTOMOBILE, BUILDING, FURNITURE, HOUSEHOLD, MACHINERY  
**Источник:** sat_customer_details

### load_date
**Описание:** Дата загрузки  
**Тип:** time  
**Гранулярность:** day  
**Источник:** sat_customer_details, sat_order_details

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
