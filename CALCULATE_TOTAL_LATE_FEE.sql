-- -----------------------------------------------------------------------------------------
-- Procedure Name: CALCULATE_LATE_FEE_AND_TAX
-- This stored procedure calculates the total late fee and tax.
-- -----------------------------------------------------------------------------------------
DELIMITER //

CREATE  PROCEDURE CALCULATE_LATE_FEE_AND_TAX
(IN actualReturnDateTime TIMESTAMP,
IN ReturnDateTime TIMESTAMP,
IN regNum CHAR(7), 
IN amount FLOAT(10,2),
OUT totalLateFee FLOAT(10,2),
OUT totalTax FLOAT(10,2)) 

BEGIN
  DECLARE lateFeePerHour FLOAT(5,2);
  DECLARE hourDifference DECIMAL(10,2);
  SELECT LATE_FEE_PER_HOUR INTO lateFeePerHour 
  FROM CAR_CATEGORY CC INNER JOIN CAR C ON CC.CATEGORY_NAME = C.CAR_CATEGORY_NAME 
  WHERE C.REGISTRATION_NUMBER = regNum;
  
  IF actualReturnDateTime > ReturnDateTime THEN
    SET hourDifference = TIMESTAMPDIFF(HOUR,ReturnDateTime,actualReturnDateTime);
    SET totalLateFee = hourDifference * lateFeePerHour;
  ELSE
    SET totalLateFee = 0;
  END IF;
  SET totalTax = (amount + totalLateFee)*0.0825;
END //
DELIMITER ;


