
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

-- https://postgrespro.ru/docs/enterprise/18/plpython-util

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

ERROR:  ModuleNotFoundError: No module named 'np'
CONTEXT:  Traceback (most recent call last):
  PL/Python function "py_test3", line 2, in <module>
    import np
PL/Python function "py_test3"



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
