USE HealthDB;
GO

-- =========================================================================================
-- ENCRYPTION_SCRIPT.SQL (Simplified Symmetric Key Encryption)
-- =========================================================================================

-- Create a Master Key to protect the Certificate/Symmetric Key.
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'HealthDB!123';
GO

-- Create a Certificate to protect the Symmetric Key
CREATE CERTIFICATE Cert_PHI WITH SUBJECT = 'Certificate for PHI Encryption';
GO

-- Create the Symmetric Key 
CREATE SYMMETRIC KEY SymKey_PHI 
WITH ALGORITHM = AES_256 
ENCRYPTION BY CERTIFICATE Cert_PHI;
GO

-- Open the Symmetric Key to perform encryption
OPEN SYMMETRIC KEY SymKey_PHI 
DECRYPTION BY CERTIFICATE Cert_PHI;
GO


ALTER TABLE Patient ADD encrypted_phone VARBINARY(128) NULL;

UPDATE Patient
SET encrypted_phone = ENCRYPTBYKEY(KEY_GUID('SymKey_PHI'), CAST(phone AS VARBINARY(MAX)))
WHERE phone IS NOT NULL;

ALTER TABLE Provider ADD encrypted_license_number VARBINARY(128) NULL;

UPDATE Provider
SET encrypted_license_number = ENCRYPTBYKEY(KEY_GUID('SymKey_PHI'), CAST(license_number AS VARBINARY(MAX)))
WHERE license_number IS NOT NULL;

ALTER TABLE Patient DROP COLUMN phone;
EXEC sp_rename 'Patient.encrypted_phone', 'phone', 'COLUMN';

ALTER TABLE Provider DROP COLUMN license_number;
EXEC sp_rename 'Provider.encrypted_license_number', 'license_number', 'COLUMN';

-- Close the Symmetric Key
CLOSE SYMMETRIC KEY SymKey_PHI;
GO

SELECT * FROM Patient;
SELECT * FROM Provider;
