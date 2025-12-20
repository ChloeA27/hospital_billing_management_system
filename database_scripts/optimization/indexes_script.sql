USE HealthDB;
GO

-- =============================================
-- Non-Clustered Indexes for Performance Optimization
-- =============================================

-- 1. Index on Encounter (patient_id, date)
-- Usage: Accelerates queries filtering on a specific patient's encounters, often ordered by date.
CREATE NONCLUSTERED INDEX IX_Encounter_PatientDate 
ON Encounter (patient_id, [date] DESC); 

SELECT * FROM Encounter WHERE patient_id = 5 ORDER BY date DESC;

-- 2. Index on Insurance_Policy (patient_id, policy_order)
CREATE NONCLUSTERED INDEX IX_Policy_PatientOrder 
ON Insurance_Policy (patient_id, policy_order);

SELECT coverage_rate FROM Insurance_Policy WHERE patient_id = 1 AND policy_order = 'Primary';

-- 3. Index on Provider (specialty)
CREATE NONCLUSTERED INDEX IX_Provider_Specialty 
ON Provider (specialty);

SELECT first_name, last_name FROM Provider WHERE specialty = 'Cardiology';

GO