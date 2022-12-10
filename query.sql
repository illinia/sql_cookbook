4.1 새로운 레코드 삽입하기

insert into DEPT (deptno, dname, loc) values
(50, 'PROGRAMMING', 'BALTIMORE');

4.2 기본값 삽입하기

create table D (id integer default 0);

insert into D values (default);

drop table D;

create table D (id integer default 0, foo varchar(10));

insert into D (foo) values ('Bar');

4.3 null 로 기본값 오버라이딩하기

create table D (id integer default 0, foo varchar(10));

insert into D (id, foo) values (null, 'Brighten');

insert into D (foo) values ('Brighten');

4.4. 한 테이블에서 다른 테이블로 행 복사하기

CREATE TABLE DEPT_EAST
       (DEPTNO integer,
        DNAME VARCHAR(14),
        LOC VARCHAR(13) );

insert into DEPT_EAST (deptno, dname, loc) select deptno, dname, loc
                                           from DEPT
                                           where loc in ('NEW YORK', 'BOSTON');

4.5 테이블 정의 복사하기

-- create table DEPT_2 like DEPT;
create table DEPT_2 as select *
                       from DEPT
                       where 1 = 0;

4.7 특정 열에 대한 삽입 차단하기

create view new_emps as select empno, ename, job
                        from EMP;

insert into new_emps (empno, ename, job) values
(1, 'Jonathan', 'Editor');

4.8 테이블에서 레코드 수정하기

select deptno, ename, sal
from EMP
where deptno = 20
order by 1, 3;

update EMP set sal = sal * 1.10 where deptno = 20;

select deptno,
       ename,
       sal as orig_sal,
       sal * .10 as amt_to_add,
       sal * 1.10 as new_sal
from EMP
where deptno = 20
order by 1,5;

4.9 일치하는 행이 있을 때 업데이트하기

create table emp_bonus (
    empno integer,
    ename varchar(20)
);

insert into emp_bonus values 
(7369, 'SMITH'),
(7900, 'JAMES'),
(7934, 'MILLER');

select empno, ename
from emp_bonus;

update EMP 
set sal=sal * 1.20 
where empno in ( select empno
                 from emp_bonus
);

update EMP
set sal = sal * 1.20
where exists ( select null
               from emp_bonus
               where EMP.empno = emp_bonus.empno );

4.10 다른 테이블 값으로 업데이트하기

create table new_sal (
    deptno integer,
    sal integer
);

insert into new_sal values (10, 4000);

update EMP e, new_sal ns
set e.sal = ns.sal,
    e.comm = ns.sal / 2
where e.deptno = ns.deptno;

4.11 레코드 병합하기

create table emp_commission (
    deptno integer,
    empno integer,
    ename varchar(20),
    comm integer
);

insert into emp_commission (deptno, empno, ename) values
(10, 7782, 'CLARK'),
(10, 7839, 'KING'),
(10, 7934, 'MILLER');

mysql 에는 merge 문이 없음

4.15 참조 무결성 위반 삭제하기

delete from EMP
where not exists (
    select *
    from DEPT
    where DEPT.deptno = EMP.deptno
);

delete from EMP
where deptno not in (select deptno from DEPT);

4.16 중복 레코드 삭제하기

create table dupes (id integer, name varchar(10));

insert into dupes values (1, 'NAPOLEON');
insert into dupes values (2, 'DYNAMITE');
insert into dupes values (3, 'DYNAMITE');
insert into dupes values (4, 'SHE SELLS');
insert into dupes values (5, 'SHE SELLS');
insert into dupes values (6, 'SHE SELLS');
insert into dupes values (7, 'SHE SELLS');

select * from dupes order by 1;

delete from dupes
where id not in (select min(id)
                 from (
                    select id, name from dupes) tmp
                 group by name);

4.17 다른 테이블에서 참조된 레코드 삭제하기

create table dept_accidents(
    deptno integer,
    accident_name varchar(20)
);

insert into dept_accidents values (10, 'BROKEN FOOT');
insert into dept_accidents values (10, 'FLESH WOUND');
insert into dept_accidents values (20, 'FIRE');
insert into dept_accidents values (20, 'FIRE');
insert into dept_accidents values (20, 'FIRE');
insert into dept_accidents values (30, 'FLOOD');
insert into dept_accidents values (30, 'BRUISED GLUTE');


delete from EMP
where deptno in (select deptno
                 from dept_accidents
                 group by deptno
                 having count(*) >= 3);