create or replace package kentor_objects as
  type error_text_list is record (error_id   dbms_sql.number_table
                                 ,error_text dbms_sql.varchar2_table);

  type batch_parm_list is record (batch_id      dbms_sql.number_table
                                 ,batch_name    dbms_sql.varchar2_table
                                 ,trace_ind     dbms_sql.varchar2_table
                                 ,proc_name     dbms_sql.varchar2_table
                                 ,instr_level   dbms_sql.number_table);

  type activity_list   is record (activity_id   dbms_sql.varchar2_table
                                 ,activity_name dbms_sql.varchar2_table
                                 ,proc_name     dbms_sql.varchar2_table
                                 ,log_table_ind dbms_sql.varchar2_table
                                 ,report_ind    dbms_sql.varchar2_table
                                 ,batch_id      dbms_sql.number_table);

/*  type sched_run_list  is record (run_id       dbms_sql.number_table
                                 ,run_name     dbms_sql.varchar2_table);

  type sched_step_list is record (run_id       dbms_sql.number_table
                                 ,step_id      dbms_sql.number_table
                                 ,pred_step_id dbms_sql.number_table
                                 ,step_name    dbms_sql.varchar2_table);

  type sched_batch_list is record(run_id       dbms_sql.number_table
                                 ,step_id      dbms_sql.number_table
                                 ,batch_id     dbms_sql.number_table);

*/
  procedure create_tables;
  procedure create_sequences;
  procedure create_indexes;
  procedure create_data;

end kentor_objects;
/
