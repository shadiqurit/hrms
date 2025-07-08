/* Formatted on 7/8/2025 1:07:48 PM (QP5 v5.362) */
DROP SEQUENCE s_attdata;

CREATE SEQUENCE s_attdata;

DELETE FROM attendance_details;

--ATT_MCDATA

BEGIN
    p_att_schedule;
    p_att_update_details;
END;



SELECT SUBSTR (mc_id, 4),
       SUBSTR (emp_id, 5)     empcode,
       mc_id,
       id
  FROM employees;

SELECT DISTINCT userid
  FROM att_mcdata;


UPDATE employees ee
   SET ee.mc_id =
           (SELECT DISTINCT userid
              FROM att_mcdata am
             WHERE substr(am.userid,4) = SUBSTR (ee.emp_id, 5))
             where ee.BRANCH_ID = 0;