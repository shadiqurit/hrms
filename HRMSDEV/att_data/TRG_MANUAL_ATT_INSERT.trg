/* Formatted on 7/8/2025 7:13:27 PM (QP5 v5.362) */
CREATE OR REPLACE TRIGGER trg_manual_att_insert
    AFTER INSERT
    ON manual_att
    FOR EACH ROW
DECLARE
    -- Declare variables to hold approver IDs
    v_rep_person_id   NUMBER;
    v_hod_id          NUMBER;
    v_md_id           NUMBER;
    v_hr_id           NUMBER;
BEGIN
    -- Get the Reporting Person (RP) ID from the emp_rp table
    BEGIN
        SELECT rep_person_id
          INTO v_rep_person_id
          FROM emp_rp
         WHERE emp_id = :NEW.empid AND status = '1';
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            v_rep_person_id := NULL; -- No reporting person, proceed without inserting RP approval history
    END;

    --Insert RP approval history if Reporting Person exists
    IF v_rep_person_id IS NOT NULL
    THEN
        INSERT INTO m_att_app_history (m_att_id,
                                       approver_level,
                                       approver_id,
                                       approval_status,
                                       approval_date,
                                       comments,
                                       ent_date,
                                       ent_by)
             VALUES (:NEW.id,
                     'RP',
                     v_rep_person_id,
                     'P',
                     SYSDATE,
                     'Waiting for Reporting Person approval',
                     SYSDATE,
                     :NEW.ent_by);
    ELSE
        SELECT hod_id
          INTO v_hod_id
          FROM hod
         WHERE dept_id = (SELECT dept_id
                            FROM employees
                           WHERE id = :NEW.empid);

        INSERT INTO m_att_app_history (m_att_id,
                                       approver_level,
                                       approver_id,
                                       approval_status,
                                       approval_date,
                                       comments,
                                       ent_date,
                                       ent_by)
             VALUES (:NEW.id,
                     'HOD',
                     v_hod_id,
                     'PENDING',
                     SYSDATE,
                     'Waiting for HOD approval',
                     SYSDATE,
                     :NEW.ent_by);
    END IF;
END trg_manual_att_insert;
/
SHOW ERRORS;
/