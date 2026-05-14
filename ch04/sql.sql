
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

explain analyze
select id, doc from applications
where id = '00000000-0000-0000-0000-000000411999';

┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                            QUERY PLAN                                                             │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using applications_pkey on applications  (cost=0.42..8.44 rows=1 width=1830) (actual time=3.786..3.789 rows=1 loops=1) │
│   Index Cond: (id = '00000000-0000-0000-0000-000000411999'::uuid)                                                                 │
│ Planning Time: 0.179 ms                                                                                                           │
│ Execution Time: 3.906 ms                                                                                                          │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

explain (analyze, buffers)
select id, doc from applications
where id = '00000000-0000-0000-0000-000000411999';

┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                            QUERY PLAN                                                             │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using applications_pkey on applications  (cost=0.42..8.44 rows=1 width=1830) (actual time=2.820..2.824 rows=1 loops=1) │
│   Index Cond: (id = '00000000-0000-0000-0000-000000411999'::uuid)                                                                 │
│   Buffers: shared read=4                                                                                                          │
│ Planning Time: 0.750 ms                                                                                                           │
│ Execution Time: 2.957 ms                                                                                                          │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                            QUERY PLAN                                                             │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using applications_pkey on applications  (cost=0.42..8.44 rows=1 width=1830) (actual time=0.054..0.055 rows=1 loops=1) │
│   Index Cond: (id = '00000000-0000-0000-0000-000000411999'::uuid)                                                                 │
│   Buffers: shared hit=4                                                                                                           │
│ Planning Time: 0.105 ms                                                                                                           │
│ Execution Time: 0.070 ms                                                                                                          │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


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


create table uuid_v7_demo(
    id uuid not null primary key,
    created_at timestamptz not null
);

insert into uuid_v7_demo
select
    uuidv7(interval '-1 day' * x),
    current_timestamp + interval '-1 day' * x
from
    generate_series(1, 9999) as seq(x);


select * from uuid_v7_demo
order by id limit 100;

┌──────────────────────────────────────┬───────────────────────────────┐
│                  id                  │          created_at           │
├──────────────────────────────────────┼───────────────────────────────┤
│ 00d4e887-b56f-7584-9190-d522f266d4bf │ 1998-12-23 20:31:14.630735+03 │
│ 00d4edae-116f-757d-a295-7f89e12c8bda │ 1998-12-24 20:31:14.630735+03 │
│ 00d4f2d4-6d6f-7575-b5d0-621727a083ed │ 1998-12-25 20:31:14.630735+03 │
│ 00d4f7fa-c96f-756c-999d-2c22d558596e │ 1998-12-26 20:31:14.630735+03 │
│ 00d4fd21-256f-7567-8158-5acbfc067301 │ 1998-12-27 20:31:14.630735+03 │
│ 00d50247-816f-755d-8377-c12809f0a1c3 │ 1998-12-28 20:31:14.630735+03 │
│ 00d5076d-dd6f-7550-b939-7c10f9f9ce5f │ 1998-12-29 20:31:14.630735+03 │
│ 00d50c94-396f-754d-bb77-9d663b4f31ea │ 1998-12-30 20:31:14.630735+03 │
│ 00d511ba-956f-7544-a16d-e9c7f8613f04 │ 1998-12-31 20:31:14.630735+03 │
│ 00d516e0-f16f-753e-8a0d-1854d65ae69e │ 1999-01-01 20:31:14.630735+03 │
│ 00d51c07-4d6f-7536-af14-ebc968cfa7b4 │ 1999-01-02 20:31:14.630735+03 │
│ 00d5212d-a96f-752d-a359-2244a9d10ec9 │ 1999-01-03 20:31:14.630735+03 │
│ 00d52654-056f-7524-99a2-07a2c7066673 │ 1999-01-04 20:31:14.630735+03 │
│ 00d52b7a-616f-751d-8af1-601a22228472 │ 1999-01-05 20:31:14.630735+03 │
│ 00d530a0-bd6f-7514-a10e-7e9fada20d2f │ 1999-01-06 20:31:14.630735+03 │
│ 00d535c7-196f-750f-9a67-5b9276168c26 │ 1999-01-07 20:31:14.630735+03 │
│ 00d53aed-756f-7504-a9dc-5731956fe50c │ 1999-01-08 20:31:14.630735+03 │
│ 00d54013-d16f-74fe-bf3e-c11a6eb4c896 │ 1999-01-09 20:31:14.630735+03 │

select
    *,
    uuid_extract_timestamp(id) as ts
from uuid_v7_demo
order by id limit 100;

┌──────────────────────────────────────┬───────────────────────────────┬────────────────────────────┐
│                  id                  │          created_at           │             ts             │
├──────────────────────────────────────┼───────────────────────────────┼────────────────────────────┤
│ 00d4e887-b56f-7584-9190-d522f266d4bf │ 1998-12-23 20:31:14.630735+03 │ 1998-12-23 20:31:14.671+03 │
│ 00d4edae-116f-757d-a295-7f89e12c8bda │ 1998-12-24 20:31:14.630735+03 │ 1998-12-24 20:31:14.671+03 │
│ 00d4f2d4-6d6f-7575-b5d0-621727a083ed │ 1998-12-25 20:31:14.630735+03 │ 1998-12-25 20:31:14.671+03 │
│ 00d4f7fa-c96f-756c-999d-2c22d558596e │ 1998-12-26 20:31:14.630735+03 │ 1998-12-26 20:31:14.671+03 │
│ 00d4fd21-256f-7567-8158-5acbfc067301 │ 1998-12-27 20:31:14.630735+03 │ 1998-12-27 20:31:14.671+03 │
│ 00d50247-816f-755d-8377-c12809f0a1c3 │ 1998-12-28 20:31:14.630735+03 │ 1998-12-28 20:31:14.671+03 │
│ 00d5076d-dd6f-7550-b939-7c10f9f9ce5f │ 1998-12-29 20:31:14.630735+03 │ 1998-12-29 20:31:14.671+03 │
│ 00d50c94-396f-754d-bb77-9d663b4f31ea │ 1998-12-30 20:31:14.630735+03 │ 1998-12-30 20:31:14.671+03 │
│ 00d511ba-956f-7544-a16d-e9c7f8613f04 │ 1998-12-31 20:31:14.630735+03 │ 1998-12-31 20:31:14.671+03 │
│ 00d516e0-f16f-753e-8a0d-1854d65ae69e │ 1999-01-01 20:31:14.630735+03 │ 1999-01-01 20:31:14.671+03 │
│ 00d51c07-4d6f-7536-af14-ebc968cfa7b4 │ 1999-01-02 20:31:14.630735+03 │ 1999-01-02 20:31:14.671+03 │

select * from uuid_v7_demo
where id between
    uuidv7(interval '-3 months')
    and
    uuidv7(interval '-2 months')
order by id
limit 100;

┌──────────────────────────────────────┬───────────────────────────────┐
│                  id                  │          created_at           │
├──────────────────────────────────────┼───────────────────────────────┤
│ 019c489b-7949-7d87-aa8f-de9eeb8726e4 │ 2026-02-10 20:31:14.630735+03 │
│ 019c4dc1-d549-7d7c-85f6-ba7201c61a63 │ 2026-02-11 20:31:14.630735+03 │
│ 019c52e8-3149-7d76-b205-897059e6d8ff │ 2026-02-12 20:31:14.630735+03 │
│ 019c580e-8d49-7d68-88d7-e846afc2c5b5 │ 2026-02-13 20:31:14.630735+03 │
│ 019c5d34-e949-7d61-8199-7ce0fed26860 │ 2026-02-14 20:31:14.630735+03 │
│ 019c625b-4549-7d5a-971e-fa0b9a827175 │ 2026-02-15 20:31:14.630735+03 │
│ 019c6781-a149-7d4f-a4f3-3f3ea25bcb2e │ 2026-02-16 20:31:14.630735+03 │
│ 019c6ca7-fd49-7d45-9449-ae8b3c2f8a9f │ 2026-02-17 20:31:14.630735+03 │
│ 019c71ce-5949-7d3f-84a5-f11c99d9e3cf │ 2026-02-18 20:31:14.630735+03 │
│ 019c76f4-b549-7d35-821c-f64da5398f11 │ 2026-02-19 20:31:14.630735+03 │
│ 019c7c1b-1149-7d2c-af1e-2b27042b726f │ 2026-02-20 20:31:14.630735+03 │
│ 019c8141-6d49-7d26-8e6e-a9cab44b4b64 │ 2026-02-21 20:31:14.630735+03 │
│ 019c8667-c949-7d1f-b9f5-7cf09ff6c908 │ 2026-02-22 20:31:14.630735+03 │

explain analyze
select * from uuid_v7_demo
where id between
    uuidv7(interval '-3 months')
    and
    uuidv7(interval '-2 months')
order by id
limit 100;

┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                    QUERY PLAN                                                                    │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Limit  (cost=0.29..54.38 rows=100 width=24) (actual time=16.618..16.744 rows=28.00 loops=1)                                                      │
│   Buffers: shared hit=134                                                                                                                        │
│   ->  Index Scan using uuid_v7_demo_pkey on uuid_v7_demo  (cost=0.29..601.26 rows=1111 width=24) (actual time=16.615..16.737 rows=28.00 loops=1) │
│         Filter: ((id >= uuidv7('-3 mons'::interval)) AND (id <= uuidv7('-2 mons'::interval)))                                                    │
│         Rows Removed by Filter: 9971                                                                                                             │
│         Index Searches: 1                                                                                                                        │
│         Buffers: shared hit=134                                                                                                                  │
│ Planning Time: 0.139 ms                                                                                                                          │
│ Execution Time: 16.767 ms                                                                                                                        │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

select id, (doc->>'application_id') as app_id
from applications
limit 10;

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

explain analyze
select id, doc from applications
where ((doc #>> '{application_id}')::int) = 550099;

┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                            QUERY PLAN                                                             │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Gather  (cost=1000.00..259833.33 rows=5000 width=1830) (actual time=268.194..453.280 rows=1 loops=1)                              │
│   Workers Planned: 2                                                                                                              │
│   Workers Launched: 2                                                                                                             │
│   ->  Parallel Seq Scan on applications  (cost=0.00..258333.33 rows=2083 width=1830) (actual time=88.504..146.584 rows=0 loops=3) │
│         Filter: (((doc #>> '{application_id}'::text[]))::integer = 550099)                                                        │
│         Rows Removed by Filter: 333333                                                                                            │
│ Planning Time: 2.099 ms                                                                                                           │
│ Execution Time: 453.380 ms                                                                                                        │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


explain
select id, doc from applications
where ((doc->>'application_id')::int) between 550000 and 550099;

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                             QUERY PLAN                                                              │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using idx_applications_application_id on applications  (cost=0.42..33.27 rows=92 width=1830)                             │
│   Index Cond: ((((doc ->> 'application_id'::text))::integer >= 550000) AND (((doc ->> 'application_id'::text))::integer <= 550099)) │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


create index if not exists
idx_applications_application_id_text
on applications using btree
((doc->>'application_id'));

analyze applications;

explain analyze
select id, doc
from applications
where (doc->>'application_id') = '550099';

┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                      QUERY PLAN                                                                      │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using idx_applications_application_id_text on applications  (cost=0.42..8.44 rows=1 width=1830) (actual time=0.060..0.062 rows=1 loops=1) │
│   Index Cond: ((doc ->> 'application_id'::text) = '550099'::text)                                                                                    │
│ Planning Time: 0.196 ms                                                                                                                              │
│ Execution Time: 0.085 ms                                                                                                                             │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

select
    (doc->>'application_id') as doc_id
from
    applications
order by 1
limit 100

┌─────────┐
│ doc_id  │
├─────────┤
│ 1       │
│ 10      │
│ 100     │
│ 1000    │
│ 10000   │
│ 100000  │
│ 1000000 │
│ 100001  │
│ 100002  │
│ 100003  │
│ 100004  │
│ 100005  │
│ 100006  │

insert into applications (doc)
values ($${
    "some_field": 42,
    "application_id": "123a456"
}$$::jsonb);

ERROR:  invalid input syntax for type integer: "123a456"



insert into applications (doc)
values ($${
    "some_field": 42,
    "another_field": "not a number"
}$$::jsonb);

INSERT 0 1





update applications
set doc['approved_at'] = to_json(current_timestamp - (interval '1 year') * random());

select id, doc['approved_at'] from applications limit 10;
┌──────────────────────────────────────┬────────────────────────────────────┐
│                  id                  │                doc                 │
├──────────────────────────────────────┼────────────────────────────────────┤
│ 00000000-0000-0000-0000-000000009985 │ "2025-10-23T15:59:46.943586+03:00" │
│ 00000000-0000-0000-0000-000000009986 │ "2025-12-17T17:25:57.205986+03:00" │
│ 00000000-0000-0000-0000-000000009987 │ "2025-11-18T21:23:10.137186+03:00" │
│ 00000000-0000-0000-0000-000000009988 │ "2026-01-22T15:32:48.498786+03:00" │
│ 00000000-0000-0000-0000-000000009989 │ "2025-07-20T23:52:08.908386+03:00" │
│ 00000000-0000-0000-0000-000000009990 │ "2025-08-07T10:45:12.690786+03:00" │
│ 00000000-0000-0000-0000-000000009991 │ "2025-12-06T19:23:07.660386+03:00" │
│ 00000000-0000-0000-0000-000000009992 │ "2026-05-04T18:27:36.681186+03:00" │
│ 00000000-0000-0000-0000-000000009993 │ "2025-11-16T02:07:33.791586+03:00" │
│ 00000000-0000-0000-0000-000000009994 │ "2025-11-03T05:24:20.783586+03:00" │
└──────────────────────────────────────┴────────────────────────────────────┘



create index if not exists
idx_applications_approved_at
on applications using btree
(((doc->>'approved_at')::timestamptz at time zone 'utc'));

functions in index expression must be marked IMMUTABLE


create or replace function to_tsz_immutable(text)
  returns timestamptz
  language sql immutable strict parallel safe
return $1::timestamptz;


create index if not exists
idx_applications_approved_at
on applications using btree
(to_tsz_immutable(doc->>'approved_at'));


explain analyze
select id from applications
where to_tsz_immutable(doc->>'approved_at') between
    current_timestamp - interval '3 months'
    and
    current_timestamp - interval '1 months'
limit 100;

┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                      QUERY PLAN                                                                                                      │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Limit  (cost=0.43..401.63 rows=100 width=16) (actual time=0.080..0.247 rows=100 loops=1)                                                                                                                             │
│   ->  Index Scan using idx_applications_approved_at on applications  (cost=0.43..20060.44 rows=5000 width=16) (actual time=0.078..0.233 rows=100 loops=1)                                                            │
│         Index Cond: ((to_tsz_immutable((doc ->> 'approved_at'::text)) >= (CURRENT_TIMESTAMP - '3 mons'::interval)) AND (to_tsz_immutable((doc ->> 'approved_at'::text)) <= (CURRENT_TIMESTAMP - '1 mon'::interval))) │
│ Planning Time: 0.257 ms                                                                                                                                                                                              │
│ Execution Time: 0.277 ms                                                                                                                                                                                             │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

analyze applications;


create index if not exists
idx_applications_org_short_name_hash
on applications using hash
(((doc #>> '{organization,short_name}')));

analyze applications;

explain
select id
from applications
where (doc #>> '{organization,short_name}') = 'Organization 543'
limit 100;


select * from pg_stat_user_indexes
where relname = 'applications'
-- order by last_idx_scan desc nulls last
limit 10;


┌──────────────────────────────────────────────────┬──────────┬──────────────┬───────────────┐
│                   indexrelname                   │ idx_scan │ idx_tup_read │ idx_tup_fetch │
├──────────────────────────────────────────────────┼──────────┼──────────────┼───────────────┤
│ applications_pkey                                │        4 │            4 │             4 │
│ idx_applications_created_at                      │        5 │       258830 │             1 │
│ idx_applications_application_id                  │        1 │          100 │           100 │
│ idx_applications_org_short_name_hash             │        6 │         4790 │           790 │
│ idx_applications_status                          │        6 │      1495416 │             0 │
│ idx_applications_status_org_short_name           │        1 │          263 │           263 │
│ idx_applications_application_id_trgm             │        1 │           20 │             0 │
│ idx_applications_application_org_short_code_trgm │        2 │         2000 │             0 │
│ idx_applications_application_trgm_pattern        │        4 │         4138 │             0 │
│ idx_applications_application_id_text             │        2 │            2 │             2 │
└──────────────────────────────────────────────────┴──────────┴──────────────┴───────────────┘


┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                      QUERY PLAN                                                       │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Limit  (cost=0.00..400.15 rows=100 width=16)                                                                          │
│   ->  Index Scan using idx_applications_org_short_name_hash on applications  (cost=0.00..20007.50 rows=5000 width=16) │
│         Index Cond: ((doc #>> '{organization,short_name}'::text[]) = 'Organization 543'::text)                        │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

select from entity where a = 1;
select from entity where b = 'test';
select from entity where c = true;

select from entity
where
        a = 1
    and b = 'test'
    and c = true;


/////////////


select id, doc
from applications
where
        doc->>'assigned_to' = 'ivanov@acme.com'
    and doc->>'status' = 'active';


create or replace function generate_status() returns text
language plpgsql strict parallel safe
as $func$
declare
    r float4;
begin
    r := random();
    case
        when r < 0.65 then return 'archived';  -- 65%
        when r < 0.85 then return 'approved';  -- 20%
        when r < 0.95 then return 'rejected';  -- 10%
        else return 'active';                  --  5%
    end case;
end;
$func$;

update applications set
doc['assigned_to'] = to_jsonb(format('user_%s@test.com', (doc->>'application_id')::int % 1000)),
doc['status'] = to_jsonb(generate_status());


select
    to_char(count(id) / 1000000.0, '0.9999') as ratio,
    doc->>'status' as status
from applications
group by 2
order by 1 desc;

┌─────────┬──────────┐
│  ratio  │  status  │
├─────────┼──────────┤
│  0.6498 │ archived │
│  0.2001 │ approved │
│  0.1002 │ rejected │
│  0.0499 │ active   │
└─────────┴──────────┘

create index if not exists
idx_applications_status
on applications using btree
((doc->>'status'));

create index if not exists
idx_applications_assigned_to
on applications using btree
((doc->>'assigned_to'));

analyze applications;

explain analyze
select id, doc from applications
where
     (doc->>'status') = 'active'
 and (doc->>'assigned_to') = 'user_999@test.com';

-- (45 rows)


┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                   QUERY PLAN                                                                   │
├────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Bitmap Heap Scan on applications  (cost=407.13..526.75 rows=30 width=1915) (actual time=8.974..9.047 rows=45 loops=1)                          │
│   Recheck Cond: (((doc ->> 'assigned_to'::text) = 'user_999@test.com'::text) AND ((doc ->> 'status'::text) = 'active'::text))                  │
│   Heap Blocks: exact=45                                                                                                                        │
│   ->  BitmapAnd  (cost=407.13..407.13 rows=30 width=0) (actual time=8.938..8.940 rows=0 loops=1)                                               │
│         ->  Bitmap Index Scan on idx_applications_assigned_to  (cost=0.00..8.99 rows=609 width=0) (actual time=0.361..0.361 rows=1000 loops=1) │
│               Index Cond: ((doc ->> 'assigned_to'::text) = 'user_999@test.com'::text)                                                          │
│         ->  Bitmap Index Scan on idx_applications_status  (cost=0.00..397.88 rows=30060 width=0) (actual time=7.956..7.956 rows=49918 loops=1) │
│               Index Cond: ((doc ->> 'status'::text) = 'active'::text)                                                                          │
│ Planning Time: 0.316 ms                                                                                                                        │
│ Execution Time: 9.338 ms                                                                                                                       │
└────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


create index if not exists
idx_applications_status_assigned_to
on applications using btree
((doc->>'status'), (doc->>'assigned_to'));

analyze applications;

explain analyze
select id, doc from applications
where
     (doc->>'status') = 'active'
 and (doc->>'assigned_to') = 'user_999@test.com';

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                       QUERY PLAN                                                                        │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using idx_applications_status_assigned_to on applications  (cost=0.42..185.65 rows=51 width=1915) (actual time=0.139..0.223 rows=45 loops=1) │
│   Index Cond: (((doc ->> 'status'::text) = 'active'::text) AND ((doc ->> 'assigned_to'::text) = 'user_999@test.com'::text))                             │
│ Planning Time: 1.733 ms                                                                                                                                 │
│ Execution Time: 0.270 ms                                                                                                                                │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


create index if not exists
idx_applications_assigned_to_active
on applications using btree
((doc->>'assigned_to'))
where (doc->>'status' = 'active');

create index if not exists
idx_applications_assigned_to_active_not_vip
on applications using btree
((doc->>'assigned_to'))
where
    (doc->>'status' = 'active')
and (not (doc->>'is_vip')::boolean);


select id, doc from applications
where
     (doc->>'status') = 'active'
 and (doc->>'assigned_to') = 'user_999@test.com'
 and (not (doc->>'is_vip')::boolean);


analyze applications;


explain analyze
select id, doc from applications
where
     (doc->>'status') = 'active'
 and (doc->>'assigned_to') = 'user_999@test.com';

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                       QUERY PLAN                                                                        │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using idx_applications_assigned_to_active on applications  (cost=0.29..200.98 rows=49 width=1915) (actual time=0.434..0.482 rows=45 loops=1) │
│   Index Cond: ((doc ->> 'assigned_to'::text) = 'user_999@test.com'::text)                                                                               │
│ Planning Time: 0.658 ms                                                                                                                                 │
│ Execution Time: 0.499 ms                                                                                                                                │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


create index if not exists
idx_applications_assigned_to_status
on applications using btree
((doc->>'assigned_to'), (doc->>'status'));

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                       QUERY PLAN                                                                        │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using idx_applications_assigned_to_status on applications  (cost=0.42..209.44 rows=51 width=1915) (actual time=0.082..0.196 rows=45 loops=1) │
│   Index Cond: (((doc ->> 'assigned_to'::text) = 'user_999@test.com'::text) AND ((doc ->> 'status'::text) = 'active'::text))                             │
│ Planning Time: 0.665 ms                                                                                                                                 │
│ Execution Time: 0.223 ms                                                                                                                                │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘





explain analyze
select id, doc
from applications
where
    created_at > '2026-07-30 00:00:00Z'
    and (doc->>'status') = 'active';



┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                 QUERY PLAN                                                                  │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using idx_applications_created_at on applications  (cost=0.42..8.45 rows=1 width=1830) (actual time=0.009..0.010 rows=0 loops=1) │
│   Index Cond: (created_at > '2026-07-30 03:00:00+03'::timestamp with time zone)                                                             │
│   Filter: ((doc ->> 'status'::text) = 'active'::text)                                                                                       │
│ Planning Time: 2.318 ms                                                                                                                     │
│ Execution Time: 0.029 ms                                                                                                                    │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


explain analyze
select id, doc
from applications
where
    (doc #>> '{organization,short_name}') = 'Organization 543'
    and (doc->>'status') = 'active';


┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                       QUERY PLAN                                                                        │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Bitmap Heap Scan on applications  (cost=2774.26..3755.54 rows=250 width=1830) (actual time=44.482..45.525 rows=263 loops=1)                             │
│   Recheck Cond: (((doc #>> '{organization,short_name}'::text[]) = 'Organization 543'::text) AND ((doc ->> 'status'::text) = 'active'::text))            │
│   Rows Removed by Index Recheck: 314                                                                                                                    │
│   Heap Blocks: exact=577                                                                                                                                │
│   ->  BitmapAnd  (cost=2774.26..2774.26 rows=250 width=0) (actual time=44.391..44.392 rows=0 loops=1)                                                   │
│         ->  Bitmap Index Scan on idx_applications_org_short_name_hash  (cost=0.00..31.46 rows=995 width=0) (actual time=0.325..0.325 rows=1000 loops=1) │
│               Index Cond: ((doc #>> '{organization,short_name}'::text[]) = 'Organization 543'::text)                                                    │
│         ->  Bitmap Index Scan on idx_applications_status  (cost=0.00..2742.42 rows=250933 width=0) (actual time=43.522..43.522 rows=249236 loops=1)     │
│               Index Cond: ((doc ->> 'status'::text) = 'active'::text)                                                                                   │
│ Planning Time: 0.223 ms                                                                                                                                 │
│ Execution Time: 46.043 ms                                                                                                                               │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

create index if not exists
idx_applications_status_org_short_name
on applications using btree
((doc->>'status'), (doc #>> '{organization,short_name}'));

analyze applications;

explain analyze
select id, doc
from applications
where
    (doc #>> '{organization,short_name}') = 'Organization 543'
    and (doc->>'status') = 'active';


┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                          QUERY PLAN                                                                          │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using idx_applications_status_org_short_name on applications  (cost=0.42..975.36 rows=250 width=1830) (actual time=0.066..0.391 rows=263 loops=1) │
│   Index Cond: (((doc ->> 'status'::text) = 'active'::text) AND ((doc #>> '{organization,short_name}'::text[]) = 'Organization 543'::text))                   │
│ Planning Time: 0.810 ms                                                                                                                                      │
│ Execution Time: 0.417 ms                                                                                                                                     │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

select '1a3' like '1?3';

select
    email,
    email ilike '%john%@gmail.com' as matches
from (values
    ('JOHN_SMITH@Gmail.com'),
    ('Adam.Smith@GMAIL.com'),
    ('John+Anderson@gmail.com'),
    ('johnson@gmail.com')
) as vals(email);

┌─────────────────────────┬─────────┐
│          email          │ matches │
├─────────────────────────┼─────────┤
│ JOHN_SMITH@Gmail.com    │ t       │
│ Adam.Smith@GMAIL.com    │ f       │
│ John+Anderson@gmail.com │ t       │
│ johnson@gmail.com       │ t       │
└─────────────────────────┴─────────┘



select id from applications
where (doc->>'application_id') like '%12345%'
limit 100;

┌──────────────────────────────────────┐
│                  id                  │
├──────────────────────────────────────┤
│ 00000000-0000-0000-0000-000000012345 │
│ 00000000-0000-0000-0000-000000112345 │
│ 00000000-0000-0000-0000-000000123450 │
│ 00000000-0000-0000-0000-000000123451 │
│ 00000000-0000-0000-0000-000000123452 │
│ 00000000-0000-0000-0000-000000123453 │
│ 00000000-0000-0000-0000-000000123454 │
│ 00000000-0000-0000-0000-000000123455 │
│ 00000000-0000-0000-0000-000000123456 │
│ 00000000-0000-0000-0000-000000123457 │
│ 00000000-0000-0000-0000-000000123458 │
│ 00000000-0000-0000-0000-000000123459 │
│ 00000000-0000-0000-0000-000000212345 │
│ 00000000-0000-0000-0000-000000312345 │
│ 00000000-0000-0000-0000-000000412345 │
│ 00000000-0000-0000-0000-000000512345 │
│ 00000000-0000-0000-0000-000000612345 │
│ 00000000-0000-0000-0000-000000712345 │
│ 00000000-0000-0000-0000-000000812345 │
│ 00000000-0000-0000-0000-000000912345 │
└──────────────────────────────────────┘

create extension pg_trgm;

create index if not exists
idx_applications_application_id_trgm
on applications using gin
((doc->>'application_id') gin_trgm_ops);

explain analyze
select id from applications
where (doc->>'application_id') like '%12345%'
limit 100;

┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                      QUERY PLAN                                                                       │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Limit  (cost=32.77..428.27 rows=100 width=16) (actual time=0.629..0.732 rows=20 loops=1)                                                              │
│   ->  Bitmap Heap Scan on applications  (cost=32.77..428.27 rows=100 width=16) (actual time=0.628..0.729 rows=20 loops=1)                             │
│         Recheck Cond: ((doc ->> 'application_id'::text) ~~ '%12345%'::text)                                                                           │
│         Heap Blocks: exact=13                                                                                                                         │
│         ->  Bitmap Index Scan on idx_applications_application_id_trgm  (cost=0.00..32.75 rows=100 width=0) (actual time=0.601..0.601 rows=20 loops=1) │
│               Index Cond: ((doc ->> 'application_id'::text) ~~ '%12345%'::text)                                                                       │
│ Planning Time: 0.646 ms                                                                                                                               │
│ Execution Time: 0.765 ms                                                                                                                              │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


explain analyze
select id from applications
where (doc->>'application_id') like '%99%'
limit 100;


┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                       QUERY PLAN                                                       │
├────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Limit  (cost=0.00..874.50 rows=100 width=16) (actual time=0.096..5.397 rows=100 loops=1)                               │
│   ->  Seq Scan on applications  (cost=0.00..265000.00 rows=30303 width=16) (actual time=0.095..5.387 rows=100 loops=1) │
│         Filter: ((doc ->> 'application_id'::text) ~~ '%99%'::text)                                                     │
│         Rows Removed by Filter: 4378                                                                                   │
│ Planning Time: 0.189 ms                                                                                                │
│ Execution Time: 5.424 ms                                                                                               │
└────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

select show_trgm('#alpha!, ?beta=, ;gamma^');

┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                        show_trgm                                        │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ {"  a","  b","  g"," al"," be"," ga",alp,amm,bet,eta,gam,"ha ",lph,"ma ",mma,pha,"ta "} │
└─────────────────────────────────────────────────────────────────────────────────────────┘

50%

select 'more than 50% in total' ilike '%50\%%';
-- t

*12345*
%12345%


create index if not exists
idx_applications_application_org_short_code_trgm
on applications using gin
((doc #>> '{organization,short_name}') gin_trgm_ops);


explain analyze
select id from applications
where (doc #>> '{organization,short_name}') like '%999%'
limit 100;

┌──────────────────────────────────────┐
│                  id                  │
├──────────────────────────────────────┤
│ 00000000-0000-0000-0000-000000000999 │
│ 00000000-0000-0000-0000-000000001999 │
│ 00000000-0000-0000-0000-000000002999 │
│ 00000000-0000-0000-0000-000000003999 │
│ 00000000-0000-0000-0000-000000004999 │
│ 00000000-0000-0000-0000-000000005999 │
│ 00000000-0000-0000-0000-000000006999 │
│ 00000000-0000-0000-0000-000000007999 │
│ 00000000-0000-0000-0000-000000008999 │
│ 00000000-0000-0000-0000-000000009999 │
│ 00000000-0000-0000-0000-000000010999 │
│ 00000000-0000-0000-0000-000000011999 │
│ 00000000-0000-0000-0000-000000012999 │

┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                             QUERY PLAN                                                                             │
├────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Limit  (cost=24.77..416.34 rows=99 width=16) (actual time=0.292..0.527 rows=100 loops=1)                                                                           │
│   ->  Bitmap Heap Scan on applications  (cost=24.77..416.34 rows=99 width=16) (actual time=0.291..0.520 rows=100 loops=1)                                          │
│         Recheck Cond: ((doc #>> '{organization,short_name}'::text[]) ~~ '%999%'::text)                                                                             │
│         Heap Blocks: exact=100                                                                                                                                     │
│         ->  Bitmap Index Scan on idx_applications_application_org_short_code_trgm  (cost=0.00..24.74 rows=99 width=0) (actual time=0.181..0.181 rows=1000 loops=1) │
│               Index Cond: ((doc #>> '{organization,short_name}'::text[]) ~~ '%999%'::text)                                                                         │
│ Planning Time: 0.224 ms                                                                                                                                            │
│ Execution Time: 0.569 ms                                                                                                                                           │
└────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


select
    id, doc
from
    applications
where
        (doc #>> '{application_id}') ilike '%12345%'
    and (doc #>> '{organization,short_name}') ilike 'Acme'
    and (doc #>> '{created_by,name}') ilike '%Мария%'
    and (doc #>> '{comment}') ilike '%начисления%'
limit
    100;


explain analyze
select
    id, doc
from
    applications
where
       (doc #>> '{application_id}')          ilike '%12345%'
    or (doc #>> '{organization,short_name}') ilike '%12345%'
    or (doc #>> '{created_by,name}')         ilike '%12345%'
    or (doc #>> '{comment}')                 ilike '%12345%'
limit
    100;

┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                                                QUERY PLAN                                                                                                                                 │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Limit  (cost=0.00..5724.80 rows=100 width=1830) (actual time=8.949..1287.774 rows=20 loops=1)                                                                                                                                                                             │
│   ->  Seq Scan on applications  (cost=0.00..280000.00 rows=4891 width=1830) (actual time=8.948..1287.771 rows=20 loops=1)                                                                                                                                                 │
│         Filter: (((doc #>> '{application_id}'::text[]) ~~* '%12345%'::text) OR ((doc #>> '{organization,short_name}'::text[]) ~~* '%12345%'::text) OR ((doc #>> '{created_by,name}'::text[]) ~~* '%12345%'::text) OR ((doc #>> '{comment}'::text[]) ~~* '%12345%'::text)) │
│         Rows Removed by Filter: 999981                                                                                                                                                                                                                                    │
│ Planning Time: 0.142 ms                                                                                                                                                                                                                                                   │
│ Execution Time: 1287.796 ms                                                                                                                                                                                                                                               │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


select id, (
       (doc #>> '{application_id}') || ' '
    || (doc #>> '{organization,short_name}') || ' '
    || (doc #>> '{created_by,name}') || ' '
    || (doc #>> '{comment}')
) as pattern
    from applications
limit 100;

┌──────────────────────────────────────┬──────────────────────────────────────────────────────┐
│                  id                  │                       pattern                        │
├──────────────────────────────────────┼──────────────────────────────────────────────────────┤
│ 00000000-0000-0000-0000-000000009857 │ 9857 Organization 857 User 0857 Comment number #9857 │
│ 00000000-0000-0000-0000-000000009858 │ 9858 Organization 858 User 0858 Comment number #9858 │
│ 00000000-0000-0000-0000-000000009859 │ 9859 Organization 859 User 0859 Comment number #9859 │
│ 00000000-0000-0000-0000-000000009860 │ 9860 Organization 860 User 0860 Comment number #9860 │
│ 00000000-0000-0000-0000-000000009861 │ 9861 Organization 861 User 0861 Comment number #9861 │
│ 00000000-0000-0000-0000-000000009862 │ 9862 Organization 862 User 0862 Comment number #9862 │
│ 00000000-0000-0000-0000-000000009863 │ 9863 Organization 863 User 0863 Comment number #9863 │
│ 00000000-0000-0000-0000-000000009864 │ 9864 Organization 864 User 0864 Comment number #9864 │

select id, concat_ws(
    ' ',
    (doc #>> '{application_id}'),
    (doc #>> '{organization,short_name}'),
    (doc #>> '{created_by,name}'),
    (doc #>> '{comment}')
) as pattern
from applications
limit 10;


┌──────────────────────────────────────┬──────────────────────────────────────────────────────┐
│                  id                  │                       pattern                        │
├──────────────────────────────────────┼──────────────────────────────────────────────────────┤
│ 00000000-0000-0000-0000-000000009921 │ 9921 Organization 921 User 0921 Comment number #9921 │
│ 00000000-0000-0000-0000-000000009922 │ 9922 Organization 922 User 0922 Comment number #9922 │
│ 00000000-0000-0000-0000-000000009923 │ 9923 Organization 923 User 0923 Comment number #9923 │
│ 00000000-0000-0000-0000-000000009924 │ 9924 Organization 924 User 0924 Comment number #9924 │
│ 00000000-0000-0000-0000-000000009925 │ 9925 Organization 925 User 0925 Comment number #9925 │
│ 00000000-0000-0000-0000-000000009926 │ 9926 Organization 926 User 0926 Comment number #9926 │
│ 00000000-0000-0000-0000-000000009927 │ 9927 Organization 927 User 0927 Comment number #9927 │
│ 00000000-0000-0000-0000-000000009928 │ 9928 Organization 928 User 0928 Comment number #9928 │
│ 00000000-0000-0000-0000-000000009929 │ 9929 Organization 929 User 0929 Comment number #9929 │
│ 00000000-0000-0000-0000-000000009930 │ 9930 Organization 930 User 0930 Comment number #9930 │
└──────────────────────────────────────┴──────────────────────────────────────────────────────┘

select 'foo' || null || 'bar' as result;
┌────────┐
│ result │
├────────┤
│ <null> │
└────────┘


create index if not exists
idx_applications_application_trgm_pattern
on applications using gin
((concat_ws(
    ' ',
    (doc #>> '{application_id}'),
    (doc #>> '{organization,short_name}'),
    (doc #>> '{created_by,name}'),
    (doc #>> '{comment}')
)) gin_trgm_ops);



-- https://stackoverflow.com/questions/54372666/create-an-immutable-clone-of-concat-ws
CREATE OR REPLACE FUNCTION immutable_concat_ws(text, VARIADIC text[])
  RETURNS text
  LANGUAGE internal IMMUTABLE PARALLEL SAFE AS 'text_concat_ws';


create index if not exists
idx_applications_application_trgm_pattern
on applications using gin
((immutable_concat_ws(
    ' ',
    (doc #>> '{application_id}'),
    (doc #>> '{organization,short_name}'),
    (doc #>> '{created_by,name}'),
    (doc #>> '{comment}')
)) gin_trgm_ops);

explain analyze
select id from applications
where (immutable_concat_ws(
    ' ',
    (doc #>> '{application_id}'),
    (doc #>> '{organization,short_name}'),
    (doc #>> '{created_by,name}'),
    (doc #>> '{comment}')
)) ilike '%User 0925%'
limit 100;

-- '%Organization 927%'
--

┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                                          QUERY PLAN                                                                                                                           │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Limit  (cost=240.78..637.27 rows=100 width=16) (actual time=31.892..32.272 rows=100 loops=1)                                                                                                                                                                  │
│   ->  Bitmap Heap Scan on applications  (cost=240.78..637.27 rows=100 width=16) (actual time=31.890..32.262 rows=100 loops=1)                                                                                                                                 │
│         Recheck Cond: (immutable_concat_ws(' '::text, VARIADIC ARRAY[(doc #>> '{application_id}'::text[]), (doc #>> '{organization,short_name}'::text[]), (doc #>> '{created_by,name}'::text[]), (doc #>> '{comment}'::text[])]) ~~* '%User 0925%'::text)     │
│         Heap Blocks: exact=100                                                                                                                                                                                                                                │
│         ->  Bitmap Index Scan on idx_applications_application_trgm_pattern  (cost=0.00..240.75 rows=100 width=0) (actual time=31.694..31.694 rows=1009 loops=1)                                                                                               │
│               Index Cond: (immutable_concat_ws(' '::text, VARIADIC ARRAY[(doc #>> '{application_id}'::text[]), (doc #>> '{organization,short_name}'::text[]), (doc #>> '{created_by,name}'::text[]), (doc #>> '{comment}'::text[])]) ~~* '%User 0925%'::text) │
│ Planning Time: 0.504 ms                                                                                                                                                                                                                                       │
│ Execution Time: 32.341 ms                                                                                                                                                                                                                                     │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


create table workers (
    id integer primary key,
    name text not null
);

insert into workers values
(1, 'Ivanov'),
(2, 'Petrov'),
(3, 'Sidorov'),
(4, 'Mikhailov'),
(5, 'Minin'),
(6, 'Pozharsky');

table workers;

┌────┬───────────┐
│ id │   name    │
├────┼───────────┤
│  1 │ Ivanov    │
│  2 │ Petrov    │
│  3 │ Sidorov   │
│  4 │ Mikhailov │
│  5 │ Minin     │
│  6 │ Pozharsky │
└────┴───────────┘
