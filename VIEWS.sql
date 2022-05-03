CREATE OR REPLACE VIEW INSURANCE_DETAILS AS
SELECT INSURANCE_CODE, INSURANCE_NAME
FROM RENTAL_CAR_INSURANCE;

CREATE OR REPLACE VIEW CUSTOMER_BOOKING_DETAILS AS
SELECT CUST.FNAME, CUST.LNAME, CUST.EMAIL_ID, BOOK.BOOKING_ID, BOOK.AMOUNT, DL_NUM
FROM CUSTOMER_DETAILS CUST NATURAL JOIN BOOKING_DETAILS BOOK;

CREATE OR REPLACE VIEW HONDA_2014_A AS
SELECT *
FROM CAR
WHERE MAKE = 'HONDA'
AND MODEL_YEAR = 2014
AND AVAILABILITY_FLAG = 'A';

CREATE OR REPLACE VIEW TABLE1 AS 
SELECT LC.LID AS LOCATIONID, LC.CNAME AS CATNAME ,COUNT(C.REGISTRATION_NUMBER) AS NOOFCARS 
FROM (SELECT L.LOCATION_ID AS LID, CC.CATEGORY_NAME AS CNAME FROM 
CAR_CATEGORY CC CROSS JOIN LOCATION_DETAILS L) LC LEFT OUTER JOIN CAR C 
ON LC.CNAME = C.CAR_CATEGORY_NAME AND LC.LID = C.LOC_ID GROUP BY LC.LID, 
LC.CNAME ORDER BY LC.LID;
  
CREATE OR REPLACE VIEW TABLE2 AS
SELECT BC.PLOC AS PICKLOC,BC.CNAME AS CNAMES, SUM(BL.TOTAL_AMOUNT) AS AMOUNT FROM 
(SELECT B.PICKUP_LOC AS PLOC, C1.CAR_CATEGORY_NAME AS CNAME, B.BOOKING_ID AS BID 
FROM BOOKING_DETAILS B INNER JOIN CAR C1 ON B.REG_NUM = C1.REGISTRATION_NUMBER) BC
INNER JOIN BILLING_DETAILS BL ON BC.BID = BL.BOOKING_ID 
WHERE (TO_DAYS (SYSDATE()) - TO_DAYS(BL.BILL_DATE)) <=30 
GROUP BY BC.PLOC,BC.CNAME ORDER BY BC.PLOC;