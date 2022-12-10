3.1 행 집합을 다른 행 위에 추가하기

select ename as ename_and_dname, deptno
from EMP
where deptno = 10
union all
select '-----------', null
from T1
union all
select dname, deptno
from DEPT;

중복 필터링 위해서 union 연산자 사용

select deptno
from EMP
union
select deptno
from DEPT;

union 을 지정하면 중복 제거하는 작업 발생
union all 출력에 distinct 를 적용하는 쿼리와 같다

select distinct deptno
from (
    select deptno
    from EMP
    union all
    select deptno
    from DEPT
) x;

3.2 연관된 여러 행 결합하기

select e.ename, d.loc
from EMP e, DEPT d
where e.deptno = d.deptno
    and e.deptno = 10;

조인의 결과셋은 from 절에 나열된 테이블에서 데카르트 곱(가능한 모든 행 조합)을 우선 생성하여 만들어진다.

select e.ename, d.loc, e.deptno as emp_deptno, d.deptno as dept_deptno
from EMP e, DEPT d
where e.deptno = 10;

그리고 where 절에서 결과셋을 제한하여 반환

select e.ename, d.loc, e.deptno as emp_deptno, d.deptno as dept_deptno
from EMP e, DEPT d
where e.deptno = d.deptno
    and e.deptno = 10;

다른 명시적 해법은 join 절 사용

select e.ename, d.loc
from EMP e
    inner join DEPT d on (e.deptno = d.deptno)
where e.deptno = 10;

3.3 두 테이블의 공통 행 찾기

create view V as
select ename, job, sal
from EMP
where job = 'CLERK';

select e.empno, e.ename, e.job, e.sal, e.deptno
from EMP e, V
where e.ename = V.ename and e.job = V.job and e.sal = V.sal;

select e.empno, e.ename, e.job, e.sal, e.deptno
from EMP e
    join V on (e.ename = V.ename and e.job = V.job and e.sal = V.sal);

3.4 한 테이블에서 다른 테이블에 존재하지 않는 값 검색하기

select deptno
from DEPT
where deptno not in (select deptno from EMP);

not in 사용시 null 에 유의

create table new_dept(deptno integer);
insert into new_dept values(10);
insert into new_dept values(50);
insert into new_dept values(null);

deptno 가 20, 30, 40 인 데이터는 new_dept 테이블에 없지만 쿼리가 반환되지 않는다.
new_dept 테이블에 null 값이 있기 때문

select *
from DEPT
where deptno not in (
    select deptno from new_dept
);

in, or 사용시 deptno 가 10 인 행만 반환된다.

select deptno
from DEPT
where deptno in (10, 50, null);

select deptno
from DEPT
where (deptno = 10 or deptno = 50 or deptno = null);

not in, not or 사용시 null 값의 논리적 or 평가에 의해 전부 Null 로 평가되어 행을 반환하지 않는다.

select deptno
from DEPT
where deptno not in (10,50,null);

select deptno
from DEPT
where not (deptno = 10 or deptno = 50 or deptno = null);

not in, null 문제 방지시 not exists 와 서브쿼리 사용

select d.deptno
from DEPT d
where not exists (
    select 1
    from EMP e
    where d.deptno = e.deptno
);

select d.deptno
from DEPT d
where not exists (
    select 1
    from new_dept nd
    where d.deptno = nd.deptno
);

3.5 다른 테이블 행과 일치하지 않는 행 검색하기

select d.*
from DEPT d
    left outer join EMP e on (d.deptno = e.deptno)
where e.deptno is null;

null 필터링 하지 않는 결과셋

select e.ename, e.deptno as emp_deptno, d.*
from DEPT d left join EMP e on(d.deptno = e.deptno);

3.6 다른 조인을 방해받지 않고 쿼리에 조인 추가하기

create table emp_bonus
        (empno integer NOT NULL,
        received varchar(20),
        type integer);

insert into emp_bonus values
        (7369, '14-MAR-2005', 1);
insert into emp_bonus values
        (7900, '14-MAR-2005', 2);
insert into emp_bonus values
        (7788, '14-MAR-2005', 3);

select * from emp_bonus;

select e.ename, d.loc
from EMP e, DEPT d
where e.deptno = d.deptno;

사원별 보너스가 지급된 날짜를 추가하여할 때 emp_bonus 테이블과 조인하면
모든 사원이 보너스를 받는 것은 아니므로 원하는 수보다 적은 행 반환

select e.ename, d.loc, eb.received
from EMP e, DEPT d, emp_bonus eb
where e.deptno = d.deptno
    and e.empno = eb.empno;

select e.ename, d.loc, eb.received
from EMP e
    join DEPT d on (e.deptno = d.deptno)
    left join emp_bonus eb on (e.empno = eb.empno)
order by 2;

스칼라 서브쿼리

select e.ename, d.loc,
    (select eb.received
    from emp_bonus eb
    where eb.empno = e.empno) as recevied
from EMP e, DEPT d
where e.deptno = d.deptno
order by 2;

3.7 두 테이블에 같은 데이터가 있는지 확인하기

create view v as
    select * from EMP where deptno != 10
    union all
    select * from EMP where ename = 'WARD';

select *
from (
    select e.empno, e.ename, e.job, e.mgr, e.hiredate, e.sal, e.comm, e.deptno, count(*) as cnt
    from EMP e
    group by empno, ename, job, mgr, hiredate, sal, comm, deptno
) e
where not exists(
    select null
    from (
        select v.empno, v.ename, v.job, v.mgr, v.hiredate, v.sal, v.comm, v.deptno, count(*) as cnt
        from v
        group by empno, ename, job, mgr, hiredate, sal, comm, deptno
    ) v
    where v.empno = e.empno
        and v.ename = e.ename
        and v.job = e.job
        and coalesce(v.mgr, 0) = coalesce(e.mgr, 0)
        and v.hiredate = e.hiredate
        and v.sal = e.sal
        and v.deptno = e.deptno
        and v.cnt = e.cnt
        and coalesce(v.comm, 0) = coalesce(e.comm, 0)
)
union all
select *
from (
    select v.empno, v.ename, v.job, v.mgr, v.hiredate, v.sal, v.comm, v.deptno, count(*) as cnt
    from v
    group by empno, ename, job, mgr, hiredate, sal, comm, deptno
) v
where not exists (
    select null
    from (
        select e.empno, e.ename, e.job, e.mgr, e.hiredate, e.sal, e.comm, e.deptno, count(*) as cnt
        from EMP e
        group by empno, ename, job, mgr, hiredate, sal, comm, deptno
    ) e
    where v.empno = e.empno
        and v.ename = e.ename
        and v.job = e.job
        and coalesce(v.mgr, 0) = coalesce(e.mgr, 0)
        and v.hiredate = e.hiredate
        and v.sal = e.sal
        and v.deptno = e.deptno
        and v.cnt = e.cnt
        and coalesce(v.comm, 0) = coalesce(e.comm, 0)
)

select count(*)
from EMP
union
select count(*)
from DEPT;


3.8 데카르트 곱 식별 및 방지하기

select e.ename, d.loc
from EMP e, DEPT d
where e.deptno = 10
    and d.deptno = e.deptno;

3.9 집계를 사용할 때 조인 수행하기

create table emp_bonus
        (empno integer NOT NULL,
        received varchar(20),
        type integer);

insert into emp_bonus values (7934, '17-MAR-2005', 1);
insert into emp_bonus values (7934, '15-FEB-2005', 2);
insert into emp_bonus values (7839, '15-FEB-2005', 3);
insert into emp_bonus values (7782, '15-FEB-2005', 1);

부서 10의 모든 사원 급여, 보너스 반환 쿼리

select e.empno,
    e.ename,
    e.sal,
    e.deptno,
    e.sal * case when eb.type = 1 then .1
                when eb.type = 2 then .2
                else .3
            end as bonus
from EMP e, emp_bonus eb
where e.empno = eb.empno
    and e.deptno = 10;

보너스 금액 합산하고자 emp_bonus 테이블에 조인하면 total_sal 이 맞지 않다
조인에 생성된 sal 열의 중복 행 때문

select deptno,
    sum(sal) as total_sal,
    sum(bonus) as total_bonus
from (
    select e.empno,
        e.ename,
        e.sal,
        e.deptno,
        e.sal * case when eb.type = 1 then .1
                    when eb.type = 2 then .2
                    else .3
                end as bonus
    from EMP e, emp_bonus eb
    where e.empno = eb.empno
        and e.deptno = 10
) x
group by deptno;

select sum(sal)
from EMP
where deptno = 10;

select e.ename, e.sal
from EMP e, emp_bonus eb
where e.empno = eb.empno
    and e.deptno = 10;


distinct 사용

select deptno,
    sum(distinct sal) as total_sal,
    sum(bonus) as total_bonus
from (
    select e.empno,
        e.ename,
        e.sal,
        e.deptno,
        e.sal * case when eb.type = 1 then .1
                    when eb.type = 2 then .2
                    else .3
                end as bonus
    from EMP e, emp_bonus eb
    where e.empno = eb.empno
        and e.deptno = 10
)x
group by deptno;

부서 10의 모든 급여 합계가 먼저 계산되고 그 행을 emp 테이블에 조인한 다음 emp_bonus 테이블에 조인합니다.

select d.deptno,
    d.total_sal,
    sum(e.sal*case when eb.type = 1 then .1
                   when eb.type = 2 then .2
                   else .3 end) as total_bonus
from EMP e,
     emp_bonus eb,
     (
        select deptno, sum(sal) as total_sal
        from EMP
        where deptno = 10
        group by deptno
     ) d
where e.deptno = d.deptno
  and e.empno = eb.empno
group by d.deptno, d.total_sal;

3.10 집계 시 외부 조인 수행하기

total_sal 값이 잘못됐다.

select deptno,
       sum(sal) as total_sal,
       sum(bonus) as total_bonus
from (
    select e.empno,
           e.ename,
           e.sal,
           e.deptno,
           e.sal * case when eb.type = 1 then .1
                        when eb.type = 2 then .2
                        else .3 end as bonus
    from EMP e, emp_bonus eb
    where e.empno = eb.empno
      and e.deptno = 10
) x
group by deptno;

부서 10의 모든 사원이 조회되게 emp_bonus 에 외부 조인한다.

select deptno,
       sum(distinct sal) as total_sal,
       sum(bonus) as total_bonus
from (
    select e.empno,
           e.ename,
           e.sal,
           e.deptno,
           e.sal * case when eb.type is null then 0
                        when eb.type = 1 then .1
                        when eb.type = 2 then .2
                        else .3 end as bonus
    from EMP e
        left outer join emp_bonus eb on(e.empno = eb.empno)
    where e.deptno = 10
) x
group by deptno;

select d.deptno,
       d.total_sal,
       sum(e.sal * case when eb.type = 1 then .1
                        when eb.type = 2 then .2
                        else .3 end) as total_bonus
from EMP e,
     emp_bonus eb,
     (
        select deptno, sum(sal) as total_sal
        from EMP
        where deptno = 10
        group by deptno
     ) d
where e.deptno = d.deptno
  and e.empno = eb.empno
group by d.deptno, d.total_sal;


3.11 여러 테이블에서 누락된 데이터 반환하기

select d.deptno, d.dname, e.ename
from DEPT d
    left outer join EMP e on (d.deptno = e.deptno);

insert into EMP (empno, ename, job, mgr, hiredate, sal, comm, deptno)
        select 1111, 'YODA', 'JEDI', null, hiredate, sal, comm, null
        from EMP
        where ename = 'KING';


select d.deptno, d.dname, e.ename
from DEPT d
    right outer join EMP e on (d.deptno = e.deptno);

select d.deptno, d.dname, e.ename
from DEPT d
    right outer join EMP e on (d.deptno = e.deptno)
union
select d.deptno, d.dname, e.ename
from DEPT d
    left outer join EMP e on (d.deptno = e.deptno);

3.12 연산 및 비교에서 null 사용하기

select ename, comm, coalesce(comm, 0)
from EMP
where coalesce(comm, 0) < (select comm
                           from EMP
                           where ename = 'WARD');

