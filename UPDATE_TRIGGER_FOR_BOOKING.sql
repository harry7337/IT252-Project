-- -----------------------------------------------------------------------------------------
-- Trigger Name: UPDATE_CAR_DETAILS
-- This trigger updates the availability flag, mileage and location in the car table 
-- when the car is returned.
-- -----------------------------------------------------------------------------------------
DROP TRIGGER IF EXISTS UPDATE_CAR_DETAILS;
DROP FUNCTION IF EXISTS get_mileage;

DELIMITER //
CREATE TRIGGER UPDATE_CAR_DETAILS
AFTER UPDATE ON BOOKING_DETAILS
FOR EACH ROW
BEGIN
    IF NEW.BOOKING_STATUS ='C' THEN
      UPDATE CAR SET LOC_ID = NEW.PICKUP_LOC WHERE REGISTRATION_NUMBER = NEW.REG_NUM;
      UPDATE CAR SET AVAILABILITY_FLAG = 'A' WHERE REGISTRATION_NUMBER = NEW.REG_NUM;
       
    ELSE 
      IF IFNULL((NEW.ACT_RET_DT_TIME),'NULL') <> 'NULL' THEN
        UPDATE CAR SET AVAILABILITY_FLAG = 'A' , LOC_ID = NEW.DROP_LOC, MILEAGE = MILEAGE+get_mileage() WHERE REGISTRATION_NUMBER = NEW.REG_NUM;
      END IF;
    END IF;
END //



CREATE FUNCTION get_mileage() RETURNS INTEGER
DETERMINISTIC
BEGIN
  DECLARE mileage INTEGER;
  SET mileage = FLOOR(RAND()*(10000-100+1)+100);
  RETURN mileage;
END //

DELIMITER ;
