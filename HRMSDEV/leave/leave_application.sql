/* Formatted on 7/15/2025 11:47:00 AM (QP5 v5.362) */
CREATE TABLE leave_types
(
    lt_id              NUMBER,
    short_code         VARCHAR2 (5 BYTE),
    leave_type_name    VARCHAR2 (50 BYTE) NOT NULL,
    description        VARCHAR2 (100 BYTE),
    annual_quota       NUMBER,
    is_paid            CHAR (1 BYTE),
    active_flag        CHAR (1 BYTE) DEFAULT 'Y',
    ent_by             VARCHAR2 (50 BYTE),
    ent_date           DATE DEFAULT SYSDATE,
    upd_by             VARCHAR2 (50 BYTE),
    upd_date           DATE,
    com_id             NUMBER
);

ALTER TABLE leave_types
    ADD (CHECK (is_paid IN ('Y', 'N')) ENABLE VALIDATE,
         CHECK (active_flag IN ('Y', 'N')) ENABLE VALIDATE,
         CONSTRAINT leave_types_pk PRIMARY KEY (lt_id));

CREATE TABLE leave_request
(
    leave_id         NUMBER PRIMARY KEY,
    empid            NUMBER NOT NULL,
    leave_type       VARCHAR2 (10) NOT NULL,
    leave_balance    NUMBER DEFAULT 10,
    leave_taken      NUMBER DEFAULT 0,
    applied_date     DATE DEFAULT SYSDATE,
    l_start_date     DATE NOT NULL,
    l_end_date       DATE NOT NULL,
    proposed_days    NUMBER NOT NULL,
    leave_purpose    VARCHAR2 (255) NOT NULL,
    leave_address    VARCHAR2 (255) NOT NULL,
    leave_status     VARCHAR2 (10) DEFAULT 'P',
    ent_date         DATE DEFAULT SYSDATE,
    ent_by           NUMBER,
    upd_date         DATE,
    upd_by           NUMBER
);
/

CREATE OR REPLACE TRIGGER trg_leave_request_pk
    BEFORE INSERT OR UPDATE
    ON leave_request
    FOR EACH ROW
BEGIN
    IF :new.leave_id IS NULL
    THEN
        SELECT NVL (MAX (leave_id), 0) + 1
          INTO :new.leave_id
          FROM leave_request;
    END IF;
END;
/



CREATE TABLE leave_app_history
(
    id                 NUMBER NOT NULL,
    leave_id           NUMBER,
    approver_level     VARCHAR2 (50 BYTE),
    approver_id        NUMBER,
    approval_date      DATE,
    approval_status    VARCHAR2 (50 BYTE),
    comments           VARCHAR2 (300 BYTE),
    com_id             NUMBER,
    ent_date           DATE DEFAULT SYSDATE,
    ent_by             NUMBER,
    upd_date           DATE,
    upd_by             NUMBER
);
/

CREATE OR REPLACE TRIGGER trg_leave_app_history_pk
    BEFORE INSERT OR UPDATE
    ON HRMS.leave_app_history
    FOR EACH ROW
BEGIN
    IF :new.id IS NULL
    THEN
        SELECT NVL (MAX (id), 0) + 1 INTO :new.id FROM leave_app_history;
    END IF;
END;
/


ALTER TABLE leave_app_history
    ADD (
        FOREIGN KEY
            (leave_id)
            REFERENCES leave_request (leave_id)
            ENABLE VALIDATE);