1.2 테이블에서 행의 하위 집합 검색하기

select * 
from EMP 
where deptno = 10;

1.3 여러 조건을 충족하는 행 찾기

SELECT *
FROM EMP
WHERE deptno = 10 or comm is not null or sal <= 2000 
    and deptno = 20;

select *
from EMP
where ( deptno = 10 or comm is not null or sal <= 2000 )
    and deptno = 20;

1.4 테이블에서 열의 하위 집합 검색하기

select ename, deptno, sal
from EMP;

1.5 열에 의미 있는 이름 지정하기

select sal as salary, comm as commission
from EMP;

1.6 WHERE 절에서 별칭이 지정된 열 참조하기

select *
from (
    select sal as salary, comm as commission
    from EMP
) x
where salary < 5000;

1.7 열 값 이어 붙이기

select concat(ename, ' WORKS AS A ', job) as msg
from EMP
where deptno = 10;

1.8 SELECT 문에서 조건식 사용하기

select ename, sal,
    case when sal <= 2000 then 'UNDERPAID'
        when sal >= 4000 then 'OVERPAID'
        else 'OK'
    end as status
from EMP;

1.9 반환되는 행 수 제한하기

select *
from EMP
limit 5;

1.10 테이블에서 n개의 무작위 레코드 반환하기

select ename, job
from EMP
order by rand()
limit 5;

1.11 null 값 찾기

select *
from EMP
where comm is null;

1.12 null 을 실젯값으로 변환하기

select coalesce(comm, 0)
from EMP;

1.13 패턴 검색하기

select ename, job
from EMP
where deptno in (10, 20)
    and (ename like '%I%' or job like '%ER');