10.1 연속 값의 범위 찾기

create view V (proj_id, proj_start, proj_end) as
select 1, '01-JAN-2020', '02-JAN-2020' union all
select 2, '02-JAN-2020', '03-JAN-2020' union all
select 3, '03-JAN-2020', '04-JAN-2020' union all
select 4, '04-JAN-2020', '05-JAN-2020' union all
select 5, '06-JAN-2020', '07-JAN-2020' union all
select 6, '16-JAN-2020', '17-JAN-2020' union all
select 7, '17-JAN-2020', '18-JAN-2020' union all
select 8, '18-JAN-2020', '19-JAN-2020' union all
select 9, '19-JAN-2020', '20-JAN-2020' union all
select 10, '21-JAN-2020', '22-JAN-2020' union all
select 11, '26-JAN-2020', '27-JAN-2020' union all
select 12, '27-JAN-2020', '28-JAN-2020' union all
select 13, '28-JAN-2020', '29-JAN-2020' union all
select 14, '29-JAN-2020', '30-JAN-2020';

select proj_id, proj_start, proj_end
from (select proj_id, proj_start, proj_end,
             lead(proj_start) over(order by proj_id) next_proj_start
      from V) alias
where next_proj_start = proj_end;
      

select *
from (select proj_id, proj_start, proj_end,
             lead(proj_start) over(order by proj_id) next_proj_start
      from V) x
where proj_id in (1, 4);


select proj_id, proj_start, proj_end
from (select proj_id, proj_start, proj_end,
             lead(proj_start) over (order by proj_id) next_start,
             lag(proj_end) over (order by proj_id) last_end
      from V
      where proj_id <= 5) x
where proj_end = next_start
   or proj_start = last_end;


10.2 같은 그룹 또는 파티션의 행 간 차이 찾기

with next_sal_tab (deptno, ename, sal, hiredate, next_sal) as
(
      select deptno, ename, sal, hiredate,
             lead(sal) over (partition by deptno order by hiredate) as next_sal
      from EMP
)

select deptno, ename, sal, hiredate,
       coalesce(cast(next_sal as char), 'N/A') as diff
from next_sal_tab;


select deptno, ename, sal, hiredate, next_sal diff
from (
      select deptno, ename, sal, hiredate,
             lead(sal) over (partition by deptno order by hiredate) as next_sal
      from EMP
) x;

10.3 연속 값 범위의 시작과 끝 찾기

select proj_grp, min(proj_start), max(proj_end)
from (select proj_id, proj_start, proj_end,
             sum(flag) over (order by proj_id) proj_grp
      from (select proj_id, proj_start, proj_end,
                   case when lag(proj_end) over (order by proj_id) = proj_start
                              then 0 else 1
                   end flag
            from V) alias1
) alias2
group by proj_grp;


select proj_id, proj_start, proj_end,
       lag(proj_end) over (order by proj_id) prior_proj_end
from V;

select proj_id, proj_start, proj_end, flag,
       sum(flag) over (order by proj_id) proj_grp
from (select proj_id, proj_start, proj_end,
             case when lag(proj_end) over (order by proj_id) = proj_start
                  then 0 else 1
             end flag
      from V
) x;

10.4 값 범위에서 누락된 값 채우기

select y.yr, coalesce(x.cnt, 0) as cnt
from (select min_year - mod(cast(min_year as signed), 10) + rn as yr
      from (select (select min(extract(year from hiredate))
                    from EMP) as min_year,
            id - 1 as rn
            from T10) a
) y
left join (select extract(year from hiredate) as yr, count(*) as cnt
           from EMP
           group by extract(year from hiredate)) x on (y.yr = x.yr)
