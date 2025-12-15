

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
