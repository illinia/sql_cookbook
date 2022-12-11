8.1 일, 월, 연도 가감하기

select hiredate - interval 5 day as hd_minus_5D,
       hiredate + interval 5 day as hd_plus_5D,
       hiredate - interval 5 month as hd_minus_5M,
       hiredate + interval 5 month as hd_plus_5M,
       hiredate - interval 5 year as hd_minus_5Y,
       hiredate + interval 5 year as hd_plus_5Y
from EMP
where deptno = 10;

select date_sub(hiredate, interval 5 day) as hd_minus_5D,
       date_add(hiredate, interval 5 day) as hd_plus_5D,
       date_sub(hiredate, interval 5 month) as hd_minus_5M,
       date_add(hiredate, interval 5 month) as hd_plus_5M,
       date_sub(hiredate, interval 5 year) as hd_minus_5Y,
       date_add(hiredate, interval 5 year) as hd_plus_5Y
from EMP
where deptno = 10;

8.2 두 날짜 사이의 일수 알아내기

select datediff(ward_hd, allen_hd)
from (select hiredate as ward_hd
      from EMP
      where ename = 'WARD') x,
     (select hiredate as allen_hd
      from EMP
      where ename = 'ALLEN') y;

8.3 두 날짜 사이의 영업일수 알아내기

select sum(case when date_format(date_add(jones_hd, interval T100.id - 1 day), '%a')
                in ('Sat', 'Sun')
                then 0 else 1
            end) as days
from (select max(case when ename = 'BLAKE' then hiredate end) as blake_hd,
             max(case when ename = 'JONES' then hiredate end) as jones_hd
      from EMP
      where ename in ('BLAKE', 'JONES')
) x, T100
where T100.id <= datediff(blake_hd, jones_hd) + 1;

max 함수의 사용 이유는 하나의 행을 반환하고 null 제거하기 위해

select case when ename = 'BLAKE'
            then hiredate
            end as blake_hd,
       case when ename = 'JONES'
            then hiredate
            end as jones_hd
from EMP
where ename in ('BLAKE', 'JONES');

8.4 두 날짜 사이의 월 또는 년 수 알아내기

select mnth, mnth/12
from (select (year(max_hd) - year(min_hd)) * 12 +
             (month(max_hd) - month(min_hd)) as mnth
      from (select min(hiredate) as min_hd, max(hiredate) as max_hd
            from EMP
      ) x
) y;

select min(hiredate) as min_hd,
       max(hiredate) as max_hd
from EMP;

select year(max_hd) as max_yr, year(min_hd) as min_yr,
       month(max_hd) as max_mon, month(min_hd) as min_mon
from (select min(hiredate) as min_hd,
             max(hiredate) as max_hd
      from EMP
) x;

8.5 두 날짜 사이의 시, 분, 초 알아내기

select datediff(ward_hd, allen_hd),
       datediff(ward_hd, allen_hd) * 24 hr,
       datediff(ward_hd, allen_hd) * 24 * 60 min,
       datediff(ward_hd, allen_hd) * 24 * 60 * 60 sec
from (select max(case when ename = 'WARD' then hiredate
                      end) as ward_hd,
             max(case when ename = 'ALLEN' then hiredate
                      end) as allen_hd
      from EMP
) x;

8.6 1년 중 평일 발생 횟수 계산하기

select date_format(
            date_add(
                cast(concat(year(current_date), '-01-01') as date),
                interval T500.id - 1 day), '%W') day,
       count(*)
from T500
where T500.id <= datediff(
    cast(concat(year(current_date) + 1, '-01-01') as date),
    cast(concat(year(current_date), '-01-01') as date))
group by date_format(
            date_add(cast(concat(year(current_date), '-01-01') as date),
                    interval T500.id - 1 day), '%W');

8.7 현재 레코드와 다음 레코드 간의 날짜 차이 알아내기

select x.ename, x.hiredate, x.next_hd,
       datediff(x.next_hd, x.hiredate) as diff
from (select deptno, ename, hiredate,
             lead(hiredate) over (order by hiredate) as next_hd
      from EMP e) x
where x.deptno = 10;

select x.ename, x.hiredate, x.next_hd, datediff(x.next_hd, x.hiredate) as diff
from ( select deptno, ename, hiredate,
              lead(hiredate, cnt - rn + 1) over (order by hiredate) next_hd
       from (select deptno, ename, hiredate,
                    count(*) over (partition by hiredate) cnt,
                    row_number() over (partition by hiredate order by empno) rn
             from EMP
             where deptno = 10)) x;