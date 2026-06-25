
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
order by 1;


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
  order by 1
)
select
    g.id, a.doc
from grouped g
join applications a on g.id = a.id;


┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                          QUERY PLAN                                                                                           │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Nested Loop  (cost=4795.97..6489.87 rows=200 width=1114) (actual time=11.788..14.574 rows=20 loops=1)                                                                                         │
│   ->  Finalize GroupAggregate  (cost=4795.54..4819.37 rows=200 width=20) (actual time=11.750..14.411 rows=20 loops=1)                                                                         │
│         Group Key: "*SELECT* 2".id                                                                                                                                                            │
│         ->  Gather Merge  (cost=4795.54..4816.93 rows=174 width=16) (actual time=11.679..14.342 rows=20 loops=1)                                                                              │
│               Workers Planned: 2                                                                                                                                                              │
│               Workers Launched: 2                                                                                                                                                             │
│               ->  Partial GroupAggregate  (cost=3795.52..3796.82 rows=87 width=16) (actual time=0.727..0.738 rows=7 loops=3)                                                                  │
│                     Group Key: "*SELECT* 2".id                                                                                                                                                │
│                     ->  Sort  (cost=3795.52..3795.74 rows=87 width=16) (actual time=0.724..0.729 rows=14 loops=3)                                                                             │
│                           Sort Key: "*SELECT* 2".id                                                                                                                                           │
│                           Sort Method: quicksort  Memory: 25kB                                                                                                                                │
│                           Worker 0:  Sort Method: quicksort  Memory: 25kB                                                                                                                     │
│                           Worker 1:  Sort Method: quicksort  Memory: 25kB                                                                                                                     │
│                           ->  Parallel Append  (cost=1894.13..3792.72 rows=87 width=16) (actual time=0.019..0.683 rows=14 loops=3)                                                            │
│                                 ->  Subquery Scan on "*SELECT* 2"  (cost=3788.27..3792.29 rows=1 width=16) (actual time=0.009..0.010 rows=0 loops=1)                                          │
│                                       ->  Bitmap Heap Scan on applications  (cost=3788.27..3792.28 rows=1 width=20) (actual time=0.008..0.009 rows=0 loops=1)                                 │
│                                             Recheck Cond: ((doc #>> '{organization.code}'::text[]) = '12398'::text)                                                                           │
│                                             ->  Bitmap Index Scan on idx_applications_org_code_trgm  (cost=0.00..3788.26 rows=1 width=0) (actual time=0.006..0.006 rows=0 loops=1)            │
│                                                   Index Cond: ((doc #>> '{organization.code}'::text[]) = '12398'::text)                                                                       │
│                                 ->  Subquery Scan on "*SELECT* 4"  (cost=1894.13..1898.16 rows=1 width=16) (actual time=0.015..0.016 rows=0 loops=1)                                          │
│                                       ->  Bitmap Heap Scan on applications applications_1  (cost=1894.13..1898.15 rows=1 width=20) (actual time=0.014..0.015 rows=0 loops=1)                  │
│                                             Recheck Cond: ((doc #>> '{organization.code}'::text[]) ~~* '%12398%'::text)                                                                       │
│                                             ->  Bitmap Index Scan on idx_applications_org_code_trgm  (cost=0.00..1894.13 rows=1 width=0) (actual time=0.010..0.011 rows=0 loops=1)            │
│                                                   Index Cond: ((doc #>> '{organization.code}'::text[]) ~~* '%12398%'::text)                                                                   │
│                                 ->  Subquery Scan on "*SELECT* 5"  (cost=71.95..467.10 rows=100 width=16) (actual time=0.863..0.970 rows=20 loops=1)                                          │
│                                       ->  Bitmap Heap Scan on applications applications_2  (cost=71.95..466.10 rows=100 width=20) (actual time=0.862..0.966 rows=20 loops=1)                  │
│                                             Recheck Cond: ((doc #>> '{comment}'::text[]) ~~* '%12398%'::text)                                                                                 │
│                                             Heap Blocks: exact=13                                                                                                                             │
│                                             ->  Bitmap Index Scan on idx_applications_comment_trgm  (cost=0.00..71.92 rows=100 width=0) (actual time=0.832..0.832 rows=20 loops=1)            │
│                                                   Index Cond: ((doc #>> '{comment}'::text[]) ~~* '%12398%'::text)                                                                             │
│                                 ->  Subquery Scan on "*SELECT* 3"  (cost=34.45..429.60 rows=100 width=16) (actual time=0.864..0.981 rows=20 loops=1)                                          │
│                                       ->  Bitmap Heap Scan on applications applications_3  (cost=34.45..428.60 rows=100 width=20) (actual time=0.863..0.977 rows=20 loops=1)                  │
│                                             Recheck Cond: ((doc #>> '{application_id}'::text[]) ~~* '%12398%'::text)                                                                          │
│                                             Heap Blocks: exact=13                                                                                                                             │
│                                             ->  Bitmap Index Scan on idx_applications_application_id_trgm  (cost=0.00..34.42 rows=100 width=0) (actual time=0.816..0.816 rows=20 loops=1)     │
│                                                   Index Cond: ((doc #>> '{application_id}'::text[]) ~~* '%12398%'::text)                                                                      │
│                                 ->  Subquery Scan on "*SELECT* 1"  (cost=0.42..8.45 rows=1 width=16) (actual time=0.056..0.058 rows=1 loops=1)                                                │
│                                       ->  Index Scan using idx_doc_application_id on applications applications_4  (cost=0.42..8.44 rows=1 width=20) (actual time=0.054..0.056 rows=1 loops=1) │
│                                             Index Cond: ((doc #>> '{application_id}'::text[]) = '12398'::text)                                                                                │
│   ->  Index Scan using applications_pkey on applications a  (cost=0.42..8.34 rows=1 width=1114) (actual time=0.007..0.007 rows=1 loops=20)                                                    │
│         Index Cond: (id = "*SELECT* 2".id)                                                                                                                                                    │
│ Planning Time: 1.196 ms                                                                                                                                                                       │
│ Execution Time: 16.299 ms                                                                                                                                                                     │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘



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


┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                     QUERY PLAN                                                                                     │
├────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Sort  (cost=6599.09..6599.34 rows=100 width=52) (actual time=1.550..1.556 rows=20 loops=1)                                                                                         │
│   Sort Key: (COALESCE((10), (20), (30), (40), (50)))                                                                                                                               │
│   Sort Method: quicksort  Memory: 47kB                                                                                                                                             │
│   ->  Hash Full Join  (cost=6200.71..6595.77 rows=100 width=52) (actual time=1.440..1.536 rows=20 loops=1)                                                                         │
│         Hash Cond: (COALESCE(app.id, applications.id, applications_1.id, applications_2.id) = applications_3.id)                                                                   │
│         ->  Hash Full Join  (cost=5733.36..6128.16 rows=100 width=4472) (actual time=0.669..0.748 rows=20 loops=1)                                                                 │
│               Hash Cond: (COALESCE(app.id, applications.id, applications_1.id) = applications_2.id)                                                                                │
│               ->  Hash Full Join  (cost=3835.20..4229.74 rows=100 width=3354) (actual time=0.644..0.713 rows=20 loops=1)                                                           │
│                     Hash Cond: (applications_1.id = COALESCE(app.id, applications.id))                                                                                             │
│                     ->  Bitmap Heap Scan on applications applications_1  (cost=34.45..428.60 rows=100 width=1118) (actual time=0.530..0.588 rows=20 loops=1)                       │
│                           Recheck Cond: ((doc #>> '{application_id}'::text[]) ~~* '%12398%'::text)                                                                                 │
│                           Heap Blocks: exact=13                                                                                                                                    │
│                           ->  Bitmap Index Scan on idx_applications_application_id_trgm  (cost=0.00..34.42 rows=100 width=0) (actual time=0.498..0.498 rows=20 loops=1)            │
│                                 Index Cond: ((doc #>> '{application_id}'::text[]) ~~* '%12398%'::text)                                                                             │
│                     ->  Hash  (cost=3800.74..3800.74 rows=1 width=2236) (actual time=0.105..0.107 rows=1 loops=1)                                                                  │
│                           Buckets: 1024  Batches: 1  Memory Usage: 10kB                                                                                                            │
│                           ->  Hash Full Join  (cost=3792.72..3800.74 rows=1 width=2236) (actual time=0.093..0.101 rows=1 loops=1)                                                  │
│                                 Hash Cond: (COALESCE(app.id) = applications.id)                                                                                                    │
│                                 ->  Index Scan using idx_doc_application_id on applications app  (cost=0.42..8.44 rows=1 width=1118) (actual time=0.077..0.079 rows=1 loops=1)     │
│                                       Index Cond: ((doc #>> '{application_id}'::text[]) = '12398'::text)                                                                           │
│                                 ->  Hash  (cost=3792.28..3792.28 rows=1 width=1118) (actual time=0.008..0.009 rows=0 loops=1)                                                      │
│                                       Buckets: 1024  Batches: 1  Memory Usage: 8kB                                                                                                 │
│                                       ->  Bitmap Heap Scan on applications  (cost=3788.27..3792.28 rows=1 width=1118) (actual time=0.008..0.009 rows=0 loops=1)                    │
│                                             Recheck Cond: ((doc #>> '{organization.code}'::text[]) = '12398'::text)                                                                │
│                                             ->  Bitmap Index Scan on idx_applications_org_code_trgm  (cost=0.00..3788.26 rows=1 width=0) (actual time=0.005..0.005 rows=0 loops=1) │
│                                                   Index Cond: ((doc #>> '{organization.code}'::text[]) = '12398'::text)                                                            │
│               ->  Hash  (cost=1898.15..1898.15 rows=1 width=1118) (actual time=0.017..0.017 rows=0 loops=1)                                                                        │
│                     Buckets: 1024  Batches: 1  Memory Usage: 8kB                                                                                                                   │
│                     ->  Bitmap Heap Scan on applications applications_2  (cost=1894.13..1898.15 rows=1 width=1118) (actual time=0.016..0.017 rows=0 loops=1)                       │
│                           Recheck Cond: ((doc #>> '{organization.code}'::text[]) ~~* '%12398%'::text)                                                                              │
│                           ->  Bitmap Index Scan on idx_applications_org_code_trgm  (cost=0.00..1894.13 rows=1 width=0) (actual time=0.009..0.009 rows=0 loops=1)                   │
│                                 Index Cond: ((doc #>> '{organization.code}'::text[]) ~~* '%12398%'::text)                                                                          │
│         ->  Hash  (cost=466.10..466.10 rows=100 width=1118) (actual time=0.760..0.761 rows=20 loops=1)                                                                             │
│               Buckets: 1024  Batches: 1  Memory Usage: 31kB                                                                                                                        │
│               ->  Bitmap Heap Scan on applications applications_3  (cost=71.95..466.10 rows=100 width=1118) (actual time=0.651..0.746 rows=20 loops=1)                             │
│                     Recheck Cond: ((doc #>> '{comment}'::text[]) ~~* '%12398%'::text)                                                                                              │
│                     Heap Blocks: exact=13                                                                                                                                          │
│                     ->  Bitmap Index Scan on idx_applications_comment_trgm  (cost=0.00..71.92 rows=100 width=0) (actual time=0.600..0.600 rows=20 loops=1)                         │
│                           Index Cond: ((doc #>> '{comment}'::text[]) ~~* '%12398%'::text)                                                                                          │
│ Planning Time: 1.060 ms                                                                                                                                                            │
│ Execution Time: 3.088 ms                                                                                                                                                           │
└────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘




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
