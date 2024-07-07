/* Formatted on 07/Jul/24 12:05:41 PM (QP5 v5.362) */
CREATE TABLE company
(
    id          NUMBER,
    code        VARCHAR2 (5),
    name        VARCHAR2 (50),
    address     VARCHAR2 (100),
    reg_no      VARCHAR2 (30),
    bin         VARCHAR2 (30),
    phone       VARCHAR2 (30),
    email       VARCHAR2 (30),
    ent_by      NUMBER,
    ent_date    DATE,
    upd_by      NUMBER,
    upd_date    DATE,
    CONSTRAINT company_pk PRIMARY KEY (id),
    CONSTRAINT company_u01 UNIQUE (code),
    CONSTRAINT company_u02 UNIQUE (bin)
);
/

--Factory , Head Office

CREATE TABLE locations
(
    id          NUMBER,
    name        VARCHAR2 (50),
    address     VARCHAR2 (100),
    phone       VARCHAR2 (30),
    email       VARCHAR2 (30),
    com_id      NUMBER,
    ent_by      NUMBER,
    ent_date    DATE,
    upd_by      NUMBER,
    upd_date    DATE,
    CONSTRAINT locations_pk PRIMARY KEY (id)
);
/

--Pharma, Natuarl,Cephalosporin, General

CREATE TABLE units
(
    id          NUMBER,
    name        VARCHAR2 (50),
    address     VARCHAR2 (100),
    phone       VARCHAR2 (30),
    email       VARCHAR2 (30),
    com_id      NUMBER,
    ent_by      NUMBER,
    ent_date    DATE,
    upd_by      NUMBER,
    upd_date    DATE,
    CONSTRAINT units_pk PRIMARY KEY (id)
);
/

CREATE TABLE branch_depo
(
    id                NUMBER,
    code              VARCHAR2 (5),
    name              VARCHAR2 (50),
    address           VARCHAR2 (100),
    contact_person    NUMBER,                                    --Employee id
    phone             VARCHAR2 (30),
    email             VARCHAR2 (30),
    ent_by            NUMBER,
    ent_date          DATE,
    upd_by            NUMBER,
    upd_date          DATE,
    CONSTRAINT br_depots_pk PRIMARY KEY (id),
    CONSTRAINT br_depots_u01 UNIQUE (code)
);
/

CREATE TABLE designations
(
    id             NUMBER,
    refno          VARCHAR2 (30 BYTE),
    refdate        DATE,
    code           VARCHAR2 (30 BYTE),
    designation    VARCHAR2 (100 BYTE),
    ent_by         NUMBER,
    ent_date       DATE,
    upd_by         NUMBER,
    upd_date       DATE,
    CONSTRAINT designations_pk PRIMARY KEY (id)
);
/