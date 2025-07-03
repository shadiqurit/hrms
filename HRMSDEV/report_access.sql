/* Formatted on 6/30/2025 5:19:42 PM (QP5 v5.362) */
CREATE TABLE reports
(
    report_id      NUMBER PRIMARY KEY,
    report_name    VARCHAR2 (100) NOT NULL,
    status         VARCHAR2 (5),
    rep_typ        VARCHAR2 (30),
    ent_by         NUMBER,
    ent_date       DATE,
    upd_by         NUMBER,
    upd_date       DATE
);
/

CREATE TABLE report_access
(
    access_id    NUMBER PRIMARY KEY,
    report_id    NUMBER,
    grp_id       NUMBER,
    emp_id       NUMBER,
    status       VARCHAR2 (5),
    ent_by       NUMBER,
    ent_date     DATE,
    upd_by       NUMBER,
    upd_date     DATE,
    FOREIGN KEY (report_id) REFERENCES reports (report_id),
    FOREIGN KEY (grp_id) REFERENCES user_group (id),
    FOREIGN KEY (emp_id) REFERENCES employees (id)
);
/

--user_group
--user_menu