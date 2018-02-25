set echo on
create pluggable database otw admin user otw_admin identified by miracle file_name_convert=('/u01/app/oracle/oradata/o12/pdbseed/','/u02/app/oracle/oradata/o12/otw/');

alter pluggable database otw open;
alter pluggable database otw save state;
alter session set container = otw;
create tablespace data datafile '/u02/app/oracle/oradata/o12/otw/data.dbf' size 50m;
create user owner identified by miracle;
create user thief identified by miracle;
alter user owner default tablespace data;
alter user owner quota unlimited on data;
grant create table to owner;
grant create view  to thief;
grant connect to owner,thief;
