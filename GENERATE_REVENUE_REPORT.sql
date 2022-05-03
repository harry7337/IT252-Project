-- -----------------------------------------------------------------------------------------
-- Procedure Name: GENERATE_REVENUE_REPORT
-- This stored procedure calculates and generates the monthly revenue report.
-- -----------------------------------------------------------------------------------------

DELIMITER //
CREATE PROCEDURE GENERATE_REVENUE_REPORT()
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
CALL GENERATE_REVENUE_REPORT();










