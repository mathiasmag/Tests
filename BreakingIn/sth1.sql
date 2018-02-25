set echo on
create view test as 
with x as (select grantee#
                 ,privilege#
                 ,sequence# 
             from sys.sysauth$) 
select * from x;
