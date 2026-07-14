# Semantic Layer Documentation

## Overview

The Semantic Layer provides a single source of truth for business metrics and semantic models. It enables consistent data definitions across the organization and simplifies reporting through BI tools.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    BI Layer (Tableau/Metabase)                      │
│                    Uses dbt Semantic Layer                          │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│              Semantic Layer (single source of truth)                │
│                    metrics.yml + semantic_models.yml                │
│  - Unified definitions                                              │
│  - Consistent naming                                                │
│  - Centralized documentation                                        │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│                      Data Mart Layer                                │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  f_orders_stats (aggregated, optimized for reporting)         │  │
│  │  f_orders_stats_dv (Data Vault-based view)                    │  │
│  └───────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│                  Core Data Store (Data Vault 2.0)                   │
│  Hubs (business keys)                                               │
│  Links (relationships)                                              │
│  Satellites (history + attributes)                                  │
└─────────────────────────────────────────────────────────────────────┘
```

## Components

### Metrics

Metrics are business definitions that can be reused across reports.

| Metric | Type | Description | Owner |
|--------|------|-------------|-------|
| `total_revenue` | Simple | Общая выручка от продаж | analytics_team |
| `order_count` | Simple | Количество заказов | analytics_team |
| `customer_count` | Simple | Количество уникальных заказчиков | analytics_team |
| `avg_order_value` | Derived | Средний чек | analytics_team |
| `monthly_revenue` | Simple | Выручка по месяцам | analytics_team |
| `yearly_revenue_growth_rate` | Derived | Темп роста выручки (YoY) | analytics_team |
| `revenue_by_customer_segment` | Simple | Выручка по сегменту клиентов | marketing_team |
| `total_quantity` | Simple | Общее количество товаров | analytics_team |
| `total_discount` | Simple | Общая сумма скидок | analytics_team |

### Semantic Models

Semantic models define the data structures for metrics.

| Model | Source | Description | Owner |
|-------|--------|-------------|-------|
| `orders_analysis` | `sat_order_details` | Детальная информация о заказах | analytics_team |
| `lineitem_details` | `mv_lineitem_enriched` | Детальная информация о позициях заказов | analytics_team |
| `customer_history` | `sat_customer_details` | История изменений данных клиентов | analytics_team |
| `order_history` | `sat_order_details` | История изменений данных заказов | analytics_team |
| `calendar` | `dim_calendar` | Унифицированный календарь | analytics_team |

## Usage

### Run semantic models

```bash
dbt run-operation dbt_semantic_layer.implement
```

### Validate metrics

```bash
dbt validate-metrics
```

### List semantic models

```bash
dbt ls -s semantic_layer
```

### Query metrics via dbt

```bash
dbt run --models semantic.total_revenue
dbt run --models semantic.order_count_by_customer_segment
```

## Best Practices

1. **Consistent Naming**: Use clear, consistent metric names
2. **Documentation**: Always document metric definitions
3. **Ownership**: Assign owners to each metric
4. **Testing**: Validate metrics before production use
