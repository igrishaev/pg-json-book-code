

select
    doc->>'application_id' as app_id,
    doc->>'status' as status,
    doc->>'credit_type' as credit_type,
    (doc->>'created_at')::date as created_at,
    doc #>> '{created_by,name}' as created_by,
    doc #>> '{organization,short_name}' as org_short_name
from
    applications
where
    doc->>'status' in ('active', 'pending')
    and (doc->>'created_at')::timestamptz > now() - interval '3 months'
order by
    (doc->>'created_at')::timestamptz
limit
    1000;

┌────────┬────────┬─────────────┬────────────┬────────────┬──────────────────┐
│ app_id │ status │ credit_type │ created_at │ created_by │  org_short_name  │
├────────┼────────┼─────────────┼────────────┼────────────┼──────────────────┤
│ 651889 │ active │ org         │ 2026-03-19 │ User 0889  │ Organization 889 │
│ 399715 │ active │ org         │ 2026-03-19 │ User 0715  │ Organization 715 │
│ 565634 │ active │ org         │ 2026-03-19 │ User 0634  │ Organization 634 │
│ 280547 │ active │ org         │ 2026-03-19 │ User 0547  │ Organization 547 │
│ 590919 │ active │ org         │ 2026-03-19 │ User 0919  │ Organization 919 │
│ 225917 │ active │ org         │ 2026-03-19 │ User 0917  │ Organization 917 │
│ 66410  │ active │ country     │ 2026-03-19 │ User 0410  │ Organization 410 │
│ 255001 │ active │ country     │ 2026-03-19 │ User 0001  │ Organization 1   │
│ 24655  │ active │ country     │ 2026-03-19 │ User 0655  │ Organization 655 │
│ 689536 │ active │ org         │ 2026-03-19 │ User 0536  │ Organization 536 │


select
    doc->>'application_id' as app_id,
    doc->>'status' as status,
    (doc->>'created_at')::date as created_at,
    doc #>> '{created_by,name}' as created_by,
    doc #>> '{organization,short_name}' as org_short_name,
    dep->>'code' as dep_code,
    dep->>'name' as dep_name,
    jsonb_path_query_array(dep, '$.users.name') as users
from
    applications,
    jsonb_array_elements(doc->'departments') as dep
where
    doc->>'status' in ('active', 'pending')
    and (doc->>'created_at')::timestamptz > now() - interval '3 months'
order by
    (doc->>'created_at')::timestamptz
limit
    1000;


┌────────┬────────┬────────────┬────────────┬──────────────────┬──────────┬───────────────┬───────────────────────────┐
│ app_id │ status │ created_at │ created_by │  org_short_name  │ dep_code │   dep_name    │           users           │
├────────┼────────┼────────────┼────────────┼──────────────────┼──────────┼───────────────┼───────────────────────────┤
│ 399715 │ active │ 2026-03-19 │ User 0715  │ Organization 715 │ dep_15   │ Department 15 │ ["User 715", "User 725"]  │
│ 399715 │ active │ 2026-03-19 │ User 0715  │ Organization 715 │ dep_25   │ Department 25 │ ["User 735", "User 45"]   │
│ 565634 │ active │ 2026-03-19 │ User 0634  │ Organization 634 │ dep_9    │ Department 9  │ ["User 634", "User 644"]  │
│ 565634 │ active │ 2026-03-19 │ User 0634  │ Organization 634 │ dep_19   │ Department 19 │ ["User 654", "User 39"]   │
│ 280547 │ active │ 2026-03-19 │ User 0547  │ Organization 547 │ dep_22   │ Department 22 │ ["User 547", "User 557"]  │
│ 280547 │ active │ 2026-03-19 │ User 0547  │ Organization 547 │ dep_32   │ Department 32 │ ["User 567", "User 52"]   │
│ 590919 │ active │ 2026-03-19 │ User 0919  │ Organization 919 │ dep_19   │ Department 19 │ ["User 919", "User 929"]  │
│ 590919 │ active │ 2026-03-19 │ User 0919  │ Organization 919 │ dep_29   │ Department 29 │ ["User 939", "User 49"]   │
│ 225917 │ active │ 2026-03-19 │ User 0917  │ Organization 917 │ dep_17   │ Department 17 │ ["User 917", "User 927"]  │
│ 225917 │ active │ 2026-03-19 │ User 0917  │ Organization 917 │ dep_27   │ Department 27 │ ["User 937", "User 47"]   │
│ 66410  │ active │ 2026-03-19 │ User 0410  │ Organization 410 │ dep_10   │ Department 10 │ ["User 410", "User 420"]  │
│ 66410  │ active │ 2026-03-19 │ User 0410  │ Organization 410 │ dep_20   │ Department 20 │ ["User 430", "User 40"]   │


create or replace function jsonb_string_agg(sep text, items jsonb)
returns text
language sql immutable strict parallel safe as $$
select string_agg(distinct item, sep)
from jsonb_array_elements_text(items) as sub(item);
$$;


select jsonb_string_agg(' | ', $$[1, 1, 1, true, false, "abc", null, 3.03]$$) as test;

┌───────────────────────────────┐
│             test              │
├───────────────────────────────┤
│ 1 | true | false | abc | 3.03 │
└───────────────────────────────┘


select
    doc->>'application_id' as app_id,
    doc->>'status' as status,
    (doc->>'created_at')::date as created_at,
    doc #>> '{created_by,name}' as created_by,
    doc #>> '{organization,short_name}' as org_short_name,
    dep->>'code' as dep_code,
    dep->>'name' as dep_name,
    jsonb_string_agg(', ', jsonb_path_query_array(dep, '$.users.name'))
    as users
from
    applications,
    jsonb_array_elements(doc->'departments') as dep
where
    doc->>'status' in ('active', 'pending')
    and (doc->>'created_at')::timestamptz > now() - interval '3 months'
order by
    (doc->>'created_at')::timestamptz
limit
    1000;


┌────────┬────────┬────────────┬────────────┬──────────────────┬──────────┬───────────────┬─────────────────────┐
│ app_id │ status │ created_at │ created_by │  org_short_name  │ dep_code │   dep_name    │        users        │
├────────┼────────┼────────────┼────────────┼──────────────────┼──────────┼───────────────┼─────────────────────┤
│ 399715 │ active │ 2026-03-19 │ User 0715  │ Organization 715 │ dep_15   │ Department 15 │ User 715, User 725  │
│ 399715 │ active │ 2026-03-19 │ User 0715  │ Organization 715 │ dep_25   │ Department 25 │ User 45, User 735   │
│ 565634 │ active │ 2026-03-19 │ User 0634  │ Organization 634 │ dep_9    │ Department 9  │ User 634, User 644  │
│ 565634 │ active │ 2026-03-19 │ User 0634  │ Organization 634 │ dep_19   │ Department 19 │ User 39, User 654   │
│ 280547 │ active │ 2026-03-19 │ User 0547  │ Organization 547 │ dep_22   │ Department 22 │ User 547, User 557  │
│ 280547 │ active │ 2026-03-19 │ User 0547  │ Organization 547 │ dep_32   │ Department 32 │ User 52, User 567   │
│ 590919 │ active │ 2026-03-19 │ User 0919  │ Organization 919 │ dep_19   │ Department 19 │ User 919, User 929  │
│ 590919 │ active │ 2026-03-19 │ User 0919  │ Organization 919 │ dep_29   │ Department 29 │ User 49, User 939   │
│ 225917 │ active │ 2026-03-19 │ User 0917  │ Organization 917 │ dep_17   │ Department 17 │ User 917, User 927  │
│ 225917 │ active │ 2026-03-19 │ User 0917  │ Organization 917 │ dep_27   │ Department 27 │ User 47, User 937   │
│ 66410  │ active │ 2026-03-19 │ User 0410  │ Organization 410 │ dep_10   │ Department 10 │ User 410, User 420  │
│ 66410  │ active │ 2026-03-19 │ User 0410  │ Organization 410 │ dep_20   │ Department 20 │ User 40, User 430   │
│ 255001 │ active │ 2026-03-19 │ User 0001  │ Organization 1   │ dep_1    │ Department 1  │ User 1, User 11     │
│ 255001 │ active │ 2026-03-19 │ User 0001  │ Organization 1   │ dep_11   │ Department 11 │ User 21, User 31    │




select
    doc->>'application_id' as app_id,
    doc->>'status' as status,
    (doc->>'created_at')::date as created_at,
    doc #>> '{created_by,name}' as created_by,
    doc #>> '{organization,short_name}' as org_short_name,
    dep->>'code' as dep_code,
    dep->>'name' as dep_name,
    usr->>'name' as user_name,
    usr->>'role' as user_role
from
    applications,
    jsonb_array_elements(doc->'departments') as dep,
    jsonb_array_elements(dep->'users') as usr
where
    doc->>'status' in ('active', 'pending')
    and (doc->>'created_at')::timestamptz > now() - interval '3 months'
order by
    (doc->>'created_at')::timestamptz
limit
    1000;


┌────────┬────────┬────────────┬────────────┬──────────────────┬──────────┬───────────────┬───────────┬────────────────┐
│ app_id │ status │ created_at │ created_by │  org_short_name  │ dep_code │   dep_name    │ user_name │   user_role    │
├────────┼────────┼────────────┼────────────┼──────────────────┼──────────┼───────────────┼───────────┼────────────────┤
│ 399715 │ active │ 2026-03-19 │ User 0715  │ Organization 715 │ dep_15   │ Department 15 │ User 715  │ support        │
│ 399715 │ active │ 2026-03-19 │ User 0715  │ Organization 715 │ dep_15   │ Department 15 │ User 725  │ analyst        │
│ 399715 │ active │ 2026-03-19 │ User 0715  │ Organization 715 │ dep_25   │ Department 25 │ User 735  │ reader         │
│ 399715 │ active │ 2026-03-19 │ User 0715  │ Organization 715 │ dep_25   │ Department 25 │ User 45   │ reader         │
│ 565634 │ active │ 2026-03-19 │ User 0634  │ Organization 634 │ dep_9    │ Department 9  │ User 634  │ analyst        │
│ 565634 │ active │ 2026-03-19 │ User 0634  │ Organization 634 │ dep_9    │ Department 9  │ User 644  │ decision-maker │
│ 565634 │ active │ 2026-03-19 │ User 0634  │ Organization 634 │ dep_19   │ Department 19 │ User 654  │ lead           │
│ 565634 │ active │ 2026-03-19 │ User 0634  │ Organization 634 │ dep_19   │ Department 19 │ User 39   │ support        │
│ 280547 │ active │ 2026-03-19 │ User 0547  │ Organization 547 │ dep_22   │ Department 22 │ User 547  │ lead           │
│ 280547 │ active │ 2026-03-19 │ User 0547  │ Organization 547 │ dep_22   │ Department 22 │ User 557  │ principal      │
│ 280547 │ active │ 2026-03-19 │ User 0547  │ Organization 547 │ dep_32   │ Department 32 │ User 567  │ manager        │
│ 280547 │ active │ 2026-03-19 │ User 0547  │ Organization 547 │ dep_32   │ Department 32 │ User 52   │ decision-maker │
│ 590919 │ active │ 2026-03-19 │ User 0919  │ Organization 919 │ dep_19   │ Department 19 │ User 919  │ decision-maker │
│ 590919 │ active │ 2026-03-19 │ User 0919  │ Organization 919 │ dep_19   │ Department 19 │ User 929  │ lead           │
│ 590919 │ active │ 2026-03-19 │ User 0919  │ Organization 919 │ dep_29   │ Department 29 │ User 939  │ decision-maker │
│ 590919 │ active │ 2026-03-19 │ User 0919  │ Organization 919 │ dep_29   │ Department 29 │ User 49   │ principal      │



select
    jt.*
from
    applications,
    json_table(doc, '$' columns(
        application_id int         path '$.application_id',
        status         text        path '$.status',
        assigned_to    text        path '$.assigned_to',
        created_at     timestamptz path '$.created_at',
        credit_type    text        path '$.credit_type'
    )) as jt
limit
    1000;


┌────────────────┬──────────┬───────────────────┬───────────────────────────────┬─────────────┐
│ application_id │  status  │    assigned_to    │          created_at           │ credit_type │
├────────────────┼──────────┼───────────────────┼───────────────────────────────┼─────────────┤
│          10177 │ archived │ user_177@test.com │ 2026-03-20 16:25:15.295135+03 │ org         │
│          10178 │ active   │ user_178@test.com │ 2026-01-27 03:01:24.60134+03  │ org         │
│          10179 │ rejected │ user_179@test.com │ 2026-01-20 14:08:31.31944+03  │ org         │
│          10180 │ archived │ user_180@test.com │ 2026-03-16 16:25:14.90315+03  │ country     │
│          10181 │ archived │ user_181@test.com │ 2026-02-24 20:31:46.79655+03  │ country     │
│          10182 │ archived │ user_182@test.com │ 2025-11-27 04:53:55.326635+03 │ org         │
│          10183 │ archived │ user_183@test.com │ 2026-01-06 18:40:52.184655+03 │ org         │
│          10184 │ archived │ user_184@test.com │ 2025-08-22 10:44:59.469485+03 │ org         │



select
    jt.*
from
    applications,
    json_table(doc, '$' columns(
        application_id int         path '$.application_id',
        status         text        path '$.status',
        credit_type    text        path '$.credit_type',
        nested path '$.departments[*]' columns(
            dep_code text path '$.code',
            dep_name text path '$.name',
            nested path '$.users[*]' columns(
                user_name text path '$.name',
                user_role text path '$.role'
            )
        )
    )) as jt
limit
    1000;


┌────────────────┬──────────┬─────────────┬──────────┬───────────────┬───────────┬────────────────┐
│ application_id │  status  │ credit_type │ dep_code │   dep_name    │ user_name │   user_role    │
├────────────────┼──────────┼─────────────┼──────────┼───────────────┼───────────┼────────────────┤
│          11457 │ archived │ org         │ dep_7    │ Department 7  │ User 457  │ support        │
│          11457 │ archived │ org         │ dep_7    │ Department 7  │ User 467  │ manager        │
│          11457 │ archived │ org         │ dep_17   │ Department 17 │ User 477  │ principal      │
│          11457 │ archived │ org         │ dep_17   │ Department 17 │ User 37   │ lead           │
│          11458 │ archived │ org         │ dep_8    │ Department 8  │ User 458  │ support        │
│          11458 │ archived │ org         │ dep_8    │ Department 8  │ User 468  │ manager        │
│          11458 │ archived │ org         │ dep_18   │ Department 18 │ User 478  │ reader         │
│          11458 │ archived │ org         │ dep_18   │ Department 18 │ User 38   │ support        │
│          11459 │ archived │ org         │ dep_9    │ Department 9  │ User 459  │ analyst        │
│          11459 │ archived │ org         │ dep_9    │ Department 9  │ User 469  │ manager        │
│          11459 │ archived │ org         │ dep_19   │ Department 19 │ User 479  │ principal      │
│          11459 │ archived │ org         │ dep_19   │ Department 19 │ User 39   │ principal      │



select
    jt.*
from
    applications,
    json_table(doc, '$' columns(
        application_id int         path '$.application_id',
        status         text        path '$.status',
        credit_type    text        path '$.credit_type',
        nested path '$.departments[*]' columns(
            dep_code text path '$.code',
            dep_name text path '$.name',
            nested path '$.users[*]' columns(
                user_name text path '$.name',
                user_role text path '$.role'
            )
        )
    )) as jt

where
        dep_code in ('dep_15', 'dep_16', 'dep_17')
    and user_role in ('support', 'reader', 'lead')
limit
    1000;



select
    jt.*
from
    applications,
    json_table(doc, '$' columns(
        application_id int         path '$.application_id',
        status         text        path '$.status',
        credit_type    text        path '$.credit_type',
        nested path '$.departments[*] ? (@.code == "dep_15" || @.code == "dep_16" || @.code == "dep_16")' columns(
            dep_code text path '$.code',
            dep_name text path '$.name',
            nested path '$.users[*] ? (@.role == "support" || @.role == "reader" || @.role == "lead")' columns(
                user_name text path '$.name',
                user_role text path '$.role'
            )
        )
    )) as jt
limit
    1000;


┌────────────────┬──────────┬─────────────┬──────────┬───────────────┬───────────┬───────────┐
│ application_id │  status  │ credit_type │ dep_code │   dep_name    │ user_name │ user_role │
├────────────────┼──────────┼─────────────┼──────────┼───────────────┼───────────┼───────────┤
│          24001 │ archived │ country     │ <null>   │ <null>        │ <null>    │ <null>    │
│          24002 │ archived │ org         │ <null>   │ <null>        │ <null>    │ <null>    │
│          24003 │ archived │ org         │ <null>   │ <null>        │ <null>    │ <null>    │
│          24004 │ archived │ org         │ <null>   │ <null>        │ <null>    │ <null>    │
│          24005 │ archived │ org         │ dep_15   │ Department 15 │ User 35   │ lead      │
│          24006 │ archived │ org         │ dep_16   │ Department 16 │ <null>    │ <null>    │
│          24007 │ approved │ org         │ <null>   │ <null>        │ <null>    │ <null>    │
│          24008 │ archived │ org         │ <null>   │ <null>        │ <null>    │ <null>    │
│          24009 │ approved │ country     │ <null>   │ <null>        │ <null>    │ <null>    │
│          24010 │ approved │ org         │ <null>   │ <null>        │ <null>    │ <null>    │
│          24011 │ archived │ org         │ <null>   │ <null>        │ <null>    │ <null>    │
│          24012 │ archived │ org         │ <null>   │ <null>        │ <null>    │ <null>    │
│          24013 │ archived │ org         │ <null>   │ <null>        │ <null>    │ <null>    │
│          24014 │ archived │ org         │ <null>   │ <null>        │ <null>    │ <null>    │


select jsonb_path_query($$
{
  "users": [
    {
      "id": 101,
      "role": "admin",
      "name": "Ivan Petrov"
    },
    {
      "id": 135,
      "role": "manager",
      "name": "Andrey Ivanov"
    },
    {
      "id": 399,
      "role": "programmer",
      "name": "Anna Smirnova"
    }
  ]
}
$$::jsonb,
    '$.users ? (@.role == $role) .id',
    jsonb_build_object('role', 'admin')
) as id;


┌─────┐
│ id  │
├─────┤
│ 101 │
└─────┘

prepare get_id_by_role as
select jsonb_path_query($$
{
  "users": [
    {
      "id": 101,
      "role": "admin",
      "name": "Ivan Petrov"
    },
    {
      "id": 135,
      "role": "manager",
      "name": "Andrey Ivanov"
    },
    {
      "id": 399,
      "role": "programmer",
      "name": "Anna Smirnova"
    }
  ]
}
$$::jsonb,
    '$.users ? (@.role == $role) .id',
    jsonb_build_object('role', $1::text)
) as id;


execute get_id_by_role('programmer');

┌─────┐
│ id  │
├─────┤
│ 399 │
└─────┘

execute get_id_by_role('janitor');

-- null

-- passing 'dep_15' as dep_code, 'support' as user_role

select
    jt.*
from
    applications,
    json_table(doc, '$' passing 'dep_15' as dep_code, 'support' as user_role
    columns(
        application_id int         path '$.application_id',
        status         text        path '$.status',
        credit_type    text        path '$.credit_type',
        nested path '$.departments[*] ? (@.code == $dep_code)' columns(
            dep_code text path '$.code',
            dep_name text path '$.name',
            nested path '$.users[*] ? (@.role == $user_role)' columns(
                user_name text path '$.name',
                user_role text path '$.role'
            )
        )
    )) as jt
limit
    1000;




select
    dep_code,
    user_role,
    count(application_id) as app_count

from
    applications,
    json_table(doc, '$' columns(
        application_id int         path '$.application_id',
        status         text        path '$.status',
        nested path '$.departments[*]' columns(
            dep_code text path '$.code',
            dep_name text path '$.name',
            nested path '$.users[*]' columns(
                user_role text path '$.role'
            )
        )
    )) as jt

where
        dep_code in ('dep_15', 'dep_16', 'dep_17')
    and status = 'active'

group by
    dep_code, user_role

order by
    dep_code, user_role

limit
    1000;


┌──────────┬────────────────┬───────────┐
│ dep_code │   user_role    │ app_count │
├──────────┼────────────────┼───────────┤
│ dep_15   │ analyst        │      1165 │
│ dep_15   │ decision-maker │      1162 │
│ dep_15   │ lead           │      1098 │
│ dep_15   │ manager        │      1147 │
│ dep_15   │ principal      │      1138 │
│ dep_15   │ reader         │      1218 │
│ dep_15   │ support        │      1168 │
│ dep_16   │ analyst        │      1163 │
│ dep_16   │ decision-maker │      1151 │
│ dep_16   │ lead           │      1157 │
│ dep_16   │ manager        │      1177 │
│ dep_16   │ principal      │      1203 │
│ dep_16   │ reader         │      1134 │
│ dep_16   │ support        │      1177 │
│ dep_17   │ analyst        │      1162 │
│ dep_17   │ decision-maker │      1134 │
│ dep_17   │ lead           │      1137 │
│ dep_17   │ manager        │      1136 │
│ dep_17   │ principal      │      1125 │
│ dep_17   │ reader         │      1132 │
│ dep_17   │ support        │      1148 │
└──────────┴────────────────┴───────────┘





select
    jt.*
from
    applications,
    json_table(doc, '$' columns(
        application_id int path '$.application_id',
        nested path '$.amounts[*]' columns(
            i for ordinality,
            amount   int8 path '$.amount',
            currency text path '$.currency'
        )
    )) as jt
limit
    1000;


┌────────────────┬───┬──────────┬──────────┐
│ application_id │ i │  amount  │ currency │
├────────────────┼───┼──────────┼──────────┤
│         152129 │ 1 │ 35343725 │ USD      │
│         152129 │ 2 │ 67772662 │ RUB      │
│         152130 │ 1 │ 31377772 │ RUB      │
│         152130 │ 2 │ 39103626 │ EUR      │
│         152131 │ 1 │  2026082 │ RUB      │
│         152131 │ 2 │ 91184516 │ USD      │



select
    currency,
    sum(amount) as amount_total,
    count(application_id) as app_count
from
    applications,
    json_table(doc, '$' columns(
        application_id int  path '$.application_id',
        status         text path '$.status',
        nested path '$.amounts[*]' columns(
            amount   int8 path '$.amount',
            currency text path '$.currency'
        )
    )) as jt
where
        status = 'active'
    and currency in ('USD', 'RUB', 'EUR')

group by currency;



┌──────────┬───────────────┬───────────┐
│ currency │ amount_total  │ app_count │
├──────────┼───────────────┼───────────┤
│ EUR      │ 1673618268900 │     33391 │
│ RUB      │ 1649511396849 │     33006 │
│ USD      │ 1678496810973 │     33427 │
└──────────┴───────────────┴───────────┘


with
recursive init as (
    select
        doc->>'id' as id,
        doc->>'title' as title,
        0 as level,
        doc->'children' as children
    from
        (values ($$
{
   "id":"101",
   "title":"Product A",
   "children":[
      {
         "id":"104",
         "title":"Product B"
      },
      {
         "id":"206",
         "title":"Product C",
         "children":[
            {
               "id":304,
               "title":"Product D"
            },
            {
               "id":323,
               "title":"Product E"
            }
         ]
      }
   ]
}
    $$::jsonb)) as _(doc)
    union all
    select
        doc->>'id' as id,
        doc->>'title' as title,
        level + 1 as level,
        doc->'children' as children
    from
        init,
        jsonb_array_elements(children) as _(doc)
)
select id, level, title
from init;

┌─────┬───────┬───────────┐
│ id  │ level │   title   │
├─────┼───────┼───────────┤
│ 101 │     0 │ Product A │
│ 104 │     1 │ Product B │
│ 206 │     1 │ Product C │
│ 304 │     2 │ Product D │
│ 323 │     2 │ Product E │
└─────┴───────┴───────────┘


doc #>> '{organization,short_name}'


create or replace function get_application_id(doc jsonb)
returns int8
language sql immutable strict parallel safe
return (doc->>'application_id')::int8;


select get_application_id(doc) as app_id
from applications limit 10;

┌────────┐
│ app_id │
├────────┤
│ 152641 │
│ 152642 │
│ 152643 │
│ 152644 │
│ 152645 │
│ 152646 │
│ 152647 │
│ 152648 │
│ 152649 │
│ 152650 │
└────────┘

create schema app;

create or replace function app.application_id(doc jsonb)
returns int8
language sql immutable strict parallel safe
return (doc->>'application_id')::int8;


set search_path to app,public,"$user";


select application_id(doc) as app_id
from applications limit 10;


create or replace function app_user_names(doc jsonb)
returns text
language sql immutable strict parallel safe as $$
select
    string_agg(distinct usr->>'name', ', ')
from
    jsonb_array_elements(doc['departments']) as deps(dep),
    jsonb_array_elements(dep['users']) as users(usr)
$$;


select app_user_names(doc) as users
from applications limit 10;

┌───────────────────────────────────────┐
│                 users                 │
├───────────────────────────────────────┤
│ User 46, User 641, User 651, User 661 │
│ User 47, User 642, User 652, User 662 │
│ User 48, User 643, User 653, User 663 │
│ User 49, User 644, User 654, User 664 │
│ User 50, User 645, User 655, User 665 │
│ User 51, User 646, User 656, User 666 │
│ User 52, User 647, User 657, User 667 │
│ User 53, User 648, User 658, User 668 │
│ User 54, User 649, User 659, User 669 │
│ User 30, User 650, User 660, User 670 │
└───────────────────────────────────────┘


create or replace function app_user_names(doc jsonb)
returns text
language sql immutable strict parallel safe as $$
select
    string_agg(distinct usr->>'name', ', ' order by usr->>'name')
from
    jsonb_array_elements(doc['departments']) as deps(dep),
    jsonb_array_elements(dep['users']) as users(usr)
$$;


create or replace function app_last_event_user_id(doc jsonb)
returns uuid
language sql immutable strict parallel safe as $$
select
    jt.user_id
from
    json_table(doc, '$.journal[*]' columns(
        user_id  uuid        path '$.user_id',
        datetime timestamptz path '$.datetime'
    )) as jt
order by datetime desc
limit 1
$$;


select app_last_event_user_id(doc) as user_id
from applications limit 10;


┌──────────────────────────────────────┐
│               user_id                │
├──────────────────────────────────────┤
│ b8c697ff-a344-446a-a433-605d10a4534a │
│ 8f3c805c-5826-4011-80e2-84602f6fc833 │
│ 6ae37c29-6408-4cd9-9b11-ac1c1bf7fb5a │
│ e8d60a6b-6f75-447b-b5e4-a410fe8ba9aa │
│ 8717b98e-500b-4d06-b7c3-ab686f9b3de8 │
│ be186c17-9f4d-4128-8778-258e3693fa17 │
│ f1e644c9-be03-407e-8bde-8255a1902302 │
│ e0e30b25-5671-4f59-931f-1634f4dcf23d │
│ 424c4b20-3e1f-4d50-9a81-8ea3abc78f23 │
│ e4f261c3-979b-496b-9d25-8e48ea363b6d │
└──────────────────────────────────────┘


create or replace function app_last_event_user_id(doc jsonb, event text)
returns uuid
language sql immutable strict parallel safe as $$
select
    jt.user_id
from
    json_table(doc, '$.journal[*]' columns(
        user_id  uuid        path '$.user_id',
        event    text        path '$.event',
        datetime timestamptz path '$.datetime'
    )) as jt
where jt.event = event
order by datetime desc
limit 1
$$;


select app_last_event_user_id(doc, 'active') as user_id
from applications limit 10;




create or replace function app_created_by_roles(doc jsonb)
returns setof text
language sql immutable strict parallel safe as $$
select
    user_role
from
    json_table(doc, '$.departments.users[*]' columns(
        user_id   uuid path '$.id',
        user_role text path '$.role'
    )) as jt
where user_id = (doc #>> '{created_by,id}')::uuid
$$;


select id, app_created_by_roles(doc)
from applications limit 10;


┌──────────────────────────────────────┬──────────────────────┐
│                  id                  │ app_created_by_roles │
├──────────────────────────────────────┼──────────────────────┤
│ 00000000-0000-0000-0000-000000152641 │ decision-maker       │
│ 00000000-0000-0000-0000-000000152642 │ analyst              │
│ 00000000-0000-0000-0000-000000152643 │ analyst              │
│ 00000000-0000-0000-0000-000000152644 │ reader               │
│ 00000000-0000-0000-0000-000000152645 │ decision-maker       │
│ 00000000-0000-0000-0000-000000152646 │ manager              │
│ 00000000-0000-0000-0000-000000152647 │ decision-maker       │
│ 00000000-0000-0000-0000-000000152648 │ reader               │
│ 00000000-0000-0000-0000-000000152649 │ reader               │
│ 00000000-0000-0000-0000-000000152650 │ decision-maker       │
└──────────────────────────────────────┴──────────────────────┘



create or replace function app_dep_user_table(doc jsonb)
returns table (
    app_id int8,
    dep_code text,
    dep_name text,
    user_email text,
    user_role text
)
language sql immutable strict parallel safe as $$
select
    jt.*
from
    json_table(doc, '$' columns(
        app_id int8 path '$.application_id',
        nested path '$.departments[*]' columns(
            dep_code text path '$.code',
            dep_name text path '$.name',
            nested path '$.users[*]' columns(
                user_email text path '$.email',
                user_role  text path '$.role'
            )
        )
    )) as jt
$$;


select
    tab.*
from
    applications,
    app_dep_user_table(doc) as tab
where
    id = '00000000-0000-0000-0000-000000000001';


┌────────┬──────────┬───────────────┬──────────────────┬───────────┐
│ app_id │ dep_code │   dep_name    │    user_email    │ user_role │
├────────┼──────────┼───────────────┼──────────────────┼───────────┤
│      1 │ dep_1    │ Department 1  │ user_1@test.com  │ analyst   │
│      1 │ dep_1    │ Department 1  │ user_11@test.com │ manager   │
│      1 │ dep_11   │ Department 11 │ user_21@test.com │ principal │
│      1 │ dep_11   │ Department 11 │ user_31@test.com │ reader    │
└────────┴──────────┴───────────────┴──────────────────┴───────────┘


create or replace function app_add_event(doc jsonb, user_id uuid, event text)
returns jsonb
language plpgsql immutable strict parallel safe as $$
declare
    journal jsonb;
begin
    journal := coalesce(doc['journal'], '[]'::jsonb);
    journal := journal || jsonb_build_object(
        'event', event,
        'user_id', user_id::text,
        'datetime', now()::text
    );
    return doc || jsonb_build_object('journal', journal);
end;
$$;


select app_add_event($${
    "journal": []
}$$::jsonb, '6d4fdd3a-0cea-4927-80e4-39e06fcdc2ae'::uuid, 'created')
as doc_new;

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                               doc_new                                                               │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ {"journal": [{"event": "created", "user_id": "6d4fdd3a-0cea-4927-80e4-39e06fcdc2ae", "datetime": "2026-06-19 16:59:09.859938+03"}]} │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


create or replace function func_b(x int4) returns int4
language plpgsql as $$
begin
    return x * x;
end;
$$;

create or replace function func_a(x int4) returns int4
language plpgsql as $$
begin
    return func_b(x);
end;
$$;

select func_a(8);

┌────────┐
│ func_a │
├────────┤
│     64 │
└────────┘

drop function func_b;


ERROR:  function func_b(integer) does not exist
LINE 1: func_b(x)
        ^
HINT:  No function matches the given name and argument types. You might need to add explicit type casts.
QUERY:  func_b(x)
CONTEXT:  PL/pgSQL function func_a(integer) line 3 at RETURN


drop function func_a;


create or replace function func_b(x int4) returns int4
language sql return x * x;

create or replace function func_a(x int4) returns int4
language sql return func_b(x);

select func_a(8);

drop function func_b;

ERROR:  cannot drop function func_b(integer) because other objects depend on it
DETAIL:  function func_a(integer) depends on function func_b(integer)
HINT:  Use DROP ... CASCADE to drop the dependent objects too.
