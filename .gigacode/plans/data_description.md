# Описание слоев данных и схемы DWH

## Обзор архитектуры

Проект реализует классическую архитектуру Data Warehouse по паттерну **Star Schema** с использованием dbt для преобразования данных и ClickHouse в качестве целевой СУБД.

### Архитектурные слои

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              DATA MART LAYER                                │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                         f_orders_stats (Aggregated)                   │  │
│  │  Агрегированные метрики по заказам: количество заказов, клиентов,     │  │
│  │  выручка по годам, статусам и приоритетам                             │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                       f_lineorder_flat (Denormalized)                 │  │
│  │  Широкая denormalized-таблица со всеми связанными данными             │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
                                      ▲
                                      │ JOINs
                                      │
┌─────────────────────────────────────────────────────────────────────────────┐
│                           STAGING LAYER (Cleaned)                           │
│  ┌──────────────────┬──────────────────┬──────────────────┐                 │
│  │   stg_customer   │   stg_orders     │  stg_lineitem    │                 │
│  │   (dim customer) │   (fact orders)  │  (fact lineitem) │                 │
│  └──────────────────┴──────────────────┴──────────────────┘                 │
│  ┌──────────────────┬──────────────────┐                                    │
│  │    stg_part      │  stg_supplier    │                                    │
│  │   (dim part)     │  (dim supplier)  │                                    │
│  └──────────────────┴──────────────────┘                                    │
└─────────────────────────────────────────────────────────────────────────────┘
                                      ▲
                                      │ SELECT FROM
                                      │
┌─────────────────────────────────────────────────────────────────────────────┐
│                          SOURCE LAYER (S3 External Tables)                  │
│  ┌──────────────────┬──────────────────┬──────────────────┐                 │
│  │   src_customer   │   src_orders     │  src_lineitem    │                 │
│  └──────────────────┴──────────────────┴──────────────────┘                 │
│  ┌──────────────────┬──────────────────┐                                    │
│  │    src_part      │  src_supplier    │                                    │
│  └──────────────────┴──────────────────┘                                    │
└─────────────────────────────────────────────────────────────────────────────┘
                                      ▲
                                      │ S3 External Data
                                      │
                         https://storage.yandexcloud.net/otus-dwh/tpch-dbgen-1g/
```

---

## Слой источников данных (Source Layer)

### Описание
Исходные данные загружаются из S3-хранилища Yandex Cloud как **EXTERNAL TABLES** в ClickHouse. Используется формат `CustomSeparated` с разделителем `|`.

### Таблицы источников

| Имя таблицы | Описание | Источник данных | Размер данных |
|-------------|----------|-----------------|---------------|
| `src_customer` | Клиенты (измерение) | `customer.tbl` | ~150K строк |
| `src_orders` | Заказы (факт) | `orders.tbl` | ~1.5M строк |
| `src_lineitem` | Позиции заказов (факт) | `lineitem.tbl` | ~6M строк |
| `src_part` | Части/Товары (измерение) | `part.tbl` | ~200K строк |
| `src_supplier` | Поставщики (измерение) | `supplier.tbl` | ~20K строк |

### Структура таблиц источников

#### src_customer
| Поле | Тип | Описание |
|------|-----|----------|
| `C_CUSTKEY` | UInt32 | Идентификатор клиента |
| `C_NAME` | String | Название компании клиента |
| `C_ADDRESS` | String | Адрес клиента |
| `C_NATIONKEY` | UInt32 | Идентификатор страны (внешний ключ) |
| `C_PHONE` | String | Телефон клиента |
| `C_ACCTBAL` | Decimal(15,2) | Баланс счета |
| `C_MKTSEGMENT` | LowCardinality(String) | Рыночный сегмент |
| `C_COMMENT` | String | Комментарий |

#### src_orders
| Поле | Тип | Описание |
|------|-----|----------|
| `O_ORDERKEY` | UInt32 | Идентификатор заказа |
| `O_CUSTKEY` | UInt32 | Идентификатор клиента (внешний ключ) |
| `O_ORDERSTATUS` | LowCardinality(String) | Статус заказа (F=fulfilled, O=open, P=pending) |
| `O_TOTALPRICE` | Decimal(15,2) | Общая стоимость заказа |
| `O_ORDERDATE` | Date | Дата заказа |
| `O_ORDERPRIORITY` | LowCardinality(String) | Приоритет заказа (1-URGENT, 2-HIGH и т.д.) |
| `O_CLERK` | String | Идентификатор сотрудника |
| `O_SHIPPRIORITY` | UInt8 | Приоритет доставки |
| `O_COMMENT` | String | Комментарий |

#### src_lineitem
| Поле | Тип | Описание |
|------|-----|----------|
| `L_ORDERKEY` | UInt32 | Идентификатор заказа (внешний ключ) |
| `L_PARTKEY` | UInt32 | Идентификатор части (внешний ключ) |
| `L_SUPPKEY` | UInt32 | Идентификатор поставщика (внешний ключ) |
| `L_LINENUMBER` | UInt8 | Номер позиции в заказе |
| `L_QUANTITY` | Decimal(15,2) | Количество заказанных единиц |
| `L_EXTENDEDPRICE` | Decimal(15,2) | Цена за единицу |
| `L_DISCOUNT` | Decimal(15,2) | Скидка |
| `L_TAX` | Decimal(15,2) | Налог |
| `L_RETURNFLAG` | LowCardinality(String) | Флаг возврата (A=returned, R=received, N=not returned) |
| `L_LINESTATUS` | LowCardinality(String) | Статус позиции (F=fulfilled, O=open) |
| `L_SHIPDATE` | Date | Дата доставки |
| `L_COMMITDATE` | Date | Дата подтверждения |
| `L_RECEIPTDATE` | Date | Дата получения |
| `L_SHIPINSTRUCT` | String | Инструкция по доставке |
| `L_SHIPMODE` | LowCardinality(String) | Способ доставки |
| `L_COMMENT` | String | Комментарий |

#### src_part
| Поле | Тип | Описание |
|------|-----|----------|
| `P_PARTKEY` | UInt32 | Идентификатор части |
| `P_NAME` | String | Название части |
| `P_MFGR` | LowCardinality(String) | Производитель |
| `P_BRAND` | LowCardinality(String) | Марка |
| `P_TYPE` | LowCardinality(String) | Тип части |
| `P_SIZE` | UInt8 | Размер |
| `P_CONTAINER` | LowCardinality(String) | Упаковка |
| `P_RETAILPRICE` | Decimal(15,2) | Розничная цена |
| `P_COMMENT` | String | Комментарий |

#### src_supplier
| Поле | Тип | Описание |
|------|-----|----------|
| `S_SUPPKEY` | UInt32 | Идентификатор поставщика |
| `S_NAME` | String | Название поставщика |
| `S_ADDRESS` | String | Адрес поставщика |
| `S_NATIONKEY` | UInt32 | Идентификатор страны (внешний ключ) |
| `S_PHONE` | String | Телефон поставщика |
| `S_ACCTBAL` | Decimal(15,2) | Баланс счета |
| `S_COMMENT` | String | Комментарий |

---

## Слой стадинга (Staging Layer)

### Описание
Стадинг-модели очищают и трансформируют исходные данные. Используется движок `MergeTree` с оптимальной сортировкой и партиционированием.

### Таблицы стадинга

| Имя таблицы | Описание | Тип | Ключевые поля |
|-------------|----------|-----|---------------|
| `stg_customer` | Очищенные данные клиентов | Dim | `C_CUSTKEY` (PK) |
| `stg_orders` | Очищенные данные заказов | Fact | `O_ORDERKEY` (PK) |
| `stg_lineitem` | Очищенные данные позиций заказов | Fact | `L_ITEMKEY` (PK), `L_ORDERKEY` (FK) |
| `stg_part` | Очищенные данные частей | Dim | `P_PARTKEY` (PK) |
| `stg_supplier` | Очищенные данные поставщиков | Dim | `S_SUPPKEY` (PK) |

### Структура стадинг-моделей

#### stg_customer
| Поле | Тип | Описание | П��имечание |
|------|-----|----------|------------|
| `C_CUSTKEY` | UInt32 | Идентификатор клиента | PK, unique |
| `C_NAME` | String | Название компании клиента | |
| `C_ADDRESS` | String | Адрес клиента | |
| `C_NATIONKEY` | UInt32 | Идентификатор страны | FK |
| `C_PHONE` | String | Телефон клиента | |
| `C_ACCTBAL` | Decimal(15,2) | Баланс счета | |
| `C_MKTSEGMENT` | LowCardinality(String) | Рыночный сегмент | |
| `C_COMMENT` | String | Комментарий | |

**Конфигурация**: `engine='MergeTree()', order_by='C_CUSTKEY'`

#### stg_orders
| Поле | Тип | Описание | Примечание |
|------|-----|----------|------------|
| `O_ORDERKEY` | UInt32 | Идентификатор заказа | PK, unique |
| `O_CUSTKEY` | UInt32 | Идентификатор клиента | FK |
| `O_ORDERSTATUS` | LowCardinality(String) | Статус заказа | |
| `O_TOTALPRICE` | Decimal(15,2) | Общая стоимость заказа | |
| `O_ORDERDATE` | Date | Дата заказа | |
| `O_ORDERPRIORITY` | LowCardinality(String) | Приоритет заказа | |
| `O_CLERK` | String | Идентификатор сотрудника | |
| `O_SHIPPRIORITY` | UInt8 | Приоритет доставки | |
| `O_COMMENT` | String | Комментарий | |

**Конфигурация**: `engine='MergeTree()', order_by=['O_ORDERKEY']`

#### stg_lineitem
| Поле | Тип | Описание | Примечание |
|------|-----|----------|------------|
| `L_ITEMKEY` | UInt32 | Уникальный идентификатор позиции | PK, сгенерирован (surrogate key) |
| `L_ORDERKEY` | UInt32 | Идентификатор заказа | FK |
| `L_PARTKEY` | UInt32 | Идентификатор части | FK |
| `L_SUPPKEY` | UInt32 | Идентификатор поставщика | FK |
| `L_LINENUMBER` | UInt8 | Номер позиции в заказе | |
| `L_QUANTITY` | Decimal(15,2) | Количество заказанных единиц | |
| `L_EXTENDEDPRICE` | Decimal(15,2) | Цена за единицу | |
| `L_DISCOUNT` | Decimal(15,2) | Скидка | |
| `L_TAX` | Decimal(15,2) | Налог | |
| `L_RETURNFLAG` | LowCardinality(String) | Флаг возврата | |
| `L_LINESTATUS` | LowCardinality(String) | Статус позиции | |
| `L_SHIPDATE` | Date | Дата доставки | PK (part) |
| `L_COMMITDATE` | Date | Дата подтверждения | |
| `L_RECEIPTDATE` | Date | Дата получения | |
| `L_SHIPINSTRUCT` | String | Инструкция по доставке | |
| `L_SHIPMODE` | LowCardinality(String) | Способ доставки | |
| `L_COMMENT` | String | Комментарий | |

**Конфигурация**: `engine='MergeTree()', order_by=['L_SHIPDATE', 'L_ORDERKEY'], partition_by='toYear(L_SHIPDATE)'`

> **Примечание**: `L_ITEMKEY` генерируется с помощью `dbt_utils.generate_surrogate_key(['L_ORDERKEY', 'L_LINENUMBER'])`

#### stg_part
| Поле | Тип | Описание | Примечание |
|------|-----|----------|------------|
| `P_PARTKEY` | UInt32 | Идентификатор части | PK, unique |
| `P_NAME` | String | Название части | |
| `P_MFGR` | LowCardinality(String) | Производитель | |
| `P_BRAND` | LowCardinality(String) | Марка | |
| `P_TYPE` | LowCardinality(String) | Тип части | |
| `P_SIZE` | UInt8 | Размер | |
| `P_CONTAINER` | LowCardinality(String) | Упаковка | |
| `P_RETAILPRICE` | Decimal(15,2) | Розничная цена | |
| `P_COMMENT` | String | Комментарий | |

**Конфигурация**: `engine='MergeTree()', order_by=['P_PARTKEY']`

#### stg_supplier
| Поле | Тип | Описание | Примечание |
|------|-----|----------|------------|
| `S_SUPPKEY` | UInt32 | Идентификатор поставщика | PK, unique |
| `S_NAME` | String | Название поставщика | |
| `S_ADDRESS` | String | Адрес поставщика | |
| `S_NATIONKEY` | UInt32 | Идентификатор страны | FK |
| `S_PHONE` | String | Телефон поставщика | |
| `S_ACCTBAL` | Decimal(15,2) | Баланс счета | |
| `S_COMMENT` | String | Комментарий | |

**Конфигурация**: `engine='MergeTree()', order_by=['S_SUPPKEY']`

---

## Слой Data Mart (Marts Layer)

### Описание
Финальные агрегированные таблицы для аналитики. Созданы по паттерну Star Schema.

### Таблицы Data Mart

#### f_lineorder_flat (Denormalized Fact Table)

**Описание**: Широкая denormalized-таблица, содержащая все данные о заказах и связанных с ними сущностях (клиенты, части, поставщики, позиции заказов). Предназначена для быстрых ad-hoc запросов без соединений.

**Тип**: Denormalized Fact Table

**Конфигурация**:
```sql
engine='MergeTree()',
order_by=['L_SHIPDATE', 'L_ORDERKEY'],
partition_by='toYear(L_SHIPDATE)'
```

**Структура**:

##### Поля из таблицы lineitem (факты)
- `L_ORDERKEY`, `L_PARTKEY`, `L_SUPPKEY`, `L_LINENUMBER`
- `L_QUANTITY`, `L_EXTENDEDPRICE`, `L_DISCOUNT`, `L_TAX`
- `L_RETURNFLAG`, `L_LINESTATUS`, `L_SHIPDATE`, `L_COMMITDATE`
- `L_RECEIPTDATE`, `L_SHIPINSTRUCT`, `L_SHIPMODE`, `L_COMMENT`

##### Поля из таблицы orders (факты)
- `O_ORDERKEY`, `O_CUSTKEY`, `O_ORDERSTATUS`, `O_TOTALPRICE`
- `O_ORDERDATE`, `O_ORDERPRIORITY`, `O_CLERK`, `O_SHIPPRIORITY`, `O_COMMENT`

##### Поля из таблицы customer (измерения)
- `C_CUSTKEY`, `C_NAME`, `C_ADDRESS`, `C_NATIONKEY`, `C_PHONE`
- `C_ACCTBAL`, `C_MKTSEGMENT`, `C_COMMENT`

##### Поля из таблицы supplier (измерения)
- `S_SUPPKEY`, `S_NAME`, `S_ADDRESS`, `S_NATIONKEY`, `S_PHONE`
- `S_ACCTBAL`, `S_COMMENT`

##### Поля из таблицы part (измерения)
- `P_PARTKEY`, `P_NAME`, `P_MFGR`, `P_BRAND`, `P_TYPE`
- `P_SIZE`, `P_CONTAINER`, `P_RETAILPRICE`, `P_COMMENT`

**Связи**:
```
stg_lineitem (L_ORDERKEY) ──► stg_orders (O_ORDERKEY) ──► stg_customer (O_CUSTKEY = C_CUSTKEY)
                                              │
                                              └──► stg_lineitem (L_PARTKEY) ──► stg_part (P_PARTKEY)
                                              └──► stg_lineitem (L_SUPPKEY) ──► stg_supplier (S_SUPPKEY)
```

---

#### f_orders_stats (Aggregated Data Mart)

**Описание**: Агрегированная таблица статистики по заказам. Предназначена для отчетности и аналитики.

**Тип**: Aggregated Fact Table

**Конфигурация**:
```sql
engine='MergeTree()',
order_by=['']
```

**Структура**:

| Поле | Тип | Описание | Примечание |
|------|-----|----------|------------|
| `O_ORDERYEAR` | UInt16 | Год заказа | из `toYear(O_ORDERDATE)` |
| `O_ORDERSTATUS` | LowCardinality(String) | Статус заказа | |
| `O_ORDERPRIORITY` | LowCardinality(String) | Приоритет заказа | |
| `num_orders` | UInt64 | Количество уникальных заказов | `count(DISTINCT O_ORDERKEY)` |
| `num_customers` | UInt64 | Количество уникальных клиентов | `count(DISTINCT C_CUSTKEY)` |
| `revenue` | Decimal(15,2) | Выручка (с учетом скидок) | `sum(L_EXTENDEDPRICE * L_DISCOUNT)` |

**Группировка**:
```sql
GROUP BY
    toYear(O_ORDERDATE),
    O_ORDERSTATUS,
    O_ORDERPRIORITY
```

**Ожидаемое количество строк**: 45 (4 года × 3 статуса × 4 приоритета)

---

## Схема связей (Entity-Relationship Diagram)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                    STARSHEMA                                        │
└─────────────────────────────────────────────────────────────────────────────────────┘

                         ┌─────────────────────┐
                         │   stg_orders        │
                         │  (Fact Orders)      │
                         ├─────────────────────┤
                         │ O_ORDERKEY (PK)     │◄───┐
                         │ O_CUSTKEY (FK)      │    │
                         │ O_ORDERSTATUS       │    │
                         │ O_TOTALPRICE        │    │
                         │ O_ORDERDATE         │    │
                         │ O_ORDERPRIORITY     │    │
                         │ O_CLERK             │    │
                         │ O_SHIPPRIORITY      │    │
                         │ O_COMMENT           │    │
                         └─────────────────────┘    │
                                  ▲                 │
                                  │                 │
              ┌───────────────────┼─────────────────┼────────────────────┐
              │                   │                 │                    │
              │                   │                 │                    │
    ┌─────────┴─────────┐  ┌──────┴───────┐  ┌──────┴────────┐  ┌────────┴────────┐
    │  stg_lineitem     │  │ stg_customer │  │  stg_part     │  │ stg_supplier    │
    │   (Fact Lineitem) │  │  (Dim)       │  │  (Dim)        │  │   (Dim)         │
    ├───────────────────┤  ├──────────────┤  ├───────────────┤  ├─────────────────┤
    │ L_ITEMKEY (PK)    │  │ C_CUSTKEY (PK)    │  │ P_PARTKEY     │  │ S_SUPPKEY       │
    │ L_ORDERKEY (FK)   │  │ (PK)         │  │ (PK)          │  │ (PK)            │
    │ L_PARTKEY (FK)    │  │ C_NAME       │  │ P_NAME        │  │ S_NAME          │
    │ L_SUPPKEY (FK)    │  │ C_ADDRESS    │  │ P_MFGR        │  │ S_ADDRESS       │
    │ L_LINENUMBER      │  │ C_PHONE      │  │ P_BRAND       │  │ S_PHONE         │
    │ L_QUANTITY        │  │ C_ACCTBAL    │  │ P_TYPE        │  │ S_ACCTBAL       │
    │ L_EXTENDEDPRICE   │  │ C_MKTSEGMENT │  │ P_SIZE        │  │ S_COMMENT       │
    │ L_DISCOUNT        │  │ C_COMMENT    │  │ P_CONTAINER   │  └─────────────────┘
    │ L_TAX             │  │ C_MKTSEGMENT │  │ P_RETAILPRICE │           ▲
    │ L_RETURNFLAG      │  │ C_COMMENT    │  │ P_COMMENT     │           │
    │ L_LINESTATUS      │  └──────────────┘  └───────────────┘           │
    │ L_RECEIPTDATE     │          │                 │                   │
    │ L_SHIPINSTRUCT    │          │                 │                   │
    │ L_SHIPMODE        │          │                 │                   │
    │ L_COMMENT         │          │                 │                   │
    └───────────────────┘          │                 │                   │
              ▲                    │                 │                   │ 
              │                    │                 │                   │ 
              └────────────────────┼─────────────────┴───────────────────┘
                                   │
                         ┌─────────┴─────────┐
                         │  f_lineorder_flat │
                         │   (Denormalized)  │
                         └───────────────────┘

                         ┌───────────────────┐
                         │  f_orders_stats   │
                         │   (Aggregated)    │
                         └───────────────────┘
```

---

## Тесты и проверки данных

### Тесты в staging-моделях
Каждая staging-модель имеет тесты на:
- **unique**: Уникальность ключевых полей (`C_CUSTKEY`, `O_ORDERKEY`, `L_ITEMKEY`, `P_PARTKEY`, `S_SUPPKEY`)
- **not_null**: Ненулевость ключевых полей

### Тесты в data mart
- `tests/assert_f_orders_stats_rowcount.sql`: Проверка, что таблица `f_orders_stats` содержит ровно 45 строк

---

## Планы развития

1. Добавить таблицу `NATION` и `REGION` как измерения
2. Добавить метрики поставок (delay_days, on_time_rate)
3. Добавить временные метки (created_at, updated_at)
4. Настроить incremental-загрузку для staging-таблиц

---

**Документ создан**: 2026-06-25  
**Версия документа**: 1.0  
**Автор**: GigaCode
