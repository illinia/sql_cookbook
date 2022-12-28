show variables like 'c%';


select count(1)
from 사원;

explain
select *
from 사원
where 사원번호 between 10001 and 20000;

# 3.2.2 기본 실행 계획 항목 분석
# id
explain
select 사원.사원번호,
       사원.이름,
       사원.성,
       급여.연봉,
       (select max(부서번호)
        from 부서사원_매핑 as 매핑
        where 매핑.사원번호 = 사원.사원번호) 카운트
from 사원,
     급여
where 사원.사원번호 = 10001
  and 사원.사원번호 = 급여.사원번호;


# select_type
# SIMPLE
explain
select *
from 사원
where 사원번호 = 100000;

explain
select 사원.사원번호, 사원.이름, 사원.성, 급여.연봉
from 사원,
     (select 사원번호, 연봉
      from 급여
      where 연봉 > 80000) as 급여
where 사원.사원번호 = 급여.사원번호
  and 사원.사원번호 between 10001 and 10010;

# PRIMARY

explain
select 사원.사원번호,
       사원.이름,
       사원.성,
       (select max(부서번호)
        from 부서사원_매핑 as 매핑
        where 매핑.사원번호 = 사원.사원번호) 카운트
from 사원
where 사원.사원번호 = 10001;

explain
select 사원1.사원번호, 사원1.이름, 사원1.성
from 사원 as 사원1
where 사원1.사원번호 = 100001
union all
select 사원2.사원번호, 사원2.이름, 사원2.성
from 사원 as 사원2
where 사원2.사원번호 = 100001;

# SUBQUERY

explain
select (select count(*)
        from 부서사원_매핑 as 매핑) as 카운트,
       (select max(연봉)
        from 급여)            as 급여;

# DERIVED

explain
select 사원.사원번호, 급여.연봉
from 사원,
     (select 사원번호, max(연봉) as 연봉
      from 급여
      where 사원번호 between 10001 and 20000) as 급여
where 사원.사원번호 = 급여.사원번호;


SET SESSION sql_mode = 'NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES';

# UNION RESULT

explain
select 사원_통합.*
from (select max(입사일자) as 입사일자
      from 사원 as 사원1
      where 성별 = 'M'
      union
      select min(입사일자) as 입사일자
      from 사원 as 사원2
      where 성별 = 'M') as 사원_통합;

# DEPENDENT SUBQUERY

explain
select 관리자.부서번호,
       (select 사원1.이름
        from 사원 as 사원1
        where 성별 = 'F'
          and 사원1.사원번호 = 관리자.사원번호

        union all

        select 사원2.이름
        from 사원 as 사원2
        where 성별 = 'M'
          and 사원2.사원번호 = 관리자.사원번호) as 이름
from 부서관리자 as 관리자;


# UNCACHEABLE SUBQUERY

explain
select *
from 사원
where 사원번호 = (select round(rand() * 1000000));


# MATERIALIZED

explain
select *
from 사원
where 사원번호 in (select 사원번호 from 급여 where 시작일자 < '2020-01-01');


# table

explain
select 사원.사원번호, 급여.연봉
from 사원,
     (select 사원번호, max(연봉) as 연봉
      from 급여
      where 사원번호 between 10001 and 20000) as 급여
where 사원.사원번호 = 급여.사원번호;

# type
# const
explain
select *
from 사원
where 사원번호 = 10001;

# eq_ref
explain
select 매핑.사원번호, 부서.부서번호, 부서.부서명
from 부서사원_매핑 as 매핑,
     부서
where 매핑.부서번호 = 부서.부서번호
  and 매핑.사원번호 between 10001 and 10010;


# ref
explain
select 사원.사원번호, 직급.직급명
from 사원,
     직급
where 사원.사원번호 = 직급.사원번호
  and 사원.사원번호 between 10001 and 10100;

explain
select *
from 사원
where 입사일자 = '1985-11-21';


# ref_or_null

explain
select *
from 사원출입기록
where 출입문 is null or 출입문 = 'A';


# range

explain
select *
from 사원
where 사원번호 between 10001 and 100000;


# index_merge

explain
select *
from 사원
where 사원번호 between 10001 and 100000
and 입사일자 = '1985-11-21';


# index

explain
select 사원번호
from 직급
where 직급명 = 'Manager';


# all

explain
select * from 사원;


# key

explain
select 사원번호
from 직급
where 직급명 = 'Manager';

explain
select * from 사원;


# key_len

explain
select 사원번호
from 직급
where 직급명 = 'Manager';


# ref

explain
select 사원.사원번호, 직급.직급명
from 사원, 직급
where 사원.사원번호 = 직급.사원번호
and 사원.사원번호 between 10001 and 10100;


# Using index

explain
select 직급명
from 직급
where 사원번호 = 100000;

# 3.2.4 확장된 실행 계획 수행

# format = traditional
explain format = traditional
select *
from 사원
where 사원번호 between 100001 and 200000;

# format = json
explain format = json
select *
from 사원
where 사원번호 between 100001 and 200000;

# explain analyze
explain analyze
select *
from 사원
where 사원번호 between 100001 and 200000;


# 3.3 프로파일링
# 3.3.1 SQL 프로파일링 실행하기

show variables like 'profiling%';

set profiling = 'ON';

select 사원번호
from 사원
where 사원번호 = 100000;

show profiles;

show profile for query 1;

show profile all for query 1;

show profile cpu for query 140;