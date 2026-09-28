#Creating DB for all tables.
CREATE DATABASE upi_analytics_db;
USE upi_analytics_db;

## CREATING CUSTOMER MASTER TABLE
CREATE TABLE customer_master (
    customer_id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    mobile_number VARCHAR(20) UNIQUE NOT NULL,
    age INT,
    gender VARCHAR(20),
    region VARCHAR(50),
    date_joined DATE NOT NULL,
    is_business_user BOOLEAN DEFAULT FALSE,
    risk_score DECIMAL(7,6),
    CONSTRAINT chk_customer_age CHECK (age >= 18 AND age <= 120),
    CONSTRAINT chk_customer_risk CHECK (risk_score >= 0.000000 AND risk_score <= 1.000000)
);

# CREATING MERCHANT INFO TABLE
CREATE TABLE merchant_info (
    merchant_id VARCHAR(50) PRIMARY KEY,
    merchant_name VARCHAR(100) NOT NULL,
    merchant_type VARCHAR(50) NOT NULL,
    region VARCHAR(50),
    onboarding_date DATE NOT NULL,
    risk_score DECIMAL(7,6),
    CONSTRAINT chk_merchant_risk CHECK (risk_score >= 0.000000 AND risk_score <= 1.000000)
);

# CREATING DEVICE INFO TABLE
CREATE TABLE device_info (
    device_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    device_type VARCHAR(50) NOT NULL,
    app_version VARCHAR(30) NOT NULL,
    is_rooted BOOLEAN NOT NULL DEFAULT FALSE,
    last_active DATETIME NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id) ON DELETE RESTRICT
);

# CREATING UPI ACCOUNT DETAILS TABLE
CREATE TABLE upi_account_details (
    upi_id VARCHAR(100) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    bank_name VARCHAR(50) NOT NULL,
    account_type VARCHAR(30) NOT NULL,
    date_added DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id) ON DELETE RESTRICT
);

# CREATING CENTRAL Fact LOG TABLE: upi_transaction_history
CREATE TABLE upi_transaction_history (
    transaction_id VARCHAR(50) PRIMARY KEY,
    upi_id VARCHAR(100) NOT NULL,
    customer_id VARCHAR(50) NOT NULL,
    timestamp DATETIME NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    transaction_type VARCHAR(30) NOT NULL,
    merchant_id VARCHAR(50),
    counterparty_upi VARCHAR(100),
    status VARCHAR(30) NOT NULL,
    device_id VARCHAR(50) NOT NULL,
    device_type VARCHAR(30) NOT NULL,
    channel VARCHAR(30) NOT NULL,
    fraud_flag BOOLEAN NOT NULL DEFAULT FALSE,
    reversal_flag BOOLEAN NOT NULL DEFAULT FALSE,
    failure_reason VARCHAR(255),
    
    CONSTRAINT chk_tx_amount CHECK (amount > 0.00),
    
    FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id) ON DELETE RESTRICT,
    FOREIGN KEY (merchant_id) REFERENCES merchant_info(merchant_id) ON DELETE SET NULL,
    FOREIGN KEY (upi_id) REFERENCES upi_account_details(upi_id) ON DELETE RESTRICT,
    FOREIGN KEY (device_id) REFERENCES device_info(device_id) ON DELETE RESTRICT
);

# CREATING FRAUD ALERT HISTORY TABLE
CREATE TABLE fraud_alert_history (
    alert_id VARCHAR(50) PRIMARY KEY,
    transaction_id VARCHAR(50) NOT NULL,
    alert_type VARCHAR(50) NOT NULL,
    alert_date DATETIME NOT NULL,
    resolved BOOLEAN NOT NULL DEFAULT FALSE,
    resolution_date DATETIME,
    remarks TEXT,
    
    FOREIGN KEY (transaction_id) REFERENCES upi_transaction_history(transaction_id) ON DELETE CASCADE
);

# CREATING CUSTOMER FEEDBACK SURVEYS TABLE
CREATE TABLE customer_feedback_surveys (
    feedback_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    date_submitted DATE NOT NULL,
    feedback_text TEXT,
    satisfaction_score INT NOT NULL,
    issue_type VARCHAR(50) NOT NULL,
    resolved BOOLEAN NOT NULL DEFAULT FALSE,
    
    CONSTRAINT chk_feedback_score CHECK (satisfaction_score >= 1 AND satisfaction_score <= 5),
    
    FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id) ON DELETE RESTRICT
);

