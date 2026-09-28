USE upi_analytics_db;

##--1. LOAD CUSTOMER MASTER--##
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\customer_master - customer_master.csv"
INTO TABLE customer_master
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(customer_id, full_name, mobile_number, age, gender, region, date_joined, is_business_user, risk_score);

SET SQL_SAFE_UPDATES = 0;

UPDATE customer_master 
SET is_business_user = CASE 
    WHEN UPPER(TRIM(is_business_user)) IN ('TRUE', '1') THEN '1' 
    ELSE '0' 
END;

ALTER TABLE customer_master MODIFY COLUMN is_business_user BOOLEAN DEFAULT FALSE;

SET SQL_SAFE_UPDATES = 1;

SELECT COUNT(*) AS 'Total Rows Injected' FROM customer_master;
##-- ===================================================================== --##


##-- 2. LOAD MERCHANT INFO --##
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\merchant_info - merchant_info.csv"
INTO TABLE merchant_info
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(merchant_id, merchant_name, merchant_type, region, onboarding_date, risk_score, @dummy1, @dummy2);

SELECT COUNT(*) AS 'Merchant Rows Ingested' FROM merchant_info;
##-- ===================================================================== --##


##-- 3. LOAD DEVICE INFO--##
ALTER TABLE device_info MODIFY COLUMN is_rooted VARCHAR(20);

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\device_info - device_info.csv"
INTO TABLE device_info
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(device_id, customer_id, device_type, app_version, is_rooted, last_active, @dummy_val);

SET SQL_SAFE_UPDATES = 0;

UPDATE device_info 
SET is_rooted = CASE 
    WHEN UPPER(TRIM(is_rooted)) IN ('TRUE', '1') THEN '1' 
    ELSE '0' 
END;

ALTER TABLE device_info MODIFY COLUMN is_rooted BOOLEAN NOT NULL DEFAULT FALSE;

SET SQL_SAFE_UPDATES = 1;

SELECT COUNT(*) AS 'Device Rows Ingested' FROM device_info;

SELECT 'merchant_info' AS table_name, COUNT(*) AS row_count FROM merchant_info
UNION ALL
SELECT 'device_info', COUNT(*) FROM device_info;
##-- ================================================================ --##

##-- 4.LOAD UPI ACCOUNT DETAILS --##
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\upi_account_details - upi_account_details.csv"
INTO TABLE upi_account_details
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(upi_id, customer_id, bank_name, account_type, date_added, status, @dummy_val);

SELECT COUNT(*) AS 'UPI Account Details Rows Ingested' FROM upi_account_details;
##-- ==============================================================================--##

##-- 5.LOAD UPI TRANSACTION HISTORY  --##
ALTER TABLE upi_transaction_history MODIFY COLUMN fraud_flag VARCHAR(20);
ALTER TABLE upi_transaction_history MODIFY COLUMN reversal_flag VARCHAR(20);

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\upi_transaction_history - upi_transaction_history.csv"
INTO TABLE upi_transaction_history
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(transaction_id, upi_id, customer_id, timestamp, amount, transaction_type, @raw_merchant_id, counterparty_upi, status, device_id, device_type, channel, fraud_flag, reversal_flag, failure_reason, 
 @dummy_cust_val, @dummy_merch_val, @dummy_upi_val, @dummy_dev_val)
SET merchant_id = NULLIF(TRIM(@raw_merchant_id), '');

SET SQL_SAFE_UPDATES = 0;

UPDATE upi_transaction_history 
SET 
    fraud_flag = CASE WHEN UPPER(TRIM(fraud_flag)) IN ('TRUE', '1') THEN 1 ELSE 0 END,
    reversal_flag = CASE WHEN UPPER(TRIM(reversal_flag)) IN ('TRUE', '1') THEN 1 ELSE 0 END;

ALTER TABLE upi_transaction_history MODIFY COLUMN fraud_flag BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE upi_transaction_history MODIFY COLUMN reversal_flag BOOLEAN NOT NULL DEFAULT FALSE;

SET SQL_SAFE_UPDATES = 1;

SELECT COUNT(*) AS 'Total Transaction Hub Rows Ingested' FROM upi_transaction_history;
##-- ===================================================================================== --##

##-- 6.LOAD FRAUD ALERT HISTORY --##
ALTER TABLE fraud_alert_history MODIFY COLUMN resolved VARCHAR(20);

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\fraud_alert_history - fraud_alert_history.csv"
INTO TABLE fraud_alert_history
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(alert_id, transaction_id, alert_type, alert_date, resolved, @raw_resolution_date, remarks, @dummy_val)
SET resolution_date = NULLIF(TRIM(@raw_resolution_date), '');

SET SQL_SAFE_UPDATES = 0;

UPDATE fraud_alert_history 
SET resolved = CASE WHEN UPPER(TRIM(resolved)) IN ('TRUE', '1') THEN 1 ELSE 0 END;

ALTER TABLE fraud_alert_history MODIFY COLUMN resolved BOOLEAN NOT NULL DEFAULT FALSE;

SET SQL_SAFE_UPDATES = 1;

SELECT COUNT(*) AS 'Fraud Alert History Rows Ingested' FROM fraud_alert_history;
##-- =============================================================================== --##


##-- 7.LOAD CUSTOMER FEEDBACK SURVEY --##
ALTER TABLE customer_feedback_surveys MODIFY COLUMN resolved VARCHAR(20);

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\customer_feedback_surveys - customer_feedback_surveys.csv"
INTO TABLE customer_feedback_surveys
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(feedback_id, customer_id, date_submitted, feedback_text, satisfaction_score, issue_type, resolved, @dummy_val);

SET SQL_SAFE_UPDATES = 0;

UPDATE customer_feedback_surveys 
SET resolved = CASE WHEN UPPER(TRIM(resolved)) IN ('TRUE', '1') THEN 1 ELSE 0 END;

ALTER TABLE customer_feedback_surveys MODIFY COLUMN resolved BOOLEAN NOT NULL DEFAULT FALSE;

SET SQL_SAFE_UPDATES = 1;

SELECT COUNT(*) AS 'Customer Feedback Surveys Rows Ingested' FROM customer_feedback_surveys;
