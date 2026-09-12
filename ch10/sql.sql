
select
    id, doc
from
    applications
where
       (doc #>> '{application_id}')          ilike '%12398%'
    or (doc #>> '{organization,short_name}') ilike '%12398%'
    or (doc #>> '{created_by,name}')         ilike '%12398%'
    or (doc #>> '{comment}')                 ilike '%12398%'
limit
    100;



create or replace function application_search_pattern(doc jsonb)
returns text
language sql immutable strict parallel safe
return concat_ws(
    ' ',
    (doc #>> '{application_id}'),
    (doc #>> '{organization,short_name}'),
    (doc #>> '{created_by,name}'),
    (doc #>> '{comment}')
);


code  org name         user name     comment
61312 Global Corp      Suzanne Smith reconciliation started ref #991015123
10151 General Acme Inc John Brown    some long comment about the app



create index if not exists
idx_applications_application_trgm_pattern
on applications using gin
((application_search_pattern(doc)) gin_trgm_ops);

analyze applications;


select id from applications
where application_search_pattern(doc) ilike '%12398%'
limit 100;


alter table applications
add column _search_pattern text generated always
as (application_search_pattern(doc)) stored;


create index if not exists
idx_applications_application_search_pattern_trgm
on applications using gin
(_search_pattern gin_trgm_ops);


select id from applications
where _search_pattern ilike '%12398%'
limit 100;



-- 1

select id, 10 as rank
from applications
where (doc #>> '{application_id}') = '12398'


create unique index idx_doc_application_id
on applications ((doc #>> '{application_id}'))
nulls not distinct;


┌──────────────────────────────────────┬──────┐
│                  id                  │ rank │
├──────────────────────────────────────┼──────┤
│ 00000000-0000-0000-0000-000000012398 │   10 │
└──────────────────────────────────────┴──────┘


-- 2

select id, 20 as rank
from applications
where (doc #>> '{organization.code}') = '12398'

-- empty


-- 3

select id, 30 as rank
from applications
where (doc #>> '{application_id}') ilike '%12398%'

┌──────────────────────────────────────┬──────┐
│                  id                  │ rank │
├──────────────────────────────────────┼──────┤
│ 00000000-0000-0000-0000-000000912398 │   30 │
│ 00000000-0000-0000-0000-000000012398 │   30 │
│ 00000000-0000-0000-0000-000000112398 │   30 │
│ 00000000-0000-0000-0000-000000123980 │   30 │
│ 00000000-0000-0000-0000-000000123981 │   30 │
│ 00000000-0000-0000-0000-000000123982 │   30 │
│ 00000000-0000-0000-0000-000000123983 │   30 │
│ 00000000-0000-0000-0000-000000123984 │   30 │
│ 00000000-0000-0000-0000-000000123985 │   30 │

-- 4

select id, 40 as rank
from applications
where (doc #>> '{organization.code}') ilike '%12398%'

-- 5

select id, 50 as rank
from applications
where (doc #>> '{comment}') ilike '%12398%'

┌──────────────────────────────────────┬──────┐
│                  id                  │ rank │
├──────────────────────────────────────┼──────┤
│ 00000000-0000-0000-0000-000000912398 │   50 │
│ 00000000-0000-0000-0000-000000012398 │   50 │
│ 00000000-0000-0000-0000-000000112398 │   50 │
│ 00000000-0000-0000-0000-000000123980 │   50 │
│ 00000000-0000-0000-0000-000000123981 │   50 │
│ 00000000-0000-0000-0000-000000123982 │   50 │

--------------------


select id, 10 as rank
from applications
where (doc #>> '{application_id}') = '12398'

union all

select id, 20 as rank
from applications
where (doc #>> '{organization.code}') = '12398'

union all

select id, 30 as rank
from applications
where (doc #>> '{application_id}') ilike '%12398%'

union all

select id, 40 as rank
from applications
where (doc #>> '{organization.code}') ilike '%12398%'

union all

select id, 50 as rank
from applications
where (doc #>> '{comment}') ilike '%12398%'

limit 200;



┌──────────────────────────────────────┬──────┐
│                  id                  │ rank │
├──────────────────────────────────────┼──────┤
│ 00000000-0000-0000-0000-000000012398 │   10 │
│ 00000000-0000-0000-0000-000000812398 │   30 │
│ 00000000-0000-0000-0000-000000712398 │   30 │
│ 00000000-0000-0000-0000-000000312398 │   30 │
│ 00000000-0000-0000-0000-000000912398 │   30 │
│ 00000000-0000-0000-0000-000000012398 │   30 │
│ 00000000-0000-0000-0000-000000112398 │   30 │
│ 00000000-0000-0000-0000-000000123980 │   30 │
│ 00000000-0000-0000-0000-000000123981 │   30 │
│ 00000000-0000-0000-0000-000000123982 │   30 │
│ 00000000-0000-0000-0000-000000123983 │   30 │
│ 00000000-0000-0000-0000-000000123984 │   30 │
│ 00000000-0000-0000-0000-000000123985 │   30 │
│ 00000000-0000-0000-0000-000000123986 │   30 │
│ 00000000-0000-0000-0000-000000123987 │   30 │
│ 00000000-0000-0000-0000-000000123988 │   30 │
│ 00000000-0000-0000-0000-000000123989 │   30 │
│ 00000000-0000-0000-0000-000000212398 │   30 │
│ 00000000-0000-0000-0000-000000412398 │   30 │
│ 00000000-0000-0000-0000-000000512398 │   30 │
│ 00000000-0000-0000-0000-000000612398 │   30 │
│ 00000000-0000-0000-0000-000000812398 │   50 │
│ 00000000-0000-0000-0000-000000012398 │   50 │
│ 00000000-0000-0000-0000-000000112398 │   50 │
│ 00000000-0000-0000-0000-000000123980 │   50 │
│ 00000000-0000-0000-0000-000000123981 │   50 │
│ 00000000-0000-0000-0000-000000123982 │   50 │
│ 00000000-0000-0000-0000-000000123983 │   50 │



with
layers as (

  select id, 10 as rank
  from applications
  where (doc #>> '{application_id}') = '12398'

  union all

  select id, 20 as rank
  from applications
  where (doc #>> '{organization.code}') = '12398'

  union all

  select id, 30 as rank
  from applications
  where (doc #>> '{application_id}') ilike '%12398%'

  union all

  select id, 40 as rank
  from applications
  where (doc #>> '{organization.code}') ilike '%12398%'

  union all

  select id, 50 as rank
  from applications
  where (doc #>> '{comment}') ilike '%12398%'

)
select
    id, min(rank) as rank
from
    layers
group by id
order by 2;


-- no 50
┌──────────────────────────────────────┬──────┐
│                  id                  │ rank │
├──────────────────────────────────────┼──────┤
│ 00000000-0000-0000-0000-000000012398 │   10 │
│ 00000000-0000-0000-0000-000000112398 │   30 │
│ 00000000-0000-0000-0000-000000123980 │   30 │
│ 00000000-0000-0000-0000-000000123981 │   30 │
│ 00000000-0000-0000-0000-000000123982 │   30 │
│ 00000000-0000-0000-0000-000000123983 │   30 │
│ 00000000-0000-0000-0000-000000123984 │   30 │
│ 00000000-0000-0000-0000-000000123985 │   30 │
│ 00000000-0000-0000-0000-000000123986 │   30 │
│ 00000000-0000-0000-0000-000000123987 │   30 │
│ 00000000-0000-0000-0000-000000123988 │   30 │
│ 00000000-0000-0000-0000-000000123989 │   30 │
│ 00000000-0000-0000-0000-000000212398 │   30 │
│ 00000000-0000-0000-0000-000000312398 │   30 │
│ 00000000-0000-0000-0000-000000412398 │   30 │
│ 00000000-0000-0000-0000-000000512398 │   30 │
│ 00000000-0000-0000-0000-000000612398 │   30 │
│ 00000000-0000-0000-0000-000000712398 │   30 │
│ 00000000-0000-0000-0000-000000812398 │   30 │
│ 00000000-0000-0000-0000-000000912398 │   30 │
└──────────────────────────────────────┴──────┘

explain analyze
with
layers as (

  select id, 10 as rank
  from applications
  where (doc #>> '{application_id}') = '12398'

  union all

  select id, 20 as rank
  from applications
  where (doc #>> '{organization.code}') = '12398'

  union all

  select id, 30 as rank
  from applications
  where (doc #>> '{application_id}') ilike '%12398%'

  union all

  select id, 40 as rank
  from applications
  where (doc #>> '{organization.code}') ilike '%12398%'

  union all

  select id, 50 as rank
  from applications
  where (doc #>> '{comment}') ilike '%12398%'

),
grouped as (
  select
      id, min(rank) as rank
  from
      layers
  group by id
  order by 2
)
select
    g.id, a.doc
from grouped g
join applications a on g.id = a.id;


┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                          QUERY PLAN                                                                                           │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Nested Loop  (cost=2951.36..4621.93 rows=200 width=1114) (actual time=10.500..12.393 rows=20 loops=1)                                                                                         │
│   ->  Sort  (cost=2950.93..2951.43 rows=200 width=20) (actual time=10.418..12.189 rows=20 loops=1)                                                                                            │
│         Sort Key: (min((20)))                                                                                                                                                                 │
│         Sort Method: quicksort  Memory: 25kB                                                                                                                                                  │
│         ->  Finalize GroupAggregate  (cost=2918.81..2943.29 rows=200 width=20) (actual time=10.389..12.179 rows=20 loops=1)                                                                   │
│               Group Key: applications.id                                                                                                                                                      │
│               ->  Gather Merge  (cost=2918.81..2940.42 rows=174 width=20) (actual time=10.363..12.157 rows=20 loops=1)                                                                        │
│                     Workers Planned: 2                                                                                                                                                        │
│                     Workers Launched: 2                                                                                                                                                       │
│                     ->  Partial GroupAggregate  (cost=1918.79..1920.31 rows=87 width=20) (actual time=0.786..0.795 rows=7 loops=3)                                                            │
│                           Group Key: applications.id                                                                                                                                          │
│                           ->  Sort  (cost=1918.79..1919.01 rows=87 width=20) (actual time=0.782..0.786 rows=14 loops=3)                                                                       │
│                                 Sort Key: applications.id                                                                                                                                     │
│                                 Sort Method: quicksort  Memory: 26kB                                                                                                                          │
│                                 Worker 0:  Sort Method: quicksort  Memory: 25kB                                                                                                               │
│                                 Worker 1:  Sort Method: quicksort  Memory: 25kB                                                                                                               │
│                                 ->  Parallel Append  (cost=957.90..1915.99 rows=87 width=20) (actual time=0.013..0.736 rows=14 loops=3)                                                       │
│                                       ->  Bitmap Heap Scan on applications  (cost=1911.55..1915.56 rows=1 width=20) (actual time=0.010..0.011 rows=0 loops=1)                                 │
│                                             Recheck Cond: ((doc #>> '{organization.code}'::text[]) = '12398'::text)                                                                           │
│                                             ->  Bitmap Index Scan on idx_applications_org_code_trgm  (cost=0.00..1911.55 rows=1 width=0) (actual time=0.008..0.008 rows=0 loops=1)            │
│                                                   Index Cond: ((doc #>> '{organization.code}'::text[]) = '12398'::text)                                                                       │
│                                       ->  Bitmap Heap Scan on applications applications_1  (cost=957.90..961.91 rows=1 width=20) (actual time=0.021..0.022 rows=0 loops=1)                    │
│                                             Recheck Cond: ((doc #>> '{organization.code}'::text[]) ~~* '%12398%'::text)                                                                       │
│                                             ->  Bitmap Index Scan on idx_applications_org_code_trgm  (cost=0.00..957.90 rows=1 width=0) (actual time=0.014..0.014 rows=0 loops=1)             │
│                                                   Index Cond: ((doc #>> '{organization.code}'::text[]) ~~* '%12398%'::text)                                                                   │
│                                       ->  Bitmap Heap Scan on applications applications_2  (cost=76.20..470.35 rows=100 width=20) (actual time=1.096..1.192 rows=20 loops=1)                  │
│                                             Recheck Cond: ((doc #>> '{comment}'::text[]) ~~* '%12398%'::text)                                                                                 │
│                                             Heap Blocks: exact=13                                                                                                                             │
│                                             ->  Bitmap Index Scan on idx_applications_comment_trgm  (cost=0.00..76.17 rows=100 width=0) (actual time=0.971..0.971 rows=20 loops=1)            │
│                                                   Index Cond: ((doc #>> '{comment}'::text[]) ~~* '%12398%'::text)                                                                             │
│                                       ->  Bitmap Heap Scan on applications applications_3  (cost=38.70..432.85 rows=100 width=20) (actual time=0.836..0.933 rows=20 loops=1)                  │
│                                             Recheck Cond: ((doc #>> '{application_id}'::text[]) ~~* '%12398%'::text)                                                                          │
│                                             Heap Blocks: exact=13                                                                                                                             │
│                                             ->  Bitmap Index Scan on idx_applications_application_id_trgm  (cost=0.00..38.67 rows=100 width=0) (actual time=0.801..0.801 rows=20 loops=1)     │
│                                                   Index Cond: ((doc #>> '{application_id}'::text[]) ~~* '%12398%'::text)                                                                      │
│                                       ->  Index Scan using idx_doc_application_id on applications applications_4  (cost=0.42..8.44 rows=1 width=20) (actual time=0.036..0.038 rows=1 loops=1) │
│                                             Index Cond: ((doc #>> '{application_id}'::text[]) = '12398'::text)                                                                                │
│   ->  Index Scan using applications_pkey on applications a  (cost=0.42..8.34 rows=1 width=1114) (actual time=0.010..0.010 rows=1 loops=20)                                                    │
│         Index Cond: (id = applications.id)                                                                                                                                                    │
│ Planning Time: 1.093 ms                                                                                                                                                                       │
│ Execution Time: 12.491 ms                                                                                                                                                                     │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
(41 rows)





explain analyze
select
    coalesce(sub1.id, sub2.id, sub3.id, sub4.id, sub5.id) as id,
    coalesce(sub1.doc, sub2.doc, sub3.doc, sub4.doc, sub5.doc) as doc
from
(
    select id, doc, 10 as rank
    from applications app
    where (doc #>> '{application_id}') = '12398'
) as sub1
full join
(
    select id, doc, 20 as rank
    from applications
    where (doc #>> '{organization.code}') = '12398'

) as sub2 on coalesce(sub1.id) = sub2.id
full join
(
    select id, doc, 30 as rank
    from applications
    where (doc #>> '{application_id}') ilike '%12398%'

) as sub3 on coalesce(sub1.id, sub2.id) = sub3.id
full join(
    select id, doc, 40 as rank
    from applications
    where (doc #>> '{organization.code}') ilike '%12398%'
) as sub4 on coalesce(sub1.id, sub2.id, sub3.id) = sub4.id
full join(
    select id, doc, 50 as rank
    from applications
    where (doc #>> '{comment}') ilike '%12398%'
) as sub5 on coalesce(sub1.id, sub2.id, sub3.id, sub4.id) = sub5.id
order by coalesce(sub1.rank, sub2.rank, sub3.rank, sub4.rank, sub5.rank);


┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                        QUERY PLAN                                                                                        │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Nested Loop  (cost=3795.06..4636.14 rows=100 width=1114) (actual time=2.137..2.273 rows=20 loops=1)                                                                                      │
│   ->  Sort  (cost=3794.64..3794.89 rows=100 width=20) (actual time=2.109..2.117 rows=20 loops=1)                                                                                         │
│         Sort Key: (COALESCE((10), (20), (30), (40), (50)))                                                                                                                               │
│         Sort Method: quicksort  Memory: 25kB                                                                                                                                             │
│         ->  Hash Full Join  (cost=3396.25..3791.32 rows=100 width=20) (actual time=1.928..2.100 rows=20 loops=1)                                                                         │
│               Hash Cond: (COALESCE(app_1.id, applications.id, applications_1.id, applications_2.id) = applications_3.id)                                                                 │
│               ->  Hash Full Join  (cost=2924.65..3319.45 rows=100 width=80) (actual time=0.964..1.114 rows=20 loops=1)                                                                   │
│                     Hash Cond: (COALESCE(app_1.id, applications.id, applications_1.id) = applications_2.id)                                                                              │
│                     ->  Hash Full Join  (cost=1962.73..2357.27 rows=100 width=60) (actual time=0.940..1.053 rows=20 loops=1)                                                             │
│                           Hash Cond: (applications_1.id = COALESCE(app_1.id, applications.id))                                                                                           │
│                           ->  Bitmap Heap Scan on applications applications_1  (cost=38.70..432.85 rows=100 width=20) (actual time=0.864..0.961 rows=20 loops=1)                         │
│                                 Recheck Cond: ((doc #>> '{application_id}'::text[]) ~~* '%12398%'::text)                                                                                 │
│                                 Heap Blocks: exact=13                                                                                                                                    │
│                                 ->  Bitmap Index Scan on idx_applications_application_id_trgm  (cost=0.00..38.67 rows=100 width=0) (actual time=0.836..0.837 rows=20 loops=1)            │
│                                       Index Cond: ((doc #>> '{application_id}'::text[]) ~~* '%12398%'::text)                                                                             │
│                           ->  Hash  (cost=1924.02..1924.02 rows=1 width=40) (actual time=0.067..0.070 rows=1 loops=1)                                                                    │
│                                 Buckets: 1024  Batches: 1  Memory Usage: 9kB                                                                                                             │
│                                 ->  Hash Full Join  (cost=1916.00..1924.02 rows=1 width=40) (actual time=0.057..0.067 rows=1 loops=1)                                                    │
│                                       Hash Cond: (COALESCE(app_1.id) = applications.id)                                                                                                  │
│                                       ->  Index Scan using idx_doc_application_id on applications app_1  (cost=0.42..8.44 rows=1 width=20) (actual time=0.026..0.027 rows=1 loops=1)     │
│                                             Index Cond: ((doc #>> '{application_id}'::text[]) = '12398'::text)                                                                           │
│                                       ->  Hash  (cost=1915.56..1915.56 rows=1 width=20) (actual time=0.027..0.028 rows=0 loops=1)                                                        │
│                                             Buckets: 1024  Batches: 1  Memory Usage: 8kB                                                                                                 │
│                                             ->  Bitmap Heap Scan on applications  (cost=1911.55..1915.56 rows=1 width=20) (actual time=0.022..0.023 rows=0 loops=1)                      │
│                                                   Recheck Cond: ((doc #>> '{organization.code}'::text[]) = '12398'::text)                                                                │
│                                                   ->  Bitmap Index Scan on idx_applications_org_code_trgm  (cost=0.00..1911.55 rows=1 width=0) (actual time=0.006..0.007 rows=0 loops=1) │
│                                                         Index Cond: ((doc #>> '{organization.code}'::text[]) = '12398'::text)                                                            │
│                     ->  Hash  (cost=961.91..961.91 rows=1 width=20) (actual time=0.017..0.018 rows=0 loops=1)                                                                            │
│                           Buckets: 1024  Batches: 1  Memory Usage: 8kB                                                                                                                   │
│                           ->  Bitmap Heap Scan on applications applications_2  (cost=957.90..961.91 rows=1 width=20) (actual time=0.017..0.017 rows=0 loops=1)                           │
│                                 Recheck Cond: ((doc #>> '{organization.code}'::text[]) ~~* '%12398%'::text)                                                                              │
│                                 ->  Bitmap Index Scan on idx_applications_org_code_trgm  (cost=0.00..957.90 rows=1 width=0) (actual time=0.007..0.007 rows=0 loops=1)                    │
│                                       Index Cond: ((doc #>> '{organization.code}'::text[]) ~~* '%12398%'::text)                                                                          │
│               ->  Hash  (cost=470.35..470.35 rows=100 width=20) (actual time=0.956..0.957 rows=20 loops=1)                                                                               │
│                     Buckets: 1024  Batches: 1  Memory Usage: 10kB                                                                                                                        │
│                     ->  Bitmap Heap Scan on applications applications_3  (cost=76.20..470.35 rows=100 width=20) (actual time=0.846..0.947 rows=20 loops=1)                               │
│                           Recheck Cond: ((doc #>> '{comment}'::text[]) ~~* '%12398%'::text)                                                                                              │
│                           Heap Blocks: exact=13                                                                                                                                          │
│                           ->  Bitmap Index Scan on idx_applications_comment_trgm  (cost=0.00..76.17 rows=100 width=0) (actual time=0.801..0.801 rows=20 loops=1)                         │
│                                 Index Cond: ((doc #>> '{comment}'::text[]) ~~* '%12398%'::text)                                                                                          │
│   ->  Index Scan using applications_pkey on applications app  (cost=0.42..8.40 rows=1 width=1114) (actual time=0.007..0.007 rows=1 loops=20)                                             │
│         Index Cond: (id = (COALESCE(app_1.id, applications.id, applications_1.id, applications_2.id, applications_3.id)))                                                                │
│ Planning Time: 1.174 ms                                                                                                                                                                  │
│ Execution Time: 2.368 ms                                                                                                                                                                 │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
(44 rows)





select
    sub1.id, sub1.rank,
    sub2.id, sub2.rank,
    sub3.id, sub3.rank,
    sub4.id, sub4.rank,
    sub5.id, sub5.rank
from
(
    select id, doc, 10 as rank
    from applications app
    where (doc #>> '{application_id}') = '12398'
) as sub1
full join
(
    select id, doc, 20 as rank
    from applications
    where (doc #>> '{organization.code}') = '12398'

) as sub2 on coalesce(sub1.id) = sub2.id
full join
(
    select id, doc, 30 as rank
    from applications
    where (doc #>> '{application_id}') ilike '%12398%'

) as sub3 on coalesce(sub1.id, sub2.id) = sub3.id
full join(
    select id, doc, 40 as rank
    from applications
    where (doc #>> '{organization.code}') ilike '%12398%'
) as sub4 on coalesce(sub1.id, sub2.id, sub3.id) = sub4.id
full join(
    select id, doc, 50 as rank
    from applications
    where (doc #>> '{comment}') ilike '%12398%'
) as sub5 on coalesce(sub1.id, sub2.id, sub3.id, sub4.id) = sub5.id
order by coalesce(sub1.rank, sub2.rank, sub3.rank, sub4.rank, sub5.rank);


┌──────────────────────────────────────┬────────┬────────┬────────┬──────────────────────────────────────┬──────┬────────┬────────┬──────────────────────────────────────┬──────┐
│                  id                  │  rank  │   id   │  rank  │                  id                  │ rank │   id   │  rank  │                  id                  │ rank │
├──────────────────────────────────────┼────────┼────────┼────────┼──────────────────────────────────────┼──────┼────────┼────────┼──────────────────────────────────────┼──────┤
│ 00000000-0000-0000-0000-000000012398 │     10 │ <null> │ <null> │ 00000000-0000-0000-0000-000000012398 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000012398 │   50 │
│ <null>                               │ <null> │ <null> │ <null> │ 00000000-0000-0000-0000-000000112398 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000112398 │   50 │
│ <null>                               │ <null> │ <null> │ <null> │ 00000000-0000-0000-0000-000000123980 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000123980 │   50 │
│ <null>                               │ <null> │ <null> │ <null> │ 00000000-0000-0000-0000-000000123981 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000123981 │   50 │
│ <null>                               │ <null> │ <null> │ <null> │ 00000000-0000-0000-0000-000000123982 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000123982 │   50 │
│ <null>                               │ <null> │ <null> │ <null> │ 00000000-0000-0000-0000-000000123983 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000123983 │   50 │
│ <null>                               │ <null> │ <null> │ <null> │ 00000000-0000-0000-0000-000000123984 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000123984 │   50 │
│ <null>                               │ <null> │ <null> │ <null> │ 00000000-0000-0000-0000-000000123985 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000123985 │   50 │
│ <null>                               │ <null> │ <null> │ <null> │ 00000000-0000-0000-0000-000000123986 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000123986 │   50 │
│ <null>                               │ <null> │ <null> │ <null> │ 00000000-0000-0000-0000-000000123987 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000123987 │   50 │
│ <null>                               │ <null> │ <null> │ <null> │ 00000000-0000-0000-0000-000000123988 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000123988 │   50 │
│ <null>                               │ <null> │ <null> │ <null> │ 00000000-0000-0000-0000-000000123989 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000123989 │   50 │
│ <null>                               │ <null> │ <null> │ <null> │ 00000000-0000-0000-0000-000000212398 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000212398 │   50 │
│ <null>                               │ <null> │ <null> │ <null> │ 00000000-0000-0000-0000-000000312398 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000312398 │   50 │
│ <null>                               │ <null> │ <null> │ <null> │ 00000000-0000-0000-0000-000000412398 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000412398 │   50 │
│ <null>                               │ <null> │ <null> │ <null> │ 00000000-0000-0000-0000-000000512398 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000512398 │   50 │
│ <null>                               │ <null> │ <null> │ <null> │ 00000000-0000-0000-0000-000000612398 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000612398 │   50 │
│ <null>                               │ <null> │ <null> │ <null> │ 00000000-0000-0000-0000-000000712398 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000712398 │   50 │
│ <null>                               │ <null> │ <null> │ <null> │ 00000000-0000-0000-0000-000000812398 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000812398 │   50 │
│ <null>                               │ <null> │ <null> │ <null> │ 00000000-0000-0000-0000-000000912398 │   30 │ <null> │ <null> │ 00000000-0000-0000-0000-000000912398 │   50 │
└──────────────────────────────────────┴────────┴────────┴────────┴──────────────────────────────────────┴──────┴────────┴────────┴──────────────────────────────────────┴──────┘


----


explain analyze
with
step1 as (
  select
      coalesce(sub1.id, sub2.id, sub3.id, sub4.id, sub5.id) as id,
      coalesce(sub1.rank, sub2.rank, sub3.rank, sub4.rank, sub5.rank) as rank
  from
  (
      select id, 10 as rank
      from applications app
      where (doc #>> '{application_id}') = '12398'
  ) as sub1
  full join
  (
      select id, 20 as rank
      from applications
      where (doc #>> '{organization.code}') = '12398'

  ) as sub2 on coalesce(sub1.id) = sub2.id
  full join
  (
      select id, 30 as rank
      from applications
      where (doc #>> '{application_id}') ilike '%12398%'

  ) as sub3 on coalesce(sub1.id, sub2.id) = sub3.id
  full join(
      select id, 40 as rank
      from applications
      where (doc #>> '{organization.code}') ilike '%12398%'
  ) as sub4 on coalesce(sub1.id, sub2.id, sub3.id) = sub4.id
  full join(
      select id, 50 as rank
      from applications
      where (doc #>> '{comment}') ilike '%12398%'
  ) as sub5 on coalesce(sub1.id, sub2.id, sub3.id, sub4.id) = sub5.id
  order by 2
)
select
    step1.id, app.doc
from
    step1
join applications app
    on step1.id = app.id;



select
    coalesce(sub1.id, sub2.id, sub3.id, sub4.id, sub5.id) as id,
    coalesce(sub1.doc, sub2.doc, sub3.doc, sub4.doc, sub5.doc) as doc
from
(
    select id, doc, 10 as rank
    from applications app
    where (doc #>> '{application_id}') = '12398'
    limit 50
) as sub1
full join
(
    select id, doc, 20 as rank
    from applications
    where (doc #>> '{organization.code}') = '12398'
    limit 50

) as sub2 on coalesce(sub1.id) = sub2.id

-----



select id, 10 as rank
from history
where
        entity = 'application'
    and created_at between ($1::timestamptz and $2::timestamptz)
    and operation = 'update'
    and (doc #>> '{application_id}') = '12398'


where patch @? '$[*] ? (@.path == "/attrs/status" && @.value == "in_transition") '




explain analyze
with
layers as (

  select id, 10 as rank
  from applications
  where (doc #>> '{application_id}') = '12398'

  union all

  select id, 20 as rank
  from applications
  where (doc #>> '{organization.code}') = '12398'

  union all

  select id, 30 as rank
  from applications
  where (doc #>> '{application_id}') ilike '%12398%'

  union all

  select id, 40 as rank
  from applications
  where (doc #>> '{organization.code}') ilike '%12398%'

  union all

  select id, 50 as rank
  from applications
  where (doc #>> '{comment}') ilike '%12398%'

  union all

  select pk, 60 as rank
  from history
  where
      entity = 'application'
  and created_at > now() - interval '1 week'
  and operation = 'update'
  and (doc #>> '{organization,short_name}') ilike '%12398%'
),
grouped as (
  select
      id, min(rank) as rank
  from
      layers
  group by id
  order by 2
)
select
    g.id, a.doc
from grouped g
join applications a on g.id = a.id;




with
layers as (

  select id from ...
  union all
  select id from ...
  union all
  select id from ...
  limit 50

----

with
layers as (

  select * from (
    select id, 10 as rank
    from applications
    where (doc #>> '{application_id}') = '12398'
    limit 50
  )

  union all

  select * from (
    select id, 20 as rank
    from applications
    where (doc #>> '{organization.code}') = '12398'
    limit 50
  )


----


select to_tsvector('russian', 'Во поле берёза стояла.');

┌────────────────────────────┐
│        to_tsvector         │
├────────────────────────────┤
│ 'берез':3 'пол':2 'стоя':4 │
└────────────────────────────┘

select to_tsvector('Во поле берёза стояла.');

┌───────────────────────────────────────┐
│              to_tsvector              │
├───────────────────────────────────────┤
│ 'берёза':3 'во':1 'поле':2 'стояла':4 │
└───────────────────────────────────────┘

select to_tsvector('russian', $$
  Долго у моря ждал он ответа,
  Не дождался, к старухе воротился.
  Глядь: опять перед ним землянка;
  На пороге сидит его старуха,
  А пред нею разбитое корыто.
$$);


┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                         to_tsvector                                                                         │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ 'ворот':11 'гляд':12 'дожда':8 'долг':1 'ждал':4 'землянк':16 'корыт':26 'мор':3 'не':24 'ответ':6 'порог':18 'пред':23 'разбит':25 'сид':19 'старух':10,21 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘





select to_tsvector('russian', 'Во поле берёза стояла.')
    @@ to_tsquery('russian', 'берёза & стояла') as res;

┌─────┐
│ res │
├─────┤
│ t   │
└─────┘

select to_tsvector('russian', 'Во поле берёза стояла.')
    @@ to_tsquery('russian', 'берёза & кудрявая') as res;



create index idx_application_comment_tsvector
on applications
using gin (to_tsvector('english', doc->>'comment'));






  select * from (
    select id, 50 as rank
    from applications
    where to_tsvector('english', doc->>'comment') @@ to_tsquery('english', '12398')
    limit 50
  ) as sub5



┌──────────────────────────────────────┬──────┐
│                  id                  │ rank │
├──────────────────────────────────────┼──────┤
│ 00000000-0000-0000-0000-000000012398 │   50 │
└──────────────────────────────────────┴──────┘


select cfgname from pg_ts_config;

┌────────────┐
│  cfgname   │
├────────────┤
│ simple     │
│ arabic     │
│ armenian   │
│ basque     │
│ catalan    │
│ danish     │
│ dutch      │
│ english    │
│ finnish    │
│ french     │
│ german     │
│ greek      │
│ hindi      │
│ hungarian  │
│ indonesian │
│ irish      │
│ italian    │
│ lithuanian │
│ nepali     │
│ norwegian  │
│ portuguese │
│ romanian   │
│ russian    │
│ serbian    │
│ spanish    │
│ swedish    │
│ tamil      │
│ turkish    │
│ yiddish    │
└────────────┘


create or replace function app_detect_lang(doc jsonb)
returns regconfig
transform for type jsonb
language plpython3u immutable strict parallel safe as $$
    from langdetect import detect
    lang = detect(doc["comment"])

    mapping = {
        "en": "english",
        "ru": "russian",
        "fr": "french"
    }

    if lang in mapping:
        return mapping[lang]
    else:
        return 'simple'
$$;


select app_detect_lang($${"comment": "fox and bird"}$$::jsonb);
┌─────────────────┐
│ app_detect_lang │
├─────────────────┤
│ english         │
└─────────────────┘


select app_detect_lang($${"comment": "я русский"}$$::jsonb);
┌─────────────────┐
│ app_detect_lang │
├─────────────────┤
│ russian         │
└─────────────────┘



create or replace function app_ts_vector(doc jsonb)
returns tsvector
language sql immutable strict parallel safe
return to_tsvector(app_detect_lang(doc), doc->>'comment');


select app_ts_vector(doc) as ts_vec
from applications limit 10;

┌───────────────────────────────────┐
│              ts_vec               │
├───────────────────────────────────┤
│ '116141':3 'comment':1 'number':2 │
│ '116142':3 'comment':1 'number':2 │
│ '116143':3 'comment':1 'number':2 │
│ '116144':3 'comment':1 'number':2 │
│ '116145':3 'comment':1 'number':2 │
│ '116146':3 'comment':1 'number':2 │
│ '116147':3 'comment':1 'number':2 │
│ '116148':3 'comment':1 'number':2 │
│ '116149':3 'comment':1 'number':2 │
│ '116150':3 'comment':1 'number':2 │
└───────────────────────────────────┘
