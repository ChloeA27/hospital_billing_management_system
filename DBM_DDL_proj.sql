IF OBJECT_ID('Claim_Payment', 'U') IS NOT NULL DROP TABLE Claim_Payment;
IF OBJECT_ID('Patient_Payment', 'U') IS NOT NULL DROP TABLE Patient_Payment;
IF OBJECT_ID('Payment', 'U') IS NOT NULL DROP TABLE Payment;
IF OBJECT_ID('Claim_Charge', 'U') IS NOT NULL DROP TABLE Claim_Charge;
IF OBJECT_ID('Claim', 'U') IS NOT NULL DROP TABLE Claim;
IF OBJECT_ID('Billing_Charge', 'U') IS NOT NULL DROP TABLE Billing_Charge;
IF OBJECT_ID('Order_Item', 'U') IS NOT NULL DROP TABLE Order_Item;
IF OBJECT_ID('Dictionary', 'U') IS NOT NULL DROP TABLE Dictionary;
IF OBJECT_ID('Clinical_Order', 'U') IS NOT NULL DROP TABLE Clinical_Order;
IF OBJECT_ID('Encounter_Provider', 'U') IS NOT NULL DROP TABLE Encounter_Provider;
IF OBJECT_ID('Provider', 'U') IS NOT NULL DROP TABLE Provider;
IF OBJECT_ID('Encounter', 'U') IS NOT NULL DROP TABLE Encounter;
IF OBJECT_ID('Location', 'U') IS NOT NULL DROP TABLE Location;
IF OBJECT_ID('Insurance_Policy', 'U') IS NOT NULL DROP TABLE Insurance_Policy;
IF OBJECT_ID('Insurance_Company', 'U') IS NOT NULL DROP TABLE Insurance_Company;
IF OBJECT_ID('Patient', 'U') IS NOT NULL DROP TABLE Patient;
GO

-- ============================================
-- DDL: CREATE TABLES
-- ============================================

-- 1. Patient Table
CREATE TABLE Patient (
    patient_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dob DATE NOT NULL,
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('Male', 'Female', 'Other', 'Prefer not to say')),
    emergency_contact_phone VARCHAR(20) NULL,
    phone VARCHAR(20) NULL,
    CONSTRAINT chk_patient_dob CHECK (dob < CAST(GETDATE() AS DATE))
);

-- 2. Insurance Company Table
CREATE TABLE Insurance_Company (
    insurance_company_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    company_country VARCHAR(50) NULL,
    company_state VARCHAR(50) NULL,
    company_city VARCHAR(50) NULL,
    company_zipcode VARCHAR(15) NULL,
    email VARCHAR(100) NULL
);

-- 3. Insurance Policy Table
CREATE TABLE Insurance_Policy (
    policy_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    insurance_company_id INT NOT NULL,
    policy_number VARCHAR(50) NOT NULL,
    effective_date DATE NOT NULL,
    expiration_date DATE NULL,
    policy_order VARCHAR(20) NOT NULL CHECK (policy_order IN ('Primary', 'Secondary', 'Tertiary')),
    coverage_rate DECIMAL(5,2) NULL CHECK (coverage_rate BETWEEN 0 AND 100),
    deductible DECIMAL(10,2) NULL,
    out_of_pocket_max DECIMAL(10,2) NULL,
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    FOREIGN KEY (insurance_company_id) REFERENCES Insurance_Company(insurance_company_id),
    CONSTRAINT chk_policy_dates CHECK (expiration_date IS NULL OR effective_date < expiration_date)
);

-- 4. Location Table
CREATE TABLE Location (
    location_id INT IDENTITY(1,1) PRIMARY KEY,
    location_type VARCHAR(50) NOT NULL CHECK (location_type IN ('Clinic', 'Ward', 'Emergency', 'ICU', 'Operating Room')),
    department VARCHAR(100) NULL,
    building_number INT NOT NULL
);

-- 5. Encounter Table
CREATE TABLE Encounter (
    encounter_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    location_id INT NOT NULL,
    encounter_type VARCHAR(50) NOT NULL CHECK (encounter_type IN ('Inpatient', 'Outpatient', 'Emergency', 'Observation')),
    chief_complaint TEXT NULL,
    date DATETIME NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

-- 6. Provider Table
CREATE TABLE Provider (
    provider_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialty VARCHAR(100) NULL,
    provider_type VARCHAR(50) NOT NULL CHECK (provider_type IN ('Physician', 'Nurse Practitioner', 'PA', 'Specialist')),
    license_number VARCHAR(50) NULL
);

-- 7. Encounter Provider Junction Table
CREATE TABLE Encounter_Provider (
    encounter_provider_id INT IDENTITY(1,1) PRIMARY KEY,
    encounter_id INT NOT NULL,
    provider_id INT NOT NULL,
    role VARCHAR(50) NULL CHECK (role IN ('Attending', 'Consulting', 'Assisting', 'Referring')),
    is_billing_provider BIT DEFAULT 0,
    FOREIGN KEY (encounter_id) REFERENCES Encounter(encounter_id),
    FOREIGN KEY (provider_id) REFERENCES Provider(provider_id),
    CONSTRAINT unique_encounter_provider UNIQUE (encounter_id, provider_id, role)
);

-- 8. Clinical Order Table
CREATE TABLE Clinical_Order (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    encounter_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    order_type VARCHAR(50) NOT NULL CHECK (order_type IN ('Lab', 'Radiology', 'Medication', 'Procedure', 'Consultation')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('Ordered', 'In Progress', 'Completed', 'Cancelled')),
    FOREIGN KEY (encounter_id) REFERENCES Encounter(encounter_id)
);

-- 9. Dictionary Table
CREATE TABLE Dictionary (
    item_id INT IDENTITY(1,1) PRIMARY KEY,
    item_name VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL CHECK (category IN ('Lab', 'Radiology', 'Medication', 'Procedure', 'Supply')),
    code VARCHAR(50) UNIQUE NULL,
    unit_price DECIMAL(10,2) NULL
);

-- 10. Order Item Table
CREATE TABLE Order_Item (
    order_item_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    scheduled_date DATETIME NULL,
    FOREIGN KEY (order_id) REFERENCES Clinical_Order(order_id),
    FOREIGN KEY (item_id) REFERENCES Dictionary(item_id)
);

-- 11. Billing Charge Table
CREATE TABLE Billing_Charge (
    billing_charge_id INT IDENTITY(1,1) PRIMARY KEY,
    order_item_id INT NOT NULL,
    encounter_id INT NOT NULL,
    patient_id INT NOT NULL,
    patient_payment_id INT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Pending', 'Billed', 'Paid', 'Partial', 'Denied', 'Overdue')),
    FOREIGN KEY (order_item_id) REFERENCES Order_Item(order_item_id),
    FOREIGN KEY (encounter_id) REFERENCES Encounter(encounter_id),
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
);

-- 12. Claim Table
CREATE TABLE Claim (
    claim_id INT IDENTITY(1,1) PRIMARY KEY,
    policy_id INT NOT NULL,
    submission_date DATE NOT NULL,
    adjudication_date DATE NULL,
    claim_amount DECIMAL(10,2) NOT NULL,
    approved_amount DECIMAL(10,2) NULL,
    status VARCHAR(50) NOT NULL CHECK (status IN ('Submitted', 'Under Review', 'Approved', 'Partially Approved', 'Denied', 'Appealed', 'Paid')),
    FOREIGN KEY (policy_id) REFERENCES Insurance_Policy(policy_id),
    CONSTRAINT chk_approved_amount CHECK (approved_amount IS NULL OR approved_amount <= claim_amount)
);

-- 13. Claim Charge Junction Table
CREATE TABLE Claim_Charge (
    claim_charge_id INT IDENTITY(1,1) PRIMARY KEY,
    claim_id INT NOT NULL,
    billing_charge_id INT NOT NULL,
    billed_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (claim_id) REFERENCES Claim(claim_id),
    FOREIGN KEY (billing_charge_id) REFERENCES Billing_Charge(billing_charge_id),
    CONSTRAINT unique_claim_charge UNIQUE (claim_id, billing_charge_id)
);

-- 14. Payment Supertype Table
CREATE TABLE Payment (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    payment_date DATE NOT NULL,
    amount_paid DECIMAL(10,2) NOT NULL CHECK (amount_paid > 0),
    payment_method VARCHAR(50) NOT NULL CHECK (payment_method IN ('Cash', 'Check', 'Credit Card', 'Debit', 'Wire Transfer', 'EFT')),
    payment_status VARCHAR(20) NOT NULL CHECK (payment_status IN ('Pending', 'Completed', 'Failed', 'Refunded', 'Cancelled')),
    payment_type VARCHAR(20) NOT NULL CHECK (payment_type IN ('PATIENT', 'CLAIM'))
);

-- 15. Patient Payment Subtype Table
CREATE TABLE Patient_Payment (
    patient_payment_id INT IDENTITY(1,1) PRIMARY KEY,
    payment_id INT UNIQUE NOT NULL,
    patient_id INT NOT NULL,
    encounter_id INT NULL,
    FOREIGN KEY (payment_id) REFERENCES Payment(payment_id),
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    FOREIGN KEY (encounter_id) REFERENCES Encounter(encounter_id)
);

-- 16. Claim Payment Subtype Table
CREATE TABLE Claim_Payment (
    claim_payment_id INT IDENTITY(1,1) PRIMARY KEY,
    payment_id INT UNIQUE NOT NULL,
    claim_id INT NOT NULL,
    FOREIGN KEY (payment_id) REFERENCES Payment(payment_id),
    FOREIGN KEY (claim_id) REFERENCES Claim(claim_id)
);

-- Add FK constraint for Billing_Charge to Patient_Payment
ALTER TABLE Billing_Charge
ADD FOREIGN KEY (patient_payment_id) REFERENCES Patient_Payment(patient_payment_id);

GO


