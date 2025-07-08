/* Formatted on 7/8/2025 11:03:26 AM (QP5 v5.362) */


CREATE TABLE manual_att
(
    id           NUMBER NOT NULL PRIMARY KEY,
    empid        NUMBER,
    empcode      VARCHAR2 (30),
    reason       VARCHAR2 (200) NOT NULL,
    m_intime     DATE,
    m_outtime    DATE,
    status       VARCHAR2 (20),
    comments     VARCHAR2 (1000),
    com_id       NUMBER,
    ent_date     DATE DEFAULT SYSDATE,
    ent_by       NUMBER,
    upd_date     DATE,
    upd_by       NUMBER,
    FOREIGN KEY (empid) REFERENCES employees (id)
);
/

CREATE TABLE m_att_app_history
(
    id                 NUMBER NOT NULL PRIMARY KEY,
    m_att_id           NUMBER,
    approver_level     VARCHAR2 (50),
    approver_id        NUMBER,
    approval_date      DATE,
    approval_status    VARCHAR2 (50),
    comments           VARCHAR2 (300),
    com_id             NUMBER,
    ent_date           DATE DEFAULT SYSDATE,
    ent_by             NUMBER,
    upd_date           DATE,
    upd_by             NUMBER,
    FOREIGN KEY (m_att_id) REFERENCES manual_att (id)
);



CREATE TABLE emp_rp
(
    id               NUMBER,
    emp_id           NUMBER,
    rep_person_id    NUMBER,
    status           VARCHAR2 (10) DEFAULT 'ACTIVE',
    ent_date         DATE DEFAULT SYSDATE,
    ent_by           NUMBER,
    upd_date         DATE,
    upd_by           NUMBER
);



CREATE TABLE hod
(
    id          NUMBER,
    dept_id     NUMBER,
    hod_id      NUMBER,
    status      VARCHAR2 (10) DEFAULT 'ACTIVE',
    ent_date    DATE DEFAULT SYSDATE,
    ent_by      NUMBER,
    upd_date    DATE,
    upd_by      NUMBER
);



--
--
--create table approval_policy
--(
--    policy_id           number primary key,        -- Unique ID for the policy
--    request_type        varchar2 (20) not null, -- Type of request (Leave, Manual Attendance, Tour, etc.)
--    notes        varchar2 (50),
--    department          number,      -- Department (e.g., Sales, HR, IT, etc.)
--    hod_id              number,
--    md_id               number,
--    hr_emp_id           number,
--    r_role              varchar2 (50) not null, -- Role (RP, HOD, MD, HR, etc.)
--    role_order          number not null, -- The order of approval (e.g., RP -> HOD -> MD -> HR)
--    role_description    varchar2 (255), -- Optional description of the role in the policy
--    active_status       varchar2 (10) default 'ACTIVE', -- Role's active status (ACTIVE/INACTIVE)
--    ent_date            date default sysdate,
--    ent_by              number,
--    upd_date            date,
--    upd_by              number
--);
--/