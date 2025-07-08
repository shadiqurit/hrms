DROP VIEW HRMS.V_ATT_GEN;

/* Formatted on 7/8/2025 4:38:14 PM (QP5 v5.362) */
CREATE OR REPLACE FORCE VIEW HRMS.V_ATT_GEN
(
    ID,
    MC_ID,
    EMP_ID,
    BRANCH_ID,
    DAY_DATE,
    REGULAR_IN_TIME,
    REGULAR_OUT_TIME
)
BEQUEATH DEFINER
AS
    WITH
        date_series (day_date)
        AS
            ( -- Generate dates from the first day of the current month to today
             -- SELECT TRUNC (TO_DATE('6/1/2025','MM/DD/RRRR'), 'MM') AS day_date FROM DUAL
             SELECT TRUNC (SYSDATE, 'MM') AS day_date FROM DUAL
             UNION ALL
             SELECT day_date + 1
               FROM date_series
              WHERE day_date + 1 <= SYSDATE),
        employee_schedule
        AS
            ( -- Get employee schedules that are active for the current date range
             SELECT e.id,
                    e.mc_id,
                    e.EMP_ID,
                    e.BRANCH_ID,
                    o.OFFICE_START,
                    o.OFFICE_END,
                    o.SCHEDULE_START_DATE,
                    o.SCHEDULE_END_DATE
               FROM employees  e
                    JOIN OFFICE_SCHEDULE o ON o.LOCATION_ID = e.BRANCH_ID)
      SELECT es.id,
             es.mc_id,
             es.EMP_ID,
             es.BRANCH_ID,
             ds.day_date,
             TO_TIMESTAMP (
                 TO_CHAR (ds.day_date, 'MM/DD/YYYY') || ' ' || es.OFFICE_START,
                 'MM/DD/YYYY HH:MI AM')    AS REGULAR_IN_TIME,
             TO_TIMESTAMP (
                 TO_CHAR (ds.day_date, 'MM/DD/YYYY') || ' ' || es.OFFICE_END,
                 'MM/DD/YYYY HH:MI AM')    AS REGULAR_OUT_TIME
        FROM date_series ds
             JOIN employee_schedule es
                 ON ds.day_date BETWEEN TO_DATE (
                                            TO_CHAR (es.SCHEDULE_START_DATE,
                                                     'MM/DD/YYYY'),
                                            'MM/DD/YYYY')
                                    AND TO_DATE (
                                            TO_CHAR (es.SCHEDULE_END_DATE,
                                                     'MM/DD/YYYY'),
                                            'MM/DD/YYYY')
    --AND es.EMP_ID = :EMP_ID
    ORDER BY ds.day_date, es.EMP_ID;
