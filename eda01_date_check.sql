-- This query inspects the GA4 sample ecommerce dataset to determine the temporal
-- coverage of the available event tables. The query identifies:
--   • earliest_date  – the first available partition
--   • latest_date    – the most recent partition
--   • total_days     – the number of distinct daily partitions
-- This is useful for validating dataset completeness, understanding the time range
-- of the data, and ensuring analyses align with the available historical window.

SELECT
  MIN(_TABLE_SUFFIX) as earliest_date,
  MAX(_TABLE_SUFFIX) as latest_date,
  COUNT(DISTINCT _TABLE_SUFFIX) as total_days
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;
