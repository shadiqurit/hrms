/* Formatted on 8/6/2025 2:32:59 PM (QP5 v5.362) */
SELECT empcode,
       e_name,
       CONFIRM_ST,
       BIRTHDATE,
       salarygrade,
       JOIN_DATE,
       TER_DATE,
       REFRESHMENT_GRADE,
       department_name,
       sub_department_name,
       desig_code,
       desig_name,
       salarystep,
       salaryscal,
       emp_status,
       WEB_PASSWORD,
       BLD_GROUP,
       ccode,
       SECTION_NAME,
       DP_CODE, cata
  FROM emp
 WHERE empcode IN ('IPI-001367', 'IPI-001366');

  ;

UPDATE emp
   SET cata = 'NON OFFICER'
 WHERE empcode IN ('IPI-001367');