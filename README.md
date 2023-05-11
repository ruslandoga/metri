Fetches or ingests Prometheus metrics into SQLite.

Your ideas are welcome [here.](https://github.com/ruslandoga/metri/issues/1)

<details>

<summary>Current schema</summary>

<br>

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
  date(datetime(timestamp / 1000, 'unixepoch')) as date,
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

<details>

<summary>Configuration</summary>

<br>

All configuration happens via environment variables:

- `TARGETS` sets the URLs to scrape, separated by a comma: `TARGETS=http://localhost:8000/metrics,http://10.0.1.12:4000/.well-known/metrics`
- `PORT` sets the port to listen on
- `HOST` sets the hostname (used in links and origin checks)
- `DATABASE_PATH` sets the path to the SQLite database
- `USERNAME` sets basic auth username
- `PASSWORD` sets basic auth password
- `PHX_SECRET_KEY` sets Phoenix secret key

Example `docker run` command:

```console
$ PHX_SECRET_KEY=$(openssl rand -base64 64 | tr -d '\n')
$ TARGETS=http://localhost:4000/metrics
$ PORT=4000
$ HOST=localhost
$ DATABASE_PATH=/data/metrics.db
$ USERNAME=username
$ PASSWORD=password
$ docker run -ti --rm -v metri_data:/data -p 4000:4000 -e $URLS -e $PORT -e $HOST -e $DATABASE_PATH -e $PHX_SECRET_KEY -e $USERNAME -e $PASSWORD ghcr.io/ruslandoga/metri
$ open http://localhost:4000
```

</details>
