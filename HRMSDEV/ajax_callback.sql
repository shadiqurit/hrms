DECLARE
   vid NUMBER := TO_NUMBER(:P500_ID); -- Use the page item value here
BEGIN
   -- Initialize the JSON response
   APEX_JSON.open_object;
   APEX_JSON.open_array('items');

   -- Query the data from your table using the parameter
   FOR rec IN (SELECT id empno,FIRSTNAME ename, lastname mgr, hiredate, 
                  PHONE job,SALARY sal,dv_id comm,dist_id deptno
               FROM employees
               where id = vid) 
   LOOP
      APEX_JSON.open_object;
      APEX_JSON.write('empno', rec.empno);
      APEX_JSON.write('ename', rec.ename);
      APEX_JSON.write('mgr', rec.mgr);
      APEX_JSON.write('hiredate', rec.hiredate);
      APEX_JSON.write('job', rec.job);
      APEX_JSON.write('sal', rec.sal);
      APEX_JSON.write('comm', rec.comm);
      APEX_JSON.write('deptno', rec.deptno);
      APEX_JSON.close_object;
   END LOOP;
   APEX_JSON.close_array;
   APEX_JSON.close_object;
END;