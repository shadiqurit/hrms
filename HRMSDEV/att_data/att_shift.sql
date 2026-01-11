/* Formatted on 1/5/2026 10:32:46 AM (QP5 v5.362) */
SELECT yearmn,
       empid,
       day_no,
       yyyymmdd,
       TO_TIMESTAMP (TO_CHAR (shift_date, 'MM/DD/YYYY') || ' ' || start_time,
                     'MM/DD/YYYY HH:MI AM')    AS shift_in_time,
       TO_TIMESTAMP (TO_CHAR (shift_date, 'MM/DD/YYYY') || ' ' || end_time,
                     'MM/DD/YYYY HH:MI AM')    AS shift_out_time,
       shift_date,
       shift_id,
       shift_name,
       start_time,
       end_time,
       duration_hours,
       is_night_shift,
       nextday_flag,
       shift_status,
       com_id
  FROM v_emp_monthly_roster
  where empid = 133008710
  and yearmn = 202601
  order by shift_date