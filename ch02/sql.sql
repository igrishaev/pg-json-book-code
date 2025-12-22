

update profiles
set extra_data['email_activated'] = true
where ...


update profiles
set extra_data['achievement_old_timer'] = true
where created_at > '2000-01-01'::date


select jsonb from (values
    ('1'::jsonb),
    ('[1, "test", true, null]'::jsonb),
    ('{"hello": {"to": ["json"]}}'::jsonb)
) as vals(jsonb);

┌─────────────────────────────┐
│            jsonb            │
├─────────────────────────────┤
│ 1                           │
│ [1, "test", true, null]     │
│ {"hello": {"to": ["json"]}} │
└─────────────────────────────┘

select '{"message": "Display: 6\", weigth:\t100 gram"}'::jsonb;
┌────────────────────────────────────────────────┐
│                     jsonb                      │
├────────────────────────────────────────────────┤
│ {"message": "Display: 6\", weigth:\t100 gram"} │
└────────────────────────────────────────────────┘

TODO

select ('{"message": "Display: 6\", weigth:\t100 gram"}'::jsonb)->>'message' as message;
┌──────────────────────────────────┐
│             message              │
├──────────────────────────────────┤
│ Display: 6", weigth:    100 gram │
└──────────────────────────────────┘


select '{
"key_a": 1,
"key_b": 2
}'::jsonb as object;
┌──────────────────────────┐
│          object          │
├──────────────────────────┤
│ {"key_a": 1, "key_b": 2} │
└──────────────────────────┘

select $$ [
    1,
    2,
    {
        "key_a": 1,
        "key_b": 1
    }
]$$::jsonb;

┌──────────────────────────────────┐
│              jsonb               │
├──────────────────────────────────┤
│ [1, 2, {"key_a": 1, "key_b": 1}] │
└──────────────────────────────────┘



select '  { "key_a": 1, "key_b": 2, "key_a": 3 }  '::json as json;
┌────────────────────────────────────────────┐
│                    json                    │
├────────────────────────────────────────────┤
│   { "key_a": 1, "key_b": 2, "key_a": 3 }   │
└────────────────────────────────────────────┘

select '  { "key_a": 1, "key_b": 2, "key_a": 3 }  '::jsonb as jsonb;
┌──────────────────────────┐
│          jsonb           │
├──────────────────────────┤
│ {"key_a": 3, "key_b": 2} │
└──────────────────────────┘


select
    '{"a": 1, "b": 2}'::jsonb -> 'a' as a,
    '{"a": 1, "b": 2}'::jsonb -> 'b' as b,
    '{"a": 1, "b": 2}'::jsonb -> 'c' as c;

┌───┬───┬────────┐
│ a │ b │   c    │
├───┼───┼────────┤
│ 1 │ 2 │ <null> │
└───┴───┴────────┘


select '[10, 20, 30]'::jsonb -> 0 as first;
┌───────┐
│ first │
├───────┤
│ 10    │
└───────┘

select '[10, 20, 30]'::jsonb -> -1 as last;
┌──────┐
│ last │
├──────┤
│ 30   │
└──────┘


select '{"a": 1, "b": 2}'::jsonb -> 'c' is null as is_null;
┌─────────┐
│ is_null │
├─────────┤
│ t       │
└─────────┘

select '{"a": 1, "b": 2, "c": null}'::jsonb -> 'c' is null as is_null;
┌─────────┐
│ is_null │
├─────────┤
│ f       │
└─────────┘

select '{"age": 42}'::jsonb -> 'age';
select '{"name": "John"}'::jsonb -> 'name';

select '{"name": "John"}'::jsonb -> 'name' as name;
┌────────┐
│  name  │
├────────┤
│ "John" │
└────────┘


prepare expr as select '{"test1": "abc", "test2": "xyz"}'::jsonb -> $1::text as result;
execute expr('test1');
execute expr('test2');

select $$ {
  "users": [
    {"id": 1, "name": "John Smith"},
    {"id": 2, "name": "Ivan Petrov"}
  ]
}$$::jsonb -> 'users' -> -1 -> 'name' as name;

┌───────────────┐
│     name      │
├───────────────┤
│ "Ivan Petrov" │
└───────────────┘

select $$ {
  "users": [
    {"id": 1, "name": "John Smith"},
    {"id": 2, "name": "Ivan Petrov"}
  ]
}$$::jsonb #> '{users,-1,name}' as name;


select $$ {
  "users": [
    {"id": 1, "name": "John Smith"},
    {"id": 2, "name": "Ivan Petrov"}
  ]
}$$::jsonb #> array['users', '-1', 'name'] as name;

prepare expr2 as select $$ {
  "users": [
    {"id": 1, "name": "John Smith"},
    {"id": 2, "name": "Ivan Petrov"}
  ]
}$$::jsonb #> array['users', $1, $2] as field;


execute expr2('0', 'id');
┌───────┐
│ field │
├───────┤
│ 1     │
└───────┘

execute expr2('-1', 'name');
┌───────────────┐
│     field     │
├───────────────┤
│ "Ivan Petrov" │
└───────────────┘

select 'Hello, ' || ('{"name": "Ivan"}'::jsonb -> 'name');



select $$ {
  "users": [
    {"id": 1, "name": "John Smith"},
    {"id": 2, "name": "Ivan Petrov"}
  ]
}$$::jsonb #>> array['users', '0', 'name'] as name;

┌────────────┐
│   name     │
├────────────┤
│ John Smith │
└────────────┘

select $$ {
  "users": [
    {"id": 1, "name": "John Smith"},
    {"id": 2, "name": "Ivan Petrov"}
  ]
}$$::jsonb ->> 'users' ->> '0' ->> 'name';



/*
select
    (doc ->> 'points')::int4 as points,
    (doc ->> 'ratio')::float4 as ratio,
    (doc ->> 'active')::bool as is_active,
    (doc ->> 'message') as message,
    (doc ->> 'datetime')::timestamptz as datetime
from (values
    ($${
        "points": 150,
        "ratio": 1.05,
        "active": true,
        "message": "You've got new bonus points!",
        "datetime": "2025-12-16T07:36:53Z"
    }$$::jsonb)
) as vals(doc);
*/

{"created_at": "2025-12-16T07:48:58.104784Z"}

{}

select to_timestamp(
    $${
      "created_at": "Tue, 15 Nov 1994 12:45:26 GMT"
    }$$::jsonb ->> 'created_at',
    'Dy, DD Mon YYYY HH:MI:SS GMT'
);

┌────────────────────────┐
│      to_timestamp      │
├────────────────────────┤
│ 1994-11-15 00:45:26+03 │
└────────────────────────┘


select ('1'::jsonb ->> 0)::integer;
┌──────┐
│ int4 │
├──────┤
│    1 │
└──────┘

select '"message"'::jsonb ->> 0 as text;
┌─────────┐
│ text    │
├─────────┤
│ message │
└─────────┘

select '{"user": {"name": "John"}}'::jsonb
    -> 'user' -> 'name' as name;

select '{"user": {"name": "John"}}'::jsonb
    -> 'user' ->> 'name' as name;

select '{"user": {"name": "John"}}'::jsonb
    #> '{user,name}' as name;

select '{"user": {"name": "John"}}'::jsonb
    #>> '{user,name}' as name;

select ('{"users": [{"name": "John"}]}'::jsonb)['users'][0]['name'] as name;

prepare expr4 as
select ('{"users": [{"name": "John", "age": 33}]}'::jsonb)['users'][$1::int4][$2::text] as field;

execute expr4(0, 'name');

execute expr4(0, 'age');

{"display": {"width": 30, "height": 20}}

update goods set
    attrs['display']['width'] = attrs['display.width'],
    attrs['display']['height'] = attrs['display.height']
where id = 2
returning *;

update goods set
    attrs = attrs - 'display.width' - 'display.height'
where id = 2
returning *;

┌────┬────────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ id │ title  │                                                      attrs                                                       │
├────┼────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  2 │ Laptop │ {"display": {"width": 30, "height": 20}, "ram.freq": 2666, "wifi.available": true, "processor.family": "ARM M4"} │
└────┴────────┴──────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


select '1'::jsonb @> '1'::jsonb; -- true

select 'null'::jsonb @> 'null'::jsonb; -- true


select '[1, 2, 3]'::jsonb @> '1'::jsonb; -- true

select '[[1, 4], 2, 3]'::jsonb @> '1'::jsonb; -- false


select '[1, 2, 3, 4]'::jsonb @> '[1, 3, 1]'::jsonb; -- true

select
  '{"users": [{"id": 1, "name": "John"}]}'::jsonb
  @>
  '{"users": [{"id": 1}]}'::jsonb; -- true

select
  '{"a": 1, "b": 2, "c": 3}'::jsonb
  @>
  '{"c": 3}'::jsonb; -- true

select '{"users": [{"id": 1}]}'::jsonb ? 'users'; -- true

select '{"a": 1, "b": 2}'::jsonb - 'a';
-- {"b": 2}

select '["active", "pending", "deleted"]'::jsonb - 2;
-- ["active", "pending"]


select
  '{"users": [{"id": 1, "name": "John"}]}'::jsonb
  #-
  '{users,0,name}';
-- {"users": [{"id": 1}]}

select
  'true'::jsonb || 'false'::jsonb;
-- [true, false]

select
  '{"a": 1, "b": 2}'::jsonb || '{"b": 9, "c": 3}'::jsonb;
-- {"a": 1, "b": 9, "c": 3}


update goods set
    attrs = attrs || $${
    "box.width": "120 mm",
    "box.height": "240 mm",
    "box.weight": "0.9 kilo"
}$$::jsonb
where id = 1
returning *;

select
  '{"a": 1, "b": [1, 2, 3]}'::jsonb
  ||
  '{"b": [4, 5, 6], "c": 3}'::jsonb;
-- {"a": 1, "b": [4, 5, 6], "c": 3}


create table sample (
    id integer,
    name text,
    job text
);

insert into sample values
  (1, 'Ivan', 'programmer'),
  (2, 'John', 'tester'),
  (3, 'Maria', 'manager');

select
    jsonb_build_array(id, name, job) as arr
from
    sample;

┌───────────────────────────┐
│            arr            │
├───────────────────────────┤
│ [1, "Ivan", "programmer"] │
│ [2, "John", "tester"]       │
│ [3, "Maria", "manager"]   │
└───────────────────────────┘


select
    jsonb_build_object('id', id, 'name', name)
    as object
from sample;

┌────────────────────────────┐
│           object           │
├────────────────────────────┤
│ {"id": 1, "name": "Ivan"}  │
│ {"id": 2, "name": "John"}  │
│ {"id": 3, "name": "Maria"} │
└────────────────────────────┘

select to_jsonb(sample) as object
from sample;
┌────────────────────────────────────────────────┐
│                     object                     │
├────────────────────────────────────────────────┤
│ {"id": 1, "job": "programmer", "name": "Ivan"} │
│ {"id": 2, "job": "tester", "name": "John"}     │
│ {"id": 3, "job": "manager", "name": "Maria"}   │
└────────────────────────────────────────────────┘

create table author (
    id integer primary key,
    name text
);

create table book (
    id integer primary key,
    author_id integer,
    title text
);

insert into author values
    (1, 'Orwell'), (2, 'Dostoevsky');

insert into book values
    (10, 1, '1984'),
    (20, 1, 'The Animal Farm'),
    (30, 2, 'Crime and Punishment'),
    (40, 2, 'The idiot');


select
    author.*, book.*
from author
left join book on book.author_id = author.id;

┌────┬────────────┬────┬───────────┬──────────────────────┐
│ id │    name    │ id │ author_id │        title         │
├────┼────────────┼────┼───────────┼──────────────────────┤
│  1 │ Orwell     │ 10 │         1 │ 1984                 │
│  1 │ Orwell     │ 20 │         1 │ The Animal Farm      │
│  2 │ Dostoevsky │ 30 │         2 │ Crime and Punishment │
│  2 │ Dostoevsky │ 40 │         2 │ The idiot            │
└────┴────────────┴────┴───────────┴──────────────────────┘


select
    author.*,
    jsonb_agg(book) as books
from author
left join book on book.author_id = author.id
group by author.id;

┌────┬────────────┬─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ id │    name    │                                                      books                                                      │
├────┼────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  1 │ Orwell     │ [{"id": 10, "title": "1984", "author_id": 1}, {"id": 20, "title": "The Animal Farm", "author_id": 1}]           │
│  2 │ Dostoevsky │ [{"id": 30, "title": "Crime and Punishment", "author_id": 2}, {"id": 40, "title": "The idiot", "author_id": 2}] │
└────┴────────────┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

select
    (book ->> 'id')::integer as id,
    book ->> 'title' as title,
    (book ->> 'author_id')::integer as author_id
from
    jsonb_array_elements($$[
        {"id": 10, "title": "1984", "author_id": 1},
        {"id": 20, "title": "The Animal Farm", "author_id": 1}
    ]$$) as book;

┌────┬─────────────────┬───────────┐
│ id │      title      │ author_id │
├────┼─────────────────┼───────────┤
│ 10 │ 1984            │         1 │
│ 20 │ The Animal Farm │         1 │
└────┴─────────────────┴───────────┘

create table application (
    id integer primary key,
    department text,
    status text,
    users jsonb
);

insert into application values
    (1, 'finance', 'active', '[{"id": 10, "name": "John"}, {"id": 12, "name": "George"}]'),
    (2, 'accounting', 'pending', '[{"id": 14, "name": "Anna"}, {"id": 18, "name": "Federica"}]');

select
    app.id as app_id,
    app.status as app_status,
    (user_item->>'id')::integer as user_id,
    user_item->>'name' as user_name
from
    application app,
    jsonb_array_elements(app.users) as user_item;

┌────────┬────────────┬─────────┬───────────┐
│ app_id │ app_status │ user_id │ user_name │
├────────┼────────────┼─────────┼───────────┤
│      1 │ active     │      10 │ John      │
│      1 │ active     │      12 │ George    │
│      2 │ pending    │      14 │ Anna      │
│      2 │ pending    │      18 │ Federica  │
└────────┴────────────┴─────────┴───────────┘


create table application2 (
    id integer primary key,
    number text,
    status text,
    departments jsonb
);


insert into application2 values
    (1, '525/23A', 'active', $$
[{"code": "risk", "name": "Risk Department", "users": [{"id": 10, "name": "John"}]},
 {"code": "analytics", "name": "Analytics Department", "users": [{"id": 12, "name": "George"}]}]
    $$),
    (2, '2460-A2', 'pending', $$
[{"code": "risk", "name": "Risk Department", "users": [{"id": 14, "name": "Anna"}]},
 {"code": "analytics", "name": "Analytics Department", "users": [{"id": 18, "name": "Federica"}]}]
    $$);


select
    app.id as app_id,
    app.number as app_number,
    dep->>'code' as dep_code,
    dep->>'name' as dep_name,
    (usr->>'id')::int as user_id,
    usr->>'name' as user_name
from
    application2 app,
    jsonb_array_elements(departments) as dep,
    jsonb_array_elements(dep->'users') as usr;


┌────────┬────────────┬───────────┬──────────────────────┬─────────┬───────────┐
│ app_id │ app_number │ dep_code  │       dep_name       │ user_id │ user_name │
├────────┼────────────┼───────────┼──────────────────────┼─────────┼───────────┤
│      1 │ 525/23A    │ risk      │ Risk Department      │      10 │ John      │
│      1 │ 525/23A    │ analytics │ Analytics Department │      12 │ George    │
│      2 │ 2460-A2    │ risk      │ Risk Department      │      14 │ Anna      │
│      2 │ 2460-A2    │ analytics │ Analytics Department │      18 │ Federica  │
└────────┴────────────┴───────────┴──────────────────────┴─────────┴───────────┘

select
    app.id as app_id,
    app.number as app_number,
    jt.*
from
    application2 app,
    json_table(departments, '$[*]' columns(
        dep_code text path '$.code',
        dep_name text path '$.name',
        nested path '$.users[*]' columns(
            user_id integer path '$.id',
            user_name text path '$.name'
        )
)) as jt;


create table goods (
    sku text primary key,
    title text,
    category text,
    price integer
);

insert into goods values
    ('Asus62HF', 'Laptop',  'computers',  56000),
    ('5236/XXL', 'T-shirt', 'cloth',      2300),
    ('623/A/HS', 'Pencil',  'stationery', 10);

prepare stmt as
with json as (
    select
        item->>'sku' as sku,
        item->>'title' as title
    from
        jsonb_array_elements($1::jsonb) as item
)
select
    db is null as json_only,
    json is null as db_only,
    db is not null as both,
    db.title as db_title,
    json.title as json_title,
    db is not null and db.title <> json.title as title_mismatch
from
    goods as db
full join json on db.sku = json.sku;

execute stmt($$[
 {"sku": "5236/XXL", "title": "T-shirt"},
 {"sku": "623/A/HS", "title": "Black pen"},
 {"sku": "UWII5133", "title": "Tea spoon"}
]$$);

┌───────────┬─────────┬──────┬──────────┬────────────┬────────────────┐
│ json_only │ db_only │ both │ db_title │ json_title │ title_mismatch │
├───────────┼─────────┼──────┼──────────┼────────────┼────────────────┤
│ f         │ t       │ t    │ Laptop   │ <null>     │ <null>         │
│ f         │ f       │ t    │ T-shirt  │ T-shirt    │ f              │
│ f         │ f       │ t    │ Pencil   │ Black pen  │ t              │
│ t         │ f       │ f    │ <null>   │ Tea spoon  │ f              │
└───────────┴─────────┴──────┴──────────┴────────────┴────────────────┘
