CREATE TABLE IF NOT EXISTS tbl_user
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   email_id text,
   password text,
   first_name text,
   last_name text,
   user_role text,
   designation text,
   contact_number text,
   company_code text,
   vendor_id text,
   manager_id text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp
);

CREATE TABLE IF NOT EXISTS tbl_company
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   company_code text UNIQUE,
   title text,
   address text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp
);

CREATE TABLE IF NOT EXISTS tbl_vendor
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   vendor_id text UNIQUE,
   title text,
   address text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp
);

CREATE TABLE IF NOT EXISTS tbl_plant
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   code text UNIQUE,
   name text,
   company_code text,
   address1 text,
   address2 text,
   city text,
   state text,
   zipcode text,
   country text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp
);

CREATE TABLE IF NOT EXISTS tbl_business_unit
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   code text UNIQUE,
   name text,
   description text,
   location text,
   company_code text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp
);

CREATE TABLE IF NOT EXISTS tbl_cost_centre
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   code text UNIQUE,
   name text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp
);

CREATE TABLE IF NOT EXISTS tbl_document
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   name text,
   type text,
   attached_id text,
   attached_type text,
   file_name text,
   file_type text,
   file_path text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp
);

-- name: document Id at other server
-- type(doc_type): work_policy, about_org, requirement, resume/cv, etc
-- attached_id: pk (int) of that table
-- attached_type: job_post_id, job_application_id, etc
-- file_name: dummy.txt
-- file_type: txt
-- file_path: not needed (todo remove this)

CREATE TABLE IF NOT EXISTS tbl_message
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   type text,
   from_user_id text,
   to_user_id text,
   content text,
   send_date timestamp
);

CREATE TABLE IF NOT EXISTS tbl_job_post
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   status text,
   title text,
   description text,
   manager_id text,
   priority text,
   type text,
   open_position text,
   kind text,
   rate money,
   rate_cur text,
   report_date text,
   start_date text,
   end_date text,
   timesheet_freq text,
   work_hours text,
   cost_center text,
   pay_terms text,
   legal_entity text,
   site text,
   business_unit text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp,
   work_hour_interval text
);

-- job_post_status : active, draft, close

CREATE TABLE IF NOT EXISTS tbl_job_post_audit
(
   operation char(1) NOT NULL,
   stamp timestamp NOT NULL,
   id bigint,
   status text,
   title text,
   description text,
   manager_id text,
   priority text,
   type text,
   open_position text,
   kind text,
   rate money,
   rate_cur text,
   report_date text,
   start_date text,
   end_date text,
   timesheet_freq text,
   work_hours text,
   cost_center text,
   pay_terms text,
   legal_entity text,
   site text,
   business_unit text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp,
   work_hour_interval text
);

CREATE OR REPLACE FUNCTION process_job_post_audit() RETURNS TRIGGER AS $job_post_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO tbl_job_post_audit SELECT 'D', now(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO tbl_job_post_audit SELECT 'U', now(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO tbl_job_post_audit SELECT 'I', now(), NEW.*;
        END IF;
        RETURN NULL;
    end;
$job_post_audit$ LANGUAGE plpgsql;

CREATE TRIGGER job_post_audit
AFTER INSERT OR UPDATE OR DELETE ON tbl_job_post
    FOR EACH ROW EXECUTE FUNCTION process_job_post_audit();

CREATE TABLE IF NOT EXISTS tbl_job_application
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   job_post_id bigint,
   status text,
   vendor_id text,
   first_name text,
   last_name text,
   work_exp_months bigint,
   available_date text,
   request_date text,
   rate money,
   rate_cur text,
   other_job_submit text,
   display_workforce text,
   comment text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp,
   worker_id text
);
ALTER TABLE IF EXISTS tbl_job_application ADD COLUMN IF NOT EXISTS worker_id text;   



CREATE TABLE IF NOT EXISTS tbl_job_type
(
   id text PRIMARY KEY,
   name text,
   description text,
   modifier_date timestamp
);

-- This table is mapped with pay_terms column of job post table (tbl_job_post)
CREATE TABLE IF NOT EXISTS tbl_payment_terms
(
   id text PRIMARY KEY,
   name text,
   description text,
   modifier_date timestamp
);

-- This table is maaped with timesheet_freq column of job post table (tbl_job_post)
CREATE TABLE IF NOT EXISTS tbl_timesheet_frequency
(
   id text PRIMARY KEY,
   title text,
   description text,
   modifier_date timestamp
);



CREATE TABLE IF NOT EXISTS tbl_job_application_audit
(
   operation char(1) NOT NULL,
   stamp timestamp NOT NULL,
   id bigint,
   job_post_id bigint,
   status text,
   vendor_id text,
   first_name text,
   last_name text,
   work_exp_months bigint,
   available_date text,
   request_date text,
   rate money,
   rate_cur text,
   other_job_submit text,
   display_workforce text,
   comment text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp
);

CREATE OR REPLACE FUNCTION process_job_application_audit() RETURNS TRIGGER AS $job_application_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO tbl_job_application_audit SELECT 'D', now(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO tbl_job_application_audit SELECT 'U', now(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO tbl_job_application_audit SELECT 'I', now(), NEW.*;
        END IF;
        RETURN NULL;
    end;
$job_application_audit$ LANGUAGE plpgsql;

CREATE TRIGGER job_application_audit
AFTER INSERT OR UPDATE OR DELETE ON tbl_job_application
    FOR EACH ROW EXECUTE FUNCTION process_job_application_audit();
    
    
 ALTER TABLE IF EXISTS tbl_job_application_audit ADD COLUMN IF NOT EXISTS worker_id text;

------------------------------------------------------------------------------

ALTER TABLE IF EXISTS tbl_job_post
    RENAME COLUMN work_per_day TO work_hours;
ALTER TABLE IF EXISTS tbl_job_post_audit
    RENAME COLUMN work_per_day TO work_hours;
ALTER TABLE IF EXISTS tbl_job_post
    ADD COLUMN IF NOT EXISTS work_hour_interval text;
ALTER TABLE IF EXISTS tbl_job_post_audit
    ADD COLUMN IF NOT EXISTS work_hour_interval text;
ALTER TABLE IF EXISTS tbl_job_post
    ADD COLUMN IF NOT EXISTS min_budget money;
ALTER TABLE IF EXISTS tbl_job_post
    ADD COLUMN IF NOT EXISTS max_budget money;
ALTER TABLE IF EXISTS tbl_job_post_audit
    ADD COLUMN IF NOT EXISTS min_budget money;  
ALTER TABLE IF EXISTS tbl_job_post_audit
    ADD COLUMN IF NOT EXISTS max_budget money;   
ALTER TABLE IF EXISTS tbl_work_order
    ADD COLUMN IF NOT EXISTS job_post_id bigint;
ALTER TABLE IF EXISTS tbl_work_order_audit
    ADD COLUMN IF NOT EXISTS job_post_id bigint;
ALTER TABLE IF EXISTS tbl_job_post
    ADD COLUMN IF NOT EXISTS audit_msg text;  
ALTER TABLE IF EXISTS tbl_job_post_audit
    ADD COLUMN IF NOT EXISTS audit_msg text;  
ALTER TABLE IF EXISTS tbl_job_application
    ADD COLUMN IF NOT EXISTS audit_msg text;  
ALTER TABLE IF EXISTS tbl_job_application_audit
    ADD COLUMN IF NOT EXISTS audit_msg text; 
ALTER TABLE IF EXISTS tbl_work_order
    ADD COLUMN IF NOT EXISTS audit_msg text; 
ALTER TABLE IF EXISTS tbl_work_order_audit
    ADD COLUMN IF NOT EXISTS audit_msg text; 

-----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS tbl_work_order
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   status text,
   title text,
   description text,
   manager_id text,
   priority text,
   type text,
   open_position text,
   kind text,
   rate money,
   rate_cur text,
   report_date text,
   start_date text,
   end_date text,
   timesheet_freq text,
   work_hours text,
   cost_center text,
   pay_terms text,
   legal_entity text,
   site text,
   business_unit text,
   max_budget money,
   min_budget money,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp,
   work_hour_interval text
);

 CREATE TABLE IF NOT EXISTS tbl_work_order_audit
(
   operation char(1) NOT NULL,
   stamp timestamp NOT NULL,
   id bigint,
   status text,
   title text,
   description text,
   manager_id text,
   priority text,
   type text,
   open_position text,
   kind text,
   rate money,
   rate_cur text,
   report_date text,
   start_date text,
   end_date text,
   timesheet_freq text,
   work_hours text,
   cost_center text,
   pay_terms text,
   legal_entity text,
   site text,
   business_unit text,
   max_budget money,
   min_budget money,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp,
   work_hour_interval text
);

CREATE OR REPLACE FUNCTION process_work_order_audit() RETURNS TRIGGER AS $work_order_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO tbl_work_order_audit SELECT 'D', now(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO tbl_work_order_audit SELECT 'U', now(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO tbl_work_order_audit SELECT 'I', now(), NEW.*;
        END IF;
        RETURN NULL;
    end;
$work_order_audit$ LANGUAGE plpgsql;

CREATE TRIGGER work_order_audit
AFTER INSERT OR UPDATE OR DELETE ON tbl_work_order
    FOR EACH ROW EXECUTE FUNCTION process_work_order_audit();




CREATE TABLE IF NOT EXISTS tbl_template
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   template_type text,
   name text,
   template_text text,   
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp
);



CREATE TABLE IF NOT EXISTS tbl_job_offer
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   status text,   
   job_post_id text,
   job_app_id text,
   offer_msg text,   
   rate money,
   budget money,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp
);
-- offer status -> OPEN, Accepted, Declined
CREATE TABLE IF NOT EXISTS tbl_task
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   status text,
   title text,
   assignee_id text,
   start_date text,
   finish_date text,
   time_spent text,
   comments text,
   work_order_id bigint,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp,
   audit_msg text
);

 CREATE TABLE IF NOT EXISTS tbl_task_audit
(
   operation char(1) NOT NULL,
   stamp timestamp NOT NULL,
   id bigint,
   status text,
   title text,
   assignee_id text,
   start_date text,
   finish_date text,
   time_spent text,
   comments text,
   work_order_id bigint,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp,
   audit_msg text
);

CREATE OR REPLACE FUNCTION process_task_audit() RETURNS TRIGGER AS $task_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO tbl_task_audit SELECT 'D', now(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO tbl_task_audit SELECT 'U', now(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO tbl_task_audit SELECT 'I', now(), NEW.*;
        END IF;
        RETURN NULL;
    end;
$task_audit$ LANGUAGE plpgsql;

CREATE TRIGGER task_audit
AFTER INSERT OR UPDATE OR DELETE ON tbl_task
    FOR EACH ROW EXECUTE FUNCTION process_task_audit();

ALTER TABLE IF EXISTS tbl_task
    ADD COLUMN IF NOT EXISTS priority text; 
ALTER TABLE IF EXISTS tbl_task_audit
    ADD COLUMN IF NOT EXISTS priority text; 
-----------------------------------------------------------------------

 CREATE TABLE IF NOT EXISTS tbl_work_force
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   first_name text,
   last_name text,
   gender text,
   work_email text,
   personal_email text,
   work_phone text,
   mobile_phone text,
   date_of_birth text,
   blood_group text,
   designation text,
   location text,
   current_address text,
   permanent_address text,
   vendor_id text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp,
   audit_msg text
);

 CREATE TABLE IF NOT EXISTS tbl_work_force_audit
(
   operation char(1) NOT NULL,
   stamp timestamp NOT NULL,
   id bigint,
   first_name text,
   last_name text,
   gender text,
   work_email text,
   personal_email text,
   work_phone text,
   mobile_phone text,
   date_of_birth text,
   blood_group text,
   designation text,
   location text,
   current_address text,
   permanent_address text,
   vendor_id text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp,
   audit_msg text
);

CREATE OR REPLACE FUNCTION process_work_force_audit() RETURNS TRIGGER AS $work_force_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO tbl_work_force_audit SELECT 'D', now(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO tbl_work_force_audit SELECT 'U', now(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO tbl_work_force_audit SELECT 'I', now(), NEW.*;
        END IF;
        RETURN NULL;
    end;
$work_force_audit$ LANGUAGE plpgsql;

CREATE TRIGGER work_force_audit
AFTER INSERT OR UPDATE OR DELETE ON tbl_work_force
    FOR EACH ROW EXECUTE FUNCTION process_work_force_audit();

--------------------------------------------------------------------------------------------------

  CREATE TABLE IF NOT EXISTS tbl_time_sheet
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   employee_id text,
   work_order_id bigint,
   from_date text,
   to_date text,
   comments text,
   total_time_spent text,
   vendor_id text,
   status text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp,
   audit_msg text
);

 CREATE TABLE IF NOT EXISTS tbl_time_sheet_audit
(
   operation char(1) NOT NULL,
   stamp timestamp NOT NULL,
   id bigint,
   employee_id text,
   work_order_id bigint,
   from_date text,
   to_date text,
   comments text,
   total_time_spent text,
   vendor_id text,
   status text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp,
   audit_msg text
);

CREATE OR REPLACE FUNCTION process_time_sheet_audit() RETURNS TRIGGER AS $time_sheet_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO tbl_time_sheet_audit SELECT 'D', now(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO tbl_time_sheet_audit SELECT 'U', now(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO tbl_time_sheet_audit SELECT 'I', now(), NEW.*;
        END IF;
        RETURN NULL;
    end;
$time_sheet_audit$ LANGUAGE plpgsql;

CREATE TRIGGER time_sheet_audit
AFTER INSERT OR UPDATE OR DELETE ON tbl_time_sheet
    FOR EACH ROW EXECUTE FUNCTION process_time_sheet_audit();
    
-------------------------------------------------------------------------------------------------------------
ALTER TABLE IF EXISTS tbl_task
    ADD COLUMN IF NOT EXISTS time_sheet_id bigint; 
ALTER TABLE IF EXISTS tbl_task_audit
    ADD COLUMN IF NOT EXISTS time_sheet_id bigint; 
    
ALTER TABLE IF EXISTS tbl_work_order
    ADD COLUMN IF NOT EXISTS vendor_id text; 
ALTER TABLE IF EXISTS tbl_work_order_audit
    ADD COLUMN IF NOT EXISTS vendor_id text; 
    
ALTER TABLE IF EXISTS tbl_work_force
    ADD COLUMN IF NOT EXISTS title text; 
ALTER TABLE IF EXISTS tbl_work_force_audit
    ADD COLUMN IF NOT EXISTS title text;
    
ALTER TABLE IF EXISTS tbl_work_force
    ADD COLUMN IF NOT EXISTS description text; 
ALTER TABLE IF EXISTS tbl_work_force_audit
    ADD COLUMN IF NOT EXISTS description text;
    
ALTER TABLE IF EXISTS tbl_work_force
    ADD COLUMN IF NOT EXISTS user_id text; 
ALTER TABLE IF EXISTS tbl_work_force_audit
    ADD COLUMN IF NOT EXISTS user_id text;
 
ALTER TABLE IF EXISTS tbl_work_force
    ADD COLUMN IF NOT EXISTS work_experience INT; 
ALTER TABLE IF EXISTS tbl_work_force_audit
    ADD COLUMN IF NOT EXISTS work_experience INT;
    
--------------------------------------------
 Date: 23-jul-2023
 
ALTER TABLE IF EXISTS tbl_vendor ADD COLUMN IF NOT EXISTS email_id text;
ALTER TABLE IF EXISTS tbl_vendor ADD COLUMN IF NOT EXISTS phone text;

 ---------------------------------------   
    
  CREATE TABLE IF NOT EXISTS tbl_notification
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   work_order_id bigint,
   vendor_id text,
   user_id text,
   notification_date text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp
);

 CREATE TABLE IF NOT EXISTS tbl_notification_audit
(
   operation char(1) NOT NULL,
   stamp timestamp NOT NULL,
   id bigint,
   work_order_id bigint,
   vendor_id text,
   user_id text,
   notification_date text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp
);

CREATE OR REPLACE FUNCTION process_notification_audit() RETURNS TRIGGER AS $notification_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO tbl_notification_audit SELECT 'D', now(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO tbl_notification_audit SELECT 'U', now(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO tbl_notification_audit SELECT 'I', now(), NEW.*;
        END IF;
        RETURN NULL;
    end;
$notification_audit$ LANGUAGE plpgsql;

CREATE TRIGGER notification_audit
AFTER INSERT OR UPDATE OR DELETE ON tbl_notification
    FOR EACH ROW EXECUTE FUNCTION process_notification_audit();  
    
    
    
    
CREATE TABLE IF NOT EXISTS tbl_invoice
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   invoice_num text UNIQUE,
   string status,
   work_order_id bigint,   
   amount money,
   tax_percentage money,
   total_amount money,
   currency text,
   invoice_date timestamp,
   vendor_title text,
   vendor_address text,
   vendor_code text,
   timesheet_list text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp
);
-----------------------------------------------------------------------

ALTER TABLE tbl_task
  RENAME COLUMN time_spent TO estimated_time;

ALTER TABLE tbl_task
  DROP COLUMN time_sheet_id;


ALTER TABLE tbl_task_audit
  RENAME COLUMN time_spent TO estimated_time;

ALTER TABLE tbl_task_audit
  DROP COLUMN time_sheet_id;

  CREATE TABLE IF NOT EXISTS tbl_timesheet_task
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   time_sheet_id bigint,
   task_id bigint,
   time_spent numeric,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp
);

 CREATE TABLE IF NOT EXISTS tbl_timesheet_task_audit
(
   operation char(1) NOT NULL,
   stamp timestamp NOT NULL,
   id bigint,
   time_sheet_id bigint,
   task_id bigint,
   time_spent numeric,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp
);

CREATE OR REPLACE FUNCTION process_timesheet_task_audit() RETURNS TRIGGER AS $timesheet_task_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO tbl_timesheet_task_audit SELECT 'D', now(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO tbl_timesheet_task_audit SELECT 'U', now(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO tbl_timesheet_task_audit SELECT 'I', now(), NEW.*;
        END IF;
        RETURN NULL;
    end;
$timesheet_task_audit$ LANGUAGE plpgsql;

CREATE TRIGGER timesheet_task_audit
AFTER INSERT OR UPDATE OR DELETE ON tbl_timesheet_task
    FOR EACH ROW EXECUTE FUNCTION process_timesheet_task_audit();  


ALTER TABLE tbl_timesheet_task 
ADD COLUMN start_date text;

ALTER TABLE tbl_timesheet_task
ADD COLUMN due_date text;

ALTER TABLE tbl_timesheet_task_audit 
ADD COLUMN start_date text;

ALTER TABLE tbl_timesheet_task_audit 
ADD COLUMN due_date text;
   
   
   
ALTER TABLE tbl_task ADD COLUMN vendor_id text;
ALTER TABLE tbl_task_audit ADD COLUMN vendor_id text;

ALTER TABLE tbl_notification       ADD COLUMN type text;
ALTER TABLE tbl_notification_audit ADD COLUMN type text;

ALTER TABLE tbl_notification       ADD COLUMN target_id bigint;
ALTER TABLE tbl_notification_audit ADD COLUMN target_id bigint;

ALTER TABLE tbl_notification       ADD COLUMN audit_msg text;
ALTER TABLE tbl_notification_audit ADD COLUMN audit_msg text;


ALTER TABLE tbl_notification        DROP COLUMN work_order_id;
ALTER TABLE tbl_notification_audit  DROP COLUMN work_order_id;

ALTER TABLE tbl_notification        DROP COLUMN notification_date;
ALTER TABLE tbl_notification_audit  DROP COLUMN notification_date;

ALTER TABLE tbl_vendor   ADD COLUMN owner_user_id text;
   
CREATE TABLE IF NOT EXISTS tbl_currencies
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   code text UNIQUE,
   title text
);    


------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS tbl_invoice
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   invoice_num text UNIQUE,
   status text,
   invoice_date text,
   due_date text,
   work_order_id bigint,   
   amount numeric,
   tax_percentage numeric,
   total_amount numeric,
   currency text,
   vendor_id text,
   vendor_address text,
   company_code text,
   company_address text,
   comments text,
   audit_msg text,
   timesheet_list text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp
);

 CREATE TABLE IF NOT EXISTS tbl_invoice_audit
(
   operation char(1) NOT NULL,
   stamp timestamp NOT NULL,
   id bigint,
   invoice_num text UNIQUE,
   status text,
   invoice_date text,
   due_date text,
   work_order_id bigint,   
   amount numeric,
   tax_percentage numeric,
   total_amount numeric,
   currency text,
   vendor_id text,
   vendor_address text,
   company_code text,
   company_address text,
   comments text,
   audit_msg text,
   timesheet_list text,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp
);

CREATE OR REPLACE FUNCTION process_invoice_audit() RETURNS TRIGGER AS $invoice_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO tbl_invoice_audit SELECT 'D', now(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO tbl_invoice_audit SELECT 'U', now(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO tbl_invoice_audit SELECT 'I', now(), NEW.*;
        END IF;
        RETURN NULL;
    end;
$invoice_audit$ LANGUAGE plpgsql;

CREATE TRIGGER invoice_audit
AFTER INSERT OR UPDATE OR DELETE ON tbl_invoice
    FOR EACH ROW EXECUTE FUNCTION process_invoice_audit();  



 CREATE TABLE IF NOT EXISTS tbl_invoice_timesheet
(
   id bigint GENERATED ALWAYS AS IDENTITY (MINVALUE 1 START WITH 1) PRIMARY KEY,
   time_sheet_id bigint,
   invoice_id bigint,
   hours numeric,
   rate numeric,
   amount numeric,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp
);

 CREATE TABLE IF NOT EXISTS tbl_invoice_timesheet_audit
(
   operation char(1) NOT NULL,
   stamp timestamp NOT NULL,
   id bigint,
   time_sheet_id bigint,
   invoice_id bigint,
   hours numeric,
   rate numeric,
   amount numeric,
   register_id text,
   register_date timestamp,
   modifier_id text,
   modifier_date timestamp  
);

CREATE OR REPLACE FUNCTION process_invoice_timesheet_audit() RETURNS TRIGGER AS $invoice_timesheet_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO tbl_invoice_timesheet_audit SELECT 'D', now(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO tbl_invoice_timesheet_audit SELECT 'U', now(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO tbl_invoice_timesheet_audit SELECT 'I', now(), NEW.*;
        END IF;
        RETURN NULL;
    end;
$invoice_timesheet_audit$ LANGUAGE plpgsql;

CREATE TRIGGER invoice_timesheet_audit
AFTER INSERT OR UPDATE OR DELETE ON tbl_invoice_timesheet
    FOR EACH ROW EXECUTE FUNCTION process_invoice_timesheet_audit();



ALTER TABLE tbl_notification  ADD COLUMN read_status text;
ALTER TABLE tbl_notification_audit  ADD COLUMN read_status text;

-----------------
5 AUg 2023
----------------

ALTER TABLE tbl_task ALTER COLUMN estimated_time  TYPE numeric USING (estimated_time::integer);
ALTER TABLE tbl_task_audit ALTER COLUMN estimated_time  TYPE numeric USING (estimated_time::integer);
    
    