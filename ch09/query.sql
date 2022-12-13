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