create or replace package kentor_error_mgr as
   procedure report_and_stop(p_in_error_num      in integer  := sqlcode
                            ,p_in_message_str    in varchar2 := null);

   procedure report_and_go  (p_in_error_num      in integer  := sqlcode 
                            ,p_in_message_str    in varchar2 := null);
   
   procedure assert         (p_in_condition_bool in boolean
                            ,p_in_message_str    in varchar2
                            ,p_in_exception_num  in number);
end kentor_error_mgr;
