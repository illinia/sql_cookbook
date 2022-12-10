2.1 지정한 순서대로 쿼리 결과 반환하기

select ename, job, sal
from EMP
where deptno = 10
order by sal asc;

select ename, job, sal
from EMP
where deptno = 10
order by 3 desc;

2.2 다중 필드로 정렬하기

select empno, deptno, sal, ename, job
from EMP
order by deptno, sal desc;

2.3 부분 문자열로 정렬하기

select ename, job
from EMP
order by substr(job, length(job) - 1);

2.5 정렬할 때 null 처리하기

null 이 아닌 comm 을 우선 오름차순 정렬하고, 모든 Null 은 마지막에 나타냄

select ename, sal, ifnull(comm, '')
from (
    select ename, sal, comm,
        case when comm is null then 0 else 1 end as is_null
    from EMP
) x
order by is_null desc, comm;

null 이 아닌 comm 을 우선 내림차순 정렬하고, 모든 null 은 마지막에 나타냄

select ename, sal, ifnull(comm, '')
from (
    select ename, sal, comm,
        case when comm is null then 0 else 1 end as is_null
    from EMP
) x
order by is_null desc, comm desc;

null 을 처음에 나타낸 후, null 이 아닌 comm 은 오름차순 정렬

select ename, sal, ifnull(comm, '')
from (
    select ename, sal, comm,
        case when comm is null then 0 else 1 end as is_null
    from EMP
) x
order by is_null, comm;

2.6 데이터 종속 키 기준으로 정렬하기

select ename, sal, job, comm
from EMP
order by case when job = 'SALESMAN' then comm else sal end;

select ename, sal, job, comm,
    case when job = 'SALESMAN' then comm else sal end as ordered
from EMP
order by 5;