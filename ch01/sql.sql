
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

select id, name from users where age between 18 and 49;

┌────┬──────┐
│ id │ name │
├────┼──────┤
│  2 │ John │
└────┴──────┘

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

    (10001, 'user/name', 'Ivan'),
    (10001, 'user/age', '14'),

    (10002, 'user/name', 'John'),
    (10002, 'user/age', '34'),

    (10003, 'user/name', 'Juan'),
    (10003, 'user/age', '51'),

    (10004, 'profile/user-ref', '10001'),
    (10004, 'profile/job', 'teacher'),
    (10004, 'profile/is-open', 'true'),

    (10005, 'profile/user-ref', '10002'),
    (10005, 'profile/job', 'programmer'),
    (10005, 'profile/is-open', 'false'),

    (10006, 'profile/user-ref', '10003'),
    (10006, 'profile/job', 'cook'),
    (10006, 'profile/is-open', 'true');

select * from eav order by e;

┌───────┬──────────────────┬────────────┐
│   e   │        a         │     v      │
├───────┼──────────────────┼────────────┤
│ 10001 │ user/name        │ Ivan       │
│ 10001 │ user/age         │ 14         │
│ 10002 │ user/name        │ John       │
│ 10002 │ user/age         │ 34         │
│ 10003 │ user/name        │ Juan       │
│ 10003 │ user/age         │ 51         │
│ 10004 │ profile/user-ref │ 10001      │
│ 10004 │ profile/job      │ teacher    │
│ 10004 │ profile/is-open  │ true       │
│ 10005 │ profile/user-ref │ 10002      │
│ 10005 │ profile/job      │ programmer │
│ 10005 │ profile/is-open  │ false      │
│ 10006 │ profile/user-ref │ 10003      │
│ 10006 │ profile/job      │ cook       │
│ 10006 │ profile/is-open  │ true       │
└───────┴──────────────────┴────────────┘

TODO

select *
from
    eav,
    (select * from eav )

where
    e in (
        select v::int from eav
        where
            a = 'profile/user-ref'
    );

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

select * from payments where id = '...'

delete from payments where id = '...'


select * from payments
where
    amount = 10000

select * from payments
where
    amount = 10000 and currency = 'USD'


create table items(
    id integer primary key,
    title text
);

create table item_props(
    item_id integer references items(id),
    property text,
    value text
);

insert into items values
    (1001, 'Gazer Flade 18'),
    (1002, 'MZI Katana 13 XH'),
    (2001, 'T-Shirt White'),
    (2002, 'Shirt Pop Blue'),
    (3001, 'Mega Snack Plus'),
    (3002, 'Protein Bomb');

insert into item_props values
    (1001, 'laptop.cpu_count', '10'),
    (1002, 'laptop.mem_freq', '5600'),
    (1002, 'laptop.cpu_count', '12'),
    (1002, 'laptop.mem_freq', '3200'),
    (2001, 'cloth.color', 'white'),
    (2001, 'cloth.size', 'L,X,XL'),
    (2002, 'cloth.color', 'blue'),
    (2002, 'cloth.size', 'XXL,S'),
    (3001, 'food.box_mass', '1400'),
    (3001, 'food.diet_note', 'no gluten'),
    (3002, 'food.box_mass', '1200'),
    (3002, 'food.diet_note', 'no sugar');

select * from items, item_props where items.id = item_props.item_id;
┌──────┬──────────────────┬─────────┬──────────────────┬───────────┐
│  id  │      title       │ item_id │     property     │   value   │
├──────┼──────────────────┼─────────┼──────────────────┼───────────┤
│ 1001 │ Gazer Flade 18   │    1001 │ laptop.cpu_count │ 10        │
│ 1002 │ MZI Katana 13 XH │    1002 │ laptop.mem_freq  │ 5600      │
│ 1002 │ MZI Katana 13 XH │    1002 │ laptop.cpu_count │ 12        │
│ 1002 │ MZI Katana 13 XH │    1002 │ laptop.mem_freq  │ 3200      │
│ 2001 │ T-Shirt White    │    2001 │ cloth.color      │ white     │
│ 2001 │ T-Shirt White    │    2001 │ cloth.size       │ L,X,XL    │
│ 2002 │ Shirt Pop Blue   │    2002 │ cloth.color      │ blue      │
│ 2002 │ Shirt Pop Blue   │    2002 │ cloth.size       │ XXL,S     │
│ 3001 │ Mega Snack Plus  │    3001 │ food.box_mass    │ 1400      │
│ 3001 │ Mega Snack Plus  │    3001 │ food.diet_note   │ no gluten │
│ 3002 │ Protein Bomb     │    3002 │ food.box_mass    │ 1200      │
│ 3002 │ Protein Bomb     │    3002 │ food.diet_note   │ no sugar  │
└──────┴──────────────────┴─────────┴──────────────────┴───────────┘


insert into item_props values
    (1001, 'laptop.video_mem', '*Gb');


create table item_props_json(
    item_id integer references items(id),
    property text,
    value jsonb
);

insert into item_props_json values
    (1001, 'laptop.cpu_count', '10'),
    (1002, 'laptop.mem_freq', '5600'),
    (1002, 'laptop.cpu_count', '12'),
    (1002, 'laptop.mem_freq', '3200'),
    (2001, 'cloth.color', '"white"'),
    (2001, 'cloth.size', '["L","X","XL"]'),
    (2002, 'cloth.color', '"blue"'),
    (2002, 'cloth.size', '["XXL","S"]'),
    (3001, 'food.box_mass', '1400'),
    (3001, 'food.diet_note', '"no gluten"'),
    (3002, 'food.box_mass', '1200'),
    (3002, 'food.diet_note', '"no sugar"');

select * from items, item_props_json where items.id = item_props_json.item_id;

┌──────┬──────────────────┬─────────┬──────────────────┬──────────────────┐
│  id  │      title       │ item_id │     property     │      value       │
├──────┼──────────────────┼─────────┼──────────────────┼──────────────────┤
│ 1001 │ Gazer Flade 18   │    1001 │ laptop.cpu_count │ 10               │
│ 1002 │ MZI Katana 13 XH │    1002 │ laptop.mem_freq  │ 5600             │
│ 1002 │ MZI Katana 13 XH │    1002 │ laptop.cpu_count │ 12               │
│ 1002 │ MZI Katana 13 XH │    1002 │ laptop.mem_freq  │ 3200             │
│ 2001 │ T-Shirt White    │    2001 │ cloth.color      │ "white"          │
│ 2001 │ T-Shirt White    │    2001 │ cloth.size       │ ["L", "X", "XL"] │
│ 2002 │ Shirt Pop Blue   │    2002 │ cloth.color      │ "blue"           │
│ 2002 │ Shirt Pop Blue   │    2002 │ cloth.size       │ ["XXL", "S"]     │
│ 3001 │ Mega Snack Plus  │    3001 │ food.box_mass    │ 1400             │
│ 3001 │ Mega Snack Plus  │    3001 │ food.diet_note   │ "no gluten"      │
│ 3002 │ Protein Bomb     │    3002 │ food.box_mass    │ 1200             │
│ 3002 │ Protein Bomb     │    3002 │ food.diet_note   │ "no sugar"       │
└──────┴──────────────────┴─────────┴──────────────────┴──────────────────┘

drop table item_props;
drop table item_props_json;

alter table items add column props jsonb;

update items set props = $$
    {"laptop.cpu_count": 10, "laptop.mem_freq": 5600}
$$ where id = 1001;

update items set props = $$
    {"cloth.color": "white", "cloth.size": ["L","X","XL"]}
$$ where id = 2001;
