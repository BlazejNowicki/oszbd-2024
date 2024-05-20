# Connection pooling lab

## Setup

Standardzik:
```
./initdb -D ~/test_db
```
Zmiana portu na 8091

```
/pg_ctl -D /home/przemek/test_db -l /home/przemek/test_db/logfile start
```

Edytujemy /etc/pgbouncer/pgbouncer.ini:

```
[databases]
postgres_template = host=localhost port=8091 dbname=postgres auth_user = testuser

port = 6455
```

Łączymy się i tworzymy testuser:
```
psql -p 8091 -U przemek -d postgres

postgres=# create user testuser superuser;
CREATE ROLE
```

Włączamy pgbouncer:
```
pgbouncer -d pgbouncer.ini
```

Łączymy się przez niego do bazy:
```
psql -p 6455 -U testuser -d postgres_template
```

## Benchmarki

Tworzę plik `/home/przemek/studia/sem8/databases/lab09/test_query.sql` o treśći:
```
select 1;
```

Przygotowanie do benchmarku:
```
pgbench -i postgres -U przemek -p 8091
```

Lecimy z benchmarkiem bez bouncera:
```
przemek@przemek-laptop:/etc/pgbouncer$ pgbench -c 20 -t 1000 -S postgres -C -f /home/przemek/studia/sem8/databases/lab09/test_query.sql -p 8091 -U przemek
starting vacuum...end.
transaction type: multiple scripts
scaling factor: 1
query mode: simple
number of clients: 20
number of threads: 1
number of transactions per client: 1000
number of transactions actually processed: 20000/20000
latency average = 47.106 ms
tps = 424.570891 (including connections establishing)
tps = 446.603964 (excluding connections establishing)
SQL script 1: <builtin: select only>
 - weight: 1 (targets 50.0% of total)
 - 9969 transactions (49.8% of total, tps = 211.627361)
 - latency average = 21.061 ms
 - latency stddev = 12.779 ms
SQL script 2: /home/przemek/studia/sem8/databases/lab09/test_query.sql
 - weight: 1 (targets 50.0% of total)
 - 10031 transactions (50.2% of total, tps = 212.943530)
 - latency average = 21.331 ms
 - latency stddev = 12.773 mspgbench -c 20 -t 1000 -S postgres -C -f /home/przemek/studia/sem8/databases/lab09/test_query.sql -p 8091 -U przemek
```

A teraz z pgbouncer:
```
przemek@przemek-laptop:/etc/pgbouncer$ pgbench -c 20 -t 1000 -S postgres_template -C -f /home/przemek/studia/sem8/databases/lab09/test_query.sql -p 6455 -U testuser
starting vacuum...end.
transaction type: multiple scripts
scaling factor: 1
query mode: simple
number of clients: 20
number of threads: 1
number of transactions per client: 1000
number of transactions actually processed: 20000/20000
latency average = 3.295 ms
tps = 6069.891271 (including connections establishing)
tps = 6356.626329 (excluding connections establishing)
SQL script 1: <builtin: select only>
 - weight: 1 (targets 50.0% of total)
 - 9966 transactions (49.8% of total, tps = 3024.626820)
 - latency average = 1.480 ms
 - latency stddev = 0.894 ms
SQL script 2: /home/przemek/studia/sem8/databases/lab09/test_query.sql
 - weight: 1 (targets 50.0% of total)
 - 10034 transactions (50.2% of total, tps = 3045.264451)
 - latency average = 1.389 ms
 - latency stddev = 0.869 ms
```

TPS urósł z 400 na 6000, co jest znaczną poprawą!

Zmieniamy w `pgbouncer.ini`:
```
pool_mode = transaction
```

I odpalamy znowu to samo:
```
przemek@przemek-laptop:/etc/pgbouncer$ pgbench -c 20 -t 1000 -S postgres_template -C -f /home/przemek/studia/sem8/databases/lab09/test_query.sql -p 6455 -U testuser
starting vacuum...end.
transaction type: multiple scripts
scaling factor: 1
query mode: simple
number of clients: 20
number of threads: 1
number of transactions per client: 1000
number of transactions actually processed: 20000/20000
latency average = 3.467 ms
tps = 5768.826137 (including connections establishing)
tps = 6041.189938 (excluding connections establishing)
SQL script 1: <builtin: select only>
 - weight: 1 (targets 50.0% of total)
 - 10043 transactions (50.2% of total, tps = 2896.816044)
 - latency average = 1.534 ms
 - latency stddev = 0.903 ms
SQL script 2: /home/przemek/studia/sem8/databases/lab09/test_query.sql
 - weight: 1 (targets 50.0% of total)
 - 9957 transactions (49.8% of total, tps = 2872.010092)
 - latency average = 1.461 ms
 - latency stddev = 0.893 ms
```

W moim przypadku bez żadnej poprawy w stosunku do poprzedniego.


Tworzymy tabele:
```
postgres_template=# create table test_tbl (id int, name varchar);
CREATE TABLE
```

Zmieniamy plik `test_query.sql` na:
```
insert into test_tbl (id, name) values(1, 'some random name');
```

Powtarzamy benchmarki.
1. Bez pgbouncer:
```
przemek@przemek-laptop:/etc/pgbouncer$ pgbench -c 20 -t 1000 -S postgres -C -f /home/przemek/studia/sem8/databases/lab09/test_query.sql -p 8091 -U przemek
starting vacuum...end.
transaction type: multiple scripts
scaling factor: 1
query mode: simple
number of clients: 20
number of threads: 1
number of transactions per client: 1000
number of transactions actually processed: 20000/20000
latency average = 48.266 ms
tps = 414.367832 (including connections establishing)
tps = 435.879977 (excluding connections establishing)
SQL script 1: <builtin: select only>
 - weight: 1 (targets 50.0% of total)
 - 10047 transactions (50.2% of total, tps = 208.157680)
 - latency average = 21.436 ms
 - latency stddev = 13.067 ms
SQL script 2: /home/przemek/studia/sem8/databases/lab09/test_query.sql
 - weight: 1 (targets 50.0% of total)
 - 9953 transactions (49.8% of total, tps = 206.210151)
 - latency average = 21.485 ms
 - latency stddev = 13.211 m
```

2. pgbouncer z `pool_mode = session`:
```
przemek@przemek-laptop:/etc/pgbouncer$ pgbench -c 20 -t 1000 -S postgres_template -C -f /home/przemek/studia/sem8/databases/lab09/test_query.sql -p 6455 -U testuser
starting vacuum...end.
transaction type: multiple scripts
scaling factor: 1
query mode: simple
number of clients: 20
number of threads: 1
number of transactions per client: 1000
number of transactions actually processed: 20000/20000
latency average = 3.521 ms
tps = 5680.090221 (including connections establishing)
tps = 5944.795371 (excluding connections establishing)
SQL script 1: <builtin: select only>
 - weight: 1 (targets 50.0% of total)
 - 9914 transactions (49.6% of total, tps = 2815.620723)
 - latency average = 1.343 ms
 - latency stddev = 0.817 ms
SQL script 2: /home/przemek/studia/sem8/databases/lab09/test_query.sql
 - weight: 1 (targets 50.0% of total)
 - 10086 transactions (50.4% of total, tps = 2864.469498)
 - latency average = 2.067 ms
 - latency stddev = 0.941 ms
```

3. pgbouncer z `pool_mode = transaction`
```
przemek@przemek-laptop:/etc/pgbouncer$ pgbench -c 20 -t 1000 -S postgres_template -C -f /home/przemek/studia/sem8/databases/lab09/test_query.sql -p 6455 -U testuser
starting vacuum...end.
transaction type: multiple scripts
scaling factor: 1
query mode: simple
number of clients: 20
number of threads: 1
number of transactions per client: 1000
number of transactions actually processed: 20000/20000
latency average = 3.653 ms
tps = 5475.022772 (including connections establishing)
tps = 5729.718010 (excluding connections establishing)
SQL script 1: <builtin: select only>
 - weight: 1 (targets 50.0% of total)
 - 10060 transactions (50.3% of total, tps = 2753.936454)
 - latency average = 1.391 ms
 - latency stddev = 0.838 ms
SQL script 2: /home/przemek/studia/sem8/databases/lab09/test_query.sql
 - weight: 1 (targets 50.0% of total)
 - 9940 transactions (49.7% of total, tps = 2721.086318)
 - latency average = 2.117 ms
 - latency stddev = 0.963 ms
 ```

 Ostatecznie mamy:
 1 - 414 TPS
 2 - 5680 TPS
 3 - 5475 TPS