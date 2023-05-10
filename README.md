Fetches or ingests Prometheus metrics into SQLite.

Your ideas are welcome [here.](https://github.com/ruslandoga/metri/issues/1)

<details>

<summary>Current schema</summary>

```sql
CREATE TABLE samples(name TEXT, labels JSON, timestamp INTEGER, value REAL);
```

```sql
select * from samples limit 4;
```

```
┌─────────────────────┬────────────────────────────────┬───────────────┬────────┐
│        name         │             labels             │   timestamp   │ value  │
├─────────────────────┼────────────────────────────────┼───────────────┼────────┤
│ http_requests_total │ {"code":"200","method":"post"} │ 1641038400000 │ 1027.0 │
│ http_requests_total │ {"code":"400","method":"post"} │ 1641038400000 │ 3.0    │
│ http_requests_total │ {"code":"200","method":"post"} │ 1641060000000 │ 2143.0 │
│ http_requests_total │ {"code":"400","method":"post"} │ 1641060000000 │ 12.0   │
└─────────────────────┴────────────────────────────────┴───────────────┴────────┘
```

Example query:

```sql
select
  datetime(timestamp / 1000, 'unixepoch') as datetime,
  avg(value) as avg
from samples
where
  name = 'http_requests_total' and
  json_extract(labels, '$.code') = '400'
group by 1;
```

```
┌────────────┬─────┐
│    date    │ avg │
├────────────┼─────┤
│ 2022-01-01 │ 7.5 │
└────────────┴─────┘
```

</details>
