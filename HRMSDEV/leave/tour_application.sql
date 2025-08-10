/* Formatted on 8/6/2025 12:22:37 PM (QP5 v5.362) */
CREATE TABLE tour_req
(
    tour_id          NUMBER,
    empid            NUMBER NOT NULL, 
    applied_date     DATE DEFAULT SYSDATE,
    t_start_date     DATE NOT NULL,
    t_end_date       DATE NOT NULL,    
    proposed_days    NUMBER NOT NULL,
    tour_purpose     VARCHAR2 (255 BYTE) NOT NULL,
    tour_address     VARCHAR2 (255 BYTE) NOT NULL,
    tour_status      VARCHAR2 (10 BYTE) DEFAULT 'p',
    comments         VARCHAR2 (200 BYTE),
    ent_date         DATE DEFAULT SYSDATE,
    ent_by           NUMBER,
    upd_date         DATE,
    upd_by           NUMBER    ,
    com_id number
);


ALTER TABLE tour_req
    ADD (PRIMARY KEY (tour_id));


CREATE OR REPLACE TRIGGER trg_tour_req_insert
    AFTER INSERT
    ON hrms.tour_req
    FOR EACH ROW
DECLARE
    -- declare variables to hold approver ids
    v_rep_person_id   NUMBER;
    v_hod_id          NUMBER;
    v_md_id           NUMBER := 222000789;                    -- example md id
    v_hr_id           NUMBER := 200007478; -- hr id, can be assigned as needed
BEGIN
    -- get the reporting person (rp) id from the emp_rp table
    BEGIN
        SELECT rep_person_id
          INTO v_rep_person_id
          FROM emp_rp
         WHERE emp_id = :new.empid AND status = '1';
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            v_rep_person_id := NULL; -- no reporting person, proceed without inserting rp approval history
    END;

    -- insert rp approval history if reporting person exists
    IF v_rep_person_id IS NOT NULL
    THEN
        INSERT INTO tour_app_history (tour_id,
                                      approver_level,
                                      approver_id,
                                      approval_status,
                                      approval_date,
                                      comments,
                                      ent_date,
                                      ent_by)
             VALUES (:new.tour_id,
                     'rp',
                     v_rep_person_id,
                     'pending', -- status is pending as it's waiting for rp approval
                     NULL,
                     'waiting for reporting person approval',
                     SYSDATE,
                     :new.ent_by);
    ELSE
        -- get hod id based on employee's department
        SELECT hod_id
          INTO v_hod_id
          FROM hod
         WHERE dept_id = (SELECT dept_id
                            FROM employees
                           WHERE id = :new.empid);

        -- if employee is not hod, forward to hod for approval
        IF v_hod_id <> :new.empid
        THEN
            INSERT INTO tour_app_history (tour_id,
                                          approver_level,
                                          approver_id,
                                          approval_status,
                                          approval_date,
                                          comments,
                                          ent_date,
                                          ent_by)
                 VALUES (:new.tour_id,
                         'hod',
                         v_hod_id,
                         'pending', -- status is pending as it's waiting for hod approval
                         NULL,
                         'waiting for head of department (hod) approval',
                         SYSDATE,
                         :new.ent_by);
        -- if employee is hod, forward to md for approval
        ELSIF v_hod_id = :new.empid
        THEN
            INSERT INTO tour_app_history (tour_id,
                                          approver_level,
                                          approver_id,
                                          approval_status,
                                          approval_date,
                                          comments,
                                          ent_date,
                                          ent_by)
                 VALUES (:new.tour_id,
                         'md',
                         v_md_id,
                         'pending', -- status is pending as it's waiting for md approval
                         NULL,
                         'waiting for md approval',
                         SYSDATE,
                         :new.ent_by);
        END IF;
    END IF;
END;
/


CREATE OR REPLACE TRIGGER hrms.trg_tour_req_pk
    BEFORE INSERT OR UPDATE
    ON hrms.tour_req
    FOR EACH ROW
BEGIN
    IF :new.tour_id IS NULL
    THEN
        SELECT NVL (MAX (tour_id), 0) + 1 INTO :new.tour_id FROM tour_req;
    END IF;
END;
/