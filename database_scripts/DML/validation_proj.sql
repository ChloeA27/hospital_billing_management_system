-- Query 1: Count rows in each table
SELECT 'Patient' AS TableName, COUNT(*) AS RecordCount FROM Patient
UNION ALL 
SELECT 'Insurance_Company' AS TableName, COUNT(*) AS RecordCount FROM Insurance_Company
UNION ALL 
SELECT 'Insurance_Policy' AS TableName, COUNT(*) AS RecordCount FROM Insurance_Policy
UNION ALL 
SELECT 'Location' AS TableName, COUNT(*) AS RecordCount FROM Location
UNION ALL 
SELECT 'Encounter' AS TableName, COUNT(*) AS RecordCount FROM Encounter
UNION ALL 
SELECT 'Provider' AS TableName, COUNT(*) AS RecordCount FROM Provider
UNION ALL 
SELECT 'Encounter_Provider' AS TableName, COUNT(*) AS RecordCount FROM Encounter_Provider
UNION ALL 
SELECT 'Clinical_Order' AS TableName, COUNT(*) AS RecordCount FROM Clinical_Order
UNION ALL 
SELECT 'Dictionary' AS TableName, COUNT(*) AS RecordCount FROM Dictionary
UNION ALL 
SELECT 'Order_Item' AS TableName, COUNT(*) AS RecordCount FROM Order_Item
UNION ALL 
SELECT 'Billing_Charge' AS TableName, COUNT(*) AS RecordCount FROM Billing_Charge
UNION ALL 
SELECT 'Claim' AS TableName, COUNT(*) AS RecordCount FROM Claim
UNION ALL 
SELECT 'Claim_Charge' AS TableName, COUNT(*) AS RecordCount FROM Claim_Charge
UNION ALL 
SELECT 'Payment' AS TableName, COUNT(*) AS RecordCount FROM Payment
UNION ALL 
SELECT 'Patient_Payment' AS TableName, COUNT(*) AS RecordCount FROM Patient_Payment
UNION ALL 
SELECT 'Claim_Payment' AS TableName, COUNT(*) AS RecordCount FROM Claim_Payment
ORDER BY TableName;

-- Query 2: Verify claim amounts match sum of charges
SELECT 
    c.claim_id,
    c.claim_amount,
    SUM(cc.billed_amount) AS sum_of_charges,
    c.claim_amount - SUM(cc.billed_amount) AS difference
FROM Claim c
JOIN Claim_Charge cc ON c.claim_id = cc.claim_id
GROUP BY c.claim_id, c.claim_amount
HAVING c.claim_amount <> SUM(cc.billed_amount);

-- Query 3: View patient payments with charges covered (N:1 relationship)
SELECT 
    pp.patient_payment_id,
    p.patient_name,
    pay.payment_date,
    pay.amount_paid,
    COUNT(bc.billing_charge_id) AS num_charges_paid
FROM Patient_Payment pp
JOIN Payment pay ON pp.payment_id = pay.payment_id
JOIN (SELECT patient_id, first_name + ' ' + last_name AS patient_name FROM Patient) p 
    ON pp.patient_id = p.patient_id
LEFT JOIN Billing_Charge bc ON pp.patient_payment_id = bc.patient_payment_id
GROUP BY pp.patient_payment_id, p.patient_name, pay.payment_date, pay.amount_paid
ORDER BY pp.patient_payment_id;

-- Query 4: Payment type distribution
SELECT 
    payment_type,
    COUNT(*) AS num_payments,
    SUM(amount_paid) AS total_amount
FROM Payment
GROUP BY payment_type;

-- Query 5: View encounters with billing summary
SELECT 
    e.encounter_id,
    pat.first_name + ' ' + pat.last_name AS patient_name,
    e.encounter_type,
    e.date AS encounter_date,
    COUNT(DISTINCT bc.billing_charge_id) AS num_charges
FROM Encounter e
JOIN Patient pat ON e.patient_id = pat.patient_id
LEFT JOIN Billing_Charge bc ON e.encounter_id = bc.encounter_id
GROUP BY e.encounter_id, pat.first_name, pat.last_name, e.encounter_type, e.date
ORDER BY e.encounter_id;

GO