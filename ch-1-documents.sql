
create table users (
    id integer,
    name text,
    age integer
);

insert into users values
    (1, 'Ivan', 14),
    (2, 'John', 34),
    (3, 'Juan', 51);

select id, name, age from users;

┌────┬──────┬─────┐
│ id │ name │ age │
├────┼──────┼─────┤
│  1 │ Ivan │  14 │
│  2 │ John │  34 │
│  3 │ Juan │  51 │
└────┴──────┴─────┘

select id, age from users;

┌────┬─────┐
│ id │ age │
├────┼─────┤
│  1 │  14 │
│  2 │  34 │
│  3 │  51 │
└────┴─────┘

create table profiles (
    user_id integer,
    job text,
    is_open boolean
);

insert into profiles values
    (1, 'teacher', true),
    (2, 'programmer', false),
    (3, 'cook', true);

select * from users u
join profiles p on u.id = p.user_id;

┌────┬──────┬─────┬─────────┬────────────┬─────────┐
│ id │ name │ age │ user_id │    job     │ is_open │
├────┼──────┼─────┼─────────┼────────────┼─────────┤
│  1 │ Ivan │  14 │       1 │ teacher    │ t       │
│  2 │ John │  34 │       2 │ programmer │ f       │
│  3 │ Juan │  51 │       3 │ cook       │ t       │
└────┴──────┴─────┴─────────┴────────────┴─────────┘

select 1 as x;

┌───┐
│ x │
├───┤
│ 1 │
└───┘

select id, name from users
where age > 18;

┌────┬──────┐
│ id │ name │
├────┼──────┤
│  2 │ John │
│  3 │ Juan │
└────┴──────┘

select * from users u
join profiles p on u.id = p.user_id
where u.age > 18 and p.is_open;

┌────┬──────┬─────┬─────────┬──────┬─────────┐
│ id │ name │ age │ user_id │ job  │ is_open │
├────┼──────┼─────┼─────────┼──────┼─────────┤
│  3 │ Juan │  51 │       3 │ cook │ t       │
└────┴──────┴─────┴─────────┴──────┴─────────┘

create table eav (
    e integer,
    a text,
    v text
);

insert into eav values

    (10001, 'user/id', '1'),
    (10001, 'user/name', 'Ivan'),
    (10001, 'user/age', '14'),

    (10002, 'user/id', '2'),
    (10002, 'user/name', 'John'),
    (10002, 'user/age', '34'),

    (10003, 'user/id', '3'),
    (10003, 'user/name', 'Juan'),
    (10003, 'user/age', '51'),

    (10004, 'profile/user-id', '1'),
    (10004, 'profile/job', 'teacher'),
    (10004, 'profile/is-open', 'true'),

    (10005, 'profile/user-id', '2'),
    (10005, 'profile/job', 'programmer'),
    (10005, 'profile/is-open', 'false'),

    (10006, 'profile/user-id', '3'),
    (10006, 'profile/job', 'cook'),
    (10006, 'profile/is-open', 'true');

select * from eav order by e;

┌───────┬─────────────────┬────────────┐
│   e   │        a        │     v      │
├───────┼─────────────────┼────────────┤
│ 10001 │ user/id         │ 1          │
│ 10001 │ user/name       │ Ivan       │
│ 10001 │ user/age        │ 14         │
│ 10002 │ user/id         │ 2          │
│ 10002 │ user/name       │ John       │
│ 10002 │ user/age        │ 34         │
│ 10003 │ user/id         │ 3          │
│ 10003 │ user/name       │ Juan       │
│ 10003 │ user/age        │ 51         │
│ 10004 │ profile/user-id │ 1          │
│ 10004 │ profile/job     │ teacher    │
│ 10004 │ profile/is-open │ true       │
│ 10005 │ profile/user-id │ 2          │
│ 10005 │ profile/job     │ programmer │
│ 10005 │ profile/is-open │ false      │
│ 10006 │ profile/user-id │ 3          │
│ 10006 │ profile/job     │ cook       │
│ 10006 │ profile/is-open │ true       │
└───────┴─────────────────┴────────────┘

create table contractors (
    id uuid primary key,
    title text
);

insert into contractors values (
    'bd6a0da9-fe35-4a37-846c-dff3f32cf0ac',
    'Acme Inc'
);

create table contract (
    id uuid primary key,
    number integer,
    created_at date,
    expires_at date,
    contractor uuid references contractors(id),
    amount integer,
    currency text
);

insert into contract values (
    'c2a44fe0-6840-4916-b6dd-b401f34f9c2a',
    523552,
    '2025-01-01',
    '2027-12-31',
    'bd6a0da9-fe35-4a37-846c-dff3f32cf0ac',
    100000000,
    'EUR'
);

select * from contract c, contractors cs
where c.contractor = cs.id;

┌──────────────────────────────────────┬────────┬────────────┬────────────┬──────────────────────────────────────┬───────────┬──────────┬──────────────────────────────────────┬──────────┐
│                  id                  │ number │ created_at │ expires_at │              contractor              │  amount   │ currency │                  id                  │  title   │
├──────────────────────────────────────┼────────┼────────────┼────────────┼──────────────────────────────────────┼───────────┼──────────┼──────────────────────────────────────┼──────────┤
│ c2a44fe0-6840-4916-b6dd-b401f34f9c2a │ 523552 │ 2025-01-01 │ 2027-12-31 │ bd6a0da9-fe35-4a37-846c-dff3f32cf0ac │ 100000000 │ EUR      │ bd6a0da9-fe35-4a37-846c-dff3f32cf0ac │ Acme Inc │
└──────────────────────────────────────┴────────┴────────────┴────────────┴──────────────────────────────────────┴───────────┴──────────┴──────────────────────────────────────┴──────────┘
