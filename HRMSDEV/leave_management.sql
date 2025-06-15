/* Formatted on 5/6/2025 2:04:14 PM (QP5 v5.362) */
----# Oracle APEX Attendance & Tour Management System Design

CREATE TABLE leave_types
(
    lt_id              NUMBER,
    short_code         VARCHAR2 (5),
    leave_type_name    VARCHAR2 (50) NOT NULL,
    description        VARCHAR2 (100),
    annual_quota       NUMBER,
    is_paid            CHAR (1) CHECK (is_paid IN ('Y', 'N')),
    active_flag        CHAR (1) DEFAULT 'Y' CHECK (active_flag IN ('Y', 'N')),
    ent_by             VARCHAR2 (50),
    ent_date           DATE DEFAULT SYSDATE,
    upd_by             VARCHAR2 (50),
    upd_date           DATE,
    com_id             NUMBER
);
/

--- Leave Allocation Policy Needed---

CREATE TABLE leave_allocation
(
    la_id                NUMBER,
    emp_id               NUMBER NOT NULL,
    lt_id                NUMBER NOT NULL,
    l_year               NUMBER NOT NULL,
    opening_balance      NUMBER,
    adjusted             NUMBER,
    used_days            NUMBER,
    tran_date            DATE,
    remaining_days       NUMBER,
    last_updated_date    DATE,
    CONSTRAINT fk_balance_employee FOREIGN KEY (emp_id)
        REFERENCES employees (id),
    CONSTRAINT fk_balance_leave_type FOREIGN KEY (lt_id)
        REFERENCES leave_types (lt_id)
);


CREATE TABLE leave_application
(
    app_id           NUMBER PRIMARY KEY,
    emp_id           NUMBER NOT NULL,
    lt_id            NUMBER,
    start_date       DATE,
    end_date         DATE,
    total_days       NUMBER,
    reason           VARCHAR2 (200),
    l_address        VARCHAR2 (200),
    status           VARCHAR2 (20),
    remarks          VARCHAR2 (200),
    approved_by      NUMBER,
    approval_date    DATE,
    ent_by           VARCHAR2 (50),
    ent_date         DATE DEFAULT SYSDATE,
    upd_by           VARCHAR2 (50),
    upd_date         DATE,
    com_id           NUMBER,
    CONSTRAINT fk_leave_employee FOREIGN KEY (emp_id)
        REFERENCES employees (id),
    CONSTRAINT fk_leave_type FOREIGN KEY (lt_id)
        REFERENCES leave_types (lt_id),
    CONSTRAINT fk_leave_approver FOREIGN KEY (approved_by)
        REFERENCES employees (id)
);


CREATE TABLE short_leave
(
    sl_id            NUMBER,
    emp_id           NUMBER NOT NULL,
    start_date       DATE NOT NULL,
    end_date         DATE NOT NULL,
    total_hour       NUMBER,
    reason           VARCHAR2 (200),
    l_address        VARCHAR2 (200),
    status           VARCHAR2 (20),
    remarks          VARCHAR2 (200),
    approved_by      NUMBER,
    approval_date    DATE,
    ent_by           VARCHAR2 (50),
    ent_date         DATE DEFAULT SYSDATE,
    upd_by           VARCHAR2 (50),
    upd_date         DATE,
    com_id           NUMBER,
    CONSTRAINT fk_shortleave_employee FOREIGN KEY (emp_id)
        REFERENCES employees (id),
    CONSTRAINT fk_shortleave_approver FOREIGN KEY (approved_by)
        REFERENCES employees (id)
);


-- ##### Tour Management Module

CREATE TABLE tour_application
(
    tour_id          NUMBER,
    emp_id           NUMBER NOT NULL,
    description      VARCHAR2 (200),
    purpose          VARCHAR2 (200) NOT NULL,
    tour_address     VARCHAR2 (200),
    start_date       DATE,
    end_date         DATE,
    status           VARCHAR2 (20),
    approved_by      NUMBER,
    approval_date    DATE,
    ent_by           NUMBER,
    ent_date         DATE DEFAULT SYSDATE,
    upd_by           NUMBER,
    upd_date         DATE,
    CONSTRAINT fk_tour_applicant FOREIGN KEY (emp_id)
        REFERENCES employees (id),
    CONSTRAINT fk_tour_creator FOREIGN KEY (ent_by) REFERENCES employees (id),
    CONSTRAINT fk_tour_updater FOREIGN KEY (upd_by) REFERENCES employees (id)
);


CREATE TABLE short_tour
(
    tour_id          NUMBER,
    emp_id           NUMBER NOT NULL,
    purpose          VARCHAR2 (200),
    tour_address     VARCHAR2 (200),
    shrot_start      DATE,
    shrot_end        DATE,
    approved_by      NUMBER,
    approval_date    DATE,
    status           VARCHAR2 (20),
    ent_by           NUMBER,
    ent_date         DATE DEFAULT SYSDATE,
    upd_by           NUMBER,
    upd_date         DATE,
    CONSTRAINT fk_shtour_applicant FOREIGN KEY (emp_id)
        REFERENCES employees (id),
    CONSTRAINT fk_shtour_creator FOREIGN KEY (ent_by)
        REFERENCES employees (id),
    CONSTRAINT fk_shtour_updater FOREIGN KEY (upd_by)
        REFERENCES employees (id)
);


-- Office Schedule ---

CREATE TABLE office_schedule
(
    os_id                   NUMBER,
    os_name                 VARCHAR2 (100),
    com_id                  NUMBER,
    location_id             NUMBER,
    department_id           NUMBER,
    office_start_time       VARCHAR2 (30),
    office_end_time         VARCHAR2 (30),
    half_day_start          VARCHAR2 (30),
    half_day_end            VARCHAR2 (30),
    grace_period_minutes    NUMBER DEFAULT 10,
    active_flag             CHAR (1)
                               DEFAULT 'Y'
                               CHECK (active_flag IN ('Y', 'N'))
);
/

-- Employee-specific attendance rules (overrides department rules)

CREATE TABLE t_shift                                         --- Shifting Duty
(
    shift_id       NUMBER,
    shift_name     VARCHAR2 (100),
    start_time     VARCHAR2 (30),
    end_time       VARCHAR2 (30),
    active_flag    CHAR (1) DEFAULT 'Y' CHECK (active_flag IN ('Y', 'N')),
    nextday_flag  CHAR (1) DEFAULT 'N' CHECK (nextday_flag IN ('Y', 'N')),
    ent_by         NUMBER,
    ent_date       DATE DEFAULT SYSDATE,
    upd_by         NUMBER,
    upd_date       DATE
);

CREATE TABLE employee_shift                                  --- Shifting Duty
(
    es_id         NUMBER,
    emp_id        NUMBER NOT NULL,
    shift_id      NUMBER,
    shift_date    DATE,
    status        VARCHAR2 (20)
                        CHECK (status IN ('A', 'I', 'C')),
    ent_by        NUMBER,
    ent_date      DATE DEFAULT SYSDATE,
    upd_by        NUMBER,
    upd_date      DATE,
    CONSTRAINT fk_er_employee FOREIGN KEY (emp_id) REFERENCES employees (id)
);



-- Manual adjustments to leave balances

CREATE TABLE leave_adjustments
(
    adjustment_id      NUMBER,
    emp_id             NUMBER NOT NULL,
    lt_id              NUMBER NOT NULL,
    adjustment_date    DATE DEFAULT SYSDATE,
    adjustment_days    NUMBER (5, 1) NOT NULL,
    year               NUMBER NOT NULL,
    reason             VARCHAR2 (200) NOT NULL,
    approved_by        NUMBER NOT NULL,
    approval_date      DATE,
    ent_by             NUMBER NOT NULL,
    ent_date           DATE DEFAULT SYSDATE,
    CONSTRAINT fk_la_employee FOREIGN KEY (emp_id) REFERENCES employees (id),
    CONSTRAINT fk_la_leave_type FOREIGN KEY (lt_id)
        REFERENCES leave_types (lt_id),
    CONSTRAINT fk_la_approver FOREIGN KEY (approved_by)
        REFERENCES employees (id),
    CONSTRAINT fk_la_creator FOREIGN KEY (ent_by) REFERENCES employees (id)
);

CREATE TABLE holidays_location_wise
(
    holiday_id       NUMBER,
    holiday_date     DATE NOT NULL,
    description      VARCHAR2 (200),
    com_id           NUMBER,
    location_id      NUMBER,
    department_id    NUMBER,
    ent_by           NUMBER,
    ent_date         DATE DEFAULT SYSDATE,
    upd_by           NUMBER,
    upd_date         DATE,
    CONSTRAINT fk_hol_locw_creator FOREIGN KEY (ent_by)
        REFERENCES employees (id),
    CONSTRAINT fk_hol_locw_upby FOREIGN KEY (upd_by)
        REFERENCES employees (id)
);



-- Leave approval hierarchy

CREATE TABLE leave_approval_hierarchy
(
    hierarchy_id           NUMBER,
    com_id                 NUMBER,
    location_id            NUMBER,
    department_id          NUMBER,
    approval_level         NUMBER NOT NULL,
    emp_id                 NUMBER,
    approver_role          VARCHAR2 (50) NOT NULL,
    skip_if_same_person    CHAR (1)
                              DEFAULT 'Y'
                              CHECK (skip_if_same_person IN ('Y', 'N')),
    active_flag            CHAR (1)
                              DEFAULT 'Y'
                              CHECK (active_flag IN ('Y', 'N')),
    CONSTRAINT fk_lah_department FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
);



CREATE TABLE att_devices
(
    id        NUMBER,
    ip        VARCHAR2 (15),
    detail    VARCHAR2 (100 BYTE)
);

ALTER TABLE att_devices
    ADD (CONSTRAINT att_devices_pk PRIMARY KEY (id));


CREATE TABLE t_attendance
(
    attendance_id    NUMBER,
    emp_id           NUMBER NOT NULL,
    att_date         DATE NOT NULL,
    time_in          VARCHAR2 (30),
    time_out         VARCHAR2 (30),
    latein           VARCHAR2 (30),
    earlyout         VARCHAR2 (30),
    status           VARCHAR2 (20)
                        CHECK
                            (status IN ('P',
                                        'A',
                                        'T',
                                        'L',
                                        'S',
                                        'H',
                                        'W')),
    in_loc           NUMBER,
    out_loc          NUMBER,
    remarks          VARCHAR2 (100),
    ent_by           VARCHAR2 (50),
    ent_date         DATE DEFAULT SYSDATE,
    upd_by           VARCHAR2 (50),
    upd_date         DATE,
    CONSTRAINT fk_attendance_employee FOREIGN KEY (emp_id)
        REFERENCES employees (id),
    CONSTRAINT fk_att_device_r FOREIGN KEY (in_loc)
        REFERENCES att_devices (id),
    CONSTRAINT fk_att_device_r FOREIGN KEY (out_loc)
        REFERENCES att_devices (id)
);



CREATE TABLE attendance_details
(
    attendance_id       NUMBER PRIMARY KEY,
    emp_id              NUMBER,
    attendance_date     DATE,
    dayofweek         VARCHAR2 (20),
    regular_in_time     DATE,
    regular_out_time    DATE,
    shift_start_time    DATE,
    shift_end_time      DATE,
    status              VARCHAR2 (20),
    in_time             DATE,
    out_time            DATE,    
    late_in             VARCHAR2 (10),
    early_out           VARCHAR2 (10),
    in_location         VARCHAR2 (50),
    out_location        VARCHAR2 (50),
    duty_hours          NUMBER,
    remarks             VARCHAR2 (255),
    com_id              NUMBER,
    weekend          NUMBER,
    nextday          NUMBER,
    holiday          NUMBER,
    FOREIGN KEY (emp_id) REFERENCES employees (id),
    FOREIGN KEY (com_id) REFERENCES company (id)
);
/










