DELIMITER $$  
CREATE FUNCTION car_mileage_rating(  
    car_mileage int  
)   
RETURNS VARCHAR(20)  
DETERMINISTIC  
BEGIN  
    DECLARE rating VARCHAR(20);  
    IF car_mileage > 35 THEN  
        SET rating = 'very good';  
    ELSEIF (car_mileage <= 35 AND   
            car_mileage >= 20) THEN  
        SET rating = 'average';  
    ELSEIF car_mileage < 20 THEN  
        SET rating = 'not good';  
    END IF;  
    RETURN (rating);  
END$$  

DELIMITER |
CREATE FUNCTION late_or_not_on_return (expected_date DATE)
  RETURNS VARCHAR(10)
   DETERMINISTIC
    BEGIN
     DECLARE sf_value VARCHAR(10);
        IF curdate() > expected_date
            THEN SET sf_value = 'Late';
        ELSEIF  curdate() <= expected_date
            THEN SET sf_value = 'Not Late';
        END IF;
    RETURN sf_value;
END|

DELIMITER $$  
CREATE FUNCTION discount_rating(  
    DISCOUNT_PERCENTAGE int  
)   
RETURNS VARCHAR(50)  
DETERMINISTIC  
BEGIN  
    DECLARE rating VARCHAR(50);  
    IF DISCOUNT_PERCENTAGE > 20 THEN  
        SET rating = 'Amazing member with good discount';  
    ELSEIF (DISCOUNT_PERCENTAGE <= 20 AND   
            DISCOUNT_PERCENTAGE >= 10) THEN  
        SET rating = 'Loved member with discount';  
    ELSEIF DISCOUNT_PERCENTAGE < 10 THEN  
        SET rating = 'Member with discount';  
    END IF;  
    RETURN (rating);  
END$$  


DELIMITER $$  
CREATE FUNCTION car_rating(  
    COST_PER_DAY FLOAT  
)   
RETURNS VARCHAR(30)  
DETERMINISTIC  
BEGIN  
    DECLARE rating VARCHAR(30);  
    IF COST_PER_DAY > 45 THEN  
        SET rating = 'High-end Car';  
    ELSEIF (COST_PER_DAY <= 45 AND   
            COST_PER_DAY >= 35) THEN  
        SET rating = 'Averagely priced Car';  
    ELSEIF COST_PER_DAY < 35 THEN  
        SET rating = 'Affordable Car';  
    END IF;  
    RETURN (rating);  
END$$  


DELIMITER $$  
CREATE FUNCTION member_or_not(  
    MEMBERSHIP_TYPE char(1)  
)   
RETURNS VARCHAR(3)  
DETERMINISTIC  
BEGIN  
    DECLARE result VARCHAR(20);  
    IF MEMBERSHIP_TYPE = 'N' THEN  
        SET result = 'No';  
    ELSEIF MEMBERSHIP_TYPE = 'M' THEN
        SET result = 'Yes';  
    END IF;  
    RETURN (result);  
END$$ 

