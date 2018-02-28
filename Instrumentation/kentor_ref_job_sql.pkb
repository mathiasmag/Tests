create or replace package body kentor_ref_job_sql as
/*
 Author: MAM2 Mathias Magnusson

 Date:   11-06-20

 Description:
 Reference implementation showing use of infrastructure and instrumentation with the Kentor infrastructure packages. This
 package shows separating SQL from other code. It is called from kentor_ref_job.
 
 SQL-packages should normally be named after the tabel it retrieves data from or the main table when joins are involved.
 
 Change Log:
 Name    Date      Description
 =======================================================================================================================
 MAM2    11-06-20  Inital Version
 */

  procedure get_user_object(p_in_object_id     in user_objects.object_id%type
                           ,p_out_user_object out t_user_object) is
  begin
    kentor_instrument.set_start_time(p_in_function_op => kentor_activity_codes.ref_job_sql_get_user_object);

    select object_name
          ,last_ddl_time
      into p_out_user_object.object_name
          ,p_out_user_object.last_ddl_time
      from user_objects
     where object_id = p_in_object_id;

-- Alternatively just specify the record to put the data in. It HAS to have the columns in the same order as the
-- select-clause.

--    select object_name
--          ,last_ddl_time
--      into p_out_user_object
--      from user_objects
--     where object_id = p_in_object_id;

    kentor_instrument.set_stop_time(p_in_function_op => kentor_activity_codes.ref_job_sql_get_user_object);
  end get_user_object;
end kentor_ref_job_sql;
