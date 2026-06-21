

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
