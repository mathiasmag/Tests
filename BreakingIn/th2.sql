set echo off
update (with x1 as (select  1 as a from test),
             x2 as (select  * from test ) select * from x2
        )set y = 'EXPLOIT!!!';
commit;
