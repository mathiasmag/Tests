set echo on
alter session set container = otw;
create user superthief identified by miracle;
grant connect to superthief;
grant select any dictionary to superthief;
grant create view to superthief;
