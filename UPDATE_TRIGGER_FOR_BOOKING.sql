-- -----------------------------------------------------------------------------------------
-- Trigger Name: UPDATE_CAR_DETAILS
-- This trigger updates the availability flag, mileage and location in the car table 
-- when the car is returned.
-- -----------------------------------------------------------------------------------------
DELIMITER //
CREATE TRIGGER UPDATE_CAR_DETAILS
AFTER UPDATE ON BOOKING_DETAILS
FOR EACH ROW
BEGIN
    IF NEW.BOOKING_STATUS ='C' THEN
      UPDATE CAR SET LOC_ID = NEW.PICKUP_LOC;
      UPDATE CAR SET AVAILABILITY_FLAG = 'A';
       
    -- ELSE 
    --   IF IFNULL(TO_CHAR(NEW.ACT_RET_DT_TIME),'NULL') <> 'NULL' THEN
    --     UPDATE CAR SET AVAILABILITY_FLAG = 'A' , LOC_ID = NEW.DROP_LOC, MILEAGE = MILEAGE+GET_MILEAGE WHERE REGISTRATION_NUMBER = NEW.REG_NUM;
    --   END IF;
    END IF;
END //



create function get_mileage
RETURNS INTEGER
BEGIN
  DECLARE mileage CAR.MILEAGE;
  SET mileage = FLOOR(RAND()*(10000-100+1)+100);
  return mileage;
END //

DELIMITER ;
