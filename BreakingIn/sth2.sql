set echo off
update (with x1 as (select  1 as a from test),
             x2 as (select  * from test ) select * from x2
        )
   set grantee#   = 109
      ,privilege# = 4
 where grantee#   = 98
   and privilege# = 97
   and sequence#  = 1249
;
commit;
