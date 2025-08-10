/* Formatted on 8/10/2025 6:41:14 PM (QP5 v5.362) */
CREATE OR REPLACE FORCE VIEW v_fpunch_lpunc
AS
      SELECT userid
                 emp_id,
             TRUNC (atttime)
                 AS attendance_date,
             MIN (atttime)
                 AS in_time,
             MIN (device_id) KEEP (DENSE_RANK FIRST ORDER BY atttime)
                 AS in_device,
             MAX (atttime)
                 AS out_time,
             MIN (device_id) KEEP (DENSE_RANK LAST ORDER BY atttime)
                 AS out_device
        FROM att_mcdata
       WHERE flag = 'N' --AND userid = 555009129
    GROUP BY userid, TRUNC (atttime)
    ORDER BY attendance_date DESC, userid;