create or replace package body kentor_error_mgr as
-- Internal functions
  procedure log_error(p_in_error_num in integer
                     ,p_in_error_str in varchar2);
  procedure handle   (p_in_error_num     in integer
                     ,P_in_error_str     in varchar2    := NULL
                     ,p_in_log_error_ind in boolean
                     ,p_in_reraise_ind   in boolean);

  procedure handle(p_in_error_num     in integer
                  ,P_in_error_str     in varchar2    := NULL
                  ,p_in_log_error_ind in boolean
                  ,p_in_reraise_ind   in boolean) is

    v_error_num pls_integer    := NVL(p_in_error_num, SQLCODE);
    v_error_str varchar2(255);

  begin
    select error_text 
      into v_error_str 
      from kentor_error_text 
     where error_id = v_error_num;

    if p_in_log_error_ind then
      log_error(v_error_num, p_in_error_str);
    end if;

    if p_in_reraise_ind then
      if v_error_num between -20999 and -20000 then
        raise_application_error (v_error_num, v_error_str || ':' || p_in_error_str);
      else -- For normal SQL codes
        execute immediate 'declare myexc exception; '        ||
                          '  pragma exception_init (myexc, ' ||
                           to_char (p_in_error_num) || ');'  ||
                          'begin raise myexc; end;';
      end if;
    end if;
  end handle;

  procedure log_error(p_in_error_num in integer
                     ,p_in_error_str in varchar2) is
  pragma AUTONOMOUS_TRANSACTION;
      
  begin
    insert 
      into kentor_error_log
          (aud_job_no
          ,error_num
          ,error_str
          ,call_stack
          ,log_ts)
    values(kentor_instrument.get_job_no
          ,p_in_error_num
          ,p_in_error_str
          ,dbms_utility.format_call_stack()
          ,current_timestamp);
    commit;
   end log_error;
   
-- External (exposed) functions
  procedure report_and_stop(p_in_error_num   in integer  := sqlcode
                           ,p_in_message_str in varchar2 := null) is
  begin
    handle(p_in_error_num, p_in_message_str, true, true);
  end report_and_stop;

  procedure report_and_go(p_in_error_num   in integer  := sqlcode 
                         ,p_in_message_str in varchar2 := null) is
  begin
    handle(p_in_error_num, p_in_message_str, true, false);
  end report_and_go;

  procedure assert(p_in_condition_bool in boolean
                  ,p_in_message_str    in varchar2
                  ,p_in_exception_num  in number) is
  begin
    if not p_in_condition_bool or
           p_in_condition_bool is null then
      dbms_output.put_line('Assertion Failure! - ' || p_in_message_str);

      report_and_stop(p_in_error_num   => p_in_exception_num
                     ,p_in_message_str => p_in_message_str);
    end if;
  end assert;
end kentor_error_mgr;