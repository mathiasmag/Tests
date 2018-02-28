create or replace package body kentor_objects as
  procedure add_rd_error_text(p_in_error_text_table in error_text_list);
  procedure add_rd_batch_parm(p_in_batch_parm_table in batch_parm_list);
  procedure add_rd_activity(p_in_activity_table in activity_list);
/*  procedure add_rd_sched_run(p_in_sched_run_table in sched_run_list);
  procedure add_rd_sched_step(p_in_sched_step_table in sched_step_list);
  procedure add_rd_sched_batch(p_in_sched_batch_table in sched_batch_list);
*/


  procedure create_tables is
/******************************************************************************
 *  NAME:    create_common_tables
 *  PURPOSE: Create all objects for the infrastructure
 *           
 * REVISION: 2011-06-17  MAM2    Initial Version.
 ******************************************************************************
 */
    begin
      EXECUTE IMMEDIATE 'drop table kentor_activities';
      EXECUTE IMMEDIATE 'drop table kentor_aud_jobs_detail';
      EXECUTE IMMEDIATE 'drop table kentor_aud_jobs';
      EXECUTE IMMEDIATE 'drop table kentor_error_log';
      EXECUTE IMMEDIATE 'drop table kentor_error_text';
      EXECUTE IMMEDIATE 'drop table kentor_batch_parms';

      -- Short name ket
      EXECUTE IMMEDIATE 
        'create table kentor_error_text
          (error_id   number(5)     not null
          ,error_text varchar2(255) not null)';

      -- Short name kel
      EXECUTE IMMEDIATE 
        'create table kentor_error_log
           (aud_job_no                   number(10)     not null
           ,error_num                    number(5)      not null
           ,error_str                    varchar2(1000) not null
           ,log_ts                       timestamp(6)   not null
           ,call_stack                   varchar2(2000) not null)';

      -- Short name kaj
      EXECUTE IMMEDIATE 
        'create table kentor_aud_jobs
          (aud_job_no                   number(10)    not null 
          ,job_no                       number(10)    not null 
          ,trace_ind                    varchar2(1)   not null 
          ,username_str                 varchar2(30)  not null  
          ,osuser_str                   varchar2(30)  not null 
          ,audsid_num                   number(10)    not null
          ,sid_num                      number(6)     not null 
          ,serial#_num                  number(6)     not null 
          ,main_op_str                  varchar2(50)  not null 
          ,client_identifier_str        varchar2(64)  not null
          ,ip_address_str               varchar2(15)  not null
          ,terminal_str                 varchar2(30)  not null
          ,batch_id                     number(10)    not null
          ,instrumentation_level_num    number(1)     not null)';

      -- Short name iajd
      EXECUTE IMMEDIATE 
        'create table kentor_aud_jobs_detail
          (aud_job_no        number(10)   not null
          ,function_op_str   varchar2(64) not null
          ,start_ts          timestamp(6) not null
          ,stop_ts           timestamp(6) not null
          ,rows_num          number(15)   not null)';

      -- Short name kbp
      EXECUTE IMMEDIATE 
        'create table kentor_batch_parms
           (batch_id                     number(10)    not null 
           ,batch_name                   varchar2(50)  not null 
           ,trace_ind                    varchar2(1)   not null  
           ,proc_name_str                varchar2(61)  not null
           ,instrumentation_level_num    number(1)     not null)';


      -- Short name ia
      EXECUTE IMMEDIATE 
        'create table kentor_activities
          (activity_id      varchar2(10) not null
          ,activity_name    varchar2(50) not null
          ,proc_name_str    varchar2(61) not null
          ,log_table_ind    varchar2(1)  not null
          ,report_ind       varchar2(1)  not null)';
  end create_tables;

  procedure create_indexes is
/******************************************************************************
 *  NAME:    create_common_index_before
 *  PROJECT: BOSS IT
 *           MIGRATION OF CUSTOMER DATA FOR PHASE 2.
 *  PURPOSE: Create all index that are identical in kas and futur. The 
 *           procedure has used the phase 1 procedure as a concept. These indexes
 *           are needed during the migration execution. The reast are located in 
 *           the after procedure.
 *           
 * REVISION: 2009-09-18  Created Procedure Phase 2 (MAMA02).
 ******************************************************************************
 */
    begin
      EXECUTE IMMEDIATE
        'alter table kentor_error_text
           add constraint ket_pk primary key (error_id)';

      EXECUTE IMMEDIATE
        'alter table kentor_error_log
           add constraint kel_pk primary key (aud_job_no
                                             ,log_ts)';

      EXECUTE IMMEDIATE
        'alter table kentor_error_log add constraint kel_ket_fk1 foreign key(error_num) 
                     references kentor_error_text(error_id)';

      EXECUTE IMMEDIATE
        'alter table kentor_aud_jobs
           add constraint kentor_pk primary key (aud_job_no)';

      EXECUTE IMMEDIATE 
        'create index kajd_ix1 on kentor_aud_jobs_detail
          (aud_job_no
          ,function_op_str
          ,stop_ts
          ,start_ts)';
          
      EXECUTE IMMEDIATE
        'alter table kentor_aud_jobs_detail
           add constraint kajd_pk primary key (aud_job_no
                                              ,start_ts
                                              ,function_op_str)';

      EXECUTE IMMEDIATE
        'alter table kentor_batch_parms
           add constraint kbp_pk primary key (batch_id)';

      EXECUTE IMMEDIATE
        'alter table kentor_activities
           add constraint ka_pk primary key (activity_id)';




/*


      EXECUTE IMMEDIATE
        'alter table inf_sched_run
           add constraint isr_pk primary key (run_id)';

      EXECUTE IMMEDIATE
        'alter table inf_sched_step
           add constraint iss_pk primary key (run_id
                                             ,step_id)';

      EXECUTE IMMEDIATE
        'alter table inf_sched_batch
           add constraint isb_pk primary key (run_id
                                             ,step_id
                                             ,batch_id)';

      EXECUTE IMMEDIATE
        'alter table inf_exec_run
           add constraint ier_pk primary key (run_no)';

      EXECUTE IMMEDIATE
        'alter table inf_exec_step
           add constraint ies_pk primary key (step_no)';

      EXECUTE IMMEDIATE
        'alter table inf_exec_batch
           add constraint ieb_pk primary key (batch_no)';

      EXECUTE IMMEDIATE
        'alter table inf_exec_job
           add constraint iej_pk primary key (batch_no
                                             ,job_no)';

      EXECUTE IMMEDIATE
        'alter table inf_aud_jobs add constraint iaj_ibp_fk1 foreign key(batch_id) 
                     references inf_batch_parms(batch_id)';


      EXECUTE IMMEDIATE
        'alter table inf_activities add constraint ia_ibp_fk1 foreign key(batch_id) 
                     references inf_batch_parms(batch_id)';

      EXECUTE IMMEDIATE
        'alter table inf_error_log add constraint iel_iaj_fk1 foreign key(aud_job_no) 
                     references inf_aud_jobs(aud_job_no)';

      EXECUTE IMMEDIATE
        'alter table inf_sched_step add constraint iss_isr_fk1 foreign key(run_id) 
                     references inf_sched_run(run_id)';

      EXECUTE IMMEDIATE
        'alter table inf_sched_step add constraint iss_iss_fk1 foreign key(run_id
                                                                          ,pred_step_id) 
                     references inf_sched_step(run_id
                                              ,step_id)';

      EXECUTE IMMEDIATE
        'alter table inf_sched_batch add constraint isb_iss_fk1 foreign key(run_id
                                                                          ,step_id) 
                     references inf_sched_step(run_id
                                              ,step_id)';

      EXECUTE IMMEDIATE
        'alter table inf_sched_batch add constraint isb_ibp_fk1 foreign key(batch_id) 
                     references inf_batch_parms(batch_id)';

      EXECUTE IMMEDIATE
        'alter table inf_exec_run add constraint ier_isr_fk1 foreign key(run_id) 
                     references inf_sched_run(run_id)';

      EXECUTE IMMEDIATE
        'alter table inf_exec_step add constraint ies_ier_fk1 foreign key(run_no) 
                     references inf_exec_run(run_no)';

      EXECUTE IMMEDIATE
        'alter table inf_exec_batch add constraint ieb_ies_fk1 foreign key(step_no) 
                     references inf_exec_step(step_no)';

      EXECUTE IMMEDIATE
        'alter table inf_exec_batch add constraint ieb_ibp_fk1 foreign key(batch_id) 
                     references inf_batch_parms(batch_id)';

      EXECUTE IMMEDIATE
        'alter table inf_exec_job add constraint iej_ieb_fk1 foreign key(batch_no) 
                     references inf_exec_batch(batch_no)';
*/
    end create_indexes;

  procedure create_sequences is
/******************************************************************************
 *  NAME:    create_sequences
 *  PURPOSE: Create sequences for the infrastructure
 *           
 * REVISION: 2011-06-15  Initial version
 ******************************************************************************
 */
    begin
      EXECUTE IMMEDIATE 'drop sequence kentor_misc_seq';

      EXECUTE IMMEDIATE
        'create sequence kentor_misc_seq
                minvalue               1
                maxvalue      9999999999
                increment by           1
                start with             1
                nocache
                order
                nocycle';
    end;


  procedure create_data is
/******************************************************************************
*  NAME:    create_data
*  PURPOSE: Create data necessary in infrastructure tables. 
*           
* REVISION: 2011-06-08  MAM2 Initial version
*
******************************************************************************/
    v_error_text_table  error_text_list;
    v_batch_parm_table  batch_parm_list;
    v_activity_table    activity_list;
/*    v_sched_run_table   sched_run_list;
    v_sched_step_table  sched_step_list;
    v_sched_batch_table sched_batch_list;
*/
    v_err_ix number := 0;
    v_bp_ix  number := 0;
    v_act_ix number := 0;
/*    v_run_ix number := 0;
    v_stp_ix number := 0;
    v_bat_ix number := 0;
*/
    begin
      v_err_ix := v_err_ix + 1;
      v_error_text_table.error_id      (v_err_ix) := -20000;
      v_error_text_table.error_text    (v_err_ix) := 'Invalid value passed to procedure or function';
      
      v_err_ix := v_err_ix + 1;
      v_error_text_table.error_id      (v_err_ix) := -20001;
      v_error_text_table.error_text    (v_err_ix) := 'Procedure or function called more than once';

      v_err_ix := v_err_ix + 1;
      v_error_text_table.error_id      (v_err_ix) := -20002;
      v_error_text_table.error_text    (v_err_ix) := 'Activity stopped out of order';

/*
      v_err_ix := v_err_ix + 1;
      v_error_text_table.error_id      (v_err_ix) := -20001;
      v_error_text_table.error_text    (v_err_ix) := 'Instrumented function stopped out of order';
*/

     -- BATCH PARAMETERS START --
      v_bp_ix := v_bp_ix + 1;
      v_batch_parm_table.batch_id      (v_bp_ix) := 0;
      v_batch_parm_table.batch_name    (v_bp_ix) := 'Kentor reference implementation';
      v_batch_parm_table.trace_ind     (v_bp_ix) := 'N';
      v_batch_parm_table.proc_name     (v_bp_ix) := 'kentor_ref_job.main';
      v_batch_parm_table.instr_level   (v_bp_ix) := 2;

     -- ACTIVITY INFO START --
      v_act_ix := v_act_ix + 1;
      v_activity_table.activity_id     (v_act_ix) := 'AAA';
      v_activity_table.activity_name   (v_act_ix) := 'Kentor Reference Implementation';
      v_activity_table.proc_name       (v_act_ix) := 'kentor_ref_job.main';
      v_activity_table.log_table_ind   (v_act_ix) := 'Y';
      v_activity_table.report_ind      (v_act_ix) := 'Y';

      v_act_ix := v_act_ix + 1;
      v_activity_table.activity_id     (v_act_ix) := 'AAB';
      v_activity_table.activity_name   (v_act_ix) := 'Kentor Reference Implementation proc_a';
      v_activity_table.proc_name       (v_act_ix) := 'kentor_ref_job.proc_a';
      v_activity_table.log_table_ind   (v_act_ix) := 'Y';
      v_activity_table.report_ind      (v_act_ix) := 'Y';

      v_act_ix := v_act_ix + 1;
      v_activity_table.activity_id     (v_act_ix) := 'AAC';
      v_activity_table.activity_name   (v_act_ix) := 'Kentor Reference Implementation proc_b';
      v_activity_table.proc_name       (v_act_ix) := 'kentor_ref_job.proc_b';
      v_activity_table.log_table_ind   (v_act_ix) := 'Y';
      v_activity_table.report_ind      (v_act_ix) := 'Y';

      v_act_ix := v_act_ix + 1;
      v_activity_table.activity_id     (v_act_ix) := 'AAD';
      v_activity_table.activity_name   (v_act_ix) := 'Kentor Reference Implementation proc_c';
      v_activity_table.proc_name       (v_act_ix) := 'kentor_ref_job.proc_c';
      v_activity_table.log_table_ind   (v_act_ix) := 'Y';
      v_activity_table.report_ind      (v_act_ix) := 'Y';

      v_act_ix := v_act_ix + 1;
      v_activity_table.activity_id     (v_act_ix) := 'AAE';
      v_activity_table.activity_name   (v_act_ix) := 'Kentor Reference Implementation util_proc';
      v_activity_table.proc_name       (v_act_ix) := 'kentor_ref_job.util_proc';
      v_activity_table.log_table_ind   (v_act_ix) := 'Y';
      v_activity_table.report_ind      (v_act_ix) := 'Y';

      v_act_ix := v_act_ix + 1;
      v_activity_table.activity_id     (v_act_ix) := 'AAF';
      v_activity_table.activity_name   (v_act_ix) := 'Kentor Reference Implementation get_user_object';
      v_activity_table.proc_name       (v_act_ix) := 'kentor_ref_job_sql.get_user_object';
      v_activity_table.log_table_ind   (v_act_ix) := 'Y';
      v_activity_table.report_ind      (v_act_ix) := 'Y';

      add_rd_error_text (p_in_error_text_table  => v_error_text_table);
      add_rd_batch_parm (p_in_batch_parm_table  => v_batch_parm_table);
      add_rd_activity   (p_in_activity_table    => v_activity_table);
    end create_data;

  procedure add_rd_error_text(p_in_error_text_table in error_text_list) is
/******************************************************************************
*  NAME:    add_rd_error_text
*  PURPOSE: Insert data into inf_error_text from collection passed in. 
*           
* REVISION: 2011-06-08  MAM2 Intial version.
*
******************************************************************************/
  begin
    forall i in 1 .. p_in_error_text_table.error_id.count
    EXECUTE IMMEDIATE
      'insert into kentor_error_text
          (error_id
          ,error_text)
       values (:h1
              ,:h2)'
      using p_in_error_text_table.error_id  (i)
           ,p_in_error_text_table.error_text(i);
  end add_rd_error_text;


  procedure add_rd_batch_parm(p_in_batch_parm_table in batch_parm_list) is
/******************************************************************************
*  NAME:    add_rd_batch_parm
*  PURPOSE: Insert data into kentor_batch_parm from collection passed in. 
*           
* REVISION: 2011-06-15  Initial version.
*
******************************************************************************/
  begin
    forall i in 1 .. p_in_batch_parm_table.batch_id.count
      EXECUTE IMMEDIATE
        'insert into kentor_batch_parms
           (batch_id
           ,batch_name
           ,trace_ind
           ,proc_name_str
           ,instrumentation_level_num)
         values(:h1
               ,:h2
               ,:h3
               ,:h4
               ,:h5)'
        using p_in_batch_parm_table.batch_id      (i)
             ,p_in_batch_parm_table.batch_name    (i)
             ,p_in_batch_parm_table.trace_ind     (i)
             ,p_in_batch_parm_table.proc_name     (i)
             ,p_in_batch_parm_table.instr_level   (i);
  end;


  procedure add_rd_activity(p_in_activity_table in activity_list) is
/******************************************************************************
*  NAME:    add_rd_activity
*  PURPOSE: Insert data into kentor_activities from collection passed in. 
*           
* REVISION: 2011-06-17  Created Procedure (MAM2).
*
******************************************************************************/
  begin
    forall i in 1 .. p_in_activity_table.activity_id.count
      EXECUTE IMMEDIATE
        'insert into kentor_activities
           (activity_id
           ,activity_name
           ,proc_name_str
           ,log_table_ind
           ,report_ind)
         values(:h1
               ,:h2
               ,:h3
               ,:h4
               ,:h5)'
        using p_in_activity_table.activity_id  (i)
             ,p_in_activity_table.activity_name(i)
             ,p_in_activity_table.proc_name    (i)
             ,p_in_activity_table.log_table_ind(i)
             ,p_in_activity_table.report_ind   (i);
  end;
end kentor_objects;
/