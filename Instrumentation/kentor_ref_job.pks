create or replace package kentor_ref_job as
/*
 Author: MAM2 Mathias Magnusson

 Date:   11-06-07

 Description:
 Reference implementation showing use of infrastructure and instrumentation with the Kentor infrastructure packages.
 
 Change Log:
 Name    Date      Description
 =======================================================================================================================
 MAM2    11-06-08  Inital Version
 */
 
-- A job package should have only one externally exposed procedure, main which is
-- used to kick off the job.
  procedure main;
end kentor_ref_job;