DROP PROCEDURE IF EXISTS CALCULATE_DISCOUNT_AMOUNT;
DROP PROCEDURE IF EXISTS CALCULATE_LATE_FEE_AND_TAX;
DROP PROCEDURE IF EXISTS GENERATE_REVENUE_REPORT;

DELIMITER //
CREATE PROCEDURE CALCULATE_DISCOUNT_AMOUNT
(IN dlNum CHAR(8),
IN amount FLOAT(10,2),
IN discountCode CHAR(4), 
OUT discountAmt FLOAT(10,2)) 
-- local declarations
BEGIN
  
  DECLARE memberType CHAR(1);
  DECLARE discountPercentage FLOAT(4,2); 
  SELECT MEMBERSHIP_TYPE INTO memberType FROM CUSTOMER_DETAILS WHERE DL_NUMBER = dlNum;
  IF IFNULL(discountCode,'NULL') <> 'NULL' THEN
    SELECT DISCOUNT_PERCENTAGE INTO discountPercentage FROM DISCOUNT_DETAILS WHERE DISCOUNT_CODE = discountCode;
    IF memberType = 'M' THEN
      SET discountAmt = amount * ((discountPercentage+10)/100);
    ELSE
     SET discountAmt = amount * (discountPercentage/100);
    END IF;
  ELSE
    IF memberType = 'M' THEN
      SET discountAmt = amount * 0.1;
    ELSE
      SET discountAmt = 0;
    END IF;
  END IF;
END //

CREATE PROCEDURE CALCULATE_LATE_FEE_AND_TAX
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

CREATE PROCEDURE GENERATE_REVENUE_REPORT
BEGIN

    DECLARE thisLocationID CHAR(4);  
    DECLARE currentLocationID CHAR(4);
    DECLARE locationName VARCHAR(50);  
    DECLARE thisCategoryName VARCHAR(25); 
    DECLARE thisNoOfCars integer;  
    DECLARE thisRevenue DECIMAL(15,2);
-- Cursor declaration
    DECLARE CURSOR_REPORT CURSOR FOR SELECT TABLE1.LOCATIONID, TABLE1.CATNAME , TABLE1.NOOFCARS,
    SUM(IFNULL((TABLE2.AMOUNT),'NULL') <> 'NULL') AS REVENUE 
    FROM (SELECT LC.LID AS LOCATIONID, LC.CNAME AS CATNAME ,COUNT(C.REGISTRATION_NUMBER) AS NOOFCARS 
    FROM (SELECT L.LOCATION_ID AS LID, CC.CATEGORY_NAME AS CNAME 
    FROM CAR_CATEGORY CC CROSS JOIN LOCATION_DETAILS L) LC LEFT OUTER JOIN CAR C ON LC.CNAME = C.CAR_CATEGORY_NAME AND LC.LID = C.LOC_ID
    GROUP BY LC.LID, LC.CNAME ORDER BY LC.LID) TABLE1 LEFT OUTER JOIN (SELECT BC.PLOC AS PICKLOC,BC.CNAME AS CNAMES, 
    SUM(BL.TOTAL_AMOUNT) AS AMOUNT 
    FROM (SELECT B.PICKUP_LOC AS PLOC, C1.CAR_CATEGORY_NAME AS CNAME, B.BOOKING_ID AS BID 
    FROM BOOKING_DETAILS B INNER JOIN CAR C1 ON B.REG_NUM = C1.REGISTRATION_NUMBER) BC INNER JOIN BILLING_DETAILS BL ON BC.BID = BL.BOOKING_ID 
    WHERE (DATE (SYSDATE) - DATE(BL.BILL_DATE)) <=30 GROUP BY BC.PLOC,BC.CNAME ORDER BY BC.PLOC) TABLE2
    ON TABLE1.LOCATIONID=TABLE2.PICKLOC AND TABLE1.CATNAME = TABLE2.CNAMES GROUP BY  TABLE1.LOCATIONID, TABLE1.CATNAME, TABLE1.NOOFCARS 
    ORDER BY TABLE1.LOCATIONID;

    
    SELECT (' ');
    SELECT ('Revenue Report');
    SELECT ('**************');
    SELECT (' ');
    OPEN CURSOR_REPORT;
    FETCH CURSOR_REPORT INTO thisLocationID, thisCategoryName, thisNoOfCars, thisRevenue;
    IF CURSOR_REPORT%NOTFOUND THEN
      SELECT ('No Report to be Generated');
    ELSE
      SET currentLocationID = thisLocationID;
      NEXT_LOC:BEGIN
      SELECT LOCATION_NAME INTO locationName from LOCATION_DETAILS WHERE LOCATION_ID = currentLocationID;
      SELECT ('Location Name: '|| locationName);
      SELECT (' ');
      SELECT ('Car Category' || '    '||'Number of Cars' ||'    '|| 'Revenue');
      SELECT ('------------' || '    '||'--------------' ||'    '|| '-------');
      SELECT (thisCategoryName || RPAD(' ', (16 - LENGTH(thisCategoryName),' '),thisNoOfCars 
      ||RPAD(' ', (18 - LENGTH(thisNoOfCars)),' ')|| thisRevenue));
      LOOP
        FETCH CURSOR_REPORT INTO thisLocationID, thisCategoryName, thisNoOfCars, thisRevenue;
        -- EXIT WHEN IF NOT EXISTS CURSOR_REPORT;
        IF thisLocationID = currentLocationID THEN
          SELECT (thisCategoryName || RPAD(' ', (16 - LENGTH(thisCategoryName)),' ')||thisNoOfCars 
          ||RPAD(' ', (18 - LENGTH(thisNoOfCars)),' ')|| thisRevenue);
          LEAVE NEXT_LOC;
        ELSE
          SET currentLocationID = thisLocationID;
          SELECT (' ');
          SELECT ('*********************************************************************************************************');
          SELECT (' ');
          
        END IF;        
      END LOOP;
      END NEXT_LOC;
    END IF;
END //

DELIMITER ;