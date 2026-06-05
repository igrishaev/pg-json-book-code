

drop index if exists idx_applications_application_id;

alter table applications add constraint ctr_doc_application_id_nn
check (doc->'application_id' is not null);

insert into applications (doc) values (
  '{"test": "abc"}'
);

-- ERROR:  new row for relation "applications" violates check constraint "ctr_doc_application_id_nn"
-- DETAIL:  Failing row contains (b6edce9d-285f-4df0-9bba-5f65d390608a, {"test": "abc"}, 2026-06-05 17:49:33.757553+03, null).



alter table applications add constraint ctr_doc_application_id_int
check ((doc->>'application_id')::int is not null);

insert into applications (doc) values (
  '{"application_id": "abc"}'
);

-- ERROR: cannot cast jsonb string to type integer

create table post_tags(
    post_id integer not null,
    tag_id integer not null,
    created_at timestamptz not null default current_timestamp,
    unique (post_id, tag_id)
);

insert into post_tags (post_id, tag_id)
values (100, 10);

insert into post_tags (post_id, tag_id)
values (100, 10);

-- ERROR:  duplicate key value violates unique constraint "post_tags_post_id_tag_id_key"
-- DETAIL:  Key (post_id, tag_id)=(100, 10) already exists.


create unique index idx_doc_application_id_u
on applications (((doc->>'application_id')::int));

-- cannot cast jsonb string to type integer

delete from applications
where doc @@ '$.application_id.type() != "number" ';

-- DELETE 1

alter table applications drop constraint ctr_doc_application_id_nn;

insert into applications (doc) values (
  '{"test": "abc"}'
);


drop index idx_doc_application_id_u;

create unique index idx_doc_application_id_u
on applications (((doc->>'application_id')::int))
nulls not distinct;

insert into applications (doc) values (
  '{"test": "abc"}'
);

-- ERROR:  duplicate key value violates unique constraint "idx_doc_application_id_u"
-- DETAIL:  Key (((doc->>'application_id'::text)::integer))=(null) already exists.

create or replace function get_year(ts_field jsonb)
returns integer
language sql immutable strict parallel safe
return extract(year from ((ts_field->>0)::timestamp));

create unique index idx_doc_app_id_date_u
on applications (
    ((doc->>'application_id')::int),
    (get_year(doc->'created_at'))
);

drop index idx_doc_application_id_u;

insert into applications (doc) values (
  '{"application_id": "10001111", "created_at": "2026-06-05T15:33:55Z"}'
);

insert into applications (doc) values (
  '{"application_id": "10001111", "created_at": "2027-06-05T15:33:55Z"}'
);

insert into applications (doc) values (
  '{"application_id": "10001111", "created_at": "2026-12-05T15:33:55Z"}'
);

-- ERROR:  duplicate key value violates unique constraint "idx_doc_app_id_date_u"
-- DETAIL:  Key (((doc ->> 'application_id'::text)::integer), get_year(doc -> 'created_at'::text))=(10001111, 2026) already exists.

explain analyze
select id from applications
where ((doc->>'application_id')::int) between 100 and 200;

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                             QUERY PLAN                                                              │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Bitmap Heap Scan on applications  (cost=107.67..17971.46 rows=5000 width=16) (actual time=0.053..0.120 rows=101 loops=1)            │
│   Recheck Cond: ((((doc ->> 'application_id'::text))::integer >= 100) AND (((doc ->> 'application_id'::text))::integer <= 200))     │
│   Heap Blocks: exact=26                                                                                                             │
│   ->  Bitmap Index Scan on idx_doc_app_id_date_u  (cost=0.00..106.42 rows=5000 width=0) (actual time=0.041..0.041 rows=101 loops=1) │
│         Index Cond: ((((doc ->> 'application_id'::text))::integer >= 100) AND (((doc ->> 'application_id'::text))::integer <= 200)) │
│ Planning Time: 0.290 ms                                                                                                             │
│ Execution Time: 0.163 ms                                                                                                            │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
