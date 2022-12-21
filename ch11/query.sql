11.1 결과셋을 페이지로 매기기

select sal
from (select row_number() over(order by sal) as rn,
             sal
      from EMP) x
where rn between 1 and 5;


11.2 테이블에서 n개 행 건너뛰기

select ename
from (select row_number() over (order by ename) rn,
             ename
      from EMP) x
where mod(rn, 2) = 1;

11.3 외부 조인을 사용할 때 OR 로직 통합하기

select e.ename, d.deptno, d.dname, d.loc
from DEPT d
    left join EMP e on (d.deptno = e.deptno and (e.deptno = 10 or e.deptno = 20))
order by 2;


select e.ename, d.deptno, d.dname, d.loc
from DEPT d
    left join (select ename, deptno
               from EMP
               where deptno in (10, 20)) e on (e.deptno = d.deptno)
order by 2;

11.4 역수 행 확인하기

create view V (TEST1, TEST2) as (
    select 20, 20 union all
    select 50, 25 union all
    select 20, 20 union all
    select 60, 30 union all
    select 70, 90 union all
    select 80, 130 union all
    select 90, 70 union all
    select 100, 50 union all
    select 110, 55 union all
    select 120, 60 union all
    select 130, 80 union all
    select 140, 70
);


select distinct v1.*
from V v1, V v2
where v1.test1 = v2.test2
  and v1.test2 = v2.test1
  and v1.test1 <= v1.test2;


11.5 상위 n개 레코드 선택하기

select ename, sal
from (select ename, sal, dense_rank() over (order by sal desc) dr
      from EMP) x
where dr <= 5;


11.6 최댓값과 최솟값을 가진 레코드 찾기

select ename
from (select ename, sal, min(sal) over() min_sal,
                         max(sal) over() max_sal
      from EMP) x
where sal in (min_sal, max_sal);


11.7 이후 행 조사하기

select ename, sal, hiredate
from (select ename, sal, hiredate, lead(sal) over (order by hiredate) next_sal
      from EMP) alias
where sal < next_sal;


11.8 행 값 이동하기

select ename, sal,
       coalesce(lead(sal) over (order by sal), min(sal) over()) forward,
       coalesce(lag(sal) over (order by sal), max(sal) over()) rewind
from EMP;

11.9 순위 결과

select dense_rank() over(order by sal) rnk, sal
from EMP;

11.10 중복 방지하기

select job
from (select job, row_number() over(partition by job order by job) rn
      from EMP) x
where rn = 1;

11.11 기사값 찾기

select deptno, ename, sal, hiredate,
       max(latest_sal) over (partition by deptno) latest_sal
from (select deptno, ename, sal, hiredate, case when hiredate = max(hiredate) over(partition by deptno)
                                                then sal
                                                else 0
                                           end latest_sal
      from EMP) x
order by 1, 4 desc;


11.12 간단한 예측 생성하기

with recursive nrows(n) as (
      select 1 from T1 union all
      select n + 1 from nrows where n + 1 <= 3
)
select id,
       order_date,
       process_date,
       case when nrows.n >= 2
            then process_date + 1
            else null
       end as verified,
       case when nrows.n = 3
            then process_date + 2
            else null
       end as shipped
from (select nrows.n id,
             getdate() + nrows.n as order_date,
             getdate() + nrows.n + 2 as process_date
      from nrows) orders, nrows
order by 1;