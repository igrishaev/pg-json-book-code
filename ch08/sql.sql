
/*
pg python
13 3.9
13 3.9
15 3.11
16 3.12
17 3.13
18 3.??
*/

-- https://postgresapp.com/documentation/plpython.html


/*
PostgreSQL Version 	         Python Version
PostgreSQL 18                Python >= 3.9.x from python.org
PostgreSQL 17                Python 3.13.x from python.org
PostgreSQL 16                Python 3.12.x from python.org
PostgreSQL 15                Python 3.11.x from python.org
PostgreSQL 14                Python 3.9.x from python.org
PostgreSQL 13                Python 3.8.x from python.org
PostgreSQL 12 and earlier    Python 2.7 (included with macOS)
*/


CREATE EXTENSION plpython3u;

/*
ERROR:  could not load library "/Applications/Postgres.app/Contents/Versions/17/lib/postgresql/plpython3.dylib": dlopen(/Applications/Postgres.app/Contents/Versions/17/lib/postgresql/plpython3.dylib, 0x000A): Library not loaded: /Library/Frameworks/Python.framework/Versions/3.13/Python
  Referenced from: <B2141B7A-14B3-3F4E-86A7-96D338EA4385> /Applications/Postgres.app/Contents/Versions/17/lib/postgresql/plpython3.dylib
  Reason: tried: '/Library/Frameworks/Python.framework/Versions/3.13/Python' (no such file), '/System/Volumes/Preboot/Cryptexes/OS/Library/Frameworks/Python.framework/Versions/3.13/Python' (no such file), '/Library/Frameworks/Python.framework/Versions/3.13/Python' (no such file)
*/



-- /opt/homebrew/Cellar/python@3.13/3.13.2/

create or replace function my_python_func(a integer, b text, c boolean)
returns text
language plpython3u as $$
    items = [a, b, c]
    return ', '.join(map(str, items))
$$;


select my_python_func(20, 'hello', true) as x;

┌─────────────────┐
│        x        │
├─────────────────┤
│ 20, hello, True │
└─────────────────┘


create or replace function py_datetime_test(dt timestamptz)
returns text
language plpython3u as $$
    print(dt, type(dt))
    return str(dt)
$$;


select py_datetime_test(now()) as x;


┌───────────────────────────────┐
│               x               │
├───────────────────────────────┤
│ 2026-06-20 16:30:47.046679+03 │
└───────────────────────────────┘

-- https://postgrespro.ru/docs/postgresql/17/plpython-util?lang=ru

create or replace function py_datetime_test(dt timestamptz)
returns text
language plpython3u as $$
    plpy.info("argument: %s, type: %s" % (dt, type(dt)), hint="debug")
    return str(dt)
$$;

INFO:  argument: 2026-06-20 16:34:02.298144+03, type: <class 'str'>
HINT:  debug



create or replace function py_datetime_test2(dt_iso timestamptz)
returns int8
language plpython3u as $$
    from datetime import datetime
    dt = datetime.fromisoformat(dt_iso)
    plpy.info("argument: %s, type: %s" % (dt, type(dt)), hint="debug")
    return dt.year
$$;

select py_datetime_test2(now()) as x;

INFO:  argument: 2026-06-20 16:39:41.228606+03:00, type: <class 'datetime.datetime'>
HINT:  debug
┌──────┐
│  x   │
├──────┤
│ 2026 │
└──────┘




create or replace function py_test3()
returns text
language plpython3u as $$
    import numpy as np

    A = np.array([[1, 2],
                  [3, 4]])

    B = np.array([[5, 6],
                  [7, 8]])

    C = A * B

    plpy.info("matrix mul result: %s" % C, hint="debug")
    return str(C)
$$;


select py_test3() as x;

INFO:  matrix mul result: [[ 5 12]
 [21 32]]
HINT:  debug
┌───────────┐
│     x     │
├───────────┤
│ [[ 5 12] ↵│
│  [21 32]] │
└───────────┘



create or replace function py_test_doc(doc jsonb)
returns jsonb
language plpython3u as $$
    doc2 = doc.copy()
    doc2["foo"] = 1
    doc2["bar"] = 2
    return doc2
$$;


select py_test_doc('{"a": "hello"}');

ERROR:  AttributeError: 'str' object has no attribute 'copy'
CONTEXT:  Traceback (most recent call last):
  PL/Python function "py_test_doc", line 2, in <module>
    doc2 = doc.copy()
PL/Python function "py_test_doc"


create or replace function py_test_doc(doc jsonb)
returns jsonb
language plpython3u as $$
    import json
    doc2 = json.loads(doc)
    doc2["foo"] = 1
    doc2["bar"] = 2
    return doc2
$$;


select py_test_doc('{"a": "hello"}');


ERROR:  invalid input syntax for type json
DETAIL:  Token "'" is invalid.
CONTEXT:  JSON data, line 1: {'...
while creating return value
PL/Python function "py_test_doc"



create or replace function py_test_doc(doc jsonb)
returns jsonb
language plpython3u as $$
    import json
    doc2 = json.loads(doc)
    doc2["foo"] = 1
    doc2["bar"] = 2
    return json.dumps(doc2)
$$;


select py_test_doc('{"a": "hello"}');


┌────────────────────────────────────┐
│            py_test_doc             │
├────────────────────────────────────┤
│ {"a": "hello", "bar": 2, "foo": 1} │
└────────────────────────────────────┘


create extension jsonb_plpython3u;


create or replace function py_test_doc(doc jsonb)
returns jsonb
transform for type jsonb
language plpython3u as $$
    doc2 = doc.copy()
    doc2["foo"] = 1
    doc2["bar"] = 2
    return doc2
$$;

select py_test_doc('{"a": "hello"}');


create or replace function py_app_users(doc jsonb)
returns text
transform for type jsonb
immutable strict parallel safe
language plpython3u as $$
    user_set = set()
    for dep in doc["departments"]:
        for user in dep["users"]:
            user_set.add(user["name"])
    user_list = list(user_set)
    user_list.sort()
    return ", ".join(user_list)
$$;


select
    doc->>'application_id' as app_id,
    py_app_users(doc) as users
from
    applications
limit
    100;


┌────────┬────────────────────────────────────┐
│ app_id │                     users          │
├────────┼────────────────────────────────────┤
│ 1      │ User 1, User 11, User 21, User 31  │
│ 2      │ User 12, User 2, User 22, User 32  │
│ 3      │ User 13, User 23, User 3, User 33  │
│ 4      │ User 14, User 24, User 34, User 4  │
│ 5      │ User 15, User 25, User 35, User 5  │
│ 6      │ User 16, User 26, User 36, User 6  │
│ 7      │ User 17, User 27, User 37, User 7  │
│ 8      │ User 18, User 28, User 38, User 8  │



create or replace function py_app_last_event_user_id(doc jsonb)
returns uuid
transform for type jsonb
immutable strict parallel safe
language plpython3u as $$

    events = doc["journal"]
    events.sort(key=lambda event: event['datetime'])

    try:
        return events[-1]["user_id"]
    except IndexError:
        return None
$$;


select
    doc->>'application_id' as app_id,
    py_app_last_event_user_id(doc) as last_user_id
from
    applications
limit
    10;


┌────────┬──────────────────────────────────────┐
│ app_id │             last_user_id             │
├────────┼──────────────────────────────────────┤
│ 129    │ 1f4c535f-2cbb-4d54-be0a-05e3cbbc7734 │
│ 130    │ 4d17e4ae-b8b2-4dbf-acaf-d42924aa8963 │
│ 131    │ 0506442e-449e-47e6-9584-e6cf35c95259 │
│ 132    │ dcffbf96-a2ee-4a5d-9209-b371f52c46d4 │
│ 133    │ 92c2e2e8-fa21-4fa8-8675-b12433af61b8 │
│ 134    │ ed2b40ee-b897-41fe-8a3a-bc81390a610f │
│ 135    │ dd3986e8-6ece-4f7e-911f-fff5bcbbb276 │
│ 136    │ 3555410a-5db8-4870-acd9-884d264768ac │
│ 137    │ 2309d179-6f8f-43ff-9a8c-892d42d50594 │
│ 138    │ fa7c1304-a3fa-4f88-aeea-391cbc1fdcaa │
└────────┴──────────────────────────────────────┘


create or replace function py_app_amount_summary(doc jsonb, rates jsonb)
returns text
transform for type jsonb
immutable strict parallel safe
language plpython3u as $$

    from datetime import date
    from dateutil.relativedelta import relativedelta

    now = date.today()

    parts = []
    amounts = doc["amounts"]
    for amount in amounts:
        currency = amount["currency"]
        rate = rates[currency]
        value = float(amount["amount"] * rate)

        y = int(amount["period"]["y"])
        m = int(amount["period"]["m"])
        w = int(amount["period"]["w"])
        d = int(amount["period"]["d"])

        days = d + w * 7

        td = relativedelta(years=y, months=m, days=days)
        limit = now + td

        parts.append("%.3f mln RUB => %s" % (value / 10e6, limit))

    return "; ".join(parts)
$$;


with
rates(rates) as (
    select * from (values ($$
{
    "RUB": 1.0,
    "EUR": 82.9,
    "USD": 73.4
}
    $$::jsonb))
)
select
    doc->>'application_id' as app_id,
    py_app_amount_summary(doc, rates) as amount_summary
from
    applications, rates
limit
    10;


┌────────┬──────────────────────────────────────────────────────────────┐
│ app_id │                        amount_summary                        │
├────────┼──────────────────────────────────────────────────────────────┤
│ 129    │ 1.110 mln RUB => 2030-01-10; 6.971 mln RUB => 2030-05-30     │
│ 130    │ 82.978 mln RUB => 2029-05-21; 551.047 mln RUB => 2033-05-25  │
│ 131    │ 6.084 mln RUB => 2028-11-13; 761.777 mln RUB => 2029-11-09   │
│ 132    │ 67.613 mln RUB => 2029-10-11; 639.206 mln RUB => 2031-05-08  │
│ 133    │ 222.791 mln RUB => 2035-02-01; 420.098 mln RUB => 2033-01-05 │
│ 134    │ 193.476 mln RUB => 2029-12-08; 240.862 mln RUB => 2028-12-26 │
│ 135    │ 280.998 mln RUB => 2030-09-20; 4.927 mln RUB => 2035-02-20   │
│ 136    │ 1.351 mln RUB => 2027-11-08; 0.230 mln RUB => 2028-02-09     │
│ 137    │ 3.701 mln RUB => 2028-05-31; 455.712 mln RUB => 2036-11-25   │
│ 138    │ 4.096 mln RUB => 2030-10-31; 1.517 mln RUB => 2030-05-31     │
└────────┴──────────────────────────────────────────────────────────────┘


id = doc["attrs"]["organization"]["id"]

doc = {...}
id = doc.get("attrs", {}).get("organization", {}).get("id")
