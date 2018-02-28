/*
 *******************************************************************************
 ** Author: MAM2 Mathias Magnusson
 **
 ** Date:   11-06-20
 **
 ** Description:
 ** All acticity codes that can be used to start and stop an actiity will be
 ** defined here.
 **
 ** NOTE that this package only has a specification, it should not have a body as 
 ** it only defines the errors.
 *******************************************************************************
 */
create or replace package kentor_activity_codes as 
   ref_job_main                constant kentor_activities.activity_id%TYPE := 'AAA';
   ref_job_proc_a              constant kentor_activities.activity_id%TYPE := 'AAB';
   ref_job_proc_b              constant kentor_activities.activity_id%TYPE := 'AAC';
   ref_job_proc_c              constant kentor_activities.activity_id%TYPE := 'AAD';
   ref_job_util_proc           constant kentor_activities.activity_id%TYPE := 'AAE';
   ref_job_sql_get_user_object constant kentor_activities.activity_id%TYPE := 'AAF';
end kentor_activity_codes;