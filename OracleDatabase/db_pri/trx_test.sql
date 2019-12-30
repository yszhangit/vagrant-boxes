connect system/testdbpw

create tablespace trx datafile '/opt/oracle/oradata/testdb/trx01.dbf' size 10M autoextend on next 10M maxsize 5G;

create user trx identified by trxpw default tablespace trx temporary tablespace temp;

grant connect to trx;
grant resource to trx;
alter user trx quota unlimited on trx;

connect trx/trxpw

create table users (
        userid number(3),
        name varchar2(100),
        constraint user_pk primary key (userid),
        constraint user_nn_name check ( name is not null)
)
/

create table trx (
        trxid number(8),
        attr1 varchar2(10),
        attr2 varchar2(20),
        userid number(3),
        created date,
        updated date,
        constraint trx_pk primary key (trxid),
        constraint trx_nn_attr1 check (attr1 is not null),
        constraint trx_ck_attr2 check (attr1 in ('val1','val2', 'val3','val4')),
        constraint trx_nn_created check (created is not null),
        constraint trx_fk_user foreign key (userid) references users (userid)
);

create sequence seq_trx start with 10000000 increment by 1;

insert into users values (1, 'user1');
insert into users values (2, 'user2');
insert into users values (3, 'user3');
insert into users values (4, 'user4');
insert into users values (5, 'user5');
insert into users values (6, 'user6');
insert into users values (7, 'user7');
insert into users values (8, 'user8');
insert into users values (9, 'user9');
insert into users values (10, 'user10');

commit;

