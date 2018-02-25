set echo on
create table my_secret_stuff as select table_name from all_tables;
grant select on my_secret_stuff to thief;

