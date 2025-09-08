CREATE
OR REPLACE PROCEDURE attance_sync_apidb AS BEGIN -- 1. Insert all data in one go using INSERT SELECT
INSERT INTO
    ATT_MCDATA @apihr (
        ID,
        USERID,
        ATTTIME,
        DEVICE_ID,
        STATUS
    )
SELECT
    att_mcdata_seq.NEXTVAL @apihr,
    userid,
    att_time,
    device,
    status
FROM
    attendance_time
WHERE
    NVL(flag, 'N') = 'N';

-- 2. Update flag in bulk  
UPDATE
    attendance_time
SET
    flag = 'Y'
WHERE
    NVL(flag, 'N') = 'N';

COMMIT;

END;

/