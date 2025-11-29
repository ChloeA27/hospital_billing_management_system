USE HealthDB;
GO


-- ===================================================
-- Test Procedure SP_ProcessNewOrderItem
-- ===================================================
DECLARE @NewChargeId INT;
DECLARE @Result BIT;
DECLARE @TestOrderItemId INT;

-- ===================================================
-- 1. 成功测试：处理一个新的 Order_Item
-- ===================================================

-- 步骤 A: 插入一条新的 Order_Item (需要关联到一个已有的 Clinical_Order, 例如 Order_ID 20)
-- Order_ID 20 关联 Encounter 14, Patient 8
INSERT INTO Order_Item (order_id, item_id, quantity, scheduled_date) 
VALUES (20, 1, 1, '2025-10-28 09:00:00'); 

-- 获取新插入的 Order_Item ID (应该大于 25)
SET @TestOrderItemId = SCOPE_IDENTITY(); 

PRINT '--- Running Success Test (Processing New Order Item ID: ' + CAST(@TestOrderItemId AS VARCHAR) + ') ---';

-- 步骤 B: 执行存储过程
DECLARE @NewChargeId INT;
DECLARE @Result BIT;
DECLARE @TestOrderItemId INT;
EXEC SP_ProcessNewOrderItem 
    @order_item_id = 27,
    @billing_charge_id = @NewChargeId OUTPUT,
    @success_flag = @Result OUTPUT;

-- 步骤 C: 查看结果
SELECT 
    'SUCCESS_TEST' AS TestScenario, 
    @TestOrderItemId AS InputOrderItemId, 
    @NewChargeId AS OutputBillingChargeId, 
    @Result AS SuccessFlag;

-- 步骤 D: (可选) 验证 Billing_Charge 表中是否创建了记录
SELECT * FROM Billing_Charge 
WHERE billing_charge_id = @NewChargeId;


-- 步骤 E: 清理数据，以便下次测试可以重新运行
DELETE FROM Billing_Charge WHERE billing_charge_id = 27;
DELETE FROM Order_Item WHERE order_item_id = @TestOrderItemId;
DELETE FROM Order_Item WHERE order_item_id = 27;
GO


-- ===================================================
-- Test Procedure SP_UpdateClaimStatus
-- ===================================================
-- ===================================================
-- Setup for testing: Claim ID 1 has claim_amount 850.00
-- ===================================================
DECLARE @Result BIT;

-- 1. 成功测试：更新为 'Paid'
-- 应成功，因为 680.00 <= 850.00
EXEC SP_UpdateClaimStatus 
    @claim_id = 1,
    @new_status = 'Paid',
    @approved_amount = 680.00,
    @success_flag = @Result OUTPUT;

SELECT 
    'SUCCESS_TEST_PAID' AS TestScenario, 
    @Result AS SuccessFlag, 
    (SELECT status FROM Claim WHERE claim_id = 1) AS NewStatus,
    (SELECT approved_amount FROM Claim WHERE claim_id = 1) AS ApprovedAmount,
    (SELECT adjudication_date FROM Claim WHERE claim_id = 1) AS AdjudicationDate;

-- 2. 失败测试：Approved Amount > Claim Amount
-- 应失败，抛出 Business Rule Violation
DECLARE @Result BIT;
SET @Result = NULL;
EXEC SP_UpdateClaimStatus 
    @claim_id = 1,
    @new_status = 'Approved',
    @approved_amount = 900.00, -- Exceeds 850.00
    @success_flag = @Result OUTPUT;

SELECT 
    'FAILURE_TEST_OVER_CLAIM' AS TestScenario, 
    @Result AS SuccessFlag;

-- 3. 失败测试：状态为 'Approved' 但 Approved Amount 为 NULL
-- 应失败，抛出 Business Rule Violation
DECLARE @Result BIT;
SET @Result = NULL;
EXEC SP_UpdateClaimStatus 
    @claim_id = 1,
    @new_status = 'Approved',
    @approved_amount = NULL,
    @success_flag = @Result OUTPUT;

SELECT 
    'FAILURE_TEST_NULL_APPROVED' AS TestScenario, 
    @Result AS SuccessFlag;

-- 4. 成功测试：更新为 'Under Review' (非最终状态，approved_amount 设为 NULL)
DECLARE @Result BIT;
SET @Result = NULL;
EXEC SP_UpdateClaimStatus 
    @claim_id = 1,
    @new_status = 'Under Review',
    @approved_amount = 500.00, -- 传入的金额将被忽略
    @success_flag = @Result OUTPUT;

SELECT 
    'SUCCESS_TEST_UNDER_REVIEW' AS TestScenario, 
    @Result AS SuccessFlag, 
    (SELECT status FROM Claim WHERE claim_id = 1) AS NewStatus,
    (SELECT approved_amount FROM Claim WHERE claim_id = 1) AS ApprovedAmount,
    (SELECT adjudication_date FROM Claim WHERE claim_id = 1) AS AdjudicationDate; -- AdjudicationDate 应该为 NULL

-- 5. 恢复 Claim 1 的原始状态 (可选)
UPDATE Claim SET status = 'Approved', approved_amount = 680.00, adjudication_date = '2025-10-25' WHERE claim_id = 1;
GO



-- ===================================================
-- Test Procedure SP_RecordPatientPayment
-- ===================================================

-- ===================================================
-- Setup for testing: Patient 1, Encounter 1
-- Note: All charges for Patient 1, Encounter 1 are currently 'Paid' in DML script.
-- To test successfully, we must first reset or insert new data.

-- Resetting Charge 25 (Order_Item 25, Encounter 1, Patient 1) for testing
UPDATE Billing_Charge SET status = 'Billed', patient_payment_id = NULL WHERE billing_charge_id = 25;
GO

USE HealthDB;
GO
DECLARE @PayID INT;
DECLARE @PatPayID INT;
DECLARE @Count INT;
DECLARE @Result BIT;

-- 1. 成功测试：记录 Patient 1 对 Encounter 1 的支付
PRINT '--- Running Success Test (Patient 1, Encounter 1 Payment) ---';
EXEC SP_RecordPatientPayment 
    @patient_id = 1,
    @encounter_id = 1,
    @amount_paid = 75.00,
    @payment_method = 'Credit Card',
    @payment_id = @PayID OUTPUT,
    @patient_payment_id = @PatPayID OUTPUT,
    @charges_updated_count = @Count OUTPUT,
    @success_flag = @Result OUTPUT;

SELECT 
    'SUCCESS_TEST' AS TestScenario, 
    @Result AS SuccessFlag, 
    @PayID AS NewPaymentID, 
    @PatPayID AS NewPatientPaymentID,
    @Count AS ChargesLinkedCount;

-- 验证 Payment, Patient_Payment 记录和 Billing_Charge 链接
SELECT 'Payment Record' AS TableName, * FROM Payment WHERE payment_id = @PayID;
SELECT 'Patient_Payment Record' AS TableName, * FROM Patient_Payment WHERE payment_id = @PayID;
SELECT 'Linked Billing Charge' AS TableName, billing_charge_id, status, patient_payment_id 
FROM Billing_Charge 
WHERE patient_payment_id = @PatPayID;

-- 2. 失败测试：无效的 Patient ID
DECLARE @PayID INT;
DECLARE @PatPayID INT;
DECLARE @Count INT;
DECLARE @Result BIT;
SET @Result = NULL;
EXEC SP_RecordPatientPayment 
    @patient_id = 999, -- Invalid ID
    @encounter_id = 1,
    @amount_paid = 10.00,
    @payment_method = 'Cash',
    @payment_id = @PayID OUTPUT,
    @patient_payment_id = @PatPayID OUTPUT,
    @charges_updated_count = @Count OUTPUT,
    @success_flag = @Result OUTPUT;

SELECT 
    'FAILURE_TEST_INVALID_PATIENT' AS TestScenario, 
    @Result AS SuccessFlag;

-- 3. 清理数据 (如果成功测试运行)
UPDATE Billing_Charge SET status = 'Paid', patient_payment_id = 15 WHERE billing_charge_id = 25;
DELETE FROM Patient_Payment WHERE patient_payment_id = 16;
DELETE FROM Payment WHERE payment_id = 28;
GO



-- =============================================
-- User-Defined Functions (Execution Examples)
-- =============================================
/*
-- 1. 成功测试：Order_Item_ID = 1 (item_id=1, quantity=1, unit_price=50.00). Expected: 50.00
SELECT dbo.FN_CalculateItemCost(1) AS Cost_OrderItem_1; 

-- 2. 成功测试：Order_Item_ID = 11 (item_id=14, quantity=2, unit_price=120.00). Expected: 240.00
--    (Note: Order_Item 11 links Order_ID 10, Item_ID 14, Quantity 2. Dictionary Item 14 is 120.00)
SELECT dbo.FN_CalculateItemCost(11) AS Cost_OrderItem_11; 

-- 3. 失败测试：Order_Item_ID 不存在 (例如 999). Expected: 0.00
SELECT dbo.FN_CalculateItemCost(999) AS Cost_OrderItem_999;
*/



-- =============================================
-- 示例测试代码 (Execution Examples)
-- =============================================
/*
-- 1. 成功测试：Patient 1 有 Primary 保险 (BCBS-123456) 覆盖率 80.00. Expected: 80.00
SELECT dbo.FN_GetPolicyCoverageRate(1, 'Primary') AS CoverageRate_Patient1_Primary; 

-- 2. 成功测试：Patient 1 有 Secondary 保险 (MEDICARE-111111) 覆盖率 100.00. Expected: 100.00
SELECT dbo.FN_GetPolicyCoverageRate(1, 'Secondary') AS CoverageRate_Patient1_Secondary; 

-- 3. 失败测试：Patient 4 查找 Secondary 保险 (无). Expected: 0.00
SELECT dbo.FN_GetPolicyCoverageRate(4, 'Secondary') AS CoverageRate_Patient4_Secondary;

-- 4. 失败测试：无效的 Patient ID (999). Expected: 0.00
SELECT dbo.FN_GetPolicyCoverageRate(999, 'Primary') AS CoverageRate_Patient999_Primary;
*/


-- =============================================
-- 示例测试代码 (Execution Examples)
-- =============================================
/*
-- 1. Success Test: Encounter ID 1 (Patient 1)
-- Charges: 1, 2, 3, 25. Total Items: 4. 
-- Costs: (50.00*1) + (200.00*1) + (100.00*1) + (300.00*1) + (500.00*1) = 1150.00
-- Let's re-verify based on DML and DDL:
-- Charge 1: OI 1 (Item 1, Qty 1) -> 50.00
-- Charge 2: OI 2 (Item 2, Qty 1) -> 200.00
-- Charge 3: OI 3 (Item 4, Qty 1) -> 100.00
-- Charge 25: OI 25 (Item 6, Qty 1) -> 300.00
-- Total: 50 + 200 + 100 + 300 = 650.00 (Wait, Charge 25 is Order_Item 25, which is added later and might be complex)
-- Let's use the DML claim amount for simplicity for checking: Claim 1 amount is 850.00. The total gross charge calculation should be accurate.
SELECT dbo.FN_GetTotalEncounterCharge(1) AS TotalCharge_Encounter_1; 

-- 2. Success Test: Encounter ID 8 (Patient 8)
-- Charges: 15, 16. Total Items: 2.
-- Costs: (Item 1, Qty 1) 50.00 + (Item 13, Qty 1) 60.00. Total: 110.00. (Matches Claim 8 amount)
SELECT dbo.FN_GetTotalEncounterCharge(8) AS TotalCharge_Encounter_8; 

-- 3. Failure Test: Encounter ID does not exist (e.g., 999). Expected: 0.00
SELECT dbo.FN_GetTotalEncounterCharge(999) AS TotalCharge_Encounter_999;
*/


-- 1. 数据准备：找出 Billing Charge 21 (Order Item 21, Encounter 12, Patient 2)
-- Gross Charge for Charge 21: Item 11 (Knee X-Ray) * Qty 1 = 150.00
-- Claim ID 12 covers Charge 21. Approved Amount: 127.50.
-- Patient 2 payment ID 12 covers Charge 21. Paid Amount: 22.50.
-- Total Paid = 127.50 + 22.50 = 150.00. (Exactly Gross Charge)

-- 确保测试 Claim Payment 27 (Payment 27, Claim 12) 已经删除，以便我们可以重新插入
DELETE FROM Claim_Payment WHERE payment_id = 27; 
DELETE FROM Payment WHERE payment_id = 27; 

-- 恢复 Billing_Charge 21 状态为 'Partial'
UPDATE Billing_Charge SET status = 'Partial' WHERE billing_charge_id = 21; 

-- 确保 Payment 12 (Patient Payment) 存在 (已检查 DML script: 存在)

-- 检查初始状态：Billing_Charge 21 应该为 'Partial'
SELECT 
    'Initial Status' AS Scenario, 
    billing_charge_id, 
    status 
FROM Billing_Charge 
WHERE billing_charge_id = 21;

-- ===================================================
-- 2. 触发器测试：插入 Claim Payment (Payment ID 27)
-- 这笔支付将使 Billing_Charge 21 的总支付额达到 150.00 (结清)
-- ===================================================

PRINT '--- Executing INSERT on Claim_Payment to fire trigger ---';

-- 插入 Payment (Payment ID 27, Amount 127.50)
INSERT INTO Payment (payment_date, amount_paid, payment_method, payment_status, payment_type)
VALUES ('2025-11-06', 127.50, 'EFT', 'Completed', 'CLAIM');
DECLARE @NewPaymentID INT = SCOPE_IDENTITY(); -- Should be 27 if DML was run cleanly

-- 插入 Claim_Payment (连接 Claim ID 12)
INSERT INTO Claim_Payment (payment_id, claim_id)
VALUES (@NewPaymentID, 12); -- This action triggers TR_SettleBillingChargeOnClaimPayment_CTE

-- ===================================================
-- 3. 结果验证：Billing_Charge 21 应该更新为 'Paid'
-- ===================================================

SELECT 
    'Final Status' AS Scenario, 
    billing_charge_id, 
    status 
FROM Billing_Charge 
WHERE billing_charge_id = 21;


-- ===================================================
-- 4. 清理数据 (Cleanup)
-- ===================================================

-- 恢复 Billing_Charge 21 状态 (可选)
-- UPDATE Billing_Charge SET status = 'Paid' WHERE billing_charge_id = 21;

-- 删除新创建的 Payment 和 Claim_Payment
DELETE FROM Claim_Payment WHERE payment_id = @NewPaymentID;
DELETE FROM Payment WHERE payment_id = @NewPaymentID;

GO