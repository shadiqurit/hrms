/* Formatted on 1/5/2026 10:35:29 AM (QP5 v5.362) */
CREATE OR REPLACE VIEW V_EMP_MONTHLY_ROSTER
AS
    SELECT rm.YEARMN,
           rm.EMPID,
           d.DAY_NO,
           rm.YEARMN || d.DAY_NO    AS YYYYMMDD,
           CASE
               WHEN TO_NUMBER (d.DAY_NO) <=
                    TO_NUMBER (
                        TO_CHAR (LAST_DAY (TO_DATE (rm.YEARMN, 'YYYYMM')),
                                 'DD'))
               THEN
                   TO_DATE (rm.YEARMN || d.DAY_NO, 'YYYYMMDD')
           END                      AS SHIFT_DATE,
           CASE d.DAY_NO
               WHEN '01' THEN rm.DAY1
               WHEN '02' THEN rm.DAY2
               WHEN '03' THEN rm.DAY3
               WHEN '04' THEN rm.DAY4
               WHEN '05' THEN rm.DAY5
               WHEN '06' THEN rm.DAY6
               WHEN '07' THEN rm.DAY7
               WHEN '08' THEN rm.DAY8
               WHEN '09' THEN rm.DAY9
               WHEN '10' THEN rm.DAY10
               WHEN '11' THEN rm.DAY11
               WHEN '12' THEN rm.DAY12
               WHEN '13' THEN rm.DAY13
               WHEN '14' THEN rm.DAY14
               WHEN '15' THEN rm.DAY15
               WHEN '16' THEN rm.DAY16
               WHEN '17' THEN rm.DAY17
               WHEN '18' THEN rm.DAY18
               WHEN '19' THEN rm.DAY19
               WHEN '20' THEN rm.DAY20
               WHEN '21' THEN rm.DAY21
               WHEN '22' THEN rm.DAY22
               WHEN '23' THEN rm.DAY23
               WHEN '24' THEN rm.DAY24
               WHEN '25' THEN rm.DAY25
               WHEN '26' THEN rm.DAY26
               WHEN '27' THEN rm.DAY27
               WHEN '28' THEN rm.DAY28
               WHEN '29' THEN rm.DAY29
               WHEN '30' THEN rm.DAY30
               WHEN '31' THEN rm.DAY31
           END                      AS SHIFT_ID,
           s.SHIFT_NAME,
           s.START_TIME,
           s.END_TIME,
           s.DURATION_HOURS,
           s.IS_NIGHT_SHIFT,
           s.NEXTDAY_FLAG,
           s.STATUS                 AS SHIFT_STATUS,
           rm.COM_ID
      FROM ROSTER_MN  rm
           CROSS JOIN (    SELECT TO_CHAR (LEVEL, 'FM00')     AS DAY_NO
                             FROM DUAL
                       CONNECT BY LEVEL <= 31) d
           LEFT JOIN SHIFTS s
               ON s.SHIFT_ID =
                  CASE d.DAY_NO
                      WHEN '01' THEN rm.DAY1
                      WHEN '02' THEN rm.DAY2
                      WHEN '03' THEN rm.DAY3
                      WHEN '04' THEN rm.DAY4
                      WHEN '05' THEN rm.DAY5
                      WHEN '06' THEN rm.DAY6
                      WHEN '07' THEN rm.DAY7
                      WHEN '08' THEN rm.DAY8
                      WHEN '09' THEN rm.DAY9
                      WHEN '10' THEN rm.DAY10
                      WHEN '11' THEN rm.DAY11
                      WHEN '12' THEN rm.DAY12
                      WHEN '13' THEN rm.DAY13
                      WHEN '14' THEN rm.DAY14
                      WHEN '15' THEN rm.DAY15
                      WHEN '16' THEN rm.DAY16
                      WHEN '17' THEN rm.DAY17
                      WHEN '18' THEN rm.DAY18
                      WHEN '19' THEN rm.DAY19
                      WHEN '20' THEN rm.DAY20
                      WHEN '21' THEN rm.DAY21
                      WHEN '22' THEN rm.DAY22
                      WHEN '23' THEN rm.DAY23
                      WHEN '24' THEN rm.DAY24
                      WHEN '25' THEN rm.DAY25
                      WHEN '26' THEN rm.DAY26
                      WHEN '27' THEN rm.DAY27
                      WHEN '28' THEN rm.DAY28
                      WHEN '29' THEN rm.DAY29
                      WHEN '30' THEN rm.DAY30
                      WHEN '31' THEN rm.DAY31
                  END;