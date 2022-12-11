7.1 평균 계산하기

select avg(sal) as avg_sal
from EMP;

select deptno, avg(sal) as avg_sal
from EMP
group by deptno;

create table t2(sal integer);

insert into t2 values (10), (20), (null);

select avg(sal) from t2;
select distinct 30/2 from t2;

select avg(coalesce(sal, 0)) from t2;
select distinct 30/3 from t2;

select avg(sal) from EMP group by deptno;

7.2 열에서 최댓값, 최솟값 찾기

select min(sal) as min_sal, max(sal) as max_sal
from EMP;

select deptno, min(sal) as min_sal, max(sal) as max_sal
from EMP
group by deptno;

select deptno, comm
from EMP
where deptno in (10, 30)
order by 1;

select min(comm), max(comm)
from EMP;

select deptno, min(comm), max(comm)
from EMP
group by deptno;

select min(comm), max(comm)
from EMP
group by deptno;

7.3 열의 값 집계하기

select sum(sal) from EMP;

select deptno, sum(sal) as total_for_dept
from EMP
group by deptno;

select deptno, comm 
from EMP 
where deptno in (10, 30) 
order by 1;

select sum(comm) 
from EMP;

select deptno, sum(comm) 
from EMP 
where deptno in (10, 30) 
group by deptno;

7.4 테이블의 행 수 계산하기

select count(*) from EMP;

select deptno, count(*)
from EMP
group by deptno;

select count(*), count(deptno), count(comm), count('hello')
from EMP;

select deptno, count(*), count(deptno), count(comm), count('hello')
from EMP
group by deptno;

select count(*) 
from EMP 
group by deptno;

7.5 열의 값 세어보기

select count(comm) from EMP;

7.6 누계 생성하기

select ename, sal, sum(sal) over (order by sal, empno) as running_total
from EMP 
order by 2;

select ename, sal,
       sum(sal) over (order by sal, empno) as running_total1,
       sum(sal) over (order by sal) as running_total2
from EMP 
order by 2;

7.7 누적곱 생성하기

select empno, ename, sal,
       exp(sum(ln(sal)) over (order by sal, empno)) as running_prod
from EMP
where deptno = 10;

7.8 일련의 값 평활화하기

create table sales (
    date1 date,
    sales integer
);

insert into sales values
('2020-01-01', 647),
('2020-01-02', 561),
('2020-01-03', 741),
('2020-01-04', 978),
('2020-01-05', 1062),
('2020-01-06', 1072),
('2020-01-07', 805),
('2020-01-08', 662),
('2020-01-09', 1083),
('2020-01-10', 970);

select date1, sales,
       lag(sales, 1) over (order by date1) as salesLagOne,
       lag(sales, 2) over (order by date1) as salesLagTwo,
       (sales + (lag(sales, 1) over (order by date1)) + lag(sales, 2) over (order by date1)) / 3 as MovingAverage
from sales;

7.9 최빈값 계산하기

select sal from EMP
where deptno = 20
order by sal;

select sal
from ( select sal, dense_rank() over(order by cnt desc) as rnk
       from (select sal, count(*) as cnt
             from EMP
             where deptno = 20
             group by sal) x
) y
where rnk = 1;

7.10 중앙값 계산하기

select sal from EMP
where deptno = 20
order by sal;

with rank_tab (sal, rank_sal) as (
    select sal, cume_dist() over (order by sal)
    from EMP
    where deptno = 20
),
inter as (
    select sal, rank_sal from rank_tab
    where rank_sal >= 0.5
union
    select sal, rank_sal from rank_tab
    where rank_sal <= 0.5
)

select avg(sal) as MedianSal
from inter;

7.11 총계에서의 백분율 알아내기

select (sum(case when deptno = 10 then sal end)/sum(sal)) * 100 as pct
from EMP;

select sum(case when deptno = 10 then sal end) as d10,
       sum(sal)
from EMP;

7.12 null 허용 열 집계하기

select avg(coalesce(comm, 0)) as avg_comm
from EMP
where deptno = 30;

select avg(comm)
from EMP
where deptno = 30;

7.13 최댓값과 최솟값을 배제한 평균 계산하기

select avg(sal)
from EMP
where sal not in ((select min(sal) from EMP),
                  (select max(sal) from EMP));

select (sum(sal) - min(sal) - max(sal))/(count(*) - 2)
from EMP;

7.15 누계에서 값 변경하기

create view V (id, amt, trx) as
select 1, 100, 'PR' from T1 union all
select 2, 100, 'PR' from T1 union all
select 3, 50, 'PY' from T1 union all
select 4, 100, 'PR' from T1 union all
select 5, 200, 'PY' from T1 union all
select 6, 50, 'PY' from T1;

select id, case when trx = 'PY'
            then 'PAYMENT'
            else 'PURCHASE'
        end trx_type,
        amt,
        sum(case when trx = 'PY'
            then -amt else amt
            end) over (order by id, amt) as balance
from V;

