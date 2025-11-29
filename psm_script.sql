USE HealthDB;
GO

-- 1. Check and drop the existing stored procedure (if it exists)
IF OBJECT_ID('SP_ProcessNewOrderItem', 'P') IS NOT NULL
    DROP PROCEDURE SP_ProcessNewOrderItem;
GO

-- =============================================
-- Stored Procedure: SP_ProcessNewOrderItem
-- Description: Creates a new Billing_Charge record for a completed Order_Item.
-- =============================================
CREATE PROCEDURE SP_ProcessNewOrderItem
    @order_item_id INT,
    @billing_charge_id INT OUTPUT,
    @success_flag BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @success_flag = 0; -- Default to failure

    DECLARE @encounter_id INT;
    DECLARE @patient_id INT;
    
    -- Retrieve the associated Encounter and Patient ID from Clinical_Order and Order_Item
    SELECT 
        @encounter_id = T1.encounter_id,
        @patient_id = T3.patient_id 
    FROM Clinical_Order T1
    INNER JOIN Order_Item T2 ON T1.order_id = T2.order_id
    INNER JOIN Encounter T3 ON T1.encounter_id = T3.encounter_id -- <-- NEW JOIN
    WHERE T2.order_item_id = @order_item_id;

    -- Data Validation: Check if the Order_Item and its associations exist
    IF @encounter_id IS NULL OR @patient_id IS NULL
    BEGIN
        SET @billing_charge_id = NULL;
        -- Raise business error for invalid input
        RAISERROR('Input Error: Order_Item_ID %d not found or missing associated Encounter/Patient data.', 16, 1, @order_item_id);
        RETURN;
    END

    -- Transaction Management and Error Handling
    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Business Validation: Check if Billing_Charge already exists to prevent duplicates
        IF EXISTS (SELECT 1 FROM Billing_Charge WHERE order_item_id = @order_item_id)
        BEGIN
            SELECT @billing_charge_id = billing_charge_id FROM Billing_Charge WHERE order_item_id = @order_item_id;
            
            -- Rollback transaction, as we will not proceed with insertion
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;

            -- Raise business rule violation error
            RAISERROR('Billing Charge already exists for Order_Item_ID %d. Existing Charge ID: %d.', 16, 1, @order_item_id, @billing_charge_id);
            SET @success_flag = 0;
            SET @billing_charge_id = NULL;
            RETURN;
        END
        
        -- 2. Insert the new Billing_Charge record
        INSERT INTO Billing_Charge (order_item_id, encounter_id, patient_id, status)
        VALUES (@order_item_id, @encounter_id, @patient_id, 'Billed');

        -- 3. Get the ID of the newly inserted record
        SET @billing_charge_id = SCOPE_IDENTITY();

        -- 4. Set the success flag
        SET @success_flag = 1;
        
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        -- Rollback transaction if any error occurred
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Set output parameters to indicate failure
        SET @success_flag = 0;
        SET @billing_charge_id = NULL;

        -- *** Capture and output detailed error information (as requested) ***
        DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        -- Re-raise the error (Severity 16 ensures the calling batch/application is notified)
        RAISERROR (
            N'SP_ProcessNewOrderItem Failed: %s (Severity: %d, State: %d)', 
            @ErrorSeverity, 
            @ErrorState, 
            @ErrorMessage, 
            @ErrorSeverity, 
            @ErrorState
        );
        
    END CATCH

END
GO





IF OBJECT_ID('SP_UpdateClaimStatus', 'P') IS NOT NULL
    DROP PROCEDURE SP_UpdateClaimStatus;
GO

-- =============================================
-- Stored Procedure: SP_UpdateClaimStatus
-- Description: Updates the status and approved amount of a claim, applying business rules.
-- =============================================
CREATE PROCEDURE SP_UpdateClaimStatus
    @claim_id INT,
    @new_status VARCHAR(50),
    @approved_amount DECIMAL(10,2) = NULL,
    @success_flag BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @success_flag = 0;

    DECLARE @current_claim_amount DECIMAL(10,2);
    DECLARE @AdjudicationDate DATE;
    DECLARE @approved_amount_str VARCHAR(20);
    DECLARE @current_claim_amount_str VARCHAR(20);
    
    -- 1. Check if Claim ID is valid and get the original claim amount
    SELECT @current_claim_amount = claim_amount
    FROM Claim
    WHERE claim_id = @claim_id;

    IF @current_claim_amount IS NULL
    BEGIN
        RAISERROR('Input Error: Claim_ID %d not found.', 16, 1, @claim_id);
        RETURN;
    END

    -- 2. Validate the new status against the allowed list
    IF @new_status NOT IN ('Submitted', 'Under Review', 'Approved', 'Partially Approved', 'Denied', 'Appealed', 'Paid')
    BEGIN
        RAISERROR('Input Error: Invalid status provided. Status must be one of the allowed types.', 16, 1);
        RETURN;
    END

    -- 3. Business Rule Validation for Approved/Paid status
    IF @new_status IN ('Approved', 'Partially Approved', 'Paid')
    BEGIN
        -- Must have an approved amount
        IF @approved_amount IS NULL
        BEGIN
            RAISERROR('Business Rule Violation: Approved/Paid status requires a non-NULL approved amount.', 16, 1);
            RETURN;
        END

        -- Approved amount cannot exceed the claimed amount
        IF @approved_amount > @current_claim_amount
        BEGIN
            -- Convert DECIMAL to VARCHAR and use %s in RAISERROR
            SET @approved_amount_str = FORMAT(@approved_amount, 'N2');
            SET @current_claim_amount_str = FORMAT(@current_claim_amount, 'N2');

            RAISERROR('Business Rule Violation: Approved amount (%s) cannot exceed claim amount (%s).', 16, 1, @approved_amount_str, @current_claim_amount_str);
            RETURN;
        END
    END
    ELSE IF @new_status IN ('Denied', 'Under Review', 'Submitted', 'Appealed')
    BEGIN
        -- For non-final or denied statuses, ensure approved_amount is NULL
        SET @approved_amount = NULL;
    END

    -- 4. Determine Adjudication Date (for final statuses)
    SET @AdjudicationDate = NULL;
    IF @new_status IN ('Approved', 'Partially Approved', 'Denied', 'Paid')
    BEGIN
        SET @AdjudicationDate = CAST(GETDATE() AS DATE);
    END
    

    -- Transaction Management and Error Handling
    BEGIN TRY
        BEGIN TRANSACTION;

        -- 5. Update the Claim record
        UPDATE Claim
        SET 
            status = @new_status,
            approved_amount = @approved_amount,
            adjudication_date = @AdjudicationDate
        WHERE claim_id = @claim_id;

        -- 6. Set success flag
        SET @success_flag = 1;
        
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        -- Rollback transaction if any error occurred
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Set output parameters to indicate failure
        SET @success_flag = 0;

        -- Capture and output detailed error information
        DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        -- Re-raise the error (using %s for the message)
        RAISERROR (
            N'SP_UpdateClaimStatus Failed: %s (Severity: %d, State: %d)', 
            @ErrorSeverity, 
            @ErrorState, 
            @ErrorMessage, 
            @ErrorSeverity, 
            @ErrorState
        );
        
    END CATCH

END
GO



-- 1. Check and drop the existing stored procedure (if it exists)
IF OBJECT_ID('SP_RecordPatientPayment', 'P') IS NOT NULL
    DROP PROCEDURE SP_RecordPatientPayment;
GO

-- =============================================
-- Stored Procedure: SP_RecordPatientPayment
-- Description: Records a patient payment and links the payment ID to relevant Billing_Charge items.
-- =============================================
CREATE PROCEDURE SP_RecordPatientPayment
    @patient_id INT,
    @encounter_id INT,
    @amount_paid DECIMAL(10,2),
    @payment_method VARCHAR(50),
    @payment_id INT OUTPUT,
    @patient_payment_id INT OUTPUT,
    @charges_updated_count INT OUTPUT,
    @success_flag BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @success_flag = 0;
    SET @charges_updated_count = 0;

    -- 1. Input Validation: Check if Patient ID is valid
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE patient_id = @patient_id)
    BEGIN
        RAISERROR('Input Error: Patient_ID %d not found.', 16, 1, @patient_id);
        RETURN;
    END

    -- 2. Input Validation: Check if Encounter ID is valid
    IF NOT EXISTS (SELECT 1 FROM Encounter WHERE encounter_id = @encounter_id)
    BEGIN
        RAISERROR('Input Error: Encounter_ID %d not found.', 16, 1, @encounter_id);
        RETURN;
    END

    -- 3. Input Validation: Check if Payment Amount is positive
    IF @amount_paid <= 0
    BEGIN
        RAISERROR('Input Error: Payment amount must be greater than zero.', 16, 1);
        RETURN;
    END

    -- Transaction Management and Error Handling
    BEGIN TRY
        BEGIN TRANSACTION;

        -- A. Insert into Payment Supertype
        INSERT INTO Payment (payment_date, amount_paid, payment_method, payment_status, payment_type)
        VALUES (CAST(GETDATE() AS DATE), @amount_paid, @payment_method, 'Completed', 'PATIENT');
        
        SET @payment_id = SCOPE_IDENTITY();

        -- B. Insert into Patient_Payment Subtype
        INSERT INTO Patient_Payment (payment_id, patient_id, encounter_id)
        VALUES (@payment_id, @patient_id, @encounter_id);
        
        SET @patient_payment_id = SCOPE_IDENTITY();

        -- C. Link the new Patient Payment ID to the relevant Billing Charges
        -- We link this payment to all Billed/Partial/Pending charges for this patient and encounter
        -- NOTE: We do NOT update the status to 'Paid' here.
        UPDATE Billing_Charge
        SET 
            patient_payment_id = @patient_payment_id
        WHERE encounter_id = @encounter_id
          AND patient_id = @patient_id
          AND status IN ('Billed', 'Partial', 'Pending') 
          AND patient_payment_id IS NULL; -- Only link if not already linked (though a single payment ID may link to multiple charges)

        SET @charges_updated_count = @@ROWCOUNT;

        -- D. Set success flag and commit
        SET @success_flag = 1;
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        -- Rollback transaction if any error occurred
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Set output parameters to indicate failure
        SET @success_flag = 0;
        SET @payment_id = NULL;
        SET @patient_payment_id = NULL;
        SET @charges_updated_count = 0;

        -- Capture and re-raise detailed error information
        DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR (
            N'SP_RecordPatientPayment Failed: %s (Severity: %d, State: %d)', 
            @ErrorSeverity, 
            @ErrorState, 
            @ErrorMessage, 
            @ErrorSeverity, 
            @ErrorState
        );
        
    END CATCH
END
GO


-- =============================================
-- View: VW_PatientBillingSummary
-- Description: Displays the total bill amount, paid amount, and unpaid amount (if any) for each patient.
-- =============================================

IF OBJECT_ID('VW_PatientBillingSummary', 'V') IS NOT NULL
    DROP VIEW VW_PatientBillingSummary;
GO

CREATE VIEW VW_PatientBillingSummary AS
-- Step 1: Calculate Total Billed Amount per Patient (Sum of unit_price * quantity for all Order Items)
-- This is the gross charge before any insurance/payment logic
WITH TotalCharges AS (
    SELECT
        BC.patient_id,
        SUM(D.unit_price * OI.quantity) AS Total_Charged
    FROM Billing_Charge BC
    INNER JOIN Order_Item OI ON BC.order_item_id = OI.order_item_id
    INNER JOIN Dictionary D ON OI.item_id = D.item_id
    GROUP BY BC.patient_id
),

-- Step 2: Calculate Total Insurance Paid (Approved Amount from Claims)
TotalInsurancePaid AS (
    SELECT
        IP.patient_id,
        SUM(C.approved_amount) AS Total_Insurance_Approved
    FROM Claim C
    INNER JOIN Insurance_Policy IP ON C.policy_id = IP.policy_id
    WHERE C.status IN ('Approved', 'Partially Approved', 'Paid') AND C.approved_amount IS NOT NULL
    GROUP BY IP.patient_id
),

-- Step 3: Calculate Total Patient Paid
TotalPatientPaid AS (
    SELECT
        PP.patient_id,
        SUM(P.amount_paid) AS Total_Patient_Paid
    FROM Patient_Payment PP
    INNER JOIN Payment P ON PP.payment_id = P.payment_id
    WHERE P.payment_status = 'Completed'
    GROUP BY PP.patient_id
)

-- Step 4: Combine all results and calculate the balance
SELECT
    P.patient_id,
    P.first_name,
    P.last_name,
    ISNULL(TC.Total_Charged, 0.00) AS Total_Charged,
    ISNULL(TIP.Total_Insurance_Approved, 0.00) AS Total_Insurance_Approved,
    ISNULL(TPP.Total_Patient_Paid, 0.00) AS Total_Patient_Paid,
    -- Simple Calculation of Balance: Total Charged - Total Insurance - Total Patient Paid
    (ISNULL(TC.Total_Charged, 0.00) - ISNULL(TIP.Total_Insurance_Approved, 0.00) - ISNULL(TPP.Total_Patient_Paid, 0.00)) AS Outstanding_Balance
FROM Patient P
LEFT JOIN TotalCharges TC ON P.patient_id = TC.patient_id
LEFT JOIN TotalInsurancePaid TIP ON P.patient_id = TIP.patient_id
LEFT JOIN TotalPatientPaid TPP ON P.patient_id = TPP.patient_id
WHERE ISNULL(TC.Total_Charged, 0.00) > 0; -- Only show patients who have charges
GO

SELECT * FROM VW_PatientBillingSummary;


-- =============================================
-- View: VW_ProviderWorkload
-- Description: Displays the number of encounters for each provider in different departments, as well as the number of encounters they make as the primary billing provider.
-- =============================================

IF OBJECT_ID('VW_ProviderWorkload', 'V') IS NOT NULL
    DROP VIEW VW_ProviderWorkload;
GO

CREATE VIEW VW_ProviderWorkload AS
SELECT
    PR.provider_id,
    PR.first_name,
    PR.last_name,
    PR.specialty,
    PR.provider_type,
    L.department,
    COUNT(EP.encounter_id) AS Total_Encounters_Count,
    SUM(CASE WHEN EP.is_billing_provider = 1 THEN 1 ELSE 0 END) AS Billing_Encounters_Count
FROM Provider PR
INNER JOIN Encounter_Provider EP ON PR.provider_id = EP.provider_id
INNER JOIN Encounter E ON EP.encounter_id = E.encounter_id
INNER JOIN Location L ON E.location_id = L.location_id
GROUP BY 
    PR.provider_id,
    PR.first_name,
    PR.last_name,
    PR.specialty,
    PR.provider_type,
    L.department;
GO

SELECT * FROM VW_ProviderWorkload;



-- =============================================
-- View: VW_ActiveInsurancePolicies
-- Description: Displays detailed information on all currently valid Primary level insurance policies for all patients.
-- =============================================
IF OBJECT_ID('VW_ActiveInsurancePolicies', 'V') IS NOT NULL
    DROP VIEW VW_ActiveInsurancePolicies;
GO

CREATE VIEW VW_ActiveInsurancePolicies AS
SELECT
    -- Patient Information
    P.patient_id,
    P.first_name AS Patient_FirstName,
    P.last_name AS Patient_LastName,
    
    -- Insurance Policy Details
    IP.policy_id,
    IP.policy_number,
    IP.policy_order,
    IP.effective_date,
    IP.expiration_date,
    IP.coverage_rate,
    IP.deductible,
    IP.out_of_pocket_max,

    -- Insurance Company Details
    IC.name AS Company_Name,
    IC.email AS Company_Email,
    IC.company_city,
    IC.company_state
FROM Patient P
INNER JOIN Insurance_Policy IP ON P.patient_id = IP.patient_id
INNER JOIN Insurance_Company IC ON IP.insurance_company_id = IC.insurance_company_id
WHERE 
    IP.policy_order = 'Primary' -- Must be Primary policy
    AND (
        IP.expiration_date IS NULL 
        OR IP.expiration_date >= CAST(GETDATE() AS DATE) -- Policy is either ongoing or expires in the future
    );
GO

SELECT * FROM VW_ActiveInsurancePolicies;



-- User-Defined Functions
IF OBJECT_ID('FN_CalculateItemCost', 'FN') IS NOT NULL
    DROP FUNCTION FN_CalculateItemCost;
GO

-- =============================================
-- User-Defined Function: FN_CalculateItemCost
-- Description: Calculates the total cost for a specific Order_Item (unit_price * quantity).
-- =============================================
CREATE FUNCTION FN_CalculateItemCost
(
    @order_item_id INT
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @TotalCost DECIMAL(10, 2);

    SELECT
        @TotalCost = D.unit_price * OI.quantity
    FROM Order_Item OI
    INNER JOIN Dictionary D ON OI.item_id = D.item_id
    WHERE OI.order_item_id = @order_item_id;

    RETURN ISNULL(@TotalCost, 0.00);

END
GO



IF OBJECT_ID('FN_GetPolicyCoverageRate', 'FN') IS NOT NULL
    DROP FUNCTION FN_GetPolicyCoverageRate;
GO

-- =============================================
-- User-Defined Function: FN_GetPolicyCoverageRate
-- Description: Retrieves the coverage rate for a patient's specific policy order (e.g., 'Primary').
-- Returns 0.00 if no active policy is found.
-- =============================================
CREATE FUNCTION FN_GetPolicyCoverageRate
(
    @patient_id INT,
    @policy_order VARCHAR(20)
)
RETURNS DECIMAL(5, 2)
AS
BEGIN
    DECLARE @CoverageRate DECIMAL(5, 2);

    -- Retrieve the Coverage Rate for the policy
    SELECT TOP 1
        @CoverageRate = coverage_rate
    FROM Insurance_Policy
    WHERE 
        patient_id = @patient_id
        AND policy_order = @policy_order
        -- Policy must be currently active or not yet expired
        AND (expiration_date IS NULL OR expiration_date >= CAST(GETDATE() AS DATE))
    ORDER BY effective_date DESC; -- Prioritize the most recent policy if multiple are valid

    -- Return 0.00 if no active policy is found
    RETURN ISNULL(@CoverageRate, 0.00);

END
GO


IF OBJECT_ID('FN_GetTotalEncounterCharge', 'FN') IS NOT NULL
    DROP FUNCTION FN_GetTotalEncounterCharge;
GO

-- =============================================
-- User-Defined Function: FN_GetTotalEncounterCharge
-- Description: Calculates the total gross charge for all billable items linked to a specific encounter.
-- =============================================
CREATE FUNCTION FN_GetTotalEncounterCharge
(
    @encounter_id INT
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @TotalCharge DECIMAL(10, 2);

    -- Aggregate the sum of (unit_price * quantity) for all charges related to the encounter
    SELECT
        @TotalCharge = SUM(D.unit_price * OI.quantity)
    FROM Billing_Charge BC
    INNER JOIN Order_Item OI ON BC.order_item_id = OI.order_item_id
    INNER JOIN Dictionary D ON OI.item_id = D.item_id
    WHERE BC.encounter_id = @encounter_id;

    -- Return 0.00 if no charges are found for the encounter
    RETURN ISNULL(@TotalCharge, 0.00);

END
GO


-- Trigger
IF OBJECT_ID('TR_SettleBillingChargeOnClaimPayment', 'TR') IS NOT NULL
    DROP TRIGGER TR_SettleBillingChargeOnClaimPayment;
GO

-- =============================================
-- DML Trigger: TR_SettleBillingChargeOnClaimPayment
-- Event: AFTER INSERT on Claim_Payment
-- Purpose: Checks if related Billing_Charge items are fully paid after a new insurance payment is recorded, 
--          and updates the Billing_Charge status to 'Paid' if settled.
-- =============================================
CREATE TRIGGER TR_SettleBillingChargeOnClaimPayment_CTE
ON Claim_Payment
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- CTE 1: Identify all unique Billing_Charge IDs affected by the new Claim_Payment.
    -- This acts as the initial filter, replacing the need for the temporary table.
    WITH AffectedCharges AS (
        SELECT DISTINCT
            CC.billing_charge_id
        FROM inserted I -- New Claim_Payments
        INNER JOIN Claim C ON I.claim_id = C.claim_id
        INNER JOIN Claim_Charge CC ON C.claim_id = CC.claim_id
        WHERE EXISTS (SELECT 1 FROM Billing_Charge BC WHERE BC.billing_charge_id = CC.billing_charge_id AND BC.status <> 'Paid')
    )
    
    -- Final Settlement Update Statement
    UPDATE BC
    SET BC.status = 'Paid'
    FROM Billing_Charge BC
    INNER JOIN AffectedCharges AC ON BC.billing_charge_id = AC.billing_charge_id
    WHERE 
    (
        -- Calculation: Total Paid vs. Gross Charge (Total Paid >= Gross Charge)
        
        -- 1. Gross Charge (Total cost of the item)
        (SELECT D.unit_price * OI.quantity
         FROM Order_Item OI 
         INNER JOIN Dictionary D ON OI.item_id = D.item_id
         WHERE OI.order_item_id = BC.order_item_id
        ) 
        <=
        -- 2. Total Paid (Sum of Patient Payment + Insurance Payment)
        (
            -- Total Patient Payment
            ISNULL((SELECT P.amount_paid
                    FROM Patient_Payment PP
                    INNER JOIN Payment P ON PP.payment_id = P.payment_id
                    WHERE PP.patient_payment_id = BC.patient_payment_id), 0.00)
            +
            -- Total Claim Payment (Sum of payments made for the claims covering this charge)
            -- Note: We sum all completed Claim Payments linked to the Claim(s) that cover this specific Billing_Charge.
            ISNULL((SELECT SUM(P_Claim.amount_paid) 
                    FROM Payment P_Claim
                    INNER JOIN Claim_Payment CP ON P_Claim.payment_id = CP.payment_id
                    INNER JOIN Claim_Charge CC_Inner ON CP.claim_id = CC_Inner.claim_id
                    WHERE CC_Inner.billing_charge_id = BC.billing_charge_id AND P_Claim.payment_status = 'Completed'), 0.00)
        )
    );
END
GO


