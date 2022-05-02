# IT252-Project
Automobile Rental System

## How to Run
```
mysql> use database project;
mysql> source DB_PROJECT.sql;
mysql> source INSERT_SCRIPT.sql;
mysql> source UPDATE_TRIGGER_FOR_BOOKING.sql;
mysql> source CALCULATE_TOTAL_FEE.sql;
mysql> source CALCULATE_DISCOUNT_AMOUNT.sql;
mysql> source GENERATE_BILLING_TRIGGER.sql;
mysql> source GENERATE_REVENUE_REPORT.sql;
```
### Tips:
- If there are errors in the file(which is very likely), and the file has been half compiled then you might have to recompile the files after undoing the previous compile. The easiest(yet the only way) to do it is to drop the database and re-run the steps given above.
```
mysql> drop database project;
```
