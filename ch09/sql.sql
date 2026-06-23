

create table history(
    id uuid not null default gen_random_uuid(),
    pk uuid not null,
    entity text not null,
    operation text not null,
    doc jsonb not null,
    created_at timestamptz not null default current_timestamp,
    user_id uuid null,
    comment text null
);


create unique index idx_history_pg_created_at
on history (pk, created_at desc);


create or replace function gen_uuid(x integer)
returns uuid
language sql immutable strict parallel safe
return to_char(x, 'FM00000000-0000-0000-0000-000000000000')::uuid;

insert into history (pk, entity, operation, doc, created_at, user_id, comment)
select
    gen_uuid(x % 100),
    ((array['applications', 'organizations', 'users', 'events'])[ceil(random() * 4)]),
    ((array['update', 'delete'])[ceil(random() * 2)]),
    jsonb_build_object(
        'foo', x,
        'bar', format('some field %s', x),
        'test', 'hello'
    ),
    now() - interval '1 year' * random(),
    gen_random_uuid(),
    format('comment %s', x)
from
    generate_series(1, 1000) as seq(x);


select * from history
limit 10 offset 855;

┌─[ RECORD 1 ]────────────────────────────────────────────────────────┐
│ id         │ cc896171-b22e-443e-9f1e-d31cc1bf7d0b                   │
│ pk         │ 00000000-0000-0000-0000-000000000056                   │
│ entity     │ events                                                 │
│ operation  │ delete                                                 │
│ doc        │ {"bar": "some field 856", "foo": 856, "test": "hello"} │
│ created_at │ 2025-10-03 08:32:13.55007+03                           │
│ user_id    │ 6a7b7910-8baa-4cd3-8b7a-e2337e3430a8                   │
│ comment    │ comment 856                                            │
├─[ RECORD 2 ]────────────────────────────────────────────────────────┤
│ id         │ b878b211-11bf-4ce6-b3ab-dd23246cde6e                   │
│ pk         │ 00000000-0000-0000-0000-000000000057                   │
│ entity     │ organizations                                          │
│ operation  │ delete                                                 │
│ doc        │ {"bar": "some field 857", "foo": 857, "test": "hello"} │
│ created_at │ 2026-01-09 16:44:54.44607+03                           │
│ user_id    │ 2bec5043-f61e-4dfe-97ad-75fc95588174                   │
│ comment    │ comment 857                                            │
├─[ RECORD 3 ]────────────────────────────────────────────────────────┤
│ id         │ c92ee4a1-f634-4d94-bf59-0b9e727c17c5                   │
│ pk         │ 00000000-0000-0000-0000-000000000058                   │
│ entity     │ events                                                 │
│ operation  │ delete                                                 │
│ doc        │ {"bar": "some field 858", "foo": 858, "test": "hello"} │
│ created_at │ 2026-03-15 23:42:29.06367+03                           │
│ user_id    │ baa57871-0134-4b66-8c73-bfa6772f2b84                   │
│ comment    │ comment 858                                            │
├─[ RECORD 4 ]────────────────────────────────────────────────────────┤


select count(*) from history
where pk = '00000000-0000-0000-0000-000000000056';

┌───────┐
│ count │
├───────┤
│    10 │
└───────┘


select id, created_at from history
where pk = '00000000-0000-0000-0000-000000000056'
order by created_at desc;

┌──────────────────────────────────────┬──────────────────────────────┐
│                  id                  │          created_at          │
├──────────────────────────────────────┼──────────────────────────────┤
│ 13aad2e6-dc8d-4506-a502-4a906f5098ae │ 2026-05-25 13:51:35.42847+03 │
│ 61e69328-cf7d-4c08-b1e4-4348ec90a355 │ 2026-03-06 13:49:14.76927+03 │
│ 2114a3bd-8227-4fc2-8d19-792b67efb24c │ 2026-02-28 22:41:54.82047+03 │
│ 41e96a49-dddc-45c2-acec-440476fcbae7 │ 2026-01-26 15:56:18.70527+03 │
│ 9d0bb1e6-31a5-4c15-b860-56ca36bb2bf1 │ 2026-01-03 04:48:32.26047+03 │
│ 44c8ddf0-0a24-4f98-b05f-7cd920bf06f0 │ 2025-11-27 12:14:12.45567+03 │
│ af7004de-ac56-4263-818f-b1de9d07dcaf │ 2025-11-08 01:02:17.17887+03 │
│ cc896171-b22e-443e-9f1e-d31cc1bf7d0b │ 2025-10-03 08:32:13.55007+03 │
│ 2e903e63-65e8-4b78-89f2-938415d5e762 │ 2025-09-20 21:43:27.49887+03 │
│ 8b6d1d09-568e-481a-a96f-a8e3cd9626d7 │ 2025-07-19 18:00:57.48927+03 │
└──────────────────────────────────────┴──────────────────────────────┘


select id, created_at from history
where pk = '00000000-0000-0000-0000-000000000056'
order by created_at desc
limit 1;

┌──────────────────────────────────────┬──────────────────────────────┐
│                  id                  │          created_at          │
├──────────────────────────────────────┼──────────────────────────────┤
│ 13aad2e6-dc8d-4506-a502-4a906f5098ae │ 2026-05-25 13:51:35.42847+03 │
└──────────────────────────────────────┴──────────────────────────────┘

-- af7004de-ac56-4263-818f-b1de9d07dcaf 2025-11-08 01:02:17.17887+03

select id, created_at from history
where pk = '00000000-0000-0000-0000-000000000056'
    and created_at <= '2025-11-08 00:00:00+03'::timestamptz
order by created_at desc
limit 1;


┌──────────────────────────────────────┬──────────────────────────────┐
│                  id                  │          created_at          │
├──────────────────────────────────────┼──────────────────────────────┤
│ cc896171-b22e-443e-9f1e-d31cc1bf7d0b │ 2025-10-03 08:32:13.55007+03 │
└──────────────────────────────────────┴──────────────────────────────┘



create or replace function fn_applications_history()
returns trigger as $$
begin
    insert into history(pk, entity, operation, doc, created_at)
    values (
        OLD.id,
        'applications',
        TG_OP,
        old.doc,
        current_timestamp
    );
    return OLD;
end;
$$ language plpgsql;


create trigger trg_application_before_delete
before delete on applications
for each row execute function fn_applications_history();

create trigger trg_application_before_update
before update on applications
for each row execute function fn_applications_history();


select id from applications limit 10;

┌──────────────────────────────────────┐
│                  id                  │
├──────────────────────────────────────┤
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
└──────────────────────────────────────┘


delete from applications
where id = '00000000-0000-0000-0000-000000012345';


select
    id,
    pk,
    entity,
    operation,
    created_at,
    jsonb_pretty(doc) as doc
from history where pk = '00000000-0000-0000-0000-000000012345';


┌─[ RECORD 1 ]───────────────────────────────────────────────────────────────────┐
│ id         │ e0437f5d-19b6-4850-a2ae-51b21e626a0e                              │
│ pk         │ 00000000-0000-0000-0000-000000012345                              │
│ entity     │ applications                                                      │
│ operation  │ DELETE                                                            │
│ created_at │ 2026-06-21 15:48:55.118652+03                                     │
│ doc        │ {                                                                ↵│
│            │     "id": "00000000-0000-0000-0000-000000012345",                ↵│
│            │     "status": "archived",                                        ↵│
│            │     "amounts": [                                                 ↵│
│            │         {                                                        ↵│
│            │             "amount": 40528181,                                  ↵│
│            │             "period": {                                          ↵│
│            │                 "d": 7,                                          ↵│
│            │                 "m": 7,                                          ↵│


update applications
set doc['extra'] = to_jsonb(42)
where id = '00000000-0000-0000-0000-000000123999';


select
    id,
    pk,
    entity,
    operation,
    created_at,
    jsonb_pretty(doc) as doc
from history where pk = '00000000-0000-0000-0000-000000123999';


┌─[ RECORD 1 ]───────────────────────────────────────────────────────────────────┐
│ id         │ 009cc4ce-ea6b-4ea1-87b1-bed7825c8781                              │
│ pk         │ 00000000-0000-0000-0000-000000123999                              │
│ entity     │ applications                                                      │
│ operation  │ UPDATE                                                            │
│ created_at │ 2026-06-21 15:52:54.03302+03                                      │
│ doc        │ {                                                                ↵│
│            │     "id": "00000000-0000-0000-0000-000000123999",                ↵│
│            │     "status": "approved",                                        ↵│
│            │     "amounts": [                                                 ↵│
│            │         {                                                        ↵│
│            │             "amount": 41513124,                                  ↵│
│            │             "period": {                                          ↵│
│            │                 "d": 4,                                          ↵│
│            │                 "m": 8,                                          ↵│
│            │                 "w": 7,                                          ↵│
│            │                 "y": 1                                           ↵│
│            │             },                                                   ↵│
│            │             "currency": "USD"                                    ↵│


alter table applications disable trigger trg_application_before_delete;

-- enable trigger



drop trigger trg_application_before_delete on applications;
drop trigger trg_application_before_update on applications;


prepare delete_application as
with
OLD as (
    delete from applications where id = $1::uuid
    returning *
)
insert into history(pk, entity, operation, doc, created_at)
select
    OLD.id,
    'applications',
    'DELETE',
    old.doc,
    current_timestamp
from
    OLD;


-- rewrite to function


execute delete_application('00000000-0000-0000-0000-000000100999'::uuid);




select
    id,
    pk,
    entity,
    operation,
    created_at,
    jsonb_pretty(doc) as doc
from history where pk = '00000000-0000-0000-0000-000000100999';


┌─[ RECORD 1 ]───────────────────────────────────────────────────────────────────┐
│ id         │ 78ce995b-c865-489c-8c24-0ab26d62caef                              │
│ pk         │ 00000000-0000-0000-0000-000000100999                              │
│ entity     │ applications                                                      │
│ operation  │ DELETE                                                            │
│ created_at │ 2026-06-21 16:16:23.510292+03                                     │
│ doc        │ {                                                                ↵│
│            │     "id": "00000000-0000-0000-0000-000000100999",                ↵│
│            │     "status": "archived",                                        ↵│
│            │     "amounts": [                                                 ↵│
│            │         {                                                        ↵│
│            │             "amount": 11520867,                                  ↵│
│            │             "period": {                                          ↵│
│            │                 "d": 2,                                          ↵│
│            │                 "m": 8,                                          ↵│
│            │                 "w": 6,                                          ↵│
│            │                 "y": 1                                           ↵│
│            │             },                                                   ↵│
│            │             "currency": "EUR"                                    ↵│


select id from applications
where id = '00000000-0000-0000-0000-000000100999';
-- (0 rows)



prepare update_application as
with
OLD as (
    select * from applications
    where id = $1
),
NEW as (
    update applications
    set doc = $2::jsonb
    where id = $1::uuid
    returning *
)
insert into history(pk, entity, operation, doc, created_at)
select
    OLD.id,
    'applications',
    'UPDATE',
    OLD.doc,
    current_timestamp
from
    OLD;


execute update_application(
    '00000000-0000-0000-0000-000000100321'::uuid,
    $$
{
    "application_id": 100321,
    "some_field": "test"
}
    $$::jsonb
);


select doc from applications
where id = '00000000-0000-0000-0000-000000100321';

┌─[ RECORD 1 ]───────────────────────────────────────────┐
│ doc │ {"some_field": "test", "application_id": 100321} │
└─────┴──────────────────────────────────────────────────┘



select
    id,
    pk,
    entity,
    operation,
    created_at,
    jsonb_pretty(doc) as doc
from history where pk = '00000000-0000-0000-0000-000000100321';

┌─[ RECORD 1 ]───────────────────────────────────────────────────────────────────┐
│ id         │ 47e6cdba-e1fe-4320-acdb-ef193ef7f3e6                              │
│ pk         │ 00000000-0000-0000-0000-000000100321                              │
│ entity     │ applications                                                      │
│ operation  │ UPDATE                                                            │
│ created_at │ 2026-06-21 16:27:53.384049+03                                     │
│ doc        │ {                                                                ↵│
│            │     "id": "00000000-0000-0000-0000-000000100321",                ↵│
│            │     "status": "archived",                                        ↵│
│            │     "amounts": [                                                 ↵│
│            │         {                                                        ↵│
│            │             "amount": 50222648,                                  ↵│
│            │             "period": {                                          ↵│



prepare update_application_throttled as
with
upsert as (
    insert into applications(id, doc)
    values ($1::uuid, $2::jsonb)
    on conflict (id) do update set
    doc = excluded.DOC,
    updated_at = now()
    returning NEW.id, OLD.doc as doc_old
)
insert into history(pk, entity, operation, doc, created_at)
select
    id,
    'applications',
    'UPDATE',
    doc_old,
    current_timestamp
from
    upsert
where
        doc_old is not null
    and not exists(select id from history where pk = upsert.id and created_at > now() - interval '1 minute');



execute update_application_throttled(
    '00000000-0000-0000-0000-000010123123'::uuid,
    $$
{
    "foo": "1"
}
    $$::jsonb
);
-- INSERT 0 0

execute update_application_throttled(
    '00000000-0000-0000-0000-000010123123'::uuid,
    $$
{
    "foo": "2"
}
    $$::jsonb
);
-- INSERT 0 1

-- TODO: wait 1 min

execute update_application_throttled(
    '00000000-0000-0000-0000-000010123123'::uuid,
    $$
{
    "foo": "3"
}
    $$::jsonb
);
-- INSERT 0 0


table applications;
┌─[ RECORD 1 ]──────────────────────────────────────┐
│ id         │ 00000000-0000-0000-0000-000010123123 │
│ doc        │ {"foo": "3"}                         │
│ created_at │ 2026-06-22 10:49:07.873169+03        │
│ updated_at │ 2026-06-22 10:49:23.494707+03        │
└────────────┴──────────────────────────────────────┘

table history;
┌─[ RECORD 1 ]──────────────────────────────────────┐
│ id         │ 7b07b9d9-2a09-46f0-9355-1dacc654ac93 │
│ pk         │ 00000000-0000-0000-0000-000010123123 │
│ entity     │ applications                         │
│ operation  │ UPDATE                               │
│ doc        │ {"foo": "1"}                         │
│ created_at │ 2026-06-22 10:49:11.080188+03        │
│ user_id    │ <null>                               │
│ comment    │ <null>                               │
└────────────┴──────────────────────────────────────┘

-- if wait

table applications;
┌─[ RECORD 1 ]──────────────────────────────────────┐
│ id         │ 00000000-0000-0000-0000-000010123123 │
│ doc        │ {"foo": "3"}                         │
│ created_at │ 2026-06-22 10:50:54.734313+03        │
│ updated_at │ 2026-06-22 10:52:54.42768+03         │
└────────────┴──────────────────────────────────────┘

table history;
┌─[ RECORD 1 ]──────────────────────────────────────┐
│ id         │ 63b3e381-ea52-485f-bd29-03bb7658e788 │
│ pk         │ 00000000-0000-0000-0000-000010123123 │
│ entity     │ applications                         │
│ operation  │ UPDATE                               │
│ doc        │ {"foo": "1"}                         │
│ created_at │ 2026-06-22 10:50:59.411999+03        │
│ user_id    │ <null>                               │
│ comment    │ <null>                               │
├─[ RECORD 2 ]──────────────────────────────────────┤
│ id         │ 62d0a592-ccb8-4d7e-97fc-e9345b2e869a │
│ pk         │ 00000000-0000-0000-0000-000010123123 │
│ entity     │ applications                         │
│ operation  │ UPDATE                               │
│ doc        │ {"foo": "2"}                         │
│ created_at │ 2026-06-22 10:52:54.42768+03         │
│ user_id    │ <null>                               │
│ comment    │ <null>                               │
└────────────┴──────────────────────────────────────┘

-- a note about comment

...


prepare restore_application as
with
del_current_doc as (
    delete from applications where id = $1::uuid
    returning *
),
create_version as (
    insert into history(pk, entity, operation, doc, created_at)
    select
        id,
        'applications',
        'RESTORE',
        doc,
        current_timestamp
    from
        del_current_doc
),
delete_version as (
    delete from history
    where
            pk = $1::uuid
        and created_at = $2::timestamptz
    returning *
)
insert into applications (id, doc, updated_at)
select
    id, doc, current_timestamp
from
    delete_version;



-- {"foo": "1"}
-- 00000000-0000-0000-0000-000010123123 2026-06-22 10:50:59.411999+03



execute restore_application('00000000-0000-0000-0000-000010123123', '2026-06-22 10:50:59.411999+03');


table applications;
┌─[ RECORD 1 ]──────────────────────────────────────┐
│ id         │ 63b3e381-ea52-485f-bd29-03bb7658e788 │
│ doc        │ {"foo": "1"}                         │
│ created_at │ 2026-06-22 10:54:59.840803+03        │
│ updated_at │ 2026-06-22 10:54:59.840803+03        │
└────────────┴──────────────────────────────────────┘

table history;
┌─[ RECORD 1 ]──────────────────────────────────────┐
│ id         │ 62d0a592-ccb8-4d7e-97fc-e9345b2e869a │
│ pk         │ 00000000-0000-0000-0000-000010123123 │
│ entity     │ applications                         │
│ operation  │ UPDATE                               │
│ doc        │ {"foo": "2"}                         │
│ created_at │ 2026-06-22 10:52:54.42768+03         │
│ user_id    │ <null>                               │
│ comment    │ <null>                               │
├─[ RECORD 2 ]──────────────────────────────────────┤
│ id         │ aa12ccd7-4c95-4d8b-a566-a8c58b3c1468 │
│ pk         │ 00000000-0000-0000-0000-000010123123 │
│ entity     │ applications                         │
│ operation  │ RESTORE                              │
│ doc        │ {"foo": "3"}                         │
│ created_at │ 2026-06-22 10:54:59.840803+03        │
│ user_id    │ <null>                               │
│ comment    │ <null>                               │
└────────────┴──────────────────────────────────────┘


create_version as (
  /* insert into history */
),
delete_version as (
  /* delete target from history */
)


delete_history_above as (
    delete from history
    where
            pk = $1::uuid
        and created_at > $2::timestamptz
)






copy (delete from history where created_at < now() - interval '1 year' returning *)
to stdout with (format csv, header on);

-- id,pk,entity,operation,doc,created_at,user_id,comment


update history set created_at = now() - interval '1 year 1 day';

id,pk,entity,operation,doc,created_at,user_id,comment
62d0a592-ccb8-4d7e-97fc-e9345b2e869a,00000000-0000-0000-0000-000010123123,applications,UPDATE,"{""foo"": ""2""}",2025-06-21 11:29:36.643889+03,,
aa12ccd7-4c95-4d8b-a566-a8c58b3c1468,00000000-0000-0000-0000-000010123123,applications,RESTORE,"{""foo"": ""3""}",2025-06-21 11:29:36.643889+03,,


to program 'gzip > /path/to/history.csv.gzip'


create or replace procedure truncate_and_dump_history()
language plpgsql as $$
begin
    execute format($sql$
copy (delete from history where created_at < now() - interval '1 year' returning *)
to program 'gzip > /Users/ivan/work/pg-json-book-code/history_%s.csv.gzip' with (format csv, header on);
    $sql$, to_char(now(), 'yyyy_mm_dd'));
end;
$$;

call truncate_and_dump_history();


SELECT cron.schedule(
    'truncate-and-dump-history',
    '0 3 * * 7',
    'call truncate_and_dump_history()'
);


alter table history
add column patch jsonb null;


/*
create or replace function py_make_patch(src jsonb, dst jsonb)
returns jsonb
transform for type jsonb
language plpython3u strict as $$
    import jsonpatch
    return jsonpatch.JsonPatch.from_diff(src, dst)
$$;
*/


deallocate update_application;


prepare update_application as
with
upsert as (
    insert into applications(id, doc)
    values ($1::uuid, $2::jsonb)
    on conflict (id) do update set
    doc = excluded.DOC,
    updated_at = now()
    returning NEW.id, OLD.doc as doc_old, NEW.doc as doc_new
)
insert into history(pk, entity, operation, doc, patch, created_at)
select
    id,
    'applications',
    'UPDATE',
    doc_old,
    py_make_patch(doc_old, doc_new),
    current_timestamp
from
    upsert
where
    doc_old is not null;




execute update_application(
    '00000000-0000-0000-0000-000000100321'::uuid,
    $$
{
    "application_id": 100321,
    "some_field": "test"
}
    $$::jsonb
);


execute update_application(
    '00000000-0000-0000-0000-000000100321'::uuid,
    $$
{
    "application_id": 100321,
    "status": "pending",
    "some_field": "foo",
    "accounts": [1, 2, 3]
}
    $$::jsonb
);


/*

ERROR:  TypeError: Object of type Decimal is not JSON serializable
CONTEXT:  Traceback (most recent call last):
  PL/Python function "py_make_patch", line 3, in <module>
    return jsonpatch.JsonPatch.from_diff(src, dst)
  PL/Python function "py_make_patch", line 661, in from_diff
  PL/Python function "py_make_patch", line 906, in _compare_values
  PL/Python function "py_make_patch", line 873, in _compare_dicts
  PL/Python function "py_make_patch", line 919, in _compare_values
  PL/Python function "py_make_patch", line 230, in dumps
  PL/Python function "py_make_patch", line 199, in encode
  PL/Python function "py_make_patch", line 260, in iterencode
  PL/Python function "py_make_patch", line 179, in default
PL/Python function "py_make_patch"

*/


create or replace function py_make_patch(src jsonb, dst jsonb)
returns jsonb
language plpython3u strict as $$
    import json
    import jsonpatch
    doc_src = json.loads(src)
    doc_dst = json.loads(dst)
    patch = jsonpatch.JsonPatch.from_diff(doc_src, doc_dst)
    return patch.to_string()
$$;


execute update_application(
    '00000000-0000-0000-0000-000000100321'::uuid,
    $$
{
    "application_id": 100321,
    "status": "pending",
    "some_field": "foo",
    "accounts": [1, 2, 3]
}
    $$::jsonb
);


select
    id, pk, entity, doc,
    jsonb_pretty(patch) as patch
from
    history;


┌─[ RECORD 1 ]──────────────────────────────────────────────┐
│ id     │ dcbb3da3-5f2c-4ae7-861c-5c401c550905             │
│ pk     │ 00000000-0000-0000-0000-000000100321             │
│ entity │ applications                                     │
│ doc    │ {"some_field": "test", "application_id": 100321} │
│ patch  │ [                                               ↵│
│        │     {                                           ↵│
│        │         "op": "add",                            ↵│
│        │         "path": "/status",                      ↵│
│        │         "value": "pending"                      ↵│
│        │     },                                          ↵│
│        │     {                                           ↵│
│        │         "op": "add",                            ↵│
│        │         "path": "/accounts",                    ↵│
│        │         "value": [                              ↵│
│        │             1,                                  ↵│
│        │             2,                                  ↵│
│        │             3                                   ↵│
│        │         ]                                       ↵│
│        │     },                                          ↵│
│        │     {                                           ↵│
│        │         "op": "replace",                        ↵│
│        │         "path": "/some_field",                  ↵│
│        │         "value": "foo"                          ↵│
│        │     }                                           ↵│
│        │ ]                                                │
└────────┴──────────────────────────────────────────────────┘


{"op": "add", "path": "/status", "value": "pending"}
{"op": "add", "path": "/accounts", "value": [1, 2, 3]}
{"op": "replace", "path": "/some_field", "value": "foo"}



create or replace function py_apply_patch(doc jsonb, patch jsonb)
returns jsonb
transform for type jsonb
language plpython3u immutable strict as $$
    import jsonpatch
    patch_obj = jsonpatch.JsonPatch(patch)
    return patch_obj.apply(doc)
$$;


select py_apply_patch(
    $$
{"some_field": "test", "application_id": 100321}
    $$::jsonb,
    $$
[
    {"op": "add", "path": "/status", "value": "pending"},
    {"op": "add", "path": "/accounts", "value": [1, 2, 3]},
    {"op": "replace", "path": "/some_field", "value": "foo"}

]
    $$::jsonb) as doc_new;


┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                                           doc_new                                           │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│ {"status": "pending", "accounts": [1, 2, 3], "some_field": "foo", "application_id": 100321} │
└─────────────────────────────────────────────────────────────────────────────────────────────┘


prepare patch_application as
update applications
set doc = py_apply_patch(doc, $2::jsonb)
where id = $1::uuid;


execute patch_application('00000000-0000-0000-0000-000000100321'::uuid, $$
[
    {"op": "add", "path": "/comment", "value": "updated using a JSON patch"}
]
$$::jsonb);
