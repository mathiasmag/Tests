set echo on
create view test as with x as (select table_name y from owner.my_secret_stuff ) select * from x;
