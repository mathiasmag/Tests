create or replace package kentor_ref_job_sql as
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

  type t_user_object is record (object_name    user_objects.object_name%type
                               ,last_ddl_time  user_objects.last_ddl_time%type);
 
  procedure get_user_object(p_in_object_id     in user_objects.object_id%type
                           ,p_out_user_object out t_user_object);
end kentor_ref_job_sql;