5.1 스키마의 테이블 목록 보기

CREATE DATABASE SMEAGOL;

select table_name
from information_schema.tables
where table_schema = 'study';

5.2 테이블의 열 나열하기

select column_name, data_type, ordinal_position
from information_schema.columns
where table_schema = 'study'
  and table_name = 'EMP';

5.3 테이블의 인덱싱된 열 나열하기

show index from EMP;

select a.name table_name,
    --    b.name index_name,
       d.name column_name,
       c.index_column_id
from sys.tables a,
    --  sys.indexes b,
     sys.index_columns c,
     sys.columns d
where true
--   and a.object_id = b.object_id
--   and b.object_id = c.object_id
--   and b.index_id = c.index_id
  and c.object_id = d.object_id
  and c.column_id = d.column_id
  and a.name = 'EMP';

5.4 테이블의 제약조건 나열하기

select a.table_name,
       a.constraint_name,
       b.column_name,
       a.constraint_type
from information_schema.table_constraints a,
     information_schema.key_column_usage b
where a.table_name = 'EMP'
  and a.table_schema = 'study'
  and a.table_name = b.table_name
  and a.table_schema = b.table_schema
  and a.constraint_name = b.constraint_name;


