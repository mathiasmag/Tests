/*
 *******************************************************************************
 ** Author: MAM2 Mathias Magnusson
 **
 ** Date:   11-06-08
 **
 ** Description:
 ** All errors that can be thrown will be defined here.
 **
 ** NOTE that this package only has a specification, it should not have a body as 
 ** it only defines the errors.
 *******************************************************************************
 */
create or replace package kentor_errors as 
-- Thrown when an invalid value is passed to a function or procedure. For example
-- if a month is not 1-12.
   invalid_value_in_parameter_exc exception;
   invalid_value_in_parameter_num constant integer := -20000;
   pragma exception_init(invalid_value_in_parameter_exc, -20000);

-- Thrown when job initialization is called again
   procedure_called_again_exc exception;
   procedure_called_again_num constant integer := -20001;
   pragma exception_init(procedure_called_again_exc, -20001);

-- Thrown when instrumented acticities are stopped out of order
   activity_stopped_oo_order_exc exception;
   activity_stopped_oo_order_num constant integer := -20002;
   pragma exception_init(activity_stopped_oo_order_exc, -20002);
end kentor_errors;