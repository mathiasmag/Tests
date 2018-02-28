create or replace package kentor_instrument as
/*
 *******************************************************************************
 ** Author: MAM2 Mathias Magnusson
 **
 ** Date:   11-06-07
 **
 ** Description:
 ** Used to instrument code. This package takes care of all details, freeing up 
 ** the calling code to not care about the details, just make the calls and 
 ** focus on the needed business logic.
 *******************************************************************************
 */

  procedure initialize(p_in_batch_id    number);
  
  procedure set_start_time    (p_in_function_op varchar2);
  
  procedure set_stop_time     (p_in_function_op varchar2
                              ,p_in_rows_num    number    := 0);
  
  function  get_job_no                                 return number;
--  function  get_proc_name                              return varchar2;
  
  procedure persist;
end kentor_instrument;