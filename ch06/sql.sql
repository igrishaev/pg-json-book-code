select jsonb_path_query_first($$
{
  "users": [
    {
      "id": 101,
      "age": 33,
      "name": "Ivan Petrov"
    },
    {
      "id": 135,
      "age": 52,
      "name": "Andrey Ivanov"
    },
    {
      "id": 399,
      "age": 41,
      "name": "Anna Smirnova"
    }
  ]
}
$$::jsonb, '$.users[0].name') as node;


┌───────────────┐
│     node      │
├───────────────┤
│ "Ivan Petrov" │
└───────────────┘

drop table if exists demo;

create table demo(doc jsonb not null);

insert into demo values ($$
{
  "users": [
    {
      "id": 101,
      "age": 33,
      "name": "Ivan Petrov"
    },
    {
      "id": 135,
      "age": 52,
      "name": "Andrey Ivanov"
    },
    {
      "id": 399,
      "age": 41,
      "name": "Anna Smirnova"
    }
  ]
}
$$::jsonb);

select
    jsonb_path_query_first(doc, '$.users.name') as node
from demo;

┌───────────────┐
│     node      │
├───────────────┤
│ "Ivan Petrov" │
└───────────────┘

select
    jsonb_path_query_array(doc, '$.users.name') as node
from demo;

┌───────────────────────────────────────────────────┐
│                       node                        │
├───────────────────────────────────────────────────┤
│ ["Ivan Petrov", "Andrey Ivanov", "Anna Smirnova"] │
└───────────────────────────────────────────────────┘

select
    jsonb_path_query(doc, '$.users.name') as node
from demo;

┌─────────────────┐
│      node       │
├─────────────────┤
│ "Ivan Petrov"   │
│ "Andrey Ivanov" │
│ "Anna Smirnova" │
└─────────────────┘

strict $.path.to.node
lax $.path.to.node


select
    jsonb_path_query(doc, 'lax $.hello.test') as node
from demo;


select
    jsonb_path_query(doc, 'strict $.hello.test') as node
from demo;

-- ERROR:  JSON object does not contain key "hello"






select
    jsonb_path_query(doc, 'strict $.users[*].id') as node
from demo;

┌──────┐
│ node │
├──────┤
│ 101  │
│ 135  │
│ 399  │
└──────┘

select
    jsonb_path_query(doc, 'lax $.users.id') as node
from demo;

┌──────┐
│ node │
├──────┤
│ 101  │
│ 135  │
│ 399  │
└──────┘


select
    jsonb_path_query(doc, 'strict $.users.id') as node
from demo;

-- ERROR:  jsonpath member accessor can only be applied to an object


select jsonb_path_query($$
{
  "matrix": [
    [{"id": 1}, {"id": 2}, {"id": 3}],
    [{"id": 4}, {"id": 5}, {"id": 6}],
    [{"id": 7}, {"id": 8}, {"id": 9}]
  ]
}
$$, 'strict $.matrix[*][*].id') as x;

┌───┐
│ x │
├───┤
│ 1 │
│ 2 │
│ 3 │
│ 4 │
│ 5 │
│ 6 │
│ 7 │
│ 8 │
│ 9 │
└───┘

select jsonb_path_query($$
{
  "matrix": [
    [{"id": 1}, {"id": 2}, {"id": 3}],
    [{"id": 4}, {"id": 5}, {"id": 6}],
    [{"id": 7}, {"id": 8}, {"id": 9}]
  ]
}
$$, 'lax $.matrix.id') as x;

┌───┐
│ x │
├───┤
└───┘
(0 rows)


create index if not exists
idx_applications_doc_gin_jsonb_ops
on applications using gin
(doc jsonb_ops);


drop index if exists idx_applications_doc_gin_jsonb_ops;

create index if not exists
idx_applications_doc_gin_jsonb_path_ops
on applications using gin
(doc jsonb_path_ops);



select id from applications
where doc @? 'lax $.departments.users.email'
limit 10;

┌──────────────────────────────────────┐
│                  id                  │
├──────────────────────────────────────┤
│ 00000000-0000-0000-0000-000000000065 │
│ 00000000-0000-0000-0000-000000000066 │
│ 00000000-0000-0000-0000-000000000067 │
│ 00000000-0000-0000-0000-000000000068 │
│ 00000000-0000-0000-0000-000000000069 │
│ 00000000-0000-0000-0000-000000000070 │
│ 00000000-0000-0000-0000-000000000071 │
│ 00000000-0000-0000-0000-000000000072 │
│ 00000000-0000-0000-0000-000000000073 │
│ 00000000-0000-0000-0000-000000000074 │
└──────────────────────────────────────┘






explain analyze
select id from applications
where doc @@ 'lax $.departments.users.email == "user_65@test.com" '
limit 10;

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                         QUERY PLAN                                                                          │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Limit  (cost=90.20..126.64 rows=10 width=16) (actual time=1.703..1.747 rows=10 loops=1)                                                                     │
│   ->  Bitmap Heap Scan on applications  (cost=90.20..36325.58 rows=9943 width=16) (actual time=1.702..1.744 rows=10 loops=1)                                │
│         Recheck Cond: (doc @@ '($."departments"."users"."email" == "user_65@test.com")'::jsonpath)                                                          │
│         Heap Blocks: exact=10                                                                                                                               │
│         ->  Bitmap Index Scan on idx_applications_doc_gin_jsonb_path_ops  (cost=0.00..87.71 rows=9943 width=0) (actual time=0.901..0.902 rows=3000 loops=1) │
│               Index Cond: (doc @@ '($."departments"."users"."email" == "user_65@test.com")'::jsonpath)                                                      │
│ Planning Time: 0.113 ms                                                                                                                                     │
│ Execution Time: 1.770 ms                                                                                                                                    │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


select id from applications
where doc @@ 'lax $.created_by.name == "User 0999"'
limit 10;


select id from applications
where doc @@ 'lax $.application_id == 1513 '
limit 10;

┌──────────────────────────────────────┐
│                  id                  │
├──────────────────────────────────────┤
│ 00000000-0000-0000-0000-000000001513 │
└──────────────────────────────────────┘


select id from applications
where doc @@ '$.created_by.id == $.departments.users.id'
limit 10;


SELECT pg_size_pretty(pg_total_relation_size('idx_applications_doc_gin_jsonb_path_ops'))
as size;

┌────────┐
│  size  │
├────────┤
│ 592 MB │ -- vs 1492 MB
└────────┘


create index if not exists
idx_applications_doc_departments_gin_jsonb_path_ops
on applications using gin
((doc['departments']) jsonb_path_ops);


SELECT pg_size_pretty(pg_total_relation_size('idx_applications_doc_departments_gin_jsonb_path_ops'))
as size;

┌───────┐
│ size  │
├───────┤
│ 50 MB │
└───────┘

analyze applications;

explain analyze
select id from applications
where doc['departments'] @@ 'lax $.users.email == "user_65@test.com" '
limit 10;

┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                               QUERY PLAN                                                                               │
├────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Limit  (cost=17.46..57.24 rows=10 width=16) (actual time=1.033..1.068 rows=10 loops=1)                                                                                 │
│   ->  Bitmap Heap Scan on applications  (cost=17.46..415.25 rows=100 width=16) (actual time=1.032..1.065 rows=10 loops=1)                                              │
│         Recheck Cond: (doc['departments'::text] @@ '($."users"."email" == "user_65@test.com")'::jsonpath)                                                              │
│         Heap Blocks: exact=10                                                                                                                                          │
│         ->  Bitmap Index Scan on idx_applications_doc_departments_gin_jsonb_path_ops  (cost=0.00..17.44 rows=100 width=0) (actual time=0.609..0.609 rows=3000 loops=1) │
│               Index Cond: (doc['departments'::text] @@ '($."users"."email" == "user_65@test.com")'::jsonpath)                                                          │
│ Planning Time: 1.842 ms                                                                                                                                                │
│ Execution Time: 1.127 ms                                                                                                                                               │
└────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


update applications
set doc['departments'][1]['users'][2] = $$
{
  "id": "00000000-0000-0000-0000-000000009999",
  "name": "User 9999",
  "role": "manager",
  "email": "user_9999@test.com"
}
$$::jsonb
where id = '00000000-0000-0000-0000-000000000065';


select id from applications
where doc['departments'] @@ '$.users.size() > 2 '
limit 10;

┌──────────────────────────────────────┐
│                  id                  │
├──────────────────────────────────────┤
│ 00000000-0000-0000-0000-000000000065 │
└──────────────────────────────────────┘
