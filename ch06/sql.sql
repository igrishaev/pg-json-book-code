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


select jsonb_path_query($$
{
  "users": {
    "101": {"name": "Ivan"},
    "123": {"name": "John"},
    "523": {"name": "Johann"}
  }
}
$$::jsonb, '$.users.keyvalue()') as node;

┌───────────────────────────────────────────────────────┐
│                         node                          │
├───────────────────────────────────────────────────────┤
│ {"id": 20, "key": "101", "value": {"name": "Ivan"}}   │
│ {"id": 20, "key": "123", "value": {"name": "John"}}   │
│ {"id": 20, "key": "523", "value": {"name": "Johann"}} │
└───────────────────────────────────────────────────────┘


select id from applications
where doc @@ '$.departments.users.name like_regex "^user 12[0-9]{1}$" flag "i"'
limit 10;


┌──────────────────────────────────────┐
│                  id                  │
├──────────────────────────────────────┤
│ 00000000-0000-0000-0000-000000008129 │
│ 00000000-0000-0000-0000-000000009100 │
│ 00000000-0000-0000-0000-000000009101 │
│ 00000000-0000-0000-0000-000000009102 │
│ 00000000-0000-0000-0000-000000009103 │
│ 00000000-0000-0000-0000-000000009104 │
│ 00000000-0000-0000-0000-000000009105 │
│ 00000000-0000-0000-0000-000000009106 │
│ 00000000-0000-0000-0000-000000009107 │
│ 00000000-0000-0000-0000-000000009108 │
└──────────────────────────────────────┘


select jsonb_path_query($$
{
  "users": {
    "101": {"name": "Ivan"},
    "123": {"name": "John"},
    "523": {"name": "Johann"}
  }
}
$$::jsonb, '$.users.*.name') as name;

┌──────────┐
│   name   │
├──────────┤
│ "Ivan"   │
│ "John"   │
│ "Johann" │
└──────────┘


select jsonb_path_query($$
{
  "users": {
    "101": {"name": "Ivan", "friends": {"991": {"name": "Anna"}, "523": {"name": "Kirill"}}},
    "123": {"name": "John", "friends": {"353": {"name": "Gleb"}, "566": {"name": "Petr"}}},
    "523": {"name": "Johann", "friends": {"834": {"name": "Marina"}, "235": {"name": "Galina"}}}
  }
}
$$::jsonb, '$.users.**.name') as name;

┌──────────┐
│   name   │
├──────────┤
│ "Ivan"   │
│ "Kirill" │
│ "Anna"   │
│ "John"   │
│ "Gleb"   │
│ "Petr"   │
│ "Johann" │
│ "Galina" │
│ "Marina" │
└──────────┘

$.**.created_at == "01-02-2025"


$.**.id == "6c92590b-2daa-487f-a50d-434d34185015"


select id, doc from applications
where doc @@ ?
limit 100


select id, doc from applications
where doc @@ $jsonpath$$.departments.users.email == "user_65@test.com"$jsonpath$
limit 10;


/*
select id from applications
where
    doc @@ '$.amounts.amount > 100000'
and doc @@ '$.amounts.currency == "EUR"'
limit 10;


select id from applications
where
    doc @? '$.amounts[*] ? (@.amount > 1000000 && @.currency == "EUR")'
limit 10;
*/

select id from applications
where
    doc @@ '$.departments.users.id == "00000000-0000-0000-0000-000000000065"'
and doc @@ '$.departments.users.role == "support"'
limit 10;

┌──────────────────────────────────────┐
│                  id                  │
├──────────────────────────────────────┤
│ 00000000-0000-0000-0000-000000001045 │
│ 00000000-0000-0000-0000-000000001055 │
│ 00000000-0000-0000-0000-000000002045 │
│ 00000000-0000-0000-0000-000000003045 │
│ 00000000-0000-0000-0000-000000003055 │
│ 00000000-0000-0000-0000-000000003065 │
│ 00000000-0000-0000-0000-000000004065 │
│ 00000000-0000-0000-0000-000000005065 │
│ 00000000-0000-0000-0000-000000006045 │
│ 00000000-0000-0000-0000-000000006055 │
└──────────────────────────────────────┘


select jsonb_pretty(doc) from applications where id = '00000000-0000-0000-0000-000000001055';


select id from applications
where
    doc @? '$.departments.users ? (@.id == "00000000-0000-0000-0000-000000000065" && @.role == "support")'
limit 10;

┌──────────────────────────────────────┐
│                  id                  │
├──────────────────────────────────────┤
│ 00000000-0000-0000-0000-000000001045 │
│ 00000000-0000-0000-0000-000000002045 │
│ 00000000-0000-0000-0000-000000003045 │
│ 00000000-0000-0000-0000-000000003055 │
│ 00000000-0000-0000-0000-000000006045 │
│ 00000000-0000-0000-0000-000000007055 │
│ 00000000-0000-0000-0000-000000011065 │
│ 00000000-0000-0000-0000-000000013045 │
│ 00000000-0000-0000-0000-000000016045 │
│ 00000000-0000-0000-0000-000000021055 │
└──────────────────────────────────────┘

select jsonb_path_query(doc, '$.departments.users[*]') as users
from applications
where id = '00000000-0000-0000-0000-000000011065';

┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                       users                                                       │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ {"id": "00000000-0000-0000-0000-000000000065", "name": "User 65", "role": "support", "email": "user_65@test.com"} │
│ {"id": "00000000-0000-0000-0000-000000000075", "name": "User 75", "role": "support", "email": "user_75@test.com"} │
│ {"id": "00000000-0000-0000-0000-000000000085", "name": "User 85", "role": "manager", "email": "user_85@test.com"} │
│ {"id": "00000000-0000-0000-0000-000000000045", "name": "User 45", "role": "reader",  "email": "user_45@test.com"} │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘



select id from applications
where
    doc @? '$.departments[*] ? (@.code == "dep_5") .users ? (@.id == "00000000-0000-0000-0000-000000000065" && @.role == "support")'
limit 10;


┌──────────────────────────────────────┐
│                  id                  │
├──────────────────────────────────────┤
│ 00000000-0000-0000-0000-000000003055 │
│ 00000000-0000-0000-0000-000000007055 │
│ 00000000-0000-0000-0000-000000021055 │
│ 00000000-0000-0000-0000-000000035055 │
│ 00000000-0000-0000-0000-000000042055 │
│ 00000000-0000-0000-0000-000000044055 │
│ 00000000-0000-0000-0000-000000045055 │
│ 00000000-0000-0000-0000-000000046055 │
│ 00000000-0000-0000-0000-000000056055 │
│ 00000000-0000-0000-0000-000000059055 │
└──────────────────────────────────────┘


select jsonb_pretty(doc['departments']) as deps
from applications
where id = '00000000-0000-0000-0000-000000035055';

│ [                                                            ↵│
│     {                                                        ↵│
│         "id": "00000000-0000-0000-0000-000000000005",        ↵│
│         "code": "dep_5",                                     ↵│
│         "name": "Department 5",                              ↵│
│         "users": [                                           ↵│
│             {                                                ↵│
│                 "id": "00000000-0000-0000-0000-000000000055",↵│
│                 "name": "User 55",                           ↵│
│                 "role": "analyst",                           ↵│
│                 "email": "user_55@test.com"                  ↵│
│             },                                               ↵│
│             {                                                ↵│
│                 "id": "00000000-0000-0000-0000-000000000065",↵│
│                 "name": "User 65",                           ↵│
│                 "role": "support",                           ↵│
│                 "email": "user_65@test.com"                  ↵│
│             }                                                ↵│
│         ]                                                    ↵│
│     },



explain analyze
select id from applications
where
    doc @? '$.departments[*] ? (@.code == "dep_5") .users ? (@.id == "00000000-0000-0000-0000-000000000065" && @.role == "support")'
limit 10;


┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 QUERY PLAN                                                                                  │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Limit  (cost=137.69..174.12 rows=10 width=16) (actual time=5.307..5.412 rows=10 loops=1)                                                                                    │
│   ->  Bitmap Heap Scan on applications  (cost=137.69..36533.88 rows=9990 width=16) (actual time=5.303..5.407 rows=10 loops=1)                                               │
│         Recheck Cond: (doc @? '$."departments"[*]?(@."code" == "dep_5")."users"?(@."id" == "00000000-0000-0000-0000-000000000065" && @."role" == "support")'::jsonpath)     │
│         Rows Removed by Index Recheck: 21                                                                                                                                   │
│         Heap Blocks: exact=31                                                                                                                                               │
│         ->  Bitmap Index Scan on idx_applications_doc_gin_jsonb_path_ops  (cost=0.00..135.19 rows=9990 width=0) (actual time=5.199..5.199 rows=470 loops=1)                 │
│               Index Cond: (doc @? '$."departments"[*]?(@."code" == "dep_5")."users"?(@."id" == "00000000-0000-0000-0000-000000000065" && @."role" == "support")'::jsonpath) │
│ Planning Time: 0.170 ms                                                                                                                                                     │
│ Execution Time: 5.830 ms                                                                                                                                                    │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
