# План улучшения семантического слоя dbt_clickhouse_lab

## Текущее состояние

Проект использует гибридную архитектуру Data Vault 2.0 + Data Marts с реализацией семантического слоя через:
- `models/semantic/semantic_models.yml` - 5 semantic models
- `models/semantic/metrics.yml` - 11 метрик
- `models/semantic/dimensions.yml` - 22 измерения

## Проблемы и области улучшения

### 1. Недостаточная документация
- Отсутствует подробная документация по каждой метрике и измерению
- Нет бизнес-глоссария
- Отсутствует руководство по использованию семантического слоя

### 2. Отсутствие зависимостей
- Нет relationships между semantic models
- Нет иерархий измерений (year -> quarter -> month -> day)
- Нет описания зависимостей между метриками

### 3. Отсутствие metadata
- Нет owners для метрик и измерений
- Нет tags для управления доступом и категоризации
- Нет versioning для semantic layer

### 4. Отсутствие тестов
- Нет тестов для проверки корректности конфигурации
- Нет проверки зависимостей

### 5. Дублирование логики
- Некоторые метрики могут быть улучшены через reuseexisting measures
- Нет conversion metrics

## План улучшений

### Фаза 1: Критичные улучшения (Приоритет: Высокий)

#### 1.1 Обновление semantic_models.yml

**Задача:** Добавить relationships и metadata

**Изменения:**
- Добавить relationships между semantic models (calendar -> orders_analysis, calendar -> lineitem_details)
- Добавить description для каждой dimension
- Добавить tags (sensitivity: public, team: analytics)
- Добавить metadata с owners

**Файл:** `models/semantic/semantic_models.yml`

```yaml
# Пример добавления relationships
relationships:
  - name: orders_to_calendar
    direction: many_to_one
    to: calendar
    type: left
    condition: orders_analysis.order_date = calendar.date_day
```

---

#### 1.2 Обновление metrics.yml

**Задача:** Добавить metadata и улучшить derived metrics

**Изменения:**
- Добавить parents для derived metrics
- Добавить metadata с owners и tags
- Добавить conversion metrics
- Добавить windowed metrics с разными time grains

**Файл:** `models/semantic/metrics.yml`

```yaml
# Пример улучшенной метрики
- name: avg_order_value
  description: "Средний чек (общая выручка / количество заказов)"
  type: derived
  type_params:
    expr: total_revenue / order_count
    parents:
      - name: total_revenue
      - name: order_count
  metadata:
    owners:
      - name: analytics_team
        email: analytics@company.com
    tags:
      - core
      - revenue
    examples:
      - query: "SELECT avg_order_value, order_date FROM semantic.avg_order_value GROUP BY order_date"
```

---

#### 1.3 Обновление dimensions.yml

**Задача:** Добавить иерархии и metadata

**Изменения:**
- Добавить hierarchies для time dimensions
- Добавить description и examples
- Добавить tags и metadata

**Файл:** `models/semantic/dimensions.yml`

```yaml
# Пример иерархии времени
- name: order_date_hierarchy
  description: "Иерархия даты заказа"
  type: time
  levels:
    - name: year
      sql: toYear(O_ORDERDATE)
    - name: quarter
      sql: toQuarter(O_ORDERDATE)
    - name: month
      sql: toMonth(O_ORDERDATE)
    - name: day
      sql: toDayOfMonth(O_ORDERDATE)
```

---

### Фаза 2: Документация (Приоритет: Высокий)

#### 2.1 Обновление docs/SEMANTIC_LAYER.md

**Задача:** Создать подробную документацию

**Содержание:**
- Бизнес-глоссарий с определениями
- Детальное описание каждой метрики с формулами
- Схема зависимостей между semantic models
- Руководство по добавлению новых метрик
- Best practices для семантического слоя

---

#### 2.2 Создание docs/SEMANTIC_LAYER_GUIDE.md

**Задача:** Создать руководство разработчика

**Содержание:**
- Обзор семантического слоя
- Архитектура и концепции
- Руководство по разработке
- Примеры запросов
- Чек-лист для проверки качества

---

### Фаза 3: Тестирование (Приоритет: Средний)

#### 3.1 Создание тестов semantic layer

**Задача:** Создать тесты для проверки конфигурации

**Структура:**
```
tests/
  semantic/
    test_semantic_models_exist.sql
    test_metrics_dependencies.sql
    test_dimensions_syntax.sql
    test_metadata_completeness.sql
```

**Типы тестов:**
- YAML schema validation
- SQL syntax validation
- Dependency validation
- Business logic validation

---

### Фаза 4: Расширенные функции (Приоритет: Низкий)

#### 4.1 Versioning semantic layer

**Задача:** Реализовать управление версиями

**Подход:**
- Использовать version в YAML-файлах
- Создать систему миграции версий
- Документировать breaking changes

---

#### 4.2 Access control

**Задача:** Добавить управление доступом

**Реализация:**
- Использовать tags для категоризации данных
- Создать систему ролей
- Документировать уровни доступа

---

#### 4.3 Расширение метрик

**Задача:** Добавить новые типы метрик

**Дополнения:**
- Conversion metrics
- Rolling window metrics
- Percentile metrics
- Ratio metrics

---

## Порядок реализации

1. **Неделя 1-2:** Фаза 1 (Критичные улучшения)
   - Обновить semantic_models.yml
   - Обновить metrics.yml
   - Обновить dimensions.yml

2. **Неделя 3:** Фаза 2 (Документация)
   - Обновить docs/SEMANTIC_LAYER.md
   - Создать docs/SEMANTIC_LAYER_GUIDE.md

3. **Неделя 4:** Фаза 3 (Тестирование)
   - Создать тесты semantic layer
   - Запустить тесты и исправить ошибки

4. **Неделя 5+:** Фаза 4 (Расширенные функции)
   - Реализовать по мере необходимости

---

## Ожидаемые результаты

1. Улучшенная документация и понимание семантического слоя
2. Улучшенная структура и целостность метрик
3. Проверка корректности конфигурации через тесты
4. Подготовка к расширению функциональности

---

## Критерии успеха

- [ ] Все метрики имеют owners и tags
- [ ] Все semantic models имеют relationships
- [ ] Документация обновлена и актуальна
- [ ] Тесты проходят успешно
- [ ] Нет дублирования логики

---

## Детальные рекомендации по улучшению

### 1. Улучшение semantic_models.yml

#### Проблема:
Текущая конфигурация не включает relationships между semantic models, что затрудняет использование в BI инструментах.

#### Решение:
Добавить relationships с описанием связей между моделями:

```yaml
relationships:
  - name: orders_to_calendar
    direction: many_to_one
    to: calendar
    type: left
    condition: orders_analysis.order_date = calendar.date_day
  - name: lineitem_to_calendar
    direction: many_to_one
    to: calendar
    type: left
    condition: lineitem_details.order_date = calendar.date_day
  - name: customer_to_calendar
    direction: many_to_one
    to: calendar
    type: left
    condition: customer_history.load_date = calendar.date_day
  - name: order_to_calendar
    direction: many_to_one
    to: calendar
    type: left
    condition: order_history.load_date = calendar.date_day
```

#### Дополнительно:
- Добавить description для каждой dimension
- Добавить tags для категоризации (sensitivity: public, team: analytics)
- Добавить metadata с owners

---

### 2. Улучшение metrics.yml

#### Проблема:
Derived metrics не имеют явных parents, что затрудняет отслеживание зависимостей.

#### Решение:
Улучшить метрику avg_order_value:

```yaml
- name: avg_order_value
  description: "Средний чек (общая выручка / количество заказов)"
  type: derived
  type_params:
    expr: total_revenue / order_count
    parents:
      - name: total_revenue
      - name: order_count
  metadata:
    owners:
      - name: analytics_team
        email: analytics@company.com
    tags:
      - core
      - revenue
    examples:
      - query: "SELECT avg_order_value, order_date FROM semantic.avg_order_value GROUP BY order_date"
```

#### Дополнительно:
- Добавить conversion metrics (percentage_of_orders_filled)
- Добавить windowed metrics с разными time grains
- Добавить rolling window metrics

---

### 3. Улучшение dimensions.yml

#### Проблема:
Отсутствуют иерархии для временных измерений.

#### Решение:
Добавить hierarchies для order_date:

```yaml
- name: order_date_hierarchy
  description: "Иерархия даты заказа"
  type: time
  levels:
    - name: year
      sql: toYear(O_ORDERDATE)
    - name: quarter
      sql: toQuarter(O_ORDERDATE)
    - name: month
      sql: toMonth(O_ORDERDATE)
    - name: day
      sql: toDayOfMonth(O_ORDERDATE)
```

#### Дополнительно:
- Добавить description и examples для каждого измерения
- Добавить tags и metadata
- Добавить hierarchies для других временных измерений

---

### 4. Создание документации

#### docs/SEMANTIC_LAYER.md - обновление:
- Добавить бизнес-глоссарий с определениями
- Добавить детальное описание каждой метрики с формулами
- Добавить схему зависимостей между semantic models
- Добавить руководство по добавлению новых метрик
- Добавить best practices для семантического слоя

#### docs/SEMANTIC_LAYER_GUIDE.md - новая документация:
- Обзор семантического слоя
- Архитектура и концепции
- Руководство по разработке
- Примеры запросов
- Чек-лист для проверки качества

---

### 5. Создание тестов

#### tests/semantic/

Создать следующие тесты:

1. **test_semantic_models_exist.sql** - проверка существования semantic models
2. **test_metrics_dependencies.sql** - проверка зависимостей между метриками
3. **test_dimensions_syntax.sql** - проверка синтаксиса измерений
4. **test_metadata_completeness.sql** - проверка полноты metadata

---

### 6. Расширенные функции

#### Versioning:
- Использовать version в YAML-файлах
- Создать систему миграции версий
- Документировать breaking changes

#### Access control:
- Использовать tags для категоризации данных
- Создать систему ролей
- Документировать уровни доступа

#### Расширение метрик:
- Conversion metrics
- Rolling window metrics
- Percentile metrics
- Ratio metrics

---

## Приоритеты реализации

1. **Критичные улучшения (Фаза 1)** - 1-2 недели
2. **Документация (Фаза 2)** - 1 неделя
3. **Тестирование (Фаза 3)** - 1 неделя
4. **Расширенные функции (Фаза 4)** - по мере необходимости