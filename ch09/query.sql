9.1 연도의 윤년 여부 결정

select day(
        last_day(
            date_add(
                date_add(
                    date_add(current_date, interval -dayofyear(current_date) day),
                    interval 1 day
                ),
                interval 1 month
            )
        )
) dy
from T1;

9.2 연도의 날짜 수 알아내기

select datediff((curr_year + interval 1 year), curr_year)
from (
    select adddate(current_date, -dayofyear(current_date) + 1) curr_year
    from T1
) x;

9.3 날짜에서 시간 단위 추출하기

select date_format(current_timestamp, '%k') hr,
       date_format(current_timestamp, '%i') min,
       date_format(current_timestamp, '%s') sec,
       date_format(current_timestamp, '%d') dy,
       date_format(current_timestamp, '%m') mon,
       date_format(current_timestamp, '%Y') yr
from T1;

9.4 월의 첫 번째 요일과 마지막 요일 알아내기

select date_add(current_date,
                interval -day(current_date) + 1 day) firstday,
                last_day(current_date) lastday
from T1;

9.5 연도의 특정 요일의 모든 날짜 알아내기

with recursive cal (dy, yr) as (
    select dy, extract(year from dy) as yr
    from (select adddate(
                    adddate(current_date, interval - dayofyear(current_date) day),
                    interval 1 day) as dy
    ) as tmp1
        union all
    select date_add(dy, interval 1 day), yr
    from cal
    where extract(year from date_add(dy, interval 1 day)) = yr
)

select dy from cal
where dayofweek(dy) = 6;

select adddate(
        adddate(current_date, interval - dayofyear(current_date) day),
        interval 1 day) dy
from T1;

with cal (dy) as
(select current
    union all
select dy +)

9.6 월의 특정 요일의 첫 번째 및 마지막 발생일 알아내기

select first_monday,
       case month(adddate(first_monday, 28))
            when mth then adddate(first_monday, 28)
                     else adddate(first_monday, 21)
       end last_monday
from (select case sign(dayofweek(dy) - 2)
                  when 0 then dy
                  when -1 then adddate(dy, abs(dayofweek(dy) - 2))
                  when 1 then adddate(dy, (7 - (dayofweek(dy) - 2)))
             end first_monday,
             mth
      from (select adddate(adddate(current_date, -day(current_date)), 1) dy,
                   month(current_date) mth
            from T1
      )x
) y;

9.8 해당 연도의 분기 시작일 및 종료일 나열하기

with recursive x (dy, cnt) as (
    select adddate(current_date, (-dayofyear(current_date)) + 1) dy,
           id
    from T1
        union all
    select adddate(dy, interval 3 month), cnt + 1
    from x
    where cnt + 1 <= 4\

)
select quarter(adddate(dy, -1)) QTR,
       date_add(dy, interval -3 month) Q_start,
       adddate(dy, -1) Q_end
from x
order by 1;

9.9 지정 분기의 시작일 및 종료일 알아내기

select date_add(
        adddate(q_end, -day(q_end) + 1),
                interval -2 month) q_start,
        q_end
from (
    -- select last_day(
    --             str_to_date(concat(substr(yrq,1,4), mod(yrq, 10) * 3), '%Y%m')) q_end
    -- select str_to_date(concat(substr(yrq,1,4), mod(yrq, 10) * 3), '%Y%m')
    select concat(substr(yrq,1,4), mod(yrq, 10) * 3)
    from (
        select 20051 as yrq from T1 union all
        select 20052 as yrq from T1 union all
        select 20053 as yrq from T1 union all
        select 20054 as yrq from T1
    ) x
) y;

9.10 누락된 날짜 채우기

select distinct extract(year from hiredate) as year
from EMP;

with recursive x (start_date, end_date) as
(
    select adddate(min(hiredate), -dayofyear(min(hiredate)) + 1) start_date
          ,adddate(max(hiredate), -dayofyear(max(hiredate)) + 1) end_date
    from EMP
union all
    select date_add(start_date, interval 1 month),
           end_date
    from x
    where date_add(start_date, interval 1 month) < end_date
)

select x.start_date mth, count(e.hiredate) num_hired
from x
    left join EMP e on (extract(year_month from start_date) = extract(year_month from e.hiredate))
group by x.start_date
order by 1;


with recursive x (start_date, end_date) as
(
    select adddate(min(hiredate), -dayofyear(min(hiredate)) + 1) start_date,
           adddate(max(hiredate), -dayofyear(max(hiredate)) + 1) end_date
    from EMP
union all
    select date_add(start_date, interval 1 month),
           end_date
    from x
    where date_add(start_date, interval 1 month) < end_date
)

select * from x;


9.11 특정 시간 단위 검색하기

select ename
from EMP
where monthname(hiredate) in ('February','December')
      or dayname(hiredate) = 'Tuesday';


9.12 날짜의 특정 부분으로 레코드 비교하기

select concat(a.ename, ' was hired on the same month and weekday as ', b.ename) msg
from EMP a, EMP b
where date_format(a.hiredate, '%w%M') = date_format(b.hiredate, '%w%M')
      and a.empno < b.empno
order by a.ename;

9.13 중복 날짜 범위 식별하기

select a.empno, a.ename,
       concat('project ', b.proj_id, ' overlaps project ', a.proj_id) as msg
from emp_project a,
     emp_project b
where a.empno = b.empno
  and b.proj_start >= a.proj_start
  and b.proj_start <= a.proj_end
  and a.proj_id != b.proj_id;