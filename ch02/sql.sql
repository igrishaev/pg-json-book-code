

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

select '"message"'::jsonb ->> 0 as message;
┌─────────┐
│ message │
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
