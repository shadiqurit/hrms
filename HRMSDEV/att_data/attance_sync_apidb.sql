/* Formatted on 6/23/2025 12:26:16 PM (QP5 v5.362) */
CREATE OR REPLACE PROCEDURE attance_sync_apidb
AS
    CURSOR c1 IS
        SELECT userid,
               att_time,
               device,
               status
          FROM attendance_time
         WHERE NVL (flag, 'N') = 'N';

BEGIN
    FOR i IN c1
    LOOP
        INSERT INTO ATT_MCDATA@apihr (ID,
                                      USERID,
                                      ATTTIME,
                                      DEVICE_ID,
                                      STATUS)
             VALUES (att_mcdata_seq.NEXTVAL,
                     i.userid,
                     i.att_time,
                     i.device,
                     i.status);



        UPDATE attendance_time
           SET flag = 'Y'
         WHERE userid = i.userid;
    END LOOP;



    COMMIT;
END;
/
