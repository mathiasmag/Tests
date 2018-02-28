create or replace package body kentor_instrument as
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
 /*
 * NOTE: Package has initalization code that executes the first time the package 
 *       is invoked in a session.
 *
 *
 */
  s_aud_job_no      kentor_aud_jobs.aud_job_no%type;
  s_proc_name_str   kentor_batch_parms.proc_name_str%type;
  s_instr_level_num kentor_batch_parms.instrumentation_level_num%type;
  s_job_no          kentor_aud_jobs.job_no%type;

  type t_log_activity_list is table of varchar2(1) index by varchar2(3);
  s_log_activity_list t_log_activity_list;
  
  sc_instr_level_full    constant number(1) := 1; -- Full and real time instrumentation
  sc_instr_level_delay   constant number(1) := 2; -- Delay saving instrumentation data to Oracle table
  sc_instr_level_notable constant number(1) := 3; -- Do not save instrumentaton to Oracle table
  sc_instr_level_none    constant number(1) := 4; -- Do no instrumentation at all, except what is done during init.
  
  type t_aud_jobs_detail_list is record (aud_job_no      dbms_sql.number_table
                                        ,function_op_str dbms_sql.varchar2_table
                                        ,start_ts        dbms_sql.timestamp_table
                                        ,stop_ts         dbms_sql.timestamp_table
                                        ,rows_num        dbms_sql.number_table);
  s_aud_jobs_detail_list t_aud_jobs_detail_list;
  
  function get_job_no return number is
  begin
    return s_job_no;
  end get_job_no;

--  function  get_proc_name return varchar2 is
--  begin
--    return s_proc_name_str;
--  end get_proc_name;

  procedure initialize(p_in_batch_id    number) is
    v_trace_ind             kentor_aud_jobs.trace_ind%type;
    v_username_str          kentor_aud_jobs.username_str%type;
    v_osuser_str            kentor_aud_jobs.osuser_str%type;
    v_audsid_num            kentor_aud_jobs.audsid_num%type;
    v_sid_num               kentor_aud_jobs.sid_num%type;
    v_serial#_num           kentor_aud_jobs.serial#_num%type;
    v_client_identifier_str kentor_aud_jobs.client_identifier_str%type;
    v_ip_address_str        kentor_aud_jobs.ip_address_str%type;
    v_terminal_str          kentor_aud_jobs.terminal_str%type;
    v_main_op_str           kentor_aud_jobs.main_op_str%type;
    
    begin
      -- This proc should only be called once per session.
      if s_aud_job_no is not null then
        kentor_error_mgr.report_and_stop(p_in_error_num => kentor_errors.procedure_called_again_num
                                        ,p_in_message_str => 'Job instrumentation has already been initialized');
      end if;
      
      select batch_name
            ,proc_name_str
            ,trace_ind
            ,instrumentation_level_num
        into v_main_op_str
            ,s_proc_name_str
            ,v_trace_ind
            ,s_instr_level_num
        from kentor_batch_parms
       where batch_id = p_in_batch_id;

      dbms_session.set_identifier('KENTOR_BATCH:' || p_in_batch_id); 

      dbms_application_info.set_module(module_name => v_main_op_str
                                      ,action_name => 'INSTRUMENT');
      dbms_application_info.set_client_info(client_info => 'INSTRUMENT');

      v_username_str          := sys_context('USERENV', 'SESSION_USER');
      v_osuser_str            := sys_context('USERENV', 'OS_USER');
      v_audsid_num            := sys_context('USERENV', 'SESSIONID');
      s_job_no                := coalesce(sys_context('USERENV', 'BG_JOB_ID'), sys_context('USERENV', 'FG_JOB_ID'), 0);
      v_client_identifier_str := sys_context('USERENV', 'CLIENT_IDENTIFIER');
      v_ip_address_str        := sys_context('USERENV', 'IP_ADDRESS');
      v_terminal_str          := sys_context('USERENV', 'TERMINAL');

      -- If job is started via dbms_job (i.e in the background) then audsid is 0 and selecting on that will return many 
      -- rows. Matching job to session needs to be done via bg_job_id. If needed this could be changed to get sid from 
      -- v$mystat and then serial# from v$session. That assumes one sid is unique in v$session at any given time. That
      -- would need to be verified.
      if v_audsid_num = 0 then
        v_sid_num     := 0;
        v_serial#_num := 0;
      else
        select sid, serial# into v_sid_num, v_serial#_num from v$session where audsid = v_audsid_num;
      end if;

      if v_trace_ind = 'Y' then
        execute immediate 'alter session set events ''10046 trace name context forever, level 12'''; -- Binds and waits
      end if;
            
      insert into kentor_aud_jobs
            (aud_job_no
            ,job_no
            ,batch_id
            ,trace_ind
            ,username_str
            ,osuser_str
            ,audsid_num
            ,sid_num
            ,serial#_num
            ,main_op_str
            ,client_identifier_str
            ,ip_address_str
            ,terminal_str
            ,instrumentation_level_num)
      values(kentor_misc_seq.nextval
            ,s_job_no
            ,p_in_batch_id
            ,v_trace_ind
            ,v_username_str
            ,coalesce(v_osuser_str, '--BG--')
            ,v_audsid_num
            ,v_sid_num
            ,v_serial#_num
            ,v_main_op_str
            ,v_client_identifier_str
            ,coalesce(v_ip_address_str, '--BG--')
            ,coalesce(v_terminal_str, '--BG--')
            ,s_instr_level_num)
      returning aud_job_no into s_aud_job_no;

      dbms_application_info.set_client_info(client_info => null);
    end initialize;



  procedure set_start_time    (p_in_function_op   varchar2) is
    v_function_op_str varchar2(64);
    
    ix number;
    
    begin
      if not s_instr_level_num = sc_instr_level_none then
        dbms_application_info.read_client_info(client_info => v_function_op_str);
        dbms_application_info.set_client_info(client_info => 'INSTRUMENT');
        
        if v_function_op_str is null then
          v_function_op_str := p_in_function_op;
        else
          v_function_op_str := v_function_op_str || ':' || p_in_function_op;
        end if;
  
        if s_instr_level_num = sc_instr_level_delay or
           s_instr_level_num = sc_instr_level_full        then
          if s_log_activity_list(p_in_function_op) = 'Y' then
            if s_instr_level_num = sc_instr_level_full then
              insert into kentor_aud_jobs_detail
                (aud_job_no
                ,function_op_str
                ,start_ts
                ,stop_ts
                ,rows_num)
              values (s_aud_job_no
                     ,v_function_op_str
                     ,current_timestamp
                     ,current_timestamp
                     ,0);
            else -- The activity is to be logged, but in delayed mode. Just saving to collection for now.
              ix := s_aud_jobs_detail_list.aud_job_no.count + 1;
              
              s_aud_jobs_detail_list.aud_job_no     (ix) := s_aud_job_no;
              s_aud_jobs_detail_list.function_op_str(ix) := v_function_op_str;
              s_aud_jobs_detail_list.start_ts       (ix) := current_timestamp;
              s_aud_jobs_detail_list.stop_ts        (ix) := null;
              s_aud_jobs_detail_list.rows_num       (ix) := null;
            end if;
          end if;
        end if;
  
        dbms_application_info.set_client_info(client_info => v_function_op_str);
      end if;
    end set_start_time;

  procedure set_stop_time     (p_in_function_op   varchar2
                              ,p_in_rows_num      number   := 0) is
    v_function_op_str     varchar2(64);
    v_function_op_str_new varchar2(64);
    
    v_last_colon_num    number(2);
    v_last_activity_str varchar2(64);
    
    begin
      if not s_instr_level_num = sc_instr_level_none then
        dbms_application_info.read_client_info(client_info => v_function_op_str);
        dbms_application_info.set_client_info(client_info => 'INSTRUMENT');
  
        v_last_colon_num    := instr(v_function_op_str, ':', -1);
        v_last_activity_str := substr(v_function_op_str, v_last_colon_num + 1);
  
-- Stop processing if an activity is stopped out of order with how they were started.
        kentor_error_mgr.assert(p_in_condition_bool => p_in_function_op = v_last_activity_str
                               ,p_in_message_str    => null
                               ,p_in_exception_num  => kentor_errors.activity_stopped_oo_order_num);
  
        if s_instr_level_num = sc_instr_level_delay or
           s_instr_level_num = sc_instr_level_full        then
          if s_log_activity_list(p_in_function_op) = 'Y' then
            if s_instr_level_num = sc_instr_level_full then
              update kentor_aud_jobs_detail
                 set stop_ts  = current_timestamp
                    ,rows_num = coalesce(p_in_rows_num,0)
               where aud_job_no      = s_aud_job_no
                 and function_op_str = v_function_op_str
                 and stop_ts         = start_ts;
            else -- The activity is to be logged, but in delayed mode. Just saving to collection for now.
              <<upd_row>>
              for i in reverse 1 .. s_aud_jobs_detail_list.aud_job_no.count
              loop
                if s_aud_jobs_detail_list.function_op_str(i) = v_function_op_str and
                   s_aud_jobs_detail_list.stop_ts        (i) is null                  then
                  s_aud_jobs_detail_list.stop_ts  (i) := current_timestamp;
                  s_aud_jobs_detail_list.rows_num (i) := coalesce(p_in_rows_num,0);
                  
                  exit upd_row;
                end if;
              end loop;
            end if;
          end if;
        end if;
        
        v_function_op_str := substr(v_function_op_str, 1, v_last_colon_num - 1);
  
        dbms_application_info.set_client_info(client_info => v_function_op_str);
      end if;
    exception
      when kentor_errors.activity_stopped_oo_order_exc then
        dbms_application_info.set_client_info(client_info => v_function_op_str);
        raise;
  end set_stop_time;

  
  procedure persist is
  begin
    forall i in 1 .. s_aud_jobs_detail_list.aud_job_no.count
      insert into kentor_aud_jobs_detail
        (aud_job_no
        ,function_op_str
        ,start_ts
        ,stop_ts
        ,rows_num)
      values (s_aud_jobs_detail_list.aud_job_no      (i)
             ,s_aud_jobs_detail_list.function_op_str (i)
             ,s_aud_jobs_detail_list.start_ts        (i)
             ,s_aud_jobs_detail_list.stop_ts         (i)
             ,s_aud_jobs_detail_list.rows_num        (i));
  end persist;




--  Initalization code for the package
 
begin
  for act_row in (select activity_id
                        ,log_table_ind
                    from kentor_activities) loop
    s_log_activity_list(act_row.activity_id) := act_row.log_table_ind;
  end loop;
end kentor_instrument;
