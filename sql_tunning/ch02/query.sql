2.1 물리 엔진과 오브젝트 용어

select engine, transactions, comment
from information_schema.engines;

2.1.3 DB 오브젝트 용어

create table major
(
    major_code char(2)    not null,
    major_name  varchar(2) not null,
    primary key (major_code)
);

create table student (
    student_code int(10) not null,
    name varchar(10) not null,
    birthday char(8),
    phone_number varchar(15),
    major_code char(2),
    primary key (student_code),
    constraint student_fk1 foreign key (major_code) references major(major_code)
);

alter table student
add unique index phone_number_index(phone_number);

alter table student
add index name_index (name);

2.2 논리적인 sql 개념 용어

2.2.1 서브쿼리 위치에 따른 SQL 용어

스칼라 서브쿼리

select name,
       (select count(*)
        from student as student2
        where student2.name = student.name) 카운트
from student as student;


인라인 뷰

select student2.student_code, student2.name
from (select *
      from student
      where gender = '남') student2;


# 중첩 서브쿼리

select *
from student
where student_code = (select max(student_code)
                      from student);


drop table student;
create table student (
    student_code int(10) not null,
    name varchar(10) not null collate 'utf8_bin',
    major_code char(2) null default null,
    primary key (student_code)
)
collate='utf8_general_ci'
engine=InnoDB;
desc student;

analyze table student update histogram on name;

select * from information_schema.column_statistics;






