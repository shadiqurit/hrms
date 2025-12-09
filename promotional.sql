
-- Critical Indexes for Performance

CREATE UNIQUE INDEX UK_POST_ACTIVE_EMP
    ON EMPLOYEE_POSTING_HISTORY (EMPLOYEE_ID, IS_ACTIVE_FLAG) WHERE IS_ACTIVE_FLAG = 'Y';                                -- Only one active posting per employee

CREATE INDEX IDX_POST_EMP_DATE
    ON EMPLOYEE_POSTING_HISTORY (EMPLOYEE_ID, EFFECTIVE_DATE DESC);

CREATE INDEX IDX_POST_DEPT
    ON EMPLOYEE_POSTING_HISTORY (DEPARTMENT_ID, IS_ACTIVE_FLAG);

CREATE INDEX IDX_POST_LOCATION
    ON EMPLOYEE_POSTING_HISTORY (LOCATION_ID, IS_ACTIVE_FLAG);

COMMENT ON TABLE EMPLOYEE_POSTING_HISTORY IS
    'Complete posting and transfer history. IS_ACTIVE_FLAG=Y indicates current posting. All movements (lateral, promotion-based, project) are tracked here.';

-- =====================================================
-- SECTION 4: PROMOTION HISTORY
-- =====================================================

CREATE TABLE EMPLOYEE_PROMOTION_HISTORY
(
    PROMOTION_HISTORY_ID       NUMBER (15) NOT NULL,
    EMPLOYEE_ID                NUMBER (10) NOT NULL,
    -- Previous State
    PREVIOUS_DESIGNATION_ID    NUMBER (10) NOT NULL,
    PREVIOUS_JOB_LEVEL         NUMBER (2),
    PREVIOUS_GRADE_CODE        VARCHAR2 (10),
    -- New State
    NEW_DESIGNATION_ID         NUMBER (10) NOT NULL,
    NEW_JOB_LEVEL              NUMBER (2),
    NEW_GRADE_CODE             VARCHAR2 (10),
    -- Promotion Details
    PROMOTION_TYPE             VARCHAR2 (30), -- MERIT, FAST_TRACK, REGULAR, EXCEPTIONAL
    PROMOTION_REASON_CODE      VARCHAR2 (30),
    LEVEL_JUMP                 NUMBER (2), -- Calculate: NEW_JOB_LEVEL - PREVIOUS_JOB_LEVEL
    -- Effective Dating
    EFFECTIVE_DATE             DATE NOT NULL,
    TRANSACTION_DATE           DATE DEFAULT SYSDATE NOT NULL,
    IS_ACTIVE_FLAG             CHAR (1) DEFAULT 'Y' NOT NULL,
    -- Approvals
    APPROVED_BY                VARCHAR2 (50),
    APPROVAL_DATE              DATE,
    COMMENTS                   VARCHAR2 (500),
    -- Audit Trail
    CREATED_BY                 VARCHAR2 (50) NOT NULL,
    CREATED_DATE               DATE DEFAULT SYSDATE NOT NULL,
    CLOSED_BY                  VARCHAR2 (50),
    CLOSED_DATE                DATE,
    CONSTRAINT PK_PROMOTION_HISTORY PRIMARY KEY (PROMOTION_HISTORY_ID),
    CONSTRAINT CHK_PROM_ACTIVE CHECK (IS_ACTIVE_FLAG IN ('Y', 'N')),
    CONSTRAINT CHK_PROM_TYPE CHECK
        (PROMOTION_TYPE IN ('MERIT',
                            'FAST_TRACK',
                            'REGULAR',
                            'EXCEPTIONAL',
                            'PROGRESSION')),
    CONSTRAINT FK_PROM_EMP FOREIGN KEY (EMPLOYEE_ID)
        REFERENCES EMPLOYEES (EMPLOYEE_ID),
    CONSTRAINT FK_PROM_OLD_DESIG FOREIGN KEY (PREVIOUS_DESIGNATION_ID)
        REFERENCES DESIGNATIONS (DESIGNATION_ID),
    CONSTRAINT FK_PROM_NEW_DESIG FOREIGN KEY (NEW_DESIGNATION_ID)
        REFERENCES DESIGNATIONS (DESIGNATION_ID),
    CONSTRAINT FK_PROM_REASON FOREIGN KEY (PROMOTION_REASON_CODE)
        REFERENCES CHANGE_REASON_CODES (REASON_CODE)
);

-- Critical Indexes

CREATE UNIQUE INDEX UK_PROM_ACTIVE_EMP
    ON EMPLOYEE_PROMOTION_HISTORY (EMPLOYEE_ID, IS_ACTIVE_FLAG) WHERE IS_ACTIVE_FLAG = 'Y';

CREATE INDEX IDX_PROM_EMP_DATE
    ON EMPLOYEE_PROMOTION_HISTORY (EMPLOYEE_ID, EFFECTIVE_DATE DESC);

CREATE INDEX IDX_PROM_EFF_DATE
    ON EMPLOYEE_PROMOTION_HISTORY (EFFECTIVE_DATE);

COMMENT ON TABLE EMPLOYEE_PROMOTION_HISTORY IS
    'Dedicated promotion tracking with before/after designation and grade. Captures level jumps and promotion velocity for analytics.';

-- =====================================================
-- SECTION 5: SALARY HISTORY
-- =====================================================

CREATE TABLE EMPLOYEE_SALARY_HISTORY
(
    SALARY_HISTORY_ID         NUMBER (15) NOT NULL,
    EMPLOYEE_ID               NUMBER (10) NOT NULL,
    -- Previous Salary
    PREVIOUS_SALARY           NUMBER (15, 2),
    PREVIOUS_CURRENCY_CODE    CHAR (3),
    -- New Salary
    NEW_SALARY                NUMBER (15, 2) NOT NULL,
    NEW_CURRENCY_CODE         CHAR (3) DEFAULT 'USD' NOT NULL,
    -- Calculated Fields
    INCREMENT_AMOUNT          NUMBER (15, 2),
    INCREMENT_PERCENTAGE      NUMBER (5, 2),
    -- Change Details
    CHANGE_REASON_CODE        VARCHAR2 (30) NOT NULL,
    CHANGE_TYPE               VARCHAR2 (30) NOT NULL, -- ANNUAL, PROMOTION, MARKET_ADJ, CORRECTION, BONUS
    SALARY_COMPONENT_TYPE     VARCHAR2 (20) DEFAULT 'BASE', -- BASE, ALLOWANCE, BONUS
    -- Effective Dating
    EFFECTIVE_DATE            DATE NOT NULL,
    TRANSACTION_DATE          DATE DEFAULT SYSDATE NOT NULL,
    IS_ACTIVE_FLAG            CHAR (1) DEFAULT 'Y' NOT NULL,
    -- Approvals
    APPROVED_BY               VARCHAR2 (50),
    APPROVAL_DATE             DATE,
    COMMENTS                  VARCHAR2 (500),
    -- Audit Trail
    CREATED_BY                VARCHAR2 (50) NOT NULL,
    CREATED_DATE              DATE DEFAULT SYSDATE NOT NULL,
    CLOSED_BY                 VARCHAR2 (50),
    CLOSED_DATE               DATE,
    CONSTRAINT PK_SALARY_HISTORY PRIMARY KEY (SALARY_HISTORY_ID),
    CONSTRAINT CHK_SAL_ACTIVE CHECK (IS_ACTIVE_FLAG IN ('Y', 'N')),
    CONSTRAINT CHK_SAL_CHANGE_TYPE CHECK
        (CHANGE_TYPE IN ('ANNUAL',
                         'PROMOTION',
                         'MARKET_ADJ',
                         'CORRECTION',
                         'BONUS',
                         'RETENTION',
                         'MERIT')),
    CONSTRAINT CHK_SAL_COMPONENT CHECK
        (SALARY_COMPONENT_TYPE IN ('BASE',
                                   'ALLOWANCE',
                                   'BONUS',
                                   'INCENTIVE')),
    CONSTRAINT CHK_SAL_POSITIVE CHECK (NEW_SALARY > 0),
    CONSTRAINT FK_SAL_EMP FOREIGN KEY (EMPLOYEE_ID)
        REFERENCES EMPLOYEES (EMPLOYEE_ID),
    CONSTRAINT FK_SAL_REASON FOREIGN KEY (CHANGE_REASON_CODE)
        REFERENCES CHANGE_REASON_CODES (REASON_CODE)
);

-- Critical Indexes

CREATE UNIQUE INDEX UK_SAL_ACTIVE_EMP
    ON EMPLOYEE_SALARY_HISTORY
    (
        EMPLOYEE_ID,
        IS_ACTIVE_FLAG,
        SALARY_COMPONENT_TYPE)                                                                                       WHERE      IS_ACTIVE_FLAG               =  'Y';                                                                                                                                                 -- One active base salary per employee

CREATE INDEX IDX_SAL_EMP_DATE
    ON EMPLOYEE_SALARY_HISTORY (EMPLOYEE_ID, EFFECTIVE_DATE DESC);

CREATE INDEX IDX_SAL_EFF_DATE
    ON EMPLOYEE_SALARY_HISTORY (EFFECTIVE_DATE);

CREATE INDEX IDX_SAL_CHANGE_TYPE
    ON EMPLOYEE_SALARY_HISTORY (CHANGE_TYPE, EFFECTIVE_DATE);

COMMENT ON TABLE EMPLOYEE_SALARY_HISTORY IS
    'Complete salary change history with automatic calculation of increment amount and percentage. Supports multiple salary components.';

-- =====================================================
-- SECTION 6: SEQUENCES FOR PRIMARY KEYS
-- =====================================================

CREATE SEQUENCE SEQ_EMPLOYEE_ID START WITH 10001 INCREMENT BY 1 CACHE 100;

CREATE SEQUENCE SEQ_BUSINESS_UNIT_ID START WITH 1 INCREMENT BY 1 CACHE 20;

CREATE SEQUENCE SEQ_DEPARTMENT_ID START WITH 1 INCREMENT BY 1 CACHE 50;

CREATE SEQUENCE SEQ_LOCATION_ID START WITH 1 INCREMENT BY 1 CACHE 50;

CREATE SEQUENCE SEQ_DESIGNATION_ID START WITH 1 INCREMENT BY 1 CACHE 50;

CREATE SEQUENCE SEQ_POSTING_HISTORY_ID START WITH 1 INCREMENT BY 1 CACHE 100;

CREATE SEQUENCE SEQ_PROMOTION_HISTORY_ID START WITH 1
                                         INCREMENT BY 1
                                         CACHE 100;

CREATE SEQUENCE SEQ_SALARY_HISTORY_ID START WITH 1 INCREMENT BY 1 CACHE 100;