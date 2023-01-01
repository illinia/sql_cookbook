select count(1)
from 급여;

show index from 급여;

show index from 부서;

show index from 부서관리자;

# 4.2.1 기본 키를 변형하는 나쁜 SQL 문
explain
select *
from 사원
where substring(사원번호, 1, 4) = 1100
  and length(사원번호) = 5;

show index from 사원;

# 튜닝 후
explain
select *
from 사원
# where 사원번호 between 11000 and 11009;
where 사원번호 >= 11000 and 사원번호 <= 11009;


# 4.2.2 사용하지 않는 함수를 포함하는 나쁜 sql 문

# 튜닝 전
explain
select ifnull(성별, 'NO DATA') as 성별, count(1) 건수
from 사원
group by ifnull(성별, 'NO DATA');

desc 사원;

# 튜닝 후
explain
select 성별, count(1) 건수
from 사원
group by 성별;


# 4.2.3 형변환으로 인덱스를 활용하지 못하는 나쁜 sql 문

# 튜닝 전
explain
select count(1)
from 급여
where 사용여부 = 1;

# 튜닝 수행
explain
select 사용여부, count(1)
from 급여
group by 사용여부;

show index from 급여;

desc 급여;

# 튜닝 결과
explain
select count(1)
from 급여
where 사용여부 = '1';


# 4.2.4 열을 결합하여 사용하는

# 튜닝 전
explain
select *
from 사원
where concat(성별, ' ', 성) = 'M Radwan';

select concat(성별, ' ', 성) '성별_성', count(1)
from 사원
where concat(성별, ' ', 성) = 'M Radwan'

union all

select '전체 데이터', count(1)
from 사원
;

# 튜닝 결과
explain
select *
from 사원
where 성별 = 'M'
and 성 = 'Radwan';


# 4.2.5 습관적으로 중복을 제거하는

# 튜닝 전
explain
select distinct 사원.사원번호, 사원.이름, 사원.성, 부서관리자.부서번호
from 사원
join 부서관리자 on (사원.사원번호 = 부서관리자.사원번호);

# 튜닝 결과
explain
select 사원.사원번호, 이름, 성, 부서번호
from 사원
join 부서관리자 on (사원.사원번호 = 부서관리자.사원번호);

# 4.2.6 다수 쿼리를 union 연산자로만 합치는

# 튜닝 전
explain
select 'M' as 성별, 사원번호
from 사원
where 성별 = 'M'
and 성 = 'Baba'

union

select 'F' as 성별, 사원번호
from 사원
where 성별 = 'F'
and 성 = 'Baba';

# 튜닝 후
explain
select 'M' as 성별, 사원번호
from 사원
where 성별 = 'M'
and 성 = 'Baba'

union all

select 'F' as 성별, 사원번호
from 사원
where 성별 = 'F'
and 성 = 'Baba';

# 4.2.7 인덱스 고려 없이 열을 사용하는

# 튜닝 전
explain
select 성, 성별, count(1) as 카운트
from 사원
group by 성, 성별;

# 튜닝 결과
explain
select 성, 성별, count(1) as 카운트
from 사원
group by 성별, 성;

# 4.2.8 엉뚱한 인덱스를 사용하는

# 튜닝 전
explain
select 사원번호
from 사원
where 입사일자 like '1989%'
and 사원번호 > 100000;

show index from 사원;

select count(1)
from 사원
;

select count(1)
from 사원
where 입사일자 like '1989%';

select count(1)
from 사원
where 사원번호 > 100000;

# 튜닝 수행
explain
select 사원번호
from 사원 use index (I_입사일자)
where 입사일자 Like '1989%'
and 사원번호 > 100000;

explain
select 사원번호
from 사원
where 입사일자 >= '1989-01-01' and 입사일자 < '1990-01-01'
and 사원번호 > 100000;

# 4.2.9 동등 조건으로 인덱스를 사용하는

# 튜닝 전
explain
select *
from 사원출입기록
where 출입문 = 'B';

select 출입문, count(1)
from 사원출입기록
group by 출입문;

# 튜닝 결과
explain
select *
from 사원출입기록 ignore index(I_출입문)
where 출입문 = 'B';