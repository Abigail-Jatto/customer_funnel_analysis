/*Q1: What is the earliest, latest, and total number of date partitions in this GA4 dataset? */

SELECT
  MIN(_TABLE_SUFFIX) as earliest_date,
  MAX(_TABLE_SUFFIX) as latest_date,
  COUNT(DISTINCT _TABLE_SUFFIX) as total_days
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;

/*Q2: How many rows, unique users, and event types appear in this GA4 dataset during the selected date range? */

SELECT
  COUNT(*) as total_rows,
  COUNT(DISTINCT user_pseudo_id) as unique_users,
  COUNT(DISTINCT event_name) as distinct_event_types
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131';

/*Q3: What is the most frequent user action and how widely are they distributed among users */

SELECT
  event_name,
  COUNT(*) as total_occurrences,
  COUNT(DISTINCT user_pseudo_id) as unique_users,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as pct_of_all_events
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY event_name
ORDER BY total_occurrences DESC;

/*Q4: What proportion of essential fields are null, indicating potential data quality issues? */

SELECT
  COUNTIF(user_pseudo_id IS NULL) as null_user_ids,
  COUNTIF(event_name IS NULL) as null_event_names,
  COUNTIF(event_date IS NULL) as null_event_dates,
  COUNTIF(device.category IS NULL) as null_device,
  COUNTIF(traffic_source.source IS NULL) as null_traffic_source,
  COUNTIF(ecommerce.purchase_revenue IS NULL) as null_revenue,
  COUNT(*) as total_rows
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131';

-- Revenue column is quite low as event type only contribute to revenue when item is purchased.

/*Q5: Which device categories account for the largest share of users and interactions? */

SELECT
  device.category,
  COUNT(DISTINCT user_pseudo_id) as unique_users,
  COUNT(*) as total_events,
  -- % share of total unique users per device
  ROUND(COUNT(DISTINCT user_pseudo_id) * 100.0 /
    SUM(COUNT(DISTINCT user_pseudo_id)) OVER(), 2) as pct_of_users
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY device.category
ORDER BY unique_users DESC;

/*Q6: Which acquisition channels bring in the largest share of users during this period? */

SELECT
  traffic_source.source,
  COUNT(DISTINCT user_pseudo_id) as unique_users,
  ROUND(COUNT(DISTINCT user_pseudo_id) * 100.0 /
    SUM(COUNT(DISTINCT user_pseudo_id)) OVER(), 2) as pct_of_users
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY traffic_source.source
ORDER BY unique_users DESC;

/*Q7: How does daily user activity and purchase volume evolve over time in this dataset? */

SELECT
  event_date,
  COUNT(*) as total_events,
  COUNT(DISTINCT user_pseudo_id) as unique_users,
  COUNTIF(event_name = 'purchase') as purchases
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY event_date
ORDER BY event_date ASC;

/*Q8: Does the funnel check follow a logical numbering? */

SELECT
  COUNT(DISTINCT IF(event_name = 'session_start', user_pseudo_id, NULL)) as sessions,
  COUNT(DISTINCT IF(event_name = 'view_item', user_pseudo_id, NULL)) as product_views,
  COUNT(DISTINCT IF(event_name = 'add_to_cart', user_pseudo_id, NULL)) as add_to_cart,
  COUNT(DISTINCT IF(event_name = 'begin_checkout', user_pseudo_id, NULL)) as checkouts,
  COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)) as purchases
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131';
