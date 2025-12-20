-- 1. Insert Patients (10 rows)
INSERT INTO Patient (first_name, last_name, dob, gender, emergency_contact_phone, phone)
VALUES
('John', 'Smith', '1985-03-15', 'Male', '555-0101', '555-0100'),
('Sarah', 'Johnson', '1990-07-22', 'Female', '555-0201', '555-0200'),
('Michael', 'Williams', '1978-11-08', 'Male', '555-0301', '555-0300'),
('Emily', 'Brown', '1995-02-14', 'Female', '555-0401', '555-0400'),
('David', 'Jones', '1982-09-30', 'Male', '555-0501', '555-0500'),
('Jessica', 'Garcia', '1988-05-17', 'Female', '555-0601', '555-0600'),
('Christopher', 'Miller', '1975-12-03', 'Male', '555-0701', '555-0700'),
('Amanda', 'Davis', '1992-08-25', 'Female', '555-0801', '555-0800'),
('Matthew', 'Rodriguez', '1986-04-12', 'Male', '555-0901', '555-0900'),
('Jennifer', 'Martinez', '1991-10-19', 'Female', '555-1001', '555-1000');

-- 2. Insert Insurance Companies (10 rows)
INSERT INTO Insurance_Company (name, company_country, company_state, company_city, company_zipcode, email)
VALUES
('Blue Cross Blue Shield', 'USA', 'MA', 'Boston', '02101', 'info@bcbs.com'),
('Aetna', 'USA', 'CT', 'Hartford', '06156', 'contact@aetna.com'),
('UnitedHealthcare', 'USA', 'MN', 'Minnetonka', '55343', 'help@uhc.com'),
('Medicare', 'USA', 'DC', 'Washington', '20201', 'support@medicare.gov'),
('Cigna', 'USA', 'CT', 'Bloomfield', '06002', 'service@cigna.com'),
('Humana', 'USA', 'KY', 'Louisville', '40202', 'info@humana.com'),
('Kaiser Permanente', 'USA', 'CA', 'Oakland', '94612', 'contact@kaiserpermanente.org'),
('Anthem', 'USA', 'IN', 'Indianapolis', '46204', 'help@anthem.com'),
('Centene', 'USA', 'MO', 'St. Louis', '63102', 'support@centene.com'),
('Molina Healthcare', 'USA', 'CA', 'Long Beach', '90802', 'info@molinahealthcare.com');

-- 3. Insert Insurance Policies (12 rows - some patients have multiple policies)
INSERT INTO Insurance_Policy (patient_id, insurance_company_id, policy_number, effective_date, expiration_date, policy_order, coverage_rate, deductible, out_of_pocket_max)
VALUES
(1, 1, 'BCBS-123456', '2025-01-01', '2025-12-31', 'Primary', 80.00, 1000.00, 5000.00),
(2, 2, 'AETNA-789012', '2025-01-01', '2025-12-31', 'Primary', 90.00, 500.00, 3000.00),
(3, 3, 'UHC-345678', '2025-01-01', '2025-12-31', 'Primary', 85.00, 750.00, 4000.00),
(4, 1, 'BCBS-901234', '2025-01-01', '2025-12-31', 'Primary', 80.00, 1000.00, 5000.00),
(5, 5, 'CIGNA-567890', '2025-01-01', '2025-12-31', 'Primary', 75.00, 1500.00, 6000.00),
(6, 6, 'HUMANA-234567', '2025-01-01', '2025-12-31', 'Primary', 85.00, 800.00, 4500.00),
(7, 7, 'KAISER-890123', '2025-01-01', '2025-12-31', 'Primary', 90.00, 500.00, 3500.00),
(8, 8, 'ANTHEM-456789', '2025-01-01', '2025-12-31', 'Primary', 80.00, 1200.00, 5500.00),
(9, 9, 'CENTENE-012345', '2025-01-01', '2025-12-31', 'Primary', 75.00, 1000.00, 4800.00),
(10, 10, 'MOLINA-678901', '2025-01-01', '2025-12-31', 'Primary', 80.00, 900.00, 4200.00),
(1, 4, 'MEDICARE-111111', '2025-01-01', NULL, 'Secondary', 100.00, 0.00, 0.00),
(3, 2, 'AETNA-222222', '2025-01-01', '2025-12-31', 'Secondary', 90.00, 500.00, 2000.00);

-- 4. Insert Locations (10 rows)
INSERT INTO Location (location_type, department, building_number)
VALUES
('Emergency', 'Emergency Medicine', 1),
('Ward', 'Surgery', 2),
('Clinic', 'Radiology', 3),
('ICU', 'Intensive Care', 1),
('Operating Room', 'Surgery', 2),
('Ward', 'Cardiology', 2),
('Clinic', 'Orthopedics', 4),
('Ward', 'Pediatrics', 5),
('Emergency', 'Trauma Center', 1),
('Clinic', 'General Medicine', 3);

-- 5. Insert Encounters (15 rows)
INSERT INTO Encounter (patient_id, location_id, encounter_type, chief_complaint, date)
VALUES
(1, 1, 'Emergency', 'Chest pain and shortness of breath', '2025-10-15 14:30:00'),
(2, 3, 'Outpatient', 'Follow-up imaging', '2025-10-20 09:00:00'),
(3, 2, 'Inpatient', 'Post-surgical monitoring', '2025-10-18 08:00:00'),
(4, 1, 'Emergency', 'Severe headache and dizziness', '2025-10-22 16:45:00'),
(5, 6, 'Inpatient', 'Acute myocardial infarction', '2025-10-19 10:20:00'),
(6, 7, 'Outpatient', 'Knee pain and swelling', '2025-10-21 11:15:00'),
(7, 8, 'Inpatient', 'Pneumonia treatment', '2025-10-17 07:45:00'),
(8, 10, 'Outpatient', 'Annual physical exam', '2025-10-23 13:30:00'),
(9, 9, 'Emergency', 'Motor vehicle accident', '2025-10-16 18:00:00'),
(10, 3, 'Outpatient', 'Chest X-ray screening', '2025-10-24 10:00:00'),
(1, 10, 'Outpatient', 'Follow-up visit', '2025-10-25 14:00:00'),
(2, 7, 'Outpatient', 'Ankle injury', '2025-10-26 09:30:00'),
(5, 6, 'Outpatient', 'Cardiac follow-up', '2025-10-27 11:00:00'),
(8, 3, 'Outpatient', 'Lab work', '2025-10-28 08:45:00'),
(9, 1, 'Emergency', 'Allergic reaction', '2025-10-29 20:15:00');

-- 6. Insert Providers (10 rows)
INSERT INTO Provider (first_name, last_name, specialty, provider_type, license_number)
VALUES
('David', 'Anderson', 'Cardiology', 'Physician', 'MD-12345'),
('Jennifer', 'Martinez', 'Radiology', 'Physician', 'MD-23456'),
('Robert', 'Garcia', 'Surgery', 'Specialist', 'MD-34567'),
('Lisa', 'Rodriguez', 'Emergency Medicine', 'Physician', 'MD-45678'),
('William', 'Lee', 'Orthopedics', 'Specialist', 'MD-56789'),
('Maria', 'Hernandez', 'Pediatrics', 'Physician', 'MD-67890'),
('James', 'Wilson', 'Internal Medicine', 'Physician', 'MD-78901'),
('Patricia', 'Taylor', 'General Practice', 'Physician', 'MD-89012'),
('Richard', 'Thomas', 'Trauma Surgery', 'Specialist', 'MD-90123'),
('Linda', 'Moore', 'Cardiology', 'Nurse Practitioner', 'NP-01234');

-- 7. Insert Encounter Providers (15 rows)
INSERT INTO Encounter_Provider (encounter_id, provider_id, role, is_billing_provider)
VALUES
(1, 1, 'Attending', 1),
(1, 4, 'Consulting', 0),
(2, 2, 'Attending', 1),
(3, 3, 'Attending', 1),
(4, 4, 'Attending', 1),
(5, 1, 'Attending', 1),
(6, 5, 'Attending', 1),
(7, 6, 'Attending', 1),
(8, 8, 'Attending', 1),
(9, 9, 'Attending', 1),
(10, 2, 'Attending', 1),
(11, 7, 'Attending', 1),
(12, 5, 'Attending', 1),
(13, 10, 'Attending', 1),
(14, 7, 'Attending', 1),
(15, 4, 'Attending', 1);

-- 8. Insert Dictionary Items (15 rows)
INSERT INTO Dictionary (item_name, category, code, unit_price)
VALUES
('Complete Blood Count (CBC)', 'Lab', 'CPT-85025', 50.00),
('Chest X-Ray', 'Radiology', 'CPT-71045', 200.00),
('CT Scan - Head', 'Radiology', 'CPT-70450', 800.00),
('EKG/ECG', 'Procedure', 'CPT-93000', 100.00),
('Emergency Department Visit', 'Procedure', 'CPT-99285', 500.00),
('Consultation - Cardiology', 'Procedure', 'CPT-99244', 300.00),
('IV Fluid Administration', 'Procedure', 'CPT-96360', 75.00),
('Appendectomy', 'Procedure', 'CPT-44950', 5000.00),
('MRI - Brain', 'Radiology', 'CPT-70551', 1200.00),
('Cardiac Catheterization', 'Procedure', 'CPT-93458', 3500.00),
('Knee X-Ray', 'Radiology', 'CPT-73560', 150.00),
('Spirometry Test', 'Lab', 'CPT-94010', 80.00),
('Lipid Panel', 'Lab', 'CPT-80061', 60.00),
('Physical Therapy Session', 'Procedure', 'CPT-97110', 120.00),
('Ultrasound - Abdomen', 'Radiology', 'CPT-76700', 300.00);

-- 9. Insert Clinical Orders (20 rows)
INSERT INTO Clinical_Order (encounter_id, order_date, order_type, status)
VALUES
(1, '2025-10-15 14:35:00', 'Lab', 'Completed'),
(1, '2025-10-15 14:36:00', 'Radiology', 'Completed'),
(1, '2025-10-15 14:37:00', 'Procedure', 'Completed'),
(2, '2025-10-20 09:05:00', 'Radiology', 'Completed'),
(3, '2025-10-18 08:30:00', 'Procedure', 'Completed'),
(4, '2025-10-22 16:50:00', 'Radiology', 'Completed'),
(5, '2025-10-19 10:25:00', 'Procedure', 'Completed'),
(5, '2025-10-19 10:30:00', 'Lab', 'Completed'),
(6, '2025-10-21 11:20:00', 'Radiology', 'Completed'),
(6, '2025-10-21 11:25:00', 'Procedure', 'Completed'),
(7, '2025-10-17 08:00:00', 'Radiology', 'Completed'),
(7, '2025-10-17 08:05:00', 'Lab', 'Completed'),
(8, '2025-10-23 13:35:00', 'Lab', 'Completed'),
(9, '2025-10-16 18:10:00', 'Radiology', 'Completed'),
(9, '2025-10-16 18:15:00', 'Procedure', 'Completed'),
(10, '2025-10-24 10:05:00', 'Radiology', 'Completed'),
(11, '2025-10-25 14:05:00', 'Lab', 'Completed'),
(12, '2025-10-26 09:35:00', 'Radiology', 'Completed'),
(13, '2025-10-27 11:05:00', 'Procedure', 'Completed'),
(14, '2025-10-28 08:50:00', 'Lab', 'Completed');

-- 10. Insert Order Items (25 rows)
INSERT INTO Order_Item (order_id, item_id, quantity, scheduled_date)
VALUES
(1, 1, 1, '2025-10-15 14:40:00'),
(2, 2, 1, '2025-10-15 14:45:00'),
(3, 4, 1, '2025-10-15 14:40:00'),
(4, 2, 1, '2025-10-20 09:10:00'),
(5, 8, 1, '2025-10-18 09:00:00'),
(6, 3, 1, '2025-10-22 17:00:00'),
(7, 10, 1, '2025-10-19 11:00:00'),
(8, 1, 1, '2025-10-19 10:35:00'),
(8, 13, 1, '2025-10-19 10:35:00'),
(9, 11, 1, '2025-10-21 11:25:00'),
(10, 14, 2, '2025-10-21 12:00:00'),
(11, 2, 1, '2025-10-17 08:10:00'),
(12, 1, 1, '2025-10-17 08:10:00'),
(12, 12, 1, '2025-10-17 08:10:00'),
(13, 1, 1, '2025-10-23 13:40:00'),
(13, 13, 1, '2025-10-23 13:40:00'),
(14, 3, 1, '2025-10-16 18:20:00'),
(15, 5, 1, '2025-10-16 18:20:00'),
(16, 2, 1, '2025-10-24 10:10:00'),
(17, 13, 1, '2025-10-25 14:10:00'),
(18, 11, 1, '2025-10-26 09:40:00'),
(19, 6, 1, '2025-10-27 11:10:00'),
(20, 1, 1, '2025-10-28 08:55:00'),
(20, 13, 1, '2025-10-28 08:55:00'),
(1, 6, 1, '2025-10-15 14:50:00');

-- 11. Insert Billing Charges (25 rows - one per order item)
INSERT INTO Billing_Charge (order_item_id, encounter_id, patient_id, patient_payment_id, status)
VALUES
(1, 1, 1, NULL, 'Billed'),
(2, 1, 1, NULL, 'Billed'),
(3, 1, 1, NULL, 'Billed'),
(4, 2, 2, NULL, 'Billed'),
(5, 3, 3, NULL, 'Billed'),
(6, 4, 4, NULL, 'Billed'),
(7, 5, 5, NULL, 'Billed'),
(8, 5, 5, NULL, 'Billed'),
(9, 5, 5, NULL, 'Billed'),
(10, 6, 6, NULL, 'Billed'),
(11, 6, 6, NULL, 'Billed'),
(12, 7, 7, NULL, 'Billed'),
(13, 7, 7, NULL, 'Billed'),
(14, 7, 7, NULL, 'Billed'),
(15, 8, 8, NULL, 'Billed'),
(16, 8, 8, NULL, 'Billed'),
(17, 9, 9, NULL, 'Billed'),
(18, 9, 9, NULL, 'Billed'),
(19, 10, 10, NULL, 'Billed'),
(20, 11, 1, NULL, 'Billed'),
(21, 12, 2, NULL, 'Billed'),
(22, 13, 5, NULL, 'Billed'),
(23, 14, 8, NULL, 'Billed'),
(24, 14, 8, NULL, 'Billed'),
(25, 1, 1, NULL, 'Billed');

-- 12. Insert Claims (12 rows - one per encounter with insurance)
INSERT INTO Claim (policy_id, submission_date, adjudication_date, claim_amount, approved_amount, status)
VALUES
(1, '2025-10-16', '2025-10-25', 850.00, 680.00, 'Approved'),
(2, '2025-10-21', '2025-10-28', 200.00, 180.00, 'Approved'),
(3, '2025-10-19', '2025-10-30', 5000.00, 4250.00, 'Approved'),
(4, '2025-10-23', '2025-11-01', 800.00, 640.00, 'Approved'),
(5, '2025-10-20', '2025-10-29', 3610.00, 2707.50, 'Approved'),
(6, '2025-10-22', '2025-10-31', 390.00, 331.50, 'Approved'),
(7, '2025-10-18', '2025-10-27', 410.00, 369.00, 'Approved'),
(8, '2025-10-24', '2025-11-02', 110.00, 88.00, 'Approved'),
(9, '2025-10-17', '2025-10-26', 1300.00, 975.00, 'Approved'),
(10, '2025-10-25', '2025-11-03', 200.00, 160.00, 'Approved'),
(1, '2025-10-26', '2025-11-04', 60.00, 48.00, 'Approved'),
(2, '2025-10-27', '2025-11-05', 150.00, 127.50, 'Approved');

-- 13. Insert Claim Charges (25+ rows - link charges to claims)
INSERT INTO Claim_Charge (claim_id, billing_charge_id, billed_amount)
VALUES
-- Claim 1 (Encounter 1 - charges 1,2,3,25)
(1, 1, 50.00),
(1, 2, 200.00),
(1, 3, 100.00),
(1, 25, 500.00),
-- Claim 2 (Encounter 2 - charge 4)
(2, 4, 200.00),
-- Claim 3 (Encounter 3 - charge 5)
(3, 5, 5000.00),
-- Claim 4 (Encounter 4 - charge 6)
(4, 6, 800.00),
-- Claim 5 (Encounter 5 - charges 7,8,9)
(5, 7, 3500.00),
(5, 8, 50.00),
(5, 9, 60.00),
-- Claim 6 (Encounter 6 - charges 10,11)
(6, 10, 150.00),
(6, 11, 240.00),
-- Claim 7 (Encounter 7 - charges 12,13,14)
(7, 12, 200.00),
(7, 13, 50.00),
(7, 14, 160.00),
-- Claim 8 (Encounter 8 - charges 15,16)
(8, 15, 50.00),
(8, 16, 60.00),
-- Claim 9 (Encounter 9 - charges 17,18)
(9, 17, 800.00),
(9, 18, 500.00),
-- Claim 10 (Encounter 10 - charge 19)
(10, 19, 200.00),
-- Claim 11 (Encounter 11 - charge 20)
(11, 20, 60.00),
-- Claim 12 (Encounter 12 - charge 21)
(12, 21, 150.00);

-- 14. Insert Payments - Supertype (25+ rows: patient + claim payments)
INSERT INTO Payment (payment_date, amount_paid, payment_method, payment_status, payment_type)
VALUES
-- Patient payments (15 rows)
('2025-10-16', 170.00, 'Credit Card', 'Completed', 'PATIENT'),
('2025-10-21', 20.00, 'Cash', 'Completed', 'PATIENT'),
('2025-10-19', 750.00, 'Check', 'Completed', 'PATIENT'),
('2025-10-23', 160.00, 'Credit Card', 'Completed', 'PATIENT'),
('2025-10-20', 902.50, 'Credit Card', 'Completed', 'PATIENT'),
('2025-10-22', 58.50, 'Cash', 'Completed', 'PATIENT'),
('2025-10-18', 41.00, 'Debit', 'Completed', 'PATIENT'),
('2025-10-24', 22.00, 'Credit Card', 'Completed', 'PATIENT'),
('2025-10-17', 325.00, 'Check', 'Completed', 'PATIENT'),
('2025-10-25', 40.00, 'Cash', 'Completed', 'PATIENT'),
('2025-10-26', 12.00, 'Credit Card', 'Completed', 'PATIENT'),
('2025-10-27', 22.50, 'Cash', 'Completed', 'PATIENT'),
('2025-10-28', 50.00, 'Debit', 'Completed', 'PATIENT'),
('2025-10-29', 100.00, 'Credit Card', 'Completed', 'PATIENT'),
('2025-10-30', 75.00, 'Cash', 'Completed', 'PATIENT'),
-- Insurance payments (12 rows - one per claim)
('2025-10-26', 680.00, 'EFT', 'Completed', 'CLAIM'),
('2025-10-29', 180.00, 'EFT', 'Completed', 'CLAIM'),
('2025-10-31', 4250.00, 'EFT', 'Completed', 'CLAIM'),
('2025-11-02', 640.00, 'EFT', 'Completed', 'CLAIM'),
('2025-10-30', 2707.50, 'EFT', 'Completed', 'CLAIM'),
('2025-11-01', 331.50, 'EFT', 'Completed', 'CLAIM'),
('2025-10-28', 369.00, 'EFT', 'Completed', 'CLAIM'),
('2025-11-03', 88.00, 'EFT', 'Completed', 'CLAIM'),
('2025-10-27', 975.00, 'EFT', 'Completed', 'CLAIM'),
('2025-11-04', 160.00, 'EFT', 'Completed', 'CLAIM'),
('2025-11-05', 48.00, 'EFT', 'Completed', 'CLAIM'),
('2025-11-06', 127.50, 'EFT', 'Completed', 'CLAIM');

-- 15. Insert Patient Payments - Subtype (15 rows)
-- Note: billing_charge_id is required, but one payment can pay multiple charges
-- So we pick one representative charge per payment
INSERT INTO Patient_Payment (payment_id, patient_id, encounter_id)
VALUES
(1, 1, 1),    -- Payment 1
(2, 2, 2),    -- Payment 2 
(3, 3, 3),    -- Payment 3 
(4, 4, 4),    -- Payment 4 
(5, 5, 5),    -- Payment 5 
(6, 6, 6),   -- Payment 6 
(7, 7, 7),   -- Payment 7 
(8, 8, 8),   -- Payment 8 
(9, 9, 9),   -- Payment 9 
(10, 10, 10), -- Payment 10 
(11, 1, 11),  -- Payment 11 
(12, 2, 12),  -- Payment 12 
(13, 8, 14),  -- Payment 13 
(14, 5, 13),  -- Payment 14
(15, 1, 1);   -- Payment 15 

-- 16. Insert Claim Payments - Subtype (12 rows)
INSERT INTO Claim_Payment (payment_id, claim_id)
VALUES
(16, 1),
(17, 2),
(18, 3),
(19, 4),
(20, 5),
(21, 6),
(22, 7),
(23, 8),
(24, 9),
(25, 10),
(26, 11),
(27, 12);

-- 17. Update Billing Charges with Patient Payment IDs
-- Link charges to the patient payments (N:1 relationship)
UPDATE Billing_Charge SET patient_payment_id = 1, status = 'Paid' WHERE billing_charge_id IN (1, 2, 3);
UPDATE Billing_Charge SET patient_payment_id = 2, status = 'Paid' WHERE billing_charge_id = 4;
UPDATE Billing_Charge SET patient_payment_id = 3, status = 'Paid' WHERE billing_charge_id = 5;
UPDATE Billing_Charge SET patient_payment_id = 4, status = 'Paid' WHERE billing_charge_id = 6;
UPDATE Billing_Charge SET patient_payment_id = 5, status = 'Paid' WHERE billing_charge_id IN (7, 8, 9);
UPDATE Billing_Charge SET patient_payment_id = 6, status = 'Paid' WHERE billing_charge_id IN (10, 11);
UPDATE Billing_Charge SET patient_payment_id = 7, status = 'Paid' WHERE billing_charge_id IN (12, 13, 14);
UPDATE Billing_Charge SET patient_payment_id = 8, status = 'Paid' WHERE billing_charge_id IN (15, 16);
UPDATE Billing_Charge SET patient_payment_id = 9, status = 'Paid' WHERE billing_charge_id IN (17, 18);
UPDATE Billing_Charge SET patient_payment_id = 10, status = 'Paid' WHERE billing_charge_id = 19;
UPDATE Billing_Charge SET patient_payment_id = 11, status = 'Paid' WHERE billing_charge_id = 20;
UPDATE Billing_Charge SET patient_payment_id = 12, status = 'Paid' WHERE billing_charge_id = 21;
UPDATE Billing_Charge SET patient_payment_id = 13, status = 'Paid' WHERE billing_charge_id IN (23, 24);
UPDATE Billing_Charge SET patient_payment_id = 14, status = 'Paid' WHERE billing_charge_id = 22;
UPDATE Billing_Charge SET patient_payment_id = 15, status = 'Paid' WHERE billing_charge_id = 25;

GO

