6.1 문자열 짚어보기

select substr(e.ename, iter.pos, 1) as C
from (select ename from EMP where ename = 'KING') e,
     (select id as pos from T10) iter
where iter.pos <= length(e.ename);

select ename, iter.pos
from (select ename from EMP where ename = 'KING') e,
     (select id as pos from T10) iter;

select ename, iter.pos
from (select ename from EMP where ename = 'KING') e,
     (select id as pos from T10) iter
where iter.pos <= length(e.ename);

select substr(e.ename, iter.pos) a,
       substr(e.ename, length(e.ename) - iter.pos + 1) b
from (select ename from EMP where ename = 'KING') e,
     (select id pos from T10) iter
where iter.pos <= length(e.ename);

6.2 문자열에 따옴표 포함하기

select 'g''day mate' qmarks from T1 union all
select 'beavers'' teeth' from T1 union all
select '''' from T1;

6.3 문자열에서 특정 문자의 발생 횟수 계산하기

select (length('10,CLARK,MANAGER') -
        length(replace('10,CLARK,MANAGER', ',', ''))) / length(',') as cnt
from T1;

select (length('HELLO HELLO') -
        length(replace('HELLO HELLO', 'LL', ''))) / length('LL') as correct_cnt,
       (length('HELLO HELLO') -
        length(replace('HELLO HELLO', 'LL', ''))) as incorrect_cnt
from T1;

6.4 문자열에서 원하지 않는 문자 제거하기

select ename,
       replace(
            replace(
                replace(
                    replace(
                        replace(ename, 'A', ''), 'E', ''), 'I', ''), 'O', ''), 'U', '')
                        as stripped1,
       sal,
       replace(sal, 0, '') stripped2
from EMP;

6.6 문자열의 영숫자 여부 확인하기

create view V as 
        select ename as data
        from EMP
        where deptno = 10
    union all
        select concat(ename, ', $', cast(sal as char(4)), '.00') as data
        from EMP
        where deptno = 20
    union all
        select concat(ename, cast(deptno as char(4))) as data
        from EMP
        where deptno = 30;

select data
from V
where data regexp '[^0-9a-zA-Z]' = 0;

6.7 이름에서 이니셜 추출하기

select case
        when cnt = 2 then
            trim(trailing '.' from
                concat_ws('.',
                    substr(substring_index(name, ' ', 1), 1, 1),
                    substr(name, length(substring_index(name, ' ', 1)) + 2, 1),
                    substr(substring_index(name, ' ', -1), 1, 1),
                    '.'))
        else
            trim(trailing '.' from
                concat_ws('.',
                    substr(substring_index(name, ' ', 1), 1, 1),
                    substr(substring_index(name, ' ', -1), 1, 1)
                    ))
        end as initials
from (
    select name, length(name) - length(replace(name, ' ', '')) as cnt
    from (
        select replace('Stewie Griffin Kim', '.', '') as name
        from T1
    ) y
) x;

select substr(substring_index(name, ' ', 1), 1, 1) as a,
       substr(substring_index(name, ' ', -1), 1, 1) as b
from (select 'Stewie Griffin' as name from T1) x;

6.8 문자열 일부를 정렬하기

select ename
from EMP
order by substr(ename, length(ename) - 1);

6.9 문자열의 숫자로 정렬하기

create view V as
    select concat(e.ename,
                  ' ',
                  cast(e.empno as char(4)),
                  ' ',
                  d.dname) as data
    from EMP e, DEPT d
    where e.deptno = d.deptno;

6.10 테이블 행으로 구분된 목록 만들기

select deptno,
       group_concat(ename order by empno separator ',') as emps
from EMP
group by deptno;

6.11 구분된 데이터를 다중값 in 목록으로 변환하기

select empno, ename, sal, deptno
from EMP
where empno in (
    select substring_index(
                substring_index(list.vals, ',', iter.pos), ',', -1) empno
    from (select id pos from T10) as iter,
         (select '7654,7698,7782,7788' as vals
          from T1) list
    where iter.pos <=
          (length(list.vals) - length(replace(list.vals, ',', ''))) + 1
);

6.12 문자열을 알파벳 순서로 정렬하기

select ename, group_concat(c order by c separator '')
from (select ename, substr(a.ename, iter.pos, 1) c
      from EMP a,
           (select id pos from T10) iter
      where iter.pos <= length(a.ename)
) x
group by ename;

6.13 숫자로 취급할 수 있는 문자열 식별하기

-- create view V as
--     select replace(mixed, ' ', '') as mixed
--     from (select concat(substr(ename, 1, 2),
--                         cast(deptno as char(4)),
--                         substr(ename, 3, 2)) as mixed
--           from EMP
--           where deptno = 10
--             union all
--           select cast(empno as char(4)) as mixed
--           from EMP
--           where deptno = 20
--             union all
--           select ename as mixed
--           from EMP
--           where deptno = 30
--     ) x;

create view V as
    select concat(substr(ename, 1, 2),
                  replace(cast(deptno as char(4)), ' ', ''),
                  substr(ename, 3, 2)) as mixed
    from EMP
    where deptno = 10
        union all
    select replace(cast(empno as char(4)), ' ', '')
    from EMP
    where deptno = 20
        union all
    select ename from EMP where deptno = 30
    ;

select cast(group_concat(c order by pos separator '') as unsigned) as MIXED1
from (select v.mixed, iter.pos, substr(v.mixed, iter.pos, 1) as c
      from V v,
           (select id pos from T10) iter
      where iter.pos <= length(v.mixed)
        and ascii(substr(v.mixed, iter.pos, 1)) between 48 and 57) y
group by mixed
order by 1;

글자 하나하나 살펴보기

select v.mixed, iter.pos, substr(v.mixed, iter.pos, 1) as C
from V v,
     (select id pos from T10) iter
where iter.pos <= length(v.mixed)
order by 1, 2;

문자를 개별적으로 평가하여 숫자가 있는 행만 유지

select v.mixed, iter.pos, substr(v.mixed, iter.pos, 1) as C
from V v,
     (select id pos from T10) iter
where iter.pos <= length(v.mixed)
  and ascii(substr(v.mixed, iter.pos, 1)) between 48 and 57
order by 1, 2;

6.14 n번째로 구분된 부분 문자열 추출하기

create view V as
    select 'mo,larry,curly' as name
    from T1
        union all
    select 'tina,gina,jaunita,regina,leena' as name
    from T1;

select name
from (select iter.pos,
             substring_index(substring_index(src.name, ',', iter.pos), ',', -1) name
      from V src,
           (select id pos from T10) iter
      where iter.pos <= length(src.name) - length(replace(src.name, ',', ''))) x
where pos = 2;

문자열 구분 기호 세어 각 문자열에 있는 값의 수 정할 수 있다.

select iter.pos, src.name
from (select id pos from T10) iter,
      V src
where iter.pos <= length(src.name) - length(replace(src.name, ',', ''));

select iter.pos,
       src.name name1,
       substring_index(src.name, ',', iter.pos) name2,
       substring_index(substring_index(src.name, ',', iter.pos), ',', -1) name3
from (select id pos from T10) iter,
      V src
where iter.pos <= length(src.name) - length(replace(src.name, ',', ''));

6.15 IP 주소 파싱하기

select substring_index(substring_index(y.ip, '.', 1), '.', -1) a,
       substring_index(substring_index(y.ip, '.', 2), '.', -1) b,
       substring_index(substring_index(y.ip, '.', 3), '.', -1) c,
       substring_index(substring_index(y.ip, '.', 4), '.', -1) d
from (select '92.111.0.2' as ip from T1) y;

6.16 소리로 문자열 비교하기

create table author_names (
    a_name varchar(20)
);

insert into author_names values
('Johnson'),
('Jonson'),
('Jonsen'),
('Jensen'),
('Johnsen'),
('Shakespeare'),
('Shakspear'),
('Shaekspir'),
('Shakespar');

select an1.a_name as name1, an2.a_name as name2, SOUNDEX(an1.a_name) as Soundex_Name
from author_names an1
    join author_names an2 on (SOUNDEX(an1.a_name) = SOUNDEX(an2.a_name)
                          and an1.a_name not like an2.a_name);

6.17 패턴과 일치하지 않는 텍스트 찾기

create table employee_comment (
    emp_id integer,
    text varchar(200)
);

insert into employee_comment values
(7369, '126 Varnum, Edmore MI 48829, 989 313-5351'),
(7499, '1105 McConnell Court Cedar Lake MI 48812 Home: 989-387-4321 Cell: (237) 438-3333');

select emp_id, text
from employee_comment
where regexp_like(text, '[0-9]{3}[-. ][0-9]{3}[-. ][0-9]{4}')
  and regexp_like(regexp_replace(text, '[0-9]{3}([-. ])[0-9]{3}\1[0-9]{4}', '***'),
                  '[0-9]{3}[-. ][0-9]{3}[-. ][0-9]{4}');