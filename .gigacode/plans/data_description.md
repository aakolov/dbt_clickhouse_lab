# Описание слоев данных и схемы DWH

## Обзор архитектуры

Проект реализует классическую архитектуру Data Warehouse по паттерну **Star Schema** с использованием dbt для преобразования данных и ClickHouse в качестве целевой СУБД.

### Архитектурные слои

```text
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

### Источники данных

| Имя таблицы | Описание | Источник данных | Размер данных |
| --- | --- | --- | --- |
| `src_customer` | Клиенты (измерение) | `customer.tbl` | ~150K строк |
| `src_orders` | Заказы (факт) | `orders.tbl` | ~1.5M строк |
| `src_lineitem` | Позиции заказов (факт) | `lineitem.tbl` | ~6M строк |
| `src_part` | Части/Товары (измерение) | `part.tbl` | ~200K строк |
| `src_supplier` | Поставщики (измерение) | `supplier.tbl` | ~20K строк |
| `src_nation` | Страны (измерение) | `nation.tbl` | ~25 строк |
| `src_region` | Регионы (измерение) | `region.tbl` | ~5 строк |

### Структура источников данных

#### Таблица src_customer

| Поле | Тип | Описание |
| --- | --- | --- |
| `C_CUSTKEY` | UInt32 | Идентификатор клиента |
| `C_NAME` | String | Название компании клиента |
| `C_ADDRESS` | String | Адрес клиента |
| `C_NATIONKEY` | UInt32 | Идентификатор страны (внешний ключ) |
| `C_PHONE` | String | Телефон клиента |
| `C_ACCTBAL` | Decimal(15,2) | Баланс счета |
| `C_MKTSEGMENT` | LowCardinality(String) | Рыночный сегмент |
| `C_COMMENT` | String | Комментарий |

#### Таблица src_orders

| Поле | Тип | Описание |
| --- | --- | --- |
| `O_ORDERKEY` | UInt32 | Идентификатор заказа |
| `O_CUSTKEY` | UInt32 | Идентификатор клиента (внешний ключ) |
| `O_ORDERSTATUS` | LowCardinality(String) | Статус заказа (F=fulfilled, O=open, P=pending) |
| `O_TOTALPRICE` | Decimal(15,2) | Общая стоимость заказа |
| `O_ORDERDATE` | Date | Дата заказа |
| `O_ORDERPRIORITY` | LowCardinality(String) | Приоритет заказа (1-URGENT, 2-HIGH и т.д.) |
| `O_CLERK` | String | Идентификатор сотрудника |
| `O_SHIPPRIORITY` | UInt8 | Приоритет доставки |
| `O_COMMENT` | String | Комментарий |

#### Таблица src_lineitem

| Поле | Тип | Описание |
| --- | --- | --- |
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

#### Таблица src_part

| Поле | Тип | Описание |
| --- | --- | --- |
| `P_PARTKEY` | UInt32 | Идентификатор части |
| `P_NAME` | String | Название части |
| `P_MFGR` | LowCardinality(String) | Производитель |
| `P_BRAND` | LowCardinality(String) | Марка |
| `P_TYPE` | LowCardinality(String) | Тип части |
| `P_SIZE` | UInt8 | Размер |
| `P_CONTAINER` | LowCardinality(String) | Упаковка |
| `P_RETAILPRICE` | Decimal(15,2) | Розничная цена |
| `P_COMMENT` | String | Комментарий |

#### Таблица src_supplier

| Поле | Тип | Описание |
| --- | --- | --- |
| `S_SUPPKEY` | UInt32 | Идентификатор поставщика |
| `S_NAME` | String | Название поставщика |
| `S_ADDRESS` | String | Адрес поставщика |
| `S_NATIONKEY` | UInt32 | Идентификатор страны (внешний ключ) |
| `S_PHONE` | String | Телефон поставщика |
| `S_ACCTBAL` | Decimal(15,2) | Баланс счета |
| `S_COMMENT` | String | Комментарий |

#### Таблица src_nation

| Поле | Тип | Описание |
| --- | --- | --- |
| `N_NATIONKEY` | UInt32 | Идентификатор страны |
| `N_NAME` | LowCardinality(String) | Название страны |
| `N_REGIONKEY` | UInt32 | Идентификатор региона (внешний ключ) |
| `N_COMMENT` | String | Комментарий |

#### Таблица src_region

| Поле | Тип | Описание |
| --- | --- | --- |
| `R_REGIONKEY` | UInt32 | Идентификатор региона |
| `R_NAME` | LowCardinality(String) | Название региона |
| `R_COMMENT` | String | Комментарий |

---

## Слой загрузки и первичной обработки данных (Staging Layer)

### Описание

Staging-модели очищают и трансформируют исходные данные. Используется движок `MergeTree` с оптимальной сортировкой и партиционированием.

### Таблицы

| Имя таблицы | Описание | Тип | Ключевые поля |
| --- | --- | --- | --- |
| `stg_customer` | Очищенные данные клиентов | Dim | `C_CUSTKEY` (PK) |
| `stg_orders` | Очищенные данные заказов | Fact | `O_ORDERKEY` (PK) |
| `stg_lineitem` | Очищенные данные позиций заказов | Fact | `L_ITEMKEY` (PK), `L_ORDERKEY` (FK) |
| `stg_part` | Очищенные данные частей | Dim | `P_PARTKEY` (PK) |
| `stg_supplier` | Очищенные данные поставщиков | Dim | `S_SUPPKEY` (PK) |

### Структура Staging-моделей

#### Таблица stg_customer

| Поле | Тип | Описание | Примечание |
| --- | --- | --- | --- |
| `C_CUSTKEY` | UInt32 | Идентификатор клиента | PK, unique |
| `C_NAME` | String | Название компании клиента | |
| `C_ADDRESS` | String | Адрес клиента | |
| `C_NATIONKEY` | UInt32 | Идентификатор страны | FK |
| `C_PHONE` | String | Телефон клиента | |
| `C_ACCTBAL` | Decimal(15,2) | Баланс счета | |
| `C_MKTSEGMENT` | LowCardinality(String) | Рыночный сегмент | |
| `C_COMMENT` | String | Комментарий | |

**Конфигурация**:

```sql
`engine='MergeTree()',
 order_by='C_CUSTKEY'`
```

#### Таблица stg_orders

| Поле | Тип | Описание | Примечание |
| --- | --- | --- | --- |
| `O_ORDERKEY` | UInt32 | Идентификатор заказа | PK, unique |
| `O_CUSTKEY` | UInt32 | Идентификатор клиента | FK |
| `O_ORDERSTATUS` | LowCardinality(String) | Статус заказа | |
| `O_TOTALPRICE` | Decimal(15,2) | Общая стоимость заказа | |
| `O_ORDERDATE` | Date | Дата заказа | |
| `O_ORDERPRIORITY` | LowCardinality(String) | Приоритет заказа | |
| `O_CLERK` | String | Идентификатор сотрудника | |
| `O_SHIPPRIORITY` | UInt8 | Приоритет доставки | |
| `O_COMMENT` | String | Комментарий | |

**Конфигурация**:

```sql
`engine='MergeTree()',
 order_by=['O_ORDERKEY']`
 ```

#### Таблица stg_lineitem

| Поле | Тип | Описание | Примечание |
| --- | --- | --- | --- |
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

**Конфигурация**:

```sql
`engine='MergeTree()',
 order_by=['L_SHIPDATE', 'L_ORDERKEY'],
 partition_by='toYear(L_SHIPDATE)'`
 ```

> **Примечание**: `L_ITEMKEY` генерируется с помощью `dbt_utils.generate_surrogate_key(['L_ORDERKEY', 'L_LINENUMBER'])`

#### Таблица stg_part

| Поле | Тип | Описание | Примечание |
| --- | --- | --- | --- |
| `P_PARTKEY` | UInt32 | Идентификатор части | PK, unique |
| `P_NAME` | String | Название части | |
| `P_MFGR` | LowCardinality(String) | Производитель | |
| `P_BRAND` | LowCardinality(String) | Марка | |
| `P_TYPE` | LowCardinality(String) | Тип части | |
| `P_SIZE` | UInt8 | Размер | |
| `P_CONTAINER` | LowCardinality(String) | Упаковка | |
| `P_RETAILPRICE` | Decimal(15,2) | Розничная цена | |
| `P_COMMENT` | String | Комментарий | |

**Конфигурация**:

```sql
`engine='MergeTree()',
 order_by=['P_PARTKEY']`
```

#### Таблица stg_supplier

| Поле | Тип | Описание | Примечание |
| --- | --- | --- | --- |
| `S_SUPPKEY` | UInt32 | Идентификатор поставщика | PK, unique |
| `S_NAME` | String | Название поставщика | |
| `S_ADDRESS` | String | Адрес поставщика | |
| `S_NATIONKEY` | UInt32 | Идентификатор страны | FK |
| `S_PHONE` | String | Телефон поставщика | |
| `S_ACCTBAL` | Decimal(15,2) | Баланс счета | |
| `S_COMMENT` | String | Комментарий | |

**Конфигурация**:

```sql
`engine='MergeTree()',
 order_by=['S_SUPPKEY']`
```

## Слой витрин данных (Marts Layer)

### Описание

Финальные агрегированные таблицы для аналитики. Созданы по паттерну Star Schema.

### Таблицы витрин данных

#### Таблица f_lineorder_flat (Denormalized Fact Table)

**Описание**: Широкая denormalized-таблица, содержащая все данные о заказах и связанных с ними сущностях (клиенты, части, поставщики, позиции заказов). Предназначена для быстрых ad-hoc запросов без соединений.

**Тип**: Denormalized Fact Table

**Конфигурация**:

```sql
`engine='MergeTree()',
 order_by=['L_SHIPDATE', 'L_ORDERKEY'],
 partition_by='toYear(L_SHIPDATE)'`
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

```text
stg_lineitem (L_ORDERKEY) ──► stg_orders (O_ORDERKEY) ──► stg_customer (O_CUSTKEY = C_CUSTKEY)
                                              │
                                              └──► stg_lineitem (L_PARTKEY) ──► stg_part (P_PARTKEY)
                                              └──► stg_lineitem (L_SUPPKEY) ──► stg_supplier (S_SUPPKEY)
```

---

#### Таблица f_orders_stats (Aggregated Data Mart)

**Описание**: Агрегированная таблица статистики по заказам. Предназначена для отчетности и аналитики.

**Тип**: Aggregated Fact Table

**Конфигурация**:

```sql
`engine='MergeTree()',
 order_by=['O_ORDERYEAR', 'O_ORDERSTATUS', 'O_ORDERPRIORITY']`
```

**Структура**:

| Поле | Тип | Описание | Примечание |
| --- | --- | --- | --- |
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

```text
┌────────────────────────────────────────────────────────────────────────────┐
│                                 STARSHEMA                                  │
└────────────────────────────────────────────────────────────────────────────┘

                           ┌─────────────────────┐
                           │   stg_orders        │
                           │  (Fact Orders)      │
                           ├─────────────────────┤
                           │ O_ORDERKEY (PK)     │
                           │ O_CUSTKEY (FK)      │
                           │ O_ORDERSTATUS       │
                           │ O_TOTALPRICE        │
                           │ O_ORDERDATE         │
                           │ O_ORDERPRIORITY     │
                           │ O_CLERK             │
                           │ O_SHIPPRIORITY      │
                           │ O_COMMENT           │
                           └─────────────────────┘
                                      ▲             
                                      │             
          ┌───────────────────┬───────┴───────────┬───────────────────┐
          │                   │                   │                   │
          │                   │                   │                   │
┌─────────┴────────┐  ┌───────┴────────┐  ┌───────┴────────┐  ┌───────┴────────┐
│  stg_lineitem    │  │ stg_customer   │  │  stg_part      │  │ stg_supplier   │
│  (Fact Lineitem) │  │  (Dim)         │  │  (Dim)         │  │   (Dim)        │
├──────────────────┤  ├────────────────┤  ├────────────────┤  ├────────────────┤
│ L_ITEMKEY (PK)   │  │ C_CUSTKEY (PK) │  │ P_PARTKEY (PK) │  │ S_SUPPKEY (PK) │ 
│ L_ORDERKEY (FK)  │  │ C_NAME         │  │ P_NAME         │  │ S_NAME         │
│ L_PARTKEY (FK)   │  │ C_ADDRESS      │  │ P_MFGR         │  │ S_ADDRESS      │
│ L_SUPPKEY (FK)   │  │ C_PHONE        │  │ P_BRAND        │  │ S_PHONE        │
│ L_LINENUMBER     │  │ C_ACCTBAL      │  │ P_TYPE         │  │ S_ACCTBAL      │
│ L_QUANTITY       │  │ C_MKTSEGMENT   │  │ P_SIZE         │  │ S_COMMENT      │
│ L_EXTENDEDPRICE  │  │ C_COMMENT      │  │ P_CONTAINER    │  └────────────────┘
│ L_DISCOUNT       │  └────────────────┘  │ P_RETAILPRICE  │          ▲ 
│ L_TAX            │          ▲           │ P_COMMENT      │          │   
│ L_RETURNFLAG     │          │           └────────────────┘          │
│ L_LINESTATUS     │          │                   ▲                   │
│ L_RECEIPTDATE    │          │                   │                   │
│ L_SHIPINSTRUCT   │          │                   │                   │
│ L_SHIPMODE       │          │                   │                   │
│ L_COMMENT        │          │                   │                   │
└──────────────────┘          │                   │                   │
          ▲                   │                   │                   │ 
          │                   │                   │                   │ 
          └───────────────────┴────┬──────────────┴───────────────────┘
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

### Тесты в Data Vault (стаб)

Data Vault-модели имеют специализированные тесты на целостность хэш-ключей и корректность временных атрибутов:

| Тип модели | Тест | Назначение |
| --- | --- | --- |
| **Хаб** (`hub_*`) | `unique_hash_key`: проверка уникальности хэш-ключа (`CUSTOMER_HK`, `ORDER_HK`, `PART_HK`, `SUPPLIER_HK`) | Гарантия отсутствия дубликатов по сущностям |
| **Хаб** (`hub_*`) | `not_null_hash_key`: ненулевой `SOURCE` и `LOAD_DATE` | Валидация обязательных метаданных |
| **Линк** (`link_*`) | `unique_link_hash_key`: уникальность `LINK_*_HK` (составного хэша) | Проверка корректности связей |
| **Линк** (`link_*`) | `valid_parent_keys`: наличие родительских хэшей в соответствующих хабах | Внешняя целостность (FK-проверка) |
| **Сателлит** (`sat_*`) | `valid_time_range`: `R_EFF_FROM ≤ R_EFF_TO` и `R_EFF_TO = '9999-12-31' OR R_EFF_TO < CURRENT_DATE + INTERVAL 1 YEAR` | Валидность временных диапазонов |

**Примечание**:  
В текущей реализации тесты Data Vault ещё не завершены.  
Рекомендуется добавить `dbt test` с тегами `datavault` и `satellite` при завершении реализации.

---

## Планы развития

1. Добавить метрики поставок (delay_days, on_time_rate)
2. Добавить временные метки (created_at, updated_at)
3. Настроить incremental-загрузку для staging-таблиц

---
