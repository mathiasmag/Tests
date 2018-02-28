create or replace package body kentor_ref_job as
/*
 Author: MAM2 Mathias Magnusson

 Date:   11-06-07

 Description:
 Reference implementation showing use of infrastructure and instrumentation with
 the Kentor infrastructure packages.

 Change Log:
 Name    Date      Description
 =======================================================================================================================
 MAM2    11-06-08  Inital Version
 */

  procedure proc_a;
  procedure proc_b;
  procedure proc_c;
  procedure util_proc;

  procedure proc_a is
  begin
    kentor_instrument.set_start_time(p_in_function_op => kentor_activity_codes.ref_job_proc_a);
    proc_b;
    util_proc;
    kentor_instrument.set_stop_time(p_in_function_op => kentor_activity_codes.ref_job_proc_a);
  end proc_a;
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  procedure proc_b is
  begin
    kentor_instrument.set_start_time(p_in_function_op => kentor_activity_codes.ref_job_proc_b);
    util_proc;
    kentor_instrument.set_stop_time(p_in_function_op => kentor_activity_codes.ref_job_proc_b);
  end proc_b;
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  procedure proc_c is
    r_user_object kentor_ref_job_sql.t_user_object;
    
  begin
    kentor_instrument.set_start_time(p_in_function_op => kentor_activity_codes.ref_job_proc_c);
    
    kentor_ref_job_sql.get_user_object(p_in_object_id    => 80935
                                      ,p_out_user_object => r_user_object);
    
    dbms_output.put_line('Paket ' 
                      || r_user_object.object_name 
                      || 'kompilerades senast ' 
                      || to_char(r_user_object.last_ddl_time, 'yyyy-mm-dd hh24:mi:ss'));
    
    util_proc;
    kentor_instrument.set_stop_time(p_in_function_op => kentor_activity_codes.ref_job_proc_c);
  end proc_c;
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  procedure util_proc is
  begin
    kentor_instrument.set_start_time(p_in_function_op => kentor_activity_codes.ref_job_util_proc);
    kentor_instrument.set_stop_time(p_in_function_op => kentor_activity_codes.ref_job_util_proc);
  end util_proc;
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  procedure main is
  begin
    kentor_instrument.set_start_time(p_in_function_op => kentor_activity_codes.ref_job_main);

    proc_a;
    proc_b;
    proc_c;
    util_proc;
    
    kentor_instrument.set_stop_time(p_in_function_op => kentor_activity_codes.ref_job_main);
    kentor_instrument.persist;
  end main;

-- Package initialization for the session
  begin
    kentor_instrument.initialize(p_in_batch_id => 0);
end kentor_ref_job;
