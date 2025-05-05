/* Formatted on 5/5/2025 5:13:03 PM (QP5 v5.362) */
----# Oracle APEX Attendance & Tour Management System Design
-- Daily attendance tracking

CREATE TABLE attendance
(
    attendance_id      NUMBER,
    emp_id             NUMBER NOT NULL,
    attendance_date    DATE NOT NULL,
    time_in            DATE,
    time_out           DATE,
    status             VARCHAR2 (20)
                          CHECK
                              (status IN ('P',
                                          'A',
                                          'T',
                                          'L',
                                          'H',
                                          'W')),
    remarks            VARCHAR2 (100),
    ent_by             VARCHAR2 (50),
    ent_date           DATE DEFAULT SYSDATE,
    upd_by             VARCHAR2 (50),
    upd_date           DATE,
    CONSTRAINT fk_attendance_employee FOREIGN KEY (emp_id)
        REFERENCES employees (id)
);

-- Leave management

CREATE TABLE leave_types
(
    leave_type_id      NUMBER,
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

CREATE TABLE leave_requests
(
    leave_request_id    NUMBER,
    emp_id              NUMBER NOT NULL,
    leave_type_id       NUMBER NOT NULL,
    start_date          DATE NOT NULL,
    end_date            DATE NOT NULL,
    total_days          NUMBER NOT NULL,
    reason              VARCHAR2 (500),
    status              VARCHAR2 (20)
                           CHECK
                               (status IN ('Pending',
                                           'Approved',
                                           'Rejected',
                                           'Cancelled')),
    approved_by         NUMBER,
    approval_date       DATE,
    ent_date            DATE DEFAULT SYSDATE,
    CONSTRAINT fk_leave_employee FOREIGN KEY (emp_id)
        REFERENCES employees (id),
    CONSTRAINT fk_leave_type FOREIGN KEY (leave_type_id)
        REFERENCES leave_types (leave_type_id),
    CONSTRAINT fk_leave_approver FOREIGN KEY (approved_by)
        REFERENCES employees (id)
);

-- Employee leave balance tracking

CREATE TABLE leave_balances
(
    leave_balance_id     NUMBER,
    emp_id               NUMBER NOT NULL,
    leave_type_id        NUMBER NOT NULL,
    year                 NUMBER NOT NULL,
    total_quota          NUMBER NOT NULL,
    used_days            NUMBER DEFAULT 0,
    remaining_days       NUMBER,
    last_updated_date    DATE,
    CONSTRAINT fk_balance_employee FOREIGN KEY (emp_id)
        REFERENCES employees (id),
    CONSTRAINT fk_balance_leave_type FOREIGN KEY (leave_type_id)
        REFERENCES leave_types (leave_type_id),
    CONSTRAINT uq_employee_leave_year UNIQUE (id, leave_type_id, year)
);

-- Holidays and company-wide off days

CREATE TABLE holidays
(
    holiday_id        NUMBER,
    holiday_date      DATE NOT NULL,
    holiday_name      VARCHAR2 (100) NOT NULL,
    description       VARCHAR2 (200),
    recurring_flag    CHAR (1)
                         DEFAULT 'N'
                         CHECK (recurring_flag IN ('Y', 'N')),
    ent_by            VARCHAR2 (50),
    ent_date          DATE DEFAULT SYSDATE
);


-- ##### Tour Management Module

-- Business tours/trips

CREATE TABLE tours
(
    tour_id        NUMBER,
    tour_name      VARCHAR2 (100) NOT NULL,
    description    VARCHAR2 (500),
    purpose        VARCHAR2 (200) NOT NULL,
    start_date     DATE NOT NULL,
    end_date       DATE NOT NULL,
    status         VARCHAR2 (20)
                      CHECK
                          (status IN ('Planned',
                                      'In Progress',
                                      'Completed',
                                      'Cancelled')),
    ent_by         NUMBER,
    ent_date       DATE DEFAULT SYSDATE,
    upd_by         NUMBER,
    upd_date       DATE,
    CONSTRAINT fk_tour_creator FOREIGN KEY (ent_by) REFERENCES employees (id),
    CONSTRAINT fk_tour_updater FOREIGN KEY (upd_by) REFERENCES employees (id)
);

-- Tour participants

CREATE TABLE tour_participants
(
    participant_id    NUMBER,
    tour_id           NUMBER NOT NULL,
    id                NUMBER NOT NULL,
    role              VARCHAR2 (50),
    join_date         DATE,
    leave_date        DATE,
    status            VARCHAR2 (20)
                         CHECK
                             (status IN ('Confirmed', 'Pending', 'Cancelled')),
    notes             VARCHAR2 (500),
    CONSTRAINT fk_participant_tour FOREIGN KEY (tour_id)
        REFERENCES tours (tour_id),
    CONSTRAINT fk_participant_employee FOREIGN KEY (id)
        REFERENCES employees (id),
    CONSTRAINT uq_tour_employee UNIQUE (tour_id, id)
);

-- Tour locations/itinerary

CREATE TABLE tour_locations
(
    location_id      NUMBER,
    tour_id          NUMBER NOT NULL,
    location_name    VARCHAR2 (100) NOT NULL,
    address          VARCHAR2 (200),
    city             VARCHAR2 (50),
    state            VARCHAR2 (50),
    country          VARCHAR2 (50),
    visit_date       DATE,
    visit_time       VARCHAR2 (20),
    duration         VARCHAR2 (50),
    purpose          VARCHAR2 (200),
    CONSTRAINT fk_location_tour FOREIGN KEY (tour_id)
        REFERENCES tours (tour_id)
);

-- Tour expenses

CREATE TABLE tour_expenses
(
    expense_id           NUMBER,
    tour_id              NUMBER NOT NULL,
    emp_id               NUMBER NOT NULL,
    expense_type         VARCHAR2 (50) NOT NULL,
    amount               NUMBER (10, 2) NOT NULL,
    expense_date         DATE NOT NULL,
    description          VARCHAR2 (200),
    receipt_reference    VARCHAR2 (200),
    status               VARCHAR2 (20)
                            CHECK
                                (status IN ('Submitted',
                                            'Approved',
                                            'Rejected',
                                            'Reimbursed')),
    approved_by          NUMBER,
    approval_date        DATE,
    CONSTRAINT fk_expense_tour FOREIGN KEY (tour_id)
        REFERENCES tours (tour_id),
    CONSTRAINT fk_expense_employee FOREIGN KEY (emp_id)
        REFERENCES employees (id),
    CONSTRAINT fk_expense_approver FOREIGN KEY (approved_by)
        REFERENCES employees (id)
);



-- Attendance rules

CREATE TABLE attendance_rules
(
    rule_id                 NUMBER,
    rule_name               VARCHAR2 (100) NOT NULL,
    department_id           NUMBER,
    work_start_time         VARCHAR2 (5),
    work_end_time           VARCHAR2 (5),
    grace_period_minutes    NUMBER DEFAULT 0,
    half_day_hours          NUMBER (5, 2),
    is_default              CHAR (1)
                               DEFAULT 'N'
                               CHECK (is_default IN ('Y', 'N')),
    active_flag             CHAR (1)
                               DEFAULT 'Y'
                               CHECK (active_flag IN ('Y', 'N')),
    CONSTRAINT fk_rule_department FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
);

-- Employee-specific attendance rules (overrides department rules)

CREATE TABLE employee_attendance_rules
(
    mapping_id    NUMBER,
    emp_id        NUMBER NOT NULL,
    rule_id       NUMBER NOT NULL,
    start_date    DATE NOT NULL,
    end_date      DATE,
    ent_by        VARCHAR2 (50),
    ent_date      DATE DEFAULT SYSDATE,
    CONSTRAINT fk_er_employee FOREIGN KEY (emp_id) REFERENCES employees (id),
    CONSTRAINT fk_er_rule FOREIGN KEY (rule_id)
        REFERENCES attendance_rules (rule_id)
);


-- Exception requests for attendance

CREATE TABLE attendance_exceptions
(
    exception_id      NUMBER,
    emp_id            NUMBER NOT NULL,
    exception_date    DATE NOT NULL,
    exception_type    VARCHAR2 (20)
                         CHECK
                             (exception_type IN ('Late Arrival',
                                                 'Early Departure',
                                                 'Work From Home',
                                                 'Custom')),
    reason            VARCHAR2 (500) NOT NULL,
    status            VARCHAR2 (20)
                         CHECK
                             (status IN ('Pending', 'Approved', 'Rejected')),
    approved_by       NUMBER,
    approval_date     DATE,
    ent_date          DATE DEFAULT SYSDATE,
    CONSTRAINT fk_exception_employee FOREIGN KEY (emp_id)
        REFERENCES employees (id),
    CONSTRAINT fk_exception_approver FOREIGN KEY (approved_by)
        REFERENCES employees (id)
);



----# Oracle APEX Leave Management Module Design



----### Core Leave Tables

-- Leave types configuration

CREATE TABLE leave_types
(
    leave_type_id             NUMBER,
    leave_type_name           VARCHAR2 (50) NOT NULL,
    description               VARCHAR2 (200),
    annual_quota              NUMBER,
    is_paid                   CHAR (1) CHECK (is_paid IN ('Y', 'N')),
    accrual_type              VARCHAR2 (20)
                                 CHECK
                                     (accrual_type IN ('Annual',
                                                       'Monthly',
                                                       'Quarterly',
                                                       'None')),
    carry_forward_limit       NUMBER DEFAULT 0,
    min_service_months        NUMBER DEFAULT 0,
    gender_specific           VARCHAR2 (10)
                                 CHECK
                                     (gender_specific IN
                                          ('Male', 'Female', 'All')),
    documentation_required    CHAR (1)
                                 DEFAULT 'N'
                                 CHECK (documentation_required IN ('Y', 'N')),
    min_advance_days          NUMBER DEFAULT 0,
    max_consecutive_days      NUMBER,
    active_flag               CHAR (1)
                                 DEFAULT 'Y'
                                 CHECK (active_flag IN ('Y', 'N')),
    ent_by                    NUMBER,
    ent_date                  DATE DEFAULT SYSDATE,
    upd_by                    NUMBER,
    upd_date                  DATE,
    CONSTRAINT fk_lt_creator FOREIGN KEY (ent_by) REFERENCES employees (id),
    CONSTRAINT fk_lt_updater FOREIGN KEY (upd_by) REFERENCES employees (id)
);

-- Leave requests from employees

CREATE TABLE leave_requests
(
    leave_request_id        NUMBER,
    emp_id                  NUMBER NOT NULL,
    leave_type_id           NUMBER NOT NULL,
    start_date              DATE NOT NULL,
    end_date                DATE NOT NULL,
    half_day_flag           CHAR (1)
                               DEFAULT 'N'
                               CHECK (half_day_flag IN ('Y', 'N')),
    half_day_am_pm          VARCHAR2 (2)
                               CHECK (half_day_am_pm IN ('AM', 'PM', NULL)),
    total_days              NUMBER (5, 1) NOT NULL,
    reason                  VARCHAR2 (500),
    contact_during_leave    VARCHAR2 (100),
    handover_to             NUMBER,
    handover_notes          VARCHAR2 (500),
    document_reference      VARCHAR2 (200),
    status                  VARCHAR2 (20)
                               CHECK
                                   (status IN ('Draft',
                                               'Pending',
                                               'Approved',
                                               'Rejected',
                                               'Cancelled')),
    recommended_by          NUMBER,
    recommendation_date     DATE,
    recommendation_notes    VARCHAR2 (200),
    approved_by             NUMBER,
    approval_date           DATE,
    rejection_reason        VARCHAR2 (200),
    ent_date                DATE DEFAULT SYSDATE,
    upd_date                DATE,
    CONSTRAINT fk_lr_employee FOREIGN KEY (emp_id) REFERENCES employees (id),
    CONSTRAINT fk_lr_type FOREIGN KEY (leave_type_id)
        REFERENCES leave_types (leave_type_id),
    CONSTRAINT fk_lr_handover FOREIGN KEY (handover_to)
        REFERENCES employees (id),
    CONSTRAINT fk_lr_recommender FOREIGN KEY (recommended_by)
        REFERENCES employees (id),
    CONSTRAINT fk_lr_approver FOREIGN KEY (approved_by)
        REFERENCES employees (id)
);

-- Employee leave balance tracking

CREATE TABLE leave_balances
(
    leave_balance_id     NUMBER,
    emp_id               NUMBER NOT NULL,
    leave_type_id        NUMBER NOT NULL,
    year                 NUMBER NOT NULL,
    opening_balance      NUMBER (5, 1) DEFAULT 0,
    accrued              NUMBER (5, 1) DEFAULT 0,
    used                 NUMBER (5, 1) DEFAULT 0,
    pending              NUMBER (5, 1) DEFAULT 0,
    adjusted             NUMBER (5, 1) DEFAULT 0,
    carried_forward      NUMBER (5, 1) DEFAULT 0,
    current_balance      NUMBER (5, 1),
    last_updated_date    DATE,
    upd_by               NUMBER,
    CONSTRAINT fk_lb_employee FOREIGN KEY (emp_id) REFERENCES employees (id),
    CONSTRAINT fk_lb_leave_type FOREIGN KEY (leave_type_id)
        REFERENCES leave_types (leave_type_id),
    CONSTRAINT fk_lb_updater FOREIGN KEY (upd_by) REFERENCES employees (id),
    CONSTRAINT uq_employee_leave_year UNIQUE (emp_id, leave_type_id, year)
);

-- Manual adjustments to leave balances

CREATE TABLE leave_adjustments
(
    adjustment_id      NUMBER,
    emp_id             NUMBER NOT NULL,
    leave_type_id      NUMBER NOT NULL,
    adjustment_date    DATE DEFAULT SYSDATE,
    adjustment_days    NUMBER (5, 1) NOT NULL,
    year               NUMBER NOT NULL,
    reason             VARCHAR2 (200) NOT NULL,
    approved_by        NUMBER NOT NULL,
    approval_date      DATE,
    ent_by             NUMBER NOT NULL,
    ent_date           DATE DEFAULT SYSDATE,
    CONSTRAINT fk_la_employee FOREIGN KEY (emp_id) REFERENCES employees (id),
    CONSTRAINT fk_la_leave_type FOREIGN KEY (leave_type_id)
        REFERENCES leave_types (leave_type_id),
    CONSTRAINT fk_la_approver FOREIGN KEY (approved_by)
        REFERENCES employees (id),
    CONSTRAINT fk_la_creator FOREIGN KEY (ent_by) REFERENCES employees (id)
);

-- Leave accrual schedule and rules

CREATE TABLE leave_accrual_rules
(
    rule_id                NUMBER,
    leave_type_id          NUMBER NOT NULL,
    employee_category      VARCHAR2 (50),
    service_years_from     NUMBER DEFAULT 0,
    service_years_to       NUMBER,
    annual_accrual_days    NUMBER (5, 1) NOT NULL,
    accrual_frequency      VARCHAR2 (20)
                              CHECK
                                  (accrual_frequency IN ('Monthly',
                                                         'Quarterly',
                                                         'Biannual',
                                                         'Annual')),
    prorated_flag          CHAR (1)
                              DEFAULT 'Y'
                              CHECK (prorated_flag IN ('Y', 'N')),
    active_flag            CHAR (1)
                              DEFAULT 'Y'
                              CHECK (active_flag IN ('Y', 'N')),
    CONSTRAINT fk_lar_leave_type FOREIGN KEY (leave_type_id)
        REFERENCES leave_types (leave_type_id)
);

-- Holiday calendar

CREATE TABLE holidays
(
    holiday_id        NUMBER,
    holiday_date      DATE NOT NULL,
    holiday_name      VARCHAR2 (100) NOT NULL,
    description       VARCHAR2 (200),
    recurring_flag    CHAR (1)
                         DEFAULT 'N'
                         CHECK (recurring_flag IN ('Y', 'N')),
    ent_by            NUMBER,
    ent_date          DATE DEFAULT SYSDATE,
    CONSTRAINT fk_h_creator FOREIGN KEY (ent_by) REFERENCES employees (id)
);

-- Leave approval hierarchy

CREATE TABLE leave_approval_hierarchy
(
    hierarchy_id           NUMBER,
    department_id          NUMBER,
    employee_category      VARCHAR2 (50),
    approval_level         NUMBER NOT NULL,
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

-- Leave cancellation and amendments

CREATE TABLE leave_amendments
(
    amendment_id           NUMBER,
    leave_request_id       NUMBER NOT NULL,
    amendment_type         VARCHAR2 (20)
                              CHECK
                                  (amendment_type IN
                                       ('Cancellation',
                                        'Date Change',
                                        'Early Return')),
    original_start_date    DATE,
    original_end_date      DATE,
    new_start_date         DATE,
    new_end_date           DATE,
    reason                 VARCHAR2 (200) NOT NULL,
    status                 VARCHAR2 (20)
                              CHECK
                                  (status IN
                                       ('Pending', 'Approved', 'Rejected')),
    approved_by            NUMBER,
    approval_date          DATE,
    ent_date               DATE DEFAULT SYSDATE,
    CONSTRAINT fk_amendment_request FOREIGN KEY (leave_request_id)
        REFERENCES leave_requests (leave_request_id),
    CONSTRAINT fk_amendment_approver FOREIGN KEY (approved_by)
        REFERENCES employees (id)
);


---### Complementary Tables

----
-- Department-specific leave policies

CREATE TABLE department_leave_policies
(
    policy_id                     NUMBER,
    department_id                 NUMBER NOT NULL,
    leave_type_id                 NUMBER NOT NULL,
    min_staff_presence_percent    NUMBER (5, 2),
    max_consecutive_applicants    NUMBER,
    special_instructions          VARCHAR2 (500),
    active_flag                   CHAR (1)
                                     DEFAULT 'Y'
                                     CHECK (active_flag IN ('Y', 'N')),
    CONSTRAINT fk_dlp_department FOREIGN KEY (department_id)
        REFERENCES departments (department_id),
    CONSTRAINT fk_dlp_leave_type FOREIGN KEY (leave_type_id)
        REFERENCES leave_types (leave_type_id),
    CONSTRAINT uq_dept_leave_type UNIQUE (department_id, leave_type_id)
);

-- Leave documents (if document management is required)

CREATE TABLE leave_documents
(
    document_id         NUMBER,
    leave_request_id    NUMBER NOT NULL,
    document_type       VARCHAR2 (50) NOT NULL,
    document_name       VARCHAR2 (100) NOT NULL,
    document_path       VARCHAR2 (500) NOT NULL,
    upload_date         DATE DEFAULT SYSDATE,
    uploaded_by         NUMBER NOT NULL,
    CONSTRAINT fk_ld_request FOREIGN KEY (leave_request_id)
        REFERENCES leave_requests (leave_request_id),
    CONSTRAINT fk_ld_uploader FOREIGN KEY (uploaded_by)
        REFERENCES employees (id)
);

-- Compensatory off tracking

CREATE TABLE compensatory_offs
(
    comp_off_id      NUMBER,
    emp_id           NUMBER NOT NULL,
    worked_date      DATE NOT NULL,
    reason           VARCHAR2 (200) NOT NULL,
    hours_worked     NUMBER (5, 1) NOT NULL,
    days_credited    NUMBER (3, 1) NOT NULL,
    expiry_date      DATE,
    status           VARCHAR2 (20)
                        CHECK
                            (status IN ('Pending',
                                        'Approved',
                                        'Rejected',
                                        'Expired',
                                        'Used')),
    approved_by      NUMBER,
    approval_date    DATE,
    ent_date         DATE DEFAULT SYSDATE,
    CONSTRAINT fk_co_employee FOREIGN KEY (emp_id) REFERENCES employees (id),
    CONSTRAINT fk_co_approver FOREIGN KEY (approved_by)
        REFERENCES employees (id)
);

-- Leave audit log for tracking changes

CREATE TABLE leave_audit_log
(
    log_id          NUMBER,
    entity_type     VARCHAR2 (50) NOT NULL,
    entity_id       NUMBER NOT NULL,
    action_type     VARCHAR2 (20) NOT NULL,
    action_date     DATE DEFAULT SYSDATE,
    performed_by    NUMBER NOT NULL,
    old_values      CLOB,
    new_values      CLOB,
    ip_address      VARCHAR2 (50),
    CONSTRAINT fk_lal_performer FOREIGN KEY (performed_by)
        REFERENCES employees (id)
);