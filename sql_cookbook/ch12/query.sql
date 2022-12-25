12. 결과셋을 하나의 행으로 피벗하기

select sum(case when deptno = 10 then 1 else 0 end) as deptno_10,
       sum(case when deptno = 20 then 1 else 0 end) as deptno_20,
       sum(case when deptno = 30 then 1 else 0 end) as deptno_30
from EMP;


12.2 결과셋을 여러 행으로 피벗하기

select max(case when job='CLERK'
                then ename else null end) as clerks,
       max(case when job='ANALYST'
                then ename else null end) as analysts,
       max(case when job='MANAGER'
                then ename else null end) as mgrs,
       max(case when job='PRESIDENT'
                then ename else null end) as prez,
       max(case when job='SALESMAN'
                then ename else null end) as sales
from (
    select job,
        ename, 
        row_number() over(partition by job order by ename) rn
    from EMP
) x
group by rn;


12.3 결과셋 역피벗하기

create view emp_cnts as
(
    select sum(case when deptno = 10 then 1 else 0 end) as deptno_10,
        sum(case when deptno = 20 then 1 else 0 end) as deptno_20,
        sum(case when deptno = 30 then 1 else 0 end) as deptno_30
    from EMP
);

select dept.deptno,
       case dept.deptno
            when 10 then emp_cnts.deptno_10
            when 20 then emp_cnts.deptno_20
            when 30 then emp_cnts.deptno_30
       end as counts_by_dept
from emp_cnts cross join
    (select deptno from DEPT where deptno <= 30) dept;