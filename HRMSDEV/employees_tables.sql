/* Formatted on 07/Jul/24 4:05:23 PM (QP5 v5.362) */
CREATE TABLE employees
(
    id                NUMBER,
    emp_id            VARCHAR2 (30),
    f_name            VARCHAR2 (30),
    l_name            VARCHAR2 (30),
    dob               DATE,
    mobile            VARCHAR2 (30),
    email             VARCHAR2 (30),
    father            VARCHAR2 (50),
    mother            VARCHAR2 (50),
    gender            VARCHAR2 (10),
    height            VARCHAR2 (10),
    weight            VARCHAR2 (10),
    blood             VARCHAR2 (10),
    nid               VARCHAR2 (30),
    address           VARCHAR2 (30),
    c_post            NUMBER,
    c_thana           NUMBER,
    c_district        NUMBER,
    c_division        NUMBER,
    p_address         VARCHAR2 (30),
    p_POST            NUMBER,
    p_thana           NUMBER,
    p_district        NUMBER,
    p_division        NUMBER,
    photo             BLOB,
    join_date         DATE,
    marital_status    VARCHAR2 (10),
    emp_type          VARCHAR2 (30),
    dept_id           NUMBER,
    loc_id            NUMBER,
    branch_id         NUMBER,
    desig_id          NUMBER,
    com_id            NUMBER,
    job_id            NUMBER,
    user_grp          NUMBER (3) DEFAULT 0,
    passw             VARCHAR2 (32),
    status VARCHAR2 (10),
    ent_by            NUMBER,
    ent_date          DATE,
    upd_by            NUMBER,
    upd_date          DATE,
    CONSTRAINT pk_employess PRIMARY KEY (id),
    CONSTRAINT employess_u01 UNIQUE (emp_id),
    CONSTRAINT employess_u02 UNIQUE (email),
    CONSTRAINT employess_u03 UNIQUE (nid)
);
/
SET DEFINE OFF;
Insert into EMPLOYEES
   (ID, EMP_ID, F_NAME, L_NAME, DOB, 
    MOBILE, EMAIL, FATHER, MOTHER, GENDER, 
    HEIGHT, WEIGHT, BLOOD, NID, ADDRESS, 
    C_POST, C_THANA, C_DISTRICT, C_DIVISION, P_ADDRESS, 
    P_POST, P_THANA, P_DISTRICT, P_DIVISION, JOIN_DATE, 
    MARITAL_STATUS, EMP_TYPE, DEPT_ID, LOC_ID, BRANCH_ID, 
    DESIG_ID, COM_ID, JOB_ID, USER_GRP, PASSW, 
    ENT_BY, ENT_DATE, UPD_BY, UPD_DATE, STATUS)
 Values
   (1, 'IPI-009129', 'Shadiqur', 'Rahman', NULL, 
    NULL, NULL, NULL, NULL, NULL, 
    NULL, NULL, NULL, NULL, NULL, 
    NULL, NULL, NULL, NULL, NULL, 
    NULL, NULL, NULL, NULL, NULL, 
    NULL, NULL, NULL, NULL, NULL, 
    NULL, NULL, NULL, 1, '123', 
    NULL, NULL, NULL, NULL, 'A');
COMMIT;


CREATE TABLE emp_education
(
    id              NUMBER,
    emp_id          NUMBER,
    exam            VARCHAR2 (100),
    passing_year    NUMBER (4),
    board           VARCHAR2 (100),
    cgpa            NUMBER (5, 2),
    remarks         VARCHAR2 (100),
    ent_by          NUMBER,
    ent_date        DATE,
    upd_by          NUMBER,
    upd_date        DATE,
    CONSTRAINT pk_emp_education PRIMARY KEY (id),
    CONSTRAINT fk_emp_education FOREIGN KEY (emp_id)
        REFERENCES employees (id)
);
/

CREATE TABLE emp_experience
(
    id              NUMBER,
    emp_id          NUMBER,
    company_name    VARCHAR2 (100),
    job_title       VARCHAR2 (100),
    job_des         VARCHAR2 (100),
    start_date      DATE,
    end_date        DATE,
    duration        VARCHAR2 (100),
    remarks         VARCHAR2 (100),
    ent_by          NUMBER,
    ent_date        DATE,
    upd_by          NUMBER,
    upd_date        DATE,
    CONSTRAINT pk_emp_id_experience PRIMARY KEY (id),
    CONSTRAINT fk_emp_id_experience FOREIGN KEY (emp_id)
        REFERENCES employees (id)
);
/

CREATE TABLE emp_training
(
    id                 NUMBER,
    emp_id             NUMBER,
    training_name      VARCHAR2 (100),
    institution        VARCHAR2 (100),
    start_date         DATE,
    completion_date    DATE,
    duration           VARCHAR2 (100),
    remarks            VARCHAR2 (100),
    ent_by             NUMBER,
    ent_date           DATE,
    upd_by             NUMBER,
    upd_date           DATE,
    CONSTRAINT pk_emp_training PRIMARY KEY (id),
    CONSTRAINT fk_emp_id_training FOREIGN KEY (emp_id)
        REFERENCES employees (id)
);
/

CREATE TABLE emp_family_dtl
(
    id          NUMBER,
    emp_id      NUMBER,
    relation    VARCHAR2 (100),
    name        VARCHAR2 (100),
    age         NUMBER,
    remarks     VARCHAR2 (100),
    ent_by      NUMBER,
    ent_date    DATE,
    upd_by      NUMBER,
    upd_date    DATE,
    CONSTRAINT pk_emp_family_dtl PRIMARY KEY (id),
    CONSTRAINT fk_emp_id_family_dtl FOREIGN KEY (emp_id)
        REFERENCES employees (id)
);
/

CREATE TABLE emp_guarantors
(
    id                 NUMBER,
    emp_id             NUMBER,
    name               VARCHAR2 (100),
    relationship       VARCHAR2 (100),
    contact_details    VARCHAR2 (255),
    address            VARCHAR2 (100),
    p_post             NUMBER,
    p_thana            NUMBER,
    p_district         NUMBER,
    p_division         NUMBER,
    remarks            VARCHAR2 (100),
    ent_by             NUMBER,
    ent_date           DATE,
    upd_by             NUMBER,
    upd_date           DATE,
    CONSTRAINT pk_emp_id_guarantors PRIMARY KEY (id),
    CONSTRAINT fk_emp_id_guarantors FOREIGN KEY (emp_id)
        REFERENCES employees (id)
);
/

CREATE TABLE emp_nominee
(
    id                 NUMBER,
    emp_id             NUMBER,
    nominee_name       VARCHAR2 (100),
    relationship       VARCHAR2 (100),
    contact_details    VARCHAR2 (255),
    address            VARCHAR2 (100),
    p_post             NUMBER,
    p_thana            NUMBER,
    p_district         NUMBER,
    p_division         NUMBER,
    remarks            VARCHAR2 (100),
    ent_by             NUMBER,
    ent_date           DATE,
    upd_by             NUMBER,
    upd_date           DATE,
    CONSTRAINT pk_emp_nominee PRIMARY KEY (id),
    CONSTRAINT fk_emp_id_nominee FOREIGN KEY (emp_id)
        REFERENCES employees (id)
);

CREATE OR REPLACE FUNCTION fn_custom_login (p_username   IN VARCHAR2,
                                            p_password   IN VARCHAR2)
    RETURN BOOLEAN
IS
    v_password          VARCHAR2 (4000);
    v_stored_password   VARCHAR2 (4000);
    v_count             NUMBER;
BEGIN
    SELECT COUNT (*)
      INTO v_count
      FROM employees
     WHERE UPPER (emp_id) = UPPER (p_username);

    IF v_count != 0
    THEN
        SELECT passw
          INTO v_stored_password
          FROM employees
         WHERE UPPER (emp_id) = UPPER (p_username);

        v_password := p_password;

        IF v_password = v_stored_password
        THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END IF;
END fn_custom_login;
/