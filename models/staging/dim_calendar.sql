{{ config(
    engine='MergeTree()',
    order_by=['date_day']
) }}

-- Генерация календаря с 2010 по 2030 год для унификации временных измерений
WITH generate_dates AS (
    SELECT 
        toDateTime(date_day) AS date_day
    FROM (
        SELECT 
            arrayJoin(
                arrayMap(
                    x -> toStartOfDay(toDateTime('2010-01-01') + toIntervalDay(x)),
                    range(7670)
                )
            ) AS date_day
    )
)

SELECT
    date_day,
    toYear(date_day) AS year,
    toMonth(date_day) AS month,
    toStartOfMonth(date_day) AS month_start,
    toQuarter(date_day) AS quarter,
    toStartOfQuarter(date_day) AS quarter_start,
    toString(toYear(date_day)) + '-Q' + toString(toQuarter(date_day)) AS quarter_name,
    toWeek(date_day, 1) AS week_of_year,
    toStartOfWeek(date_day, 1) AS week_start,
    toDayOfWeek(date_day) AS day_of_week,
    toDayOfYear(date_day) AS day_of_year,
    toString(date_day, 'YYYY-MM-DD') AS date_key,
    toString(date_day, 'DD.MM.YYYY') AS date_formatted,
    toString(date_day, 'Month YYYY') AS month_year,
    toString(date_day, 'Q') + ' Quarter ' + toString(toYear(date_day)) AS quarter_year,
    isHoliday(date_day) AS is_holiday,
    if(day_of_week IN (1, 7), true, false) AS is_weekend,
    if(is_holiday OR is_weekend, false, true) AS is_business_day,
    if(month = 12 AND toDayOfMonth(date_day) >= 24, true, false) AS is_christmas_season,
    if(month = 1, true, false) AS is_january_buying_season,
    'Q' + toString(toQuarter(date_day)) AS quarter_short,
    CASE 
        WHEN month BETWEEN 3 AND 5 THEN 'Spring'
        WHEN month BETWEEN 6 AND 8 THEN 'Summer'
        WHEN month BETWEEN 9 AND 11 THEN 'Autumn'
        ELSE 'Winter'
    END AS season,
    'H' + toString(intDiv(month - 1, 6) + 1) AS half_year,
    date_day AS time_id
FROM generate_dates
