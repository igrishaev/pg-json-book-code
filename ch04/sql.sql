
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


explain
select id, doc from applications
where ((doc->>'application_id')::int) between 550000 and 550099;

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                             QUERY PLAN                                                              │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using idx_applications_application_id on applications  (cost=0.42..33.27 rows=92 width=1830)                             │
│   Index Cond: ((((doc ->> 'application_id'::text))::integer >= 550000) AND (((doc ->> 'application_id'::text))::integer <= 550099)) │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


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
    "application_id": "not a number"
}$$::jsonb);

ERROR:  invalid input syntax for type integer: "not a number"


insert into applications (doc)
values ($${
    "some_field": 42,
    "another_field": "not a number"
}$$::jsonb);

INSERT 0 1



/*
create index if not exists
idx_applications_created_at
on applications using btree
(((doc->>'created_at')::timestamptz));

analyze applications;
*/


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

┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                      QUERY PLAN                                                       │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Limit  (cost=0.00..400.15 rows=100 width=16)                                                                          │
│   ->  Index Scan using idx_applications_org_short_name_hash on applications  (cost=0.00..20007.50 rows=5000 width=16) │
│         Index Cond: ((doc #>> '{organization,short_name}'::text[]) = 'Organization 543'::text)                        │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

create index if not exists
idx_applications_status
on applications using btree
((doc->>'status'));

analyze applications;



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

select show_trgm('#alpha#, ?beta?, @gamma@');

┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                        show_trgm                                        │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ {"  a","  b","  g"," al"," be"," ga",alp,amm,bet,eta,gam,"ha ",lph,"ma ",mma,pha,"ta "} │
└─────────────────────────────────────────────────────────────────────────────────────────┘

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
