

drop index if exists idx_applications_application_id;

alter table applications add constraint ctr_doc_application_id_nn
check (doc->'application_id' is not null);

insert into applications (doc) values (
  '{"test": "abc"}'
);

-- ERROR:  new row for relation "applications" violates check constraint "ctr_doc_application_id_nn"
-- DETAIL:  Failing row contains (b6edce9d-285f-4df0-9bba-5f65d390608a, {"test": "abc"}, 2026-06-05 17:49:33.757553+03, null).


alter table applications
drop constraint ctr_doc_application_id_nn;

alter table applications add constraint ctr_doc_application_id_int
check ((doc->>'application_id')::int is not null);

insert into applications (doc) values (
  '{"application_id": "abc"}'
);

-- ERROR: cannot cast jsonb string to type integer

create table users_demo(
    id integer primary key,
    full_name text not null,
    email text not null,
    unique(email)
);

create table post_tags(
    post_id integer not null,
    tag_id integer not null,
    created_at timestamptz not null default current_timestamp,
    unique (post_id, tag_id)
);

drop table post_tags;

create table post_tags(
    post_id integer not null,
    tag_id integer not null,
    created_at timestamptz not null default current_timestamp
);

alter table post_tags
add constraint ctx_post_id_tag_id_u
unique (post_id, tag_id);


insert into post_tags (post_id, tag_id)
values (100, 10);

insert into post_tags (post_id, tag_id)
values (100, 10);

-- ERROR:  duplicate key value violates unique constraint "ctx_post_id_tag_id_u"
-- DETAIL:  Key (post_id, tag_id)=(100, 10) already exists.


alter table applications
add constraint ctx_doc_application_id_u
unique (((doc->>'application_id')::int));

-- ERROR:  syntax error at or near "("
-- LINE 3: unique (((doc->>'application_id')::int));

alter table applications
drop constraint ctr_doc_application_id_int;

\d+ applications

Indexes:
    "applications_pkey" PRIMARY KEY, btree (id)
    ...
Check constraints:
    "ctr_doc_application_id_int" CHECK (((doc ->> 'application_id'::text)::integer) IS NOT NULL)

create unique index idx_doc_application_id_u
on applications (((doc->>'application_id')::int));

-- cannot cast jsonb string to type integer

delete from applications
where doc @@ '$.application_id.type() != "number" ';


insert into applications (doc) values (
  '{"application_id": "12345"}'
);

ERROR:  duplicate key value violates unique constraint "idx_doc_application_id_u"
DETAIL:  Key (((doc ->> 'application_id'::text)::integer))=(12345) already exists.

-- DELETE 1

alter table applications drop constraint ctr_doc_application_id_nn;

insert into applications (doc) values (
  '{"test": "abc"}'
);


drop index idx_doc_application_id_u;

create unique index idx_doc_application_id_u
on applications (((doc->>'application_id')::int))
nulls not distinct;

insert into applications (doc) values (
  '{"test": "abc"}'
);

-- OK

insert into applications (doc) values (
  '{"test": "abc"}'
);

-- ERROR:  duplicate key value violates unique constraint "idx_doc_application_id_u"
-- DETAIL:  Key (((doc->>'application_id'::text)::integer))=(null) already exists.


drop index idx_doc_application_id_u;

create or replace function created_at_year(doc jsonb)
returns timestamptz
language sql immutable strict parallel safe
return date_trunc('year', (doc->>'created_at')::timestamp);


create unique index idx_doc_app_id_date_u
on applications (
    ((doc->>'application_id')::int),
    (created_at_year(doc))
);

insert into applications (doc) values (
  '{"application_id": "10001111", "created_at": "2026-06-05T15:33:55Z"}'
);

insert into applications (doc) values (
  '{"application_id": "10001111", "created_at": "2027-06-05T15:33:55Z"}'
);

insert into applications (doc) values (
  '{"application_id": "10001111", "created_at": "2026-12-05T15:33:55Z"}'
);

-- ERROR:  duplicate key value violates unique constraint "idx_doc_app_id_date_u"
-- DETAIL:  Key (((doc ->> 'application_id'::text)::integer), get_year(doc))=(10001111, 2026-01-01 00:00:00+03) already exists.


insert into applications (doc) values (
  '{"application_id": "10001111", "created_at": "2026-12-05T15:33:55Z"}'
) on conflict (
    ((doc->>'application_id')::int),
    (created_at_year(doc))
)
do nothing;

-- INSERT 0 0

-- full index expression
-- do update set ...

create table organizations (
    id uuid primary key default uuid_generate_v4(),
    doc jsonb compression lz4 not null,
    created_at timestamptz not null default current_timestamp,
    updated_at timestamptz
);


select distinct doc #>> '{organization,id}' as org_id
from applications
limit 100;

┌──────────────────────────────────────┐
│                org_id                │
├──────────────────────────────────────┤
│ 00000000-0000-0000-0000-000000000000 │
│ 00000000-0000-0000-0000-000000000001 │
│ 00000000-0000-0000-0000-000000000002 │
│ 00000000-0000-0000-0000-000000000003 │
│ 00000000-0000-0000-0000-000000000004 │
│ 00000000-0000-0000-0000-000000000005 │
│ 00000000-0000-0000-0000-000000000006 │
│ 00000000-0000-0000-0000-000000000007 │
│ 00000000-0000-0000-0000-000000000008 │
│ 00000000-0000-0000-0000-000000000009 │
│ 00000000-0000-0000-0000-000000000010 │
│ 00000000-0000-0000-0000-000000000011 │
│ 00000000-0000-0000-0000-000000000012 │


delete from applications
where (doc #>> '{organization,id}') is null;
-- DELETE 3

select distinct on (doc #>> '{organization,id}')
    (doc #>> '{organization,id}')::uuid as id,
    jsonb_build_object(
        'id',         (doc #>> '{organization,id}'),
        'status',     'active',
        'code',       (doc #>> '{organization,code}'),
        'short_name', (doc #>> '{organization,short_name}')
    ) as doc
from
    applications
limit
    100;

┌──────────────────────────────────────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                  id                  │                                                        doc                                                        │
├──────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ 00000000-0000-0000-0000-000000000000 │ {"id": "00000000-0000-0000-0000-000000000000", "code": "0", "status": "active", "short_name": "Organization 0"}   │
│ 00000000-0000-0000-0000-000000000001 │ {"id": "00000000-0000-0000-0000-000000000001", "code": "1", "status": "active", "short_name": "Organization 1"}   │
│ 00000000-0000-0000-0000-000000000002 │ {"id": "00000000-0000-0000-0000-000000000002", "code": "2", "status": "active", "short_name": "Organization 2"}   │
│ 00000000-0000-0000-0000-000000000003 │ {"id": "00000000-0000-0000-0000-000000000003", "code": "3", "status": "active", "short_name": "Organization 3"}   │
│ 00000000-0000-0000-0000-000000000004 │ {"id": "00000000-0000-0000-0000-000000000004", "code": "4", "status": "active", "short_name": "Organization 4"}   │
│ 00000000-0000-0000-0000-000000000005 │ {"id": "00000000-0000-0000-0000-000000000005", "code": "5", "status": "active", "short_name": "Organization 5"}   │
│ 00000000-0000-0000-0000-000000000006 │ {"id": "00000000-0000-0000-0000-000000000006", "code": "6", "status": "active", "short_name": "Organization 6"}   │
│ 00000000-0000-0000-0000-000000000007 │ {"id": "00000000-0000-0000-0000-000000000007", "code": "7", "status": "active", "short_name": "Organization 7"}   │
│ 00000000-0000-0000-0000-000000000008 │ {"id": "00000000-0000-0000-0000-000000000008", "code": "8", "status": "active", "short_name": "Organization 8"}   │
│ 00000000-0000-0000-0000-000000000009 │ {"id": "00000000-0000-0000-0000-000000000009", "code": "9", "status": "active", "short_name": "Organization 9"}   │
│ 00000000-0000-0000-0000-000000000010 │ {"id": "00000000-0000-0000-0000-000000000010", "code": "10", "status": "active", "short_name": "Organization 10"} │
│ 00000000-0000-0000-0000-000000000011 │ {"id": "00000000-0000-0000-0000-000000000011", "code": "11", "status": "active", "short_name": "Organization 11"} │
│ 00000000-0000-0000-0000-000000000012 │ {"id": "00000000-0000-0000-0000-000000000012", "code": "12", "status": "active", "short_name": "Organization 12"} │

insert into organizations (id, doc)
select distinct on (doc #>> '{organization,id}')
    (doc #>> '{organization,id}')::uuid as id,
    jsonb_build_object(
        'id',         (doc #>> '{organization,id}'),
        'status',     'active',
        'code',       (doc #>> '{organization,code}'),
        'short_name', (doc #>> '{organization,short_name}')
    ) as doc
from
    applications;

select count(*) from organizations;

┌───────┐
│ count │
├───────┤
│  1000 │
└───────┘

select
    app.id as app_id,
    org.doc->>'code' as org_code,
    org.doc->>'short_name' as org_name
from
    applications app
join
    organizations org
    on (app.doc #>> '{organization,id}')::uuid = org.id
limit
    100;

┌──────────────────────────────────────┬──────────┬──────────────────┐
│                app_id                │ org_code │     org_name     │
├──────────────────────────────────────┼──────────┼──────────────────┤
│ 00000000-0000-0000-0000-000000635585 │ 585      │ Organization 585 │
│ 00000000-0000-0000-0000-000000635586 │ 586      │ Organization 586 │
│ 00000000-0000-0000-0000-000000635587 │ 587      │ Organization 587 │
│ 00000000-0000-0000-0000-000000635588 │ 588      │ Organization 588 │
│ 00000000-0000-0000-0000-000000635589 │ 589      │ Organization 589 │
│ 00000000-0000-0000-0000-000000635590 │ 590      │ Organization 590 │


alter table applications add constraint fk_org_id
foreign key ((doc #>> '{organization,id}')::uuid) references organizations(id);

ERROR:  syntax error at or near "("
LINE 2: foreign key ((doc #>> '{organization,id}')::uuid) references...


alter table applications
add column _org_id uuid generated always
as ((doc #>> '{organization,id}')::uuid) stored;

-- https://postgrespro.ru/docs/postgresql/18/ddl-generated-columns?lang=ru
-- https://postgrespro.ru/docs/postgresql/17/ddl-generated-columns?lang=ru

alter table applications add constraint fk_org_id
foreign key (_org_id) references organizations(id);


select id, _org_id from applications limit 10;

┌──────────────────────────────────────┬──────────────────────────────────────┐
│                  id                  │               _org_id                │
├──────────────────────────────────────┼──────────────────────────────────────┤
│ 00000000-0000-0000-0000-000000635649 │ 00000000-0000-0000-0000-000000000649 │
│ 00000000-0000-0000-0000-000000635650 │ 00000000-0000-0000-0000-000000000650 │
│ 00000000-0000-0000-0000-000000635651 │ 00000000-0000-0000-0000-000000000651 │
│ 00000000-0000-0000-0000-000000635652 │ 00000000-0000-0000-0000-000000000652 │
│ 00000000-0000-0000-0000-000000635653 │ 00000000-0000-0000-0000-000000000653 │


insert into applications (doc) values ($$
  {
    "application_id": 1999111,
    "organization": {
      "id": "967849e5-9c59-4fa2-bc57-0a4a84bbd41c"
    }
  }
$$::jsonb);

-- ERROR:  insert or update on table "applications" violates foreign key constraint "fk_org_id"
-- DETAIL:  Key (_org_id)=(967849e5-9c59-4fa2-bc57-0a4a84bbd41c) is not present in table "organizations".


delete from organizations
where id = '00000000-0000-0000-0000-000000000649';

-- ERROR:  update or delete on table "organizations" violates foreign key constraint "fk_org_id" on table "applications"
-- DETAIL:  Key (id)=(00000000-0000-0000-0000-000000000649) is still referenced from table "applications".

alter table applications drop constraint fk_org_id;


alter table applications add constraint fk_org_id
foreign key (_org_id) references organizations(id)
on delete cascade;


delete from organizations
where id = '00000000-0000-0000-0000-000000000649';

select id from applications
where (doc #>> '{organization,id}') = '00000000-0000-0000-0000-000000000649';
-- (0 rows)

alter table applications drop constraint fk_org_id;

alter table applications add constraint fk_org_id
foreign key (_org_id) references organizations(id)
on delete set null;

-- ERROR:  invalid ON DELETE action for foreign key constraint containing generated column


create or replace function fn_applications_org_ref_null()
returns trigger as $$
begin
    update applications
    set doc['organization'] = null
    where (doc #>> '{organization,id}')::uuid = OLD.id;
    return OLD;
end;
$$ language plpgsql;


create trigger trg_organizations_before_delete
before delete on organizations
for each row execute function fn_applications_org_ref_null();

delete from organizations
where id = '00000000-0000-0000-0000-000000000651';

select id, _org_id, doc -> 'organization' as org
from applications
where id = '00000000-0000-0000-0000-000000635651';

┌──────────────────────────────────────┬─────────┬──────┐
│                  id                  │ _org_id │ org  │
├──────────────────────────────────────┼─────────┼──────┤
│ 00000000-0000-0000-0000-000000635651 │ <null>  │ null │
└──────────────────────────────────────┴─────────┴──────┘


create index if not exists idx_app_org_id_1
on applications using btree
(((doc #>> '{organization,id}')::uuid));

create index if not exists idx_app_org_id_2
on applications using btree (_org_id);

analyze applications;


explain (analyze)
select id, doc from applications
where (((doc #>> '{organization,id}')::uuid)) between
'00000000-0000-0000-0000-000000000153' and '00000000-0000-0000-0000-000000000353';

┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                        QUERY PLAN                                                                                                         │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Bitmap Heap Scan on applications  (cost=2698.86..272948.89 rows=194969 width=1932) (actual time=31.504..228.308 rows=201000 loops=1)                                                                                      │
│   Recheck Cond: ((((doc #>> '{organization,id}'::text[]))::uuid >= '00000000-0000-0000-0000-000000000153'::uuid) AND (((doc #>> '{organization,id}'::text[]))::uuid <= '00000000-0000-0000-0000-000000000353'::uuid))     │
│   Heap Blocks: exact=50985                                                                                                                                                                                                │
│   ->  Bitmap Index Scan on idx_app_org_id_1  (cost=0.00..2650.12 rows=194969 width=0) (actual time=22.102..22.102 rows=201000 loops=1)                                                                                    │
│         Index Cond: ((((doc #>> '{organization,id}'::text[]))::uuid >= '00000000-0000-0000-0000-000000000153'::uuid) AND (((doc #>> '{organization,id}'::text[]))::uuid <= '00000000-0000-0000-0000-000000000353'::uuid)) │
│ Planning Time: 0.378 ms                                                                                                                                                                                                   │
│ Execution Time: 231.996 ms                                                                                                                                                                                                │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

explain (analyze)
select id, doc from applications
where _org_id between
'00000000-0000-0000-0000-000000000153' and '00000000-0000-0000-0000-000000000353';

┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                  QUERY PLAN                                                                   │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Bitmap Heap Scan on applications  (cost=2698.86..260778.65 rows=194969 width=1932) (actual time=30.887..213.769 rows=201000 loops=1)          │
│   Recheck Cond: ((_org_id >= '00000000-0000-0000-0000-000000000153'::uuid) AND (_org_id <= '00000000-0000-0000-0000-000000000353'::uuid))     │
│   Heap Blocks: exact=50985                                                                                                                    │
│   ->  Bitmap Index Scan on idx_app_org_id_2  (cost=0.00..2650.12 rows=194969 width=0) (actual time=22.072..22.073 rows=201000 loops=1)        │
│         Index Cond: ((_org_id >= '00000000-0000-0000-0000-000000000153'::uuid) AND (_org_id <= '00000000-0000-0000-0000-000000000353'::uuid)) │
│ Planning Time: 0.764 ms                                                                                                                       │
│ Execution Time: 218.374 ms                                                                                                                    │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

create table demo(
    x integer not null default 0,
    y integer not null default 0,
    sum integer generated always as (x + y) stored
);

insert into demo values (1, 2), (3, 4)
returning x, y, sum;

┌───┬───┬─────┐
│ x │ y │ sum │
├───┼───┼─────┤
│ 1 │ 2 │   3 │
│ 3 │ 4 │   7 │
└───┴───┴─────┘
