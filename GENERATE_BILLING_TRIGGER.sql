-- -----------------------------------------------------------------------------------------
-- Trigger Name: GENERATE_BILLING
-- This trigger generates the bill and inserts a row in Billing_Details table
-- -----------------------------------------------------------------------------------------
DROP TRIGGER IF EXISTS GENERATE_BILLING;

DELIMITER //
CREATE TRIGGER GENERATE_BILLING
AFTER UPDATE ON BOOKING_DETAILS
FOR EACH ROW
BEGIN
  DECLARE lastBillId CHAR(6);
  DECLARE newBillId CHAR(6);
  DECLARE discountAmt FLOAT(10,2);
  DECLARE totalLateFee FLOAT(10,2);
  DECLARE totalTax FLOAT(10,2);
  DECLARE totalAmountBeforeDiscount FLOAT(10,2);
  DECLARE finalAmount FLOAT(10,2);
  IF IFNULL((NEW.ACT_RET_DT_TIME),'NULL') <> 'NULL' AND NEW.BOOKING_STATUS ='R' THEN
   
    SELECT x.BILL_ID INTO lastBillId FROM 
      ( 
        SELECT BILL_ID, ROWNUM AS RN FROM  BILLING_DETAILS
        WHERE RN= (SELECT MAX(ROWNUM) FROM BILLING_DETAILS);
      )x 
     
    
    SET newBillId = 'BL' || CHAR(CAST( SUBSTRING(lastBillId,3) AS UNSIGNED )+1);
    
    CALL CALCULATE_LATE_FEE_AND_TAX(NEW.ACT_RET_DT_TIME, NEW.RET_DT_TIME, NEW.REG_NUM,NEW.AMOUNT, totalLateFee, totalTax);
    
    SET totalAmountBeforeDiscount = NEW.AMOUNT + totalLateFee + totalTax;
    
    CALL CALCULATE_DISCOUNT_AMOUNT(NEW.DL_NUM, totalAmountBeforeDiscount, NEW.DISCOUNT_CODE, discountAmt);
    
    SET finalAmount = totalAmountBeforeDiscount - discountAmt;  
    -- insert new bill into the billing_details table
    INSERT INTO BILLING_DETAILS (BILL_ID,BILL_DATE,BILL_STATUS,DISCOUNT_AMOUNT,TOTAL_AMOUNT,TAX_AMOUNT,BOOKING_ID,TOTAL_LATE_FEE) 
    VALUES (newBillId,SYSDATE(),'P',discountAmt,finalAmount,totalTax,NEW.BOOKING_ID,totalLateFee);
  END IF;
END //
DELIMITER ;









