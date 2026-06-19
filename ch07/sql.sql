

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
