
create table application_amounts(
    application_id uuid references applications(id),
    amount integer,
    currency text,
    year integer,
    month integer,
    week integer,
    day integer
);

create extension if not exists "uuid-ossp";

create table applications (
    id uuid primary key default uuid_generate_v4(),
    doc jsonb compression lz4 not null,
    created_at timestamptz not null default current_timestamp,
    updated_at timestamptz
);

create table tasks (
    id integer primary key,
    status text
);

insert into tasks values
    (1, 'active'),
    (2, 'active'),
    (3, 'pending'),
    (4, 'approved'),
    (5, 'pending'),
    (6, 'deleted'),
    (7, 'approved'),
    (8, 'approved'),
    (9, 'active');

select count(*) from tasks;
-- 9

select count(distinct status) from tasks;
-- 4

select distinct status from tasks;
┌──────────┐
│  status  │
├──────────┤
│ active   │
│ approved │
│ pending  │
│ deleted  │
└──────────┘

with
total(count) as (
    select count(*) from tasks
),
grouped(status, count) as (
    select
        status,
        count(status)
    from tasks
    group by status
)
select
    grouped.status,
    to_char(grouped.count * 1.0 / total.count, '00.99')
    as ratio
from grouped, total;

┌──────────┬────────┐
│  status  │ ratio  │
├──────────┼────────┤
│ active   │  00.33 │
│ approved │  00.33 │
│ pending  │  00.22 │
│ deleted  │  00.11 │
└──────────┴────────┘


select distinct doc #>> '{meta,status}' from tasks;

delete from tasks;

insert into tasks(id, status)
select
    x,
    format('status_%s', x)
from
    generate_series(1, 9) as seq(x);

select * from tasks;

┌────┬──────────┐
│ id │  status  │
├────┼──────────┤
│  1 │ status_1 │
│  2 │ status_2 │
│  3 │ status_3 │
│  4 │ status_4 │
│  5 │ status_5 │
│  6 │ status_6 │
│  7 │ status_7 │
│  8 │ status_8 │
│  9 │ status_9 │
└────┴──────────┘

delete from applications;

insert into applications (id, doc, created_at)
select
    uuid_generate_v4(),
    format($${
        "id": "%1$s",
        "status": "active",
        "application_id": %2$s,
        "created_by": {
            "id": "%3$s",
            "email": "user_%3$s@acme.com",
            "name": "Test User %1$s"
        }
    }$$, uuid_generate_v4(), x, uuid_generate_v4())::jsonb,
    now()
from
    generate_series(1, 9) as seq(x);

select id, jsonb_pretty(doc), created_at
from applications limit 2;

┌─[ RECORD 1 ]─┬───────────────────────────────────────────────────────────────────────┐
│ id           │ 207971c8-9072-4ad1-a6e8-50dbafe30a5d                                  │
│ jsonb_pretty │ {                                                                    ↵│
│              │     "id": "b77c179c-7f2b-4706-a18d-612061c3b30b",                    ↵│
│              │     "status": "active",                                              ↵│
│              │     "created_by": {                                                  ↵│
│              │         "id": "831c894e-b702-4cbe-b583-8c577ec0f9be",                ↵│
│              │         "name": "Test User b77c179c-7f2b-4706-a18d-612061c3b30b",    ↵│
│              │         "email": "user_831c894e-b702-4cbe-b583-8c577ec0f9be@acme.com"↵│
│              │     },                                                               ↵│
│              │     "application_id": 1                                              ↵│
│              │ }                                                                     │
│ created_at   │ 2025-12-25 12:27:36.158705+03                                         │
├─[ RECORD 2 ]─┼───────────────────────────────────────────────────────────────────────┤
│ id           │ ab825d3c-4ef6-4fad-91db-76c278432597                                  │
│ jsonb_pretty │ {                                                                    ↵│
│              │     "id": "6f24b2df-6e6e-49a8-9464-b59fc4d7b8c4",                    ↵│
│              │     "status": "active",                                              ↵│
│              │     "created_by": {                                                  ↵│
│              │         "id": "bfd65cea-ecc0-4106-9552-b4187ef93037",                ↵│
│              │         "name": "Test User 6f24b2df-6e6e-49a8-9464-b59fc4d7b8c4",    ↵│
│              │         "email": "user_bfd65cea-ecc0-4106-9552-b4187ef93037@acme.com"↵│
│              │     },                                                               ↵│
│              │     "application_id": 2                                              ↵│
│              │ }                                                                     │
│ created_at   │ 2025-12-25 12:27:36.158705+03                                         │
└──────────────┴───────────────────────────────────────────────────────────────────────┘

delete from applications;

insert into applications (id, doc, created_at)
select
    uuid_generate_v4(),
    jsonb_build_object(
        'id', uuid_generate_v4(),
        'status', 'active',
        'application_id', x,
        'created_by', jsonb_build_object(
            'id', uuid_generate_v4(),
            'email', format('user_%s@acme.com', x),
            'name', format('Test User %s', x)
        )
    ),
    now()
from
    generate_series(1, 9) as seq(x);

delete from applications;

insert into applications (id, doc, created_at)
with gen as (
    select x, uuid_generate_v4() as uuid
    from generate_series(1, 9) as seq(x)
)
select
    uuid,
    jsonb_build_object(
        'id', uuid,
        'status', 'active',
        'application_id', x,
        'created_by', jsonb_build_object(
            'id', uuid_generate_v4(),
            'email', format('user_%s@acme.com', x),
            'name', format('Test User %s', x)
        )
    ),
    now()
from
    gen;

select id, jsonb_pretty(doc), created_at
from applications limit 2;

┌─[ RECORD 1 ]─┬───────────────────────────────────────────────────────┐
│ id           │ 6001b727-119e-489a-b30a-67b5aae615b2                  │
│ jsonb_pretty │ {                                                    ↵│
│              │     "id": "6001b727-119e-489a-b30a-67b5aae615b2",    ↵│
│              │     "status": "active",                              ↵│
│              │     "created_by": {                                  ↵│
│              │         "id": "937ee91a-c9d3-4f0a-8c25-45ddccb116e9",↵│
│              │         "name": "Test User 1",                       ↵│
│              │         "email": "user_1@acme.com"                   ↵│
│              │     },                                               ↵│
│              │     "application_id": 1                              ↵│
│              │ }                                                     │
│ created_at   │ 2025-12-25 12:30:39.74283+03                          │
├─[ RECORD 2 ]─┼───────────────────────────────────────────────────────┤
│ id           │ 8da2210e-eef6-4b55-9879-a73366f66121                  │
│ jsonb_pretty │ {                                                    ↵│
│              │     "id": "8da2210e-eef6-4b55-9879-a73366f66121",    ↵│
│              │     "status": "active",                              ↵│
│              │     "created_by": {                                  ↵│
│              │         "id": "f008557e-7cff-4da1-a70b-8009a7491209",↵│
│              │         "name": "Test User 2",                       ↵│
│              │         "email": "user_2@acme.com"                   ↵│
│              │     },                                               ↵│
│              │     "application_id": 2                              ↵│
│              │ }                                                     │
│ created_at   │ 2025-12-25 12:30:39.74283+03                          │
└──────────────┴───────────────────────────────────────────────────────┘


delete from applications;

select to_char(1, 'FM00000000-0000-0000-0000-000000000000')::uuid;

-- full modifier

insert into applications (id, doc, created_at)
select
    to_char(x, 'FM00000000-0000-0000-0000-000000000000')::uuid,
    jsonb_build_object(
        'id', to_char(x, 'FM00000000-0000-0000-0000-000000000000')::uuid,
        'status', 'active',
        'application_id', x,
        'created_by', jsonb_build_object(
            'id', uuid_generate_v4(),
            'email', format('user_%s@acme.com', x),
            'name', format('Test User %s', x)
        )
    ),
    now()
from
    generate_series(1, 9) as seq(x);


select id, jsonb_pretty(doc), created_at
from applications limit 2;


┌─[ RECORD 1 ]─┬───────────────────────────────────────────────────────┐
│ id           │ 00000000-0000-0000-0000-000000000001                  │
│ jsonb_pretty │ {                                                    ↵│
│              │     "id": "00000000-0000-0000-0000-000000000001",    ↵│
│              │     "status": "active",                              ↵│
│              │     "created_by": {                                  ↵│
│              │         "id": "b42897e2-30aa-4689-86ff-76c08036b2ff",↵│
│              │         "name": "Test User 1",                       ↵│
│              │         "email": "user_1@acme.com"                   ↵│
│              │     },                                               ↵│
│              │     "application_id": 1                              ↵│
│              │ }                                                     │
│ created_at   │ 2025-12-25 12:37:57.986389+03                         │
├─[ RECORD 2 ]─┼───────────────────────────────────────────────────────┤
│ id           │ 00000000-0000-0000-0000-000000000002                  │
│ jsonb_pretty │ {                                                    ↵│
│              │     "id": "00000000-0000-0000-0000-000000000002",    ↵│
│              │     "status": "active",                              ↵│
│              │     "created_by": {                                  ↵│
│              │         "id": "8d6e3cb4-6413-4ce3-a994-b6703feaa326",↵│
│              │         "name": "Test User 2",                       ↵│
│              │         "email": "user_2@acme.com"                   ↵│
│              │     },                                               ↵│
│              │     "application_id": 2                              ↵│
│              │ }                                                     │
│ created_at   │ 2025-12-25 12:37:57.986389+03                         │
└──────────────┴───────────────────────────────────────────────────────┘




(array['a', 'b', 'c'])[ceil(random() * 3)]

select (array['a', 'b', 'c'])[ceil(random() * 3)] from generate_series(1, 10);

┌───────┐
│ array │
├───────┤
│ a     │
│ b     │
│ c     │
│ a     │
│ b     │
│ c     │
│ b     │
│ c     │
│ c     │
│ c     │
└───────┘

now() - interval '1 day' * random() * 365

create or replace function gen_uuid(x integer)
returns uuid
language sql immutable strict parallel safe
return to_char(x, 'FM00000000-0000-0000-0000-000000000000')::uuid;


insert into applications (id, doc, created_at)
select
    gen_uuid(x),
    jsonb_build_object(
        /* huge json goes here */
    ),
    now()
from
    generate_series(1, 9) as seq(x);


(format('user_%s', x % 1000))

select * from (values
    (to_char(1, '999.00')),
    (to_char(-1, '999.00')))
as vals(x);

┌────────┐
│   x    │
├────────┤
│  01.00 │
│ -01.00 │
└────────┘

insert into applications (id, doc, created_at)
select
    gen_uuid(x),
    jsonb_build_object(
        'id', gen_uuid(x),
        'status', ((array['active', 'pending', 'approved', 'deleted'])[ceil(random() * 4)]),
        'created_at', (now() - interval '1 day' * random() * 365),
        'created_by', jsonb_build_object(
            'id', gen_uuid(x % 1000),
            'email', (format('user_%s@test.com', to_char(x % 1000, 'FM0000'))),
            'name', (format('User %s', to_char(x % 1000, 'FM0000')))
        ),
        'application_id', x,
        'organization', jsonb_build_object(
            'id', gen_uuid(x % 1000),
            'code', x % 1000,
            'short_name', format('Organization %s', x % 1000)
        ),
        'comment', format('Comment number #%s', x),
        'amounts', jsonb_build_array(
            jsonb_build_object(
                'amount', (ceil(random() * 100000000)),
                'currency', ((array['USD', 'EUR', 'RUB'])[ceil(random() * 3)]),
                'period', jsonb_build_object('y', ceil(random() * 10), 'm', ceil(random() * 10), 'w', ceil(random() * 10), 'd', ceil(random() * 10))
            ),
            jsonb_build_object(
                'amount', (ceil(random() * 100000000)),
                'currency', ((array['USD', 'EUR', 'RUB'])[ceil(random() * 3)]),
                'period', jsonb_build_object('y', ceil(random() * 10), 'm', ceil(random() * 10), 'w', ceil(random() * 10), 'd', ceil(random() * 10))
            )
        ),
        'departments', jsonb_build_array(
            jsonb_build_object(
                'id', gen_uuid((x % 25)),
                'code', format('dep_%s', (x % 25)),
                'name', format('Department %s', (x % 25)),
                'users', jsonb_build_array(
                    jsonb_build_object(
                        'id', gen_uuid((x % 1000)),
                        'email', (format('user_%s@test.com', (x % 1000))),
                        'name', (format('User %s', (x % 1000)))
                    ),
                    jsonb_build_object(
                        'id', gen_uuid((x % 1000 + 10)),
                        'email', (format('user_%s@test.com', (x % 1000 + 10))),
                        'name', (format('User %s', (x % 1000 + 10)))
                    )
                )
            ),
            jsonb_build_object(
                'id', gen_uuid((x % 25 + 10)),
                'code', format('dep_%s', (x % 25 + 10)),
                'name', format('Department %s', (x % 25 + 10)),
                'users', jsonb_build_array(
                    jsonb_build_object(
                        'id', gen_uuid((x % 1000 + 20)),
                        'email', (format('user_%s@test.com', (x % 1000 + 20))),
                        'name', (format('User %s', (x % 1000 + 20)))
                    ),
                    jsonb_build_object(
                        'id', gen_uuid((x % 25 + 30)),
                        'email', (format('user_%s@test.com', (x % 25 + 30))),
                        'name', (format('User %s', (x % 25 + 30)))
                    )
                )
            )
        ),
        'journal', jsonb_build_array(
            jsonb_build_object(
                'event', ((array['active', 'pending', 'approved', 'deleted'])[ceil(random() * 4)]),
                'datetime', (now() - interval '1 day' * random() * 365),
                'user_id', uuid_generate_v4()
            ),
            jsonb_build_object(
                'event', ((array['active', 'pending', 'approved', 'deleted'])[ceil(random() * 4)]),
                'datetime', (now() - interval '1 day' * random() * 365),
                'user_id', uuid_generate_v4()
            ),
            jsonb_build_object(
                'event', ((array['active', 'pending', 'approved', 'deleted'])[ceil(random() * 4)]),
                'datetime', (now() - interval '1 day' * random() * 365),
                'user_id', uuid_generate_v4()
            )
        )
    ),
    now()
from
    generate_series(1, 9) as seq(x);


select doc as doc
from applications
limit 1 offset 7;


delete from applications;


select count(*) from applications;

┌─[ RECORD 1 ]────┐
│ count │ 1000000 │
└───────┴─────────┘

---------------

select id, jsonb_pretty(doc) as doc
from applications
limit 1
offset 500000;

┌──────────────────────────────────────┬───────────────────────────────────────────────────────────────────┐
│                  id                  │                                doc                                │
├──────────────────────────────────────┼───────────────────────────────────────────────────────────────────┤
│ 00000000-0000-0000-0000-000000500001 │ {                                                                ↵│
│                                      │     "id": "00000000-0000-0000-0000-000000500001",                ↵│
│                                      │     "status": "deleted",                                         ↵│
│                                      │     "amounts": [                                                 ↵│
│                                      │         {                                                        ↵│
│                                      │             "amount": 23223688,                                  ↵│
│                                      │             "period": {                                          ↵│
│                                      │                 "d": 7,                                          ↵│
│                                      │                 "m": 3,                                          ↵│
│                                      │                 "w": 3,                                          ↵│
│                                      │                 "y": 6                                           ↵│
│                                      │             },                                                   ↵│
│                                      │             "currency": "USD"                                    ↵│
│                                      │         },                                                       ↵│
│                                      │         {                                                        ↵│
│                                      │             "amount": 24467700,                                  ↵│
│                                      │             "period": {                                          ↵│
│                                      │                 "d": 6,                                          ↵│
│                                      │                 "m": 8,                                          ↵│
│                                      │                 "w": 7,                                          ↵│
│                                      │                 "y": 9                                           ↵│
│                                      │             },                                                   ↵│
│                                      │             "currency": "RUB"                                    ↵│
│                                      │         }                                                        ↵│
│                                      │     ],                                                           ↵│
│                                      │     "comment": "Comment number #500001",                         ↵│
│                                      │     "journal": [                                                 ↵│
│                                      │         {                                                        ↵│
│                                      │             "event": "active",                                   ↵│
│                                      │             "user_id": "a9922c57-3da1-4177-b03c-263dec405d93",   ↵│
│                                      │             "datetime": "2025-09-08T17:38:42.415013+03:00"       ↵│
│                                      │         },                                                       ↵│


select * from applications
where id = '00000000-0000-0000-0000-000000500001';


select id from applications
where doc #>> '{organization,id}' = '00000000-0000-0000-0000-000000000001';

┌──────────────────────────────────────┐
│                  id                  │
├──────────────────────────────────────┤
│ 00000000-0000-0000-0000-000000500001 │
│ 00000000-0000-0000-0000-000000501001 │
│ 00000000-0000-0000-0000-000000502001 │
│ 00000000-0000-0000-0000-000000503001 │
│ 00000000-0000-0000-0000-000000504001 │


update applications set
    doc['status'] = '"deleted"',
    doc['updated_at'] = '"2026-01-02T09:46:12Z"',
    doc['comment'] = '"Deleting this applicaton"'
where
    id = '00000000-0000-0000-0000-000000500001';

update applications set
    doc = doc || $${
        "status": "deleted",
        "updated_at": "2026-01-02T09:46:12Z",
        "comment": "Deleting this applicaton"
    }$$::jsonb
where id = '00000000-0000-0000-0000-000000500001';


update applications set
    doc['departments'][0]['users'][0]['name'] = '"Peter Dow"'
where id = '00000000-0000-0000-0000-000000500001';


update applications set
    doc['departments'][-1]['users'][-1]['name'] = '"Last User"'
where id = '00000000-0000-0000-0000-000000500001';



update applications set
    doc['review']['risk']['created_by'] = '"ivan@test.com"',
    doc['review']['risk']['description'] = '"Some comment"'
where id = '00000000-0000-0000-0000-000000500001'
returning doc['review'];

┌──────────────────────────────────────────────────────────────────────────┐
│                                   doc                                    │
├──────────────────────────────────────────────────────────────────────────┤
│ {"risk": {"created_by": "ivan@test.com", "description": "Some comment"}} │
└──────────────────────────────────────────────────────────────────────────┘
(1 row)


update applications
set doc = deep_merge(doc, $1)
where id = $2;

update applications set
    doc['status'] = '"pending"',
    doc['udpated_at']['id'] = '"<UUID>"',
    doc['udpated_at']['email'] = '"ivan@acme.com"',
    doc['udpated_at']['name'] = '"Ivan Petrov"'
where id = '00000000-0000-0000-0000-000000500001'
returning doc['review'];


update applications set
    doc['journal'] = '"[]"'
where id = '00000000-0000-0000-0000-000000500001';

update applications set
    doc = '"{}"'
where id = '00000000-0000-0000-0000-000000500001';

select * from applications
where id = '00000000-0000-0000-0000-000000500001';

┌──────────────────────────────────────┬──────┬───────────────────────────────┬────────────┐
│                  id                  │ doc  │          created_at           │ updated_at │
├──────────────────────────────────────┼──────┼───────────────────────────────┼────────────┤
│ 00000000-0000-0000-0000-000000500001 │ "{}" │ 2025-12-25 13:18:06.873203+03 │ <null>     │
└──────────────────────────────────────┴──────┴───────────────────────────────┴────────────┘


prepare app_upsert as
insert into applications(id, doc) values ($1, $2)
on conflict (id) do update set
    doc = excluded.doc,
    updated_at = now()
returning id, doc, updated_at;


execute app_upsert('00000000-0000-0000-0000-000000500001', $${
  "some": "field"
}$$::jsonb);

┌──────────────────────────────────────┬───────────────────┬───────────────────────────────┐
│                  id                  │        doc        │          updated_at           │
├──────────────────────────────────────┼───────────────────┼───────────────────────────────┤
│ 00000000-0000-0000-0000-000000500001 │ {"some": "field"} │ 2026-01-02 13:11:20.270694+03 │
└──────────────────────────────────────┴───────────────────┴───────────────────────────────┘

create temp table app_temp (
    id uuid primary key,
    doc jsonb not null
);

insert into app_temp values
    ('00000000-0000-0000-0000-000000500001', '{"field1": "test1"}'::jsonb),
    ('00000000-0000-0000-0000-000000500002', '{"field2": "test2"}'::jsonb),
    ('00000000-0000-0000-0000-000000500003', '{"field3": "test3"}'::jsonb);


insert into applications(id, doc)
select * from app_temp
on conflict (id) do update set
    doc = excluded.doc,
    updated_at = now()
returning id, doc, updated_at;

┌──────────────────────────────────────┬─────────────────────┬───────────────────────────────┐
│                  id                  │         doc         │          updated_at           │
├──────────────────────────────────────┼─────────────────────┼───────────────────────────────┤
│ 00000000-0000-0000-0000-000000500001 │ {"field1": "test1"} │ 2026-01-02 13:15:52.478099+03 │
│ 00000000-0000-0000-0000-000000500002 │ {"field2": "test2"} │ 2026-01-02 13:15:52.478099+03 │
│ 00000000-0000-0000-0000-000000500003 │ {"field3": "test3"} │ 2026-01-02 13:15:52.478099+03 │
└──────────────────────────────────────┴─────────────────────┴───────────────────────────────┘


doc = doc || excluded.doc

merge into applications as a
using app_temp as t
on a.id = t.id
when matched then
    update set
        doc = t.doc,
        updated_at = now()
when not matched then
    insert (id, doc)
    values (t.id, t.doc);

delete from applications
where id = '00000000-0000-0000-0000-000000500005'
returning doc;

delete from applications
where doc->>'status' = 'deleted';
-- DELETE 249656


update applications
set doc['journal'] = 'null'
where doc->>'status' = 'deleted';
-- UPDATE 249656

update applications
set doc = doc - 'journal'
where doc->>'status' = 'deleted';
-- UPDATE 249656

truncate applications;
