/* Formatted on 7/29/2025 12:28:48 PM (QP5 v5.362) */
DROP SEQUENCE s_attdata;
/

CREATE SEQUENCE s_attdata;
/

DELETE FROM attendance_details;
/

--ATT_MCDATA

BEGIN
    p_att_schedule;
    p_att_update_details;
END;
/

BEGIN
    p_att_up;
END;
/

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
             WHERE SUBSTR (am.userid, 4) = SUBSTR (ee.emp_id, 5))
 WHERE ee.BRANCH_ID = 0;