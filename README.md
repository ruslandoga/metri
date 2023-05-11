Naive metrics storage using SQLite:

```sql
CREATE TABLE naive_metrics(name TEXT, labels JSON, timestamp INTEGER, value REAL);
```

Example:

```sql
select
  -- timestamps are stored with millisecond precision
  date(datetime(timestamp / 1000, 'unixepoch')) as date,
  avg(value) as avg
from naive_metrics
where
  name = 'http_requests_total' and
  -- labels is a flat JSON object like `{"code":"400","method":"post"}`
  json_extract(labels, '$.code') = '400'
group by 1
order by 1;
```

Consider:

- [ ] a view for each metric with labels (`select * from http_requests_total where code = '200'`, etc.)

Schemas:

```sql
CREATE TABLE samples (
  series_id INTEGER,
  timestamp INTEGER,
  value REAL,
);

CREATE TABLE metric_to_series (
  metric_name_with_labels TEXT PRIMARY KEY,
  series_id INTEGER
);

CREATE TABLE series_to_metric (
  series_id INTEGER PRIMARY KEY,
  metric_name_with_labels TEXT
);

CREATE TABLE label_to_series (
  label_id INTEGER,
  series_id INTEGER
);

CREATE TABLE labels (
  id INTEGER PRIMARY KEY,
  value TEXT -- "code=200" or "__name__=http_requests_total"
);
```

https://promscale-legacy-docs.timescale.com/promscale/latest/query-data/query-metrics/

```sql
create view http_requests_total as
  select timestamp, value, series_id, labels, method, code
  from samples
  where series_id in (
    select series_id from label_to_series
    where label_id = (
      select id from labels
      where value = '__name__=http_requests_total'
    )
  )
```

```sql
select date(datetime(timestamp / 1000, 'unixepoch')), avg(value)
from http_requests_total
where code = (select id from labels where value = 'code=400')
group by 1;
```
