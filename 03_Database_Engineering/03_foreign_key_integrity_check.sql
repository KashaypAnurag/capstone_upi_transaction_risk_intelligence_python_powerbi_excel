USE upi_analytics_db;

-- CHECKPOINT 1: Verify device logs map back to valid customer profiles
SELECT '1. device_info -> customer_master' AS audit_checkpoint, COUNT(d.device_id) AS orphan_row_count
FROM device_info d
LEFT JOIN customer_master c ON d.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

-- CHECKPOINT 2: Verify banking handles map back to valid customer profiles
SELECT '2. upi_account_details -> customer_master', COUNT(u.upi_id)
FROM upi_account_details u
LEFT JOIN customer_master c ON u.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

-- CHECKPOINT 3: Verify transaction ledgers link back to registered customers
SELECT '3. upi_transaction_history -> customer_master', COUNT(t.transaction_id)
FROM upi_transaction_history t
LEFT JOIN customer_master c ON t.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

-- CHECKPOINT 4: Verify transactions tie back to active bank handles
SELECT '4. upi_transaction_history -> upi_account_details', COUNT(t.transaction_id)
FROM upi_transaction_history t
LEFT JOIN upi_account_details u ON t.upi_id = u.upi_id
WHERE u.upi_id IS NULL

UNION ALL

-- CHECKPOINT 5: Verify transactions map to captured hardware telemetry
SELECT '5. upi_transaction_history -> device_info', COUNT(t.transaction_id)
FROM upi_transaction_history t
LEFT JOIN device_info d ON t.device_id = d.device_id
WHERE d.device_id IS NULL

UNION ALL

-- CHECKPOINT 6: Verify merchant checkouts link to onboarded business profiles 
-- (Excludes P2P entries where merchant_id is natively NULL)
SELECT '6. upi_transaction_history -> merchant_info', COUNT(t.transaction_id)
FROM upi_transaction_history t
LEFT JOIN merchant_info m ON t.merchant_id = m.merchant_id
WHERE t.merchant_id IS NOT NULL AND m.merchant_id IS NULL

UNION ALL

-- CHECKPOINT 7: Verify tracking alerts hook into a historical transaction record
SELECT '7. fraud_alert_history -> upi_transaction_history', COUNT(f.alert_id)
FROM fraud_alert_history f
LEFT JOIN upi_transaction_history t ON f.transaction_id = t.transaction_id
WHERE t.transaction_id IS NULL

UNION ALL

-- CHECKPOINT 8: Verify survey results are anchored to an existing user profile
SELECT '8. customer_feedback_surveys -> customer_master', COUNT(s.feedback_id)
FROM customer_feedback_surveys s
LEFT JOIN customer_master c ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
