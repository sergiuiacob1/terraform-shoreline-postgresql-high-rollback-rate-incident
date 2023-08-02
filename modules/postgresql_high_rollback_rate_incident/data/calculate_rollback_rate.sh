SELECT
  sum(t.rollback_time) / sum(t.xact_rollback) AS rollback_rate
FROM
  pg_stat_database d
JOIN
  pg_stat_bgwriter t
ON
  d.datname = current_database()
WHERE
  d.datname = current_database();