
select id, doc from applications
where id = '00000000-0000-0000-0000-000000411999';

explain
select id, doc from applications
where id = '00000000-0000-0000-0000-000000411999';

┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                       QUERY PLAN                                        │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using applications_pkey on applications  (cost=0.42..8.44 rows=1 width=1729) │
│   Index Cond: (id = '00000000-0000-0000-0000-000000411999'::uuid)                       │
└─────────────────────────────────────────────────────────────────────────────────────────┘

explain
select id, doc from applications;

┌─────────────────────────────────────────────────────────────────────────┐
│                               QUERY PLAN                                │
├─────────────────────────────────────────────────────────────────────────┤
│ Seq Scan on applications  (cost=0.00..359524.33 rows=965633 width=1729) │
└─────────────────────────────────────────────────────────────────────────┘

explain
select id, doc from applications
order by (doc->>'application_id')::int

┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│                                          QUERY PLAN                                          │
├──────────────────────────────────────────────────────────────────────────────────────────────┤
│ Gather Merge  (cost=1000457.74..1094345.26 rows=804694 width=1733)                           │
│   Workers Planned: 2                                                                         │
│   ->  Sort  (cost=999457.72..1000463.59 rows=402347 width=1733)                              │
│         Sort Key: (((doc ->> 'application_id'::text))::integer)                              │
│         ->  Parallel Seq Scan on applications  (cost=0.00..356909.07 rows=402347 width=1733) │
└──────────────────────────────────────────────────────────────────────────────────────────────┘

create index if not exists idx_applications_created_at
on applications
using btree (created_at desc);

analyze applications;

explain
select id, doc from applications
order by created_at desc
limit 100;

┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                     QUERY PLAN                                                     │
├────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Limit  (cost=0.42..37.19 rows=100 width=1736)                                                                      │
│   ->  Index Scan using idx_applications_created_at on applications  (cost=0.42..368293.21 rows=1001719 width=1736) │
└────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


explain
select id, doc from applications
where created_at between '2025-07-30 00:00:00Z' and '2025-07-30 23:59:59Z'
order by created_at desc;

┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                        QUERY PLAN                                                                         │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using idx_applications_created_at on applications  (cost=0.42..10918.55 rows=2711 width=1738)                                                  │
│   Index Cond: ((created_at >= '2025-07-30 03:00:00+03'::timestamp with time zone) AND (created_at <= '2025-07-31 02:59:59+03'::timestamp with time zone)) │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

explain
select id, doc from applications
where created_at between ('2025-07-30'::timestamptz) and ('2025-07-30'::timestamptz + interval '1 day' - interval '1 second')
order by created_at desc;

┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                QUERY PLAN                                                                                                │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using idx_applications_created_at on applications  (cost=0.43..10838.16 rows=2691 width=1738)                                                                                                 │
│   Index Cond: ((created_at >= '2025-07-30 00:00:00+03'::timestamp with time zone) AND (created_at <= (('2025-07-30 00:00:00+03'::timestamp with time zone + '1 day'::interval) - '00:00:01'::interval))) │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

create index if not exists
idx_applications_application_id
on applications using btree
(((doc->>'application_id')::int));

analyze applications;


explain
select id, doc from applications
where ((doc->>'application_id')::int) = 550433;

┌───────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                              QUERY PLAN                                               │
├───────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using idx_applications_application_id on applications  (cost=0.42..8.44 rows=1 width=1730) │
│   Index Cond: (((doc ->> 'application_id'::text))::integer = 550433)                                  │
└───────────────────────────────────────────────────────────────────────────────────────────────────────┘

explain
select id, doc from applications
where ((doc->>'application_id')::int) between 550000 and 550099
order by ((doc->>'application_id')::int) asc;

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                             QUERY PLAN                                                              │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using idx_applications_application_id on applications  (cost=0.42..286.56 rows=94 width=1734)                            │
│   Index Cond: ((((doc ->> 'application_id'::text))::integer >= 550000) AND (((doc ->> 'application_id'::text))::integer <= 550099)) │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

explain analyze
select id, doc from applications
where ((doc->>'application_id')::int) between 550000 and 550099
order by ((doc->>'application_id')::int) asc;

┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                      QUERY PLAN                                                                      │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using idx_applications_application_id on applications  (cost=0.42..286.56 rows=94 width=1734) (actual time=0.349..0.611 rows=100 loops=1) │
│   Index Cond: ((((doc ->> 'application_id'::text))::integer >= 550000) AND (((doc ->> 'application_id'::text))::integer <= 550099))                  │
│ Planning Time: 0.086 ms                                                                                                                              │
│ Execution Time: 0.632 ms                                                                                                                             │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

explain
select id, doc from applications
where ((doc #>> '{application_id}')::int) between 550000 and 550099
order by ((doc #>> '{application_id}')::int) asc;

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                     QUERY PLAN                                                                      │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Gather Merge  (cost=488635.14..489120.27 rows=4158 width=1734)                                                                                      │
│   Workers Planned: 2                                                                                                                                │
│   ->  Sort  (cost=487635.11..487640.31 rows=2079 width=1734)                                                                                        │
│         Sort Key: (((doc #>> '{application_id}'::text[]))::integer)                                                                                 │
│         ->  Parallel Seq Scan on applications  (cost=0.00..487520.54 rows=2079 width=1734)                                                          │
│               Filter: ((((doc #>> '{application_id}'::text[]))::integer >= 550000) AND (((doc #>> '{application_id}'::text[]))::integer <= 550099)) │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

explain
select id, doc from applications
where ((doc #>> '{application_id}')::int) = 550099;

┌──────────────────────────────────────────────────────────────────────────────────────┐
│                                      QUERY PLAN                                      │
├──────────────────────────────────────────────────────────────────────────────────────┤
│ Gather  (cost=1000.00..484846.20 rows=4989 width=1730)                               │
│   Workers Planned: 2                                                                 │
│   ->  Parallel Seq Scan on applications  (cost=0.00..483347.30 rows=2079 width=1730) │
│         Filter: (((doc #>> '{application_id}'::text[]))::integer = 550099)           │
└──────────────────────────────────────────────────────────────────────────────────────┘
