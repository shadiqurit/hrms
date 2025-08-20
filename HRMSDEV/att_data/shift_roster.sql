/* Formatted on 8/11/2025 7:35:23 PM (QP5 v5.362) */
--OFFICE_SCHEDULE
CREATE TABLE shifts
(
    shift_id          NUMBER PRIMARY KEY,
    shift_name        VARCHAR2 (50) NOT NULL,
    start_time        VARCHAR2 (50) NOT NULL,
    end_time          VARCHAR2 (50) NOT NULL,
    duration_hours    NUMBER (5, 2),
    is_night_shift    VARCHAR2 (5) CHECK (is_night_shift IN ('Y', 'N')),
    nextday_flag      VARCHAR2 (5 BYTE) DEFAULT 'N',
    status            VARCHAR2 (5 BYTE),
    ent_by            NUMBER,
    ent_date          DATE DEFAULT SYSDATE,
    upd_by            NUMBER,
    upd_date          DATE,
    com_id            NUMBER
);


CREATE TABLE rosters
(
    roster_id    NUMBER PRIMARY KEY,
    empid        NUMBER,
    shift_id     NUMBER NOT NULL,
    duty_date    DATE,
    status       VARCHAR2 (20 BYTE),
    remarks      VARCHAR2 (200),
    ent_by       NUMBER,
    ent_date     DATE DEFAULT SYSDATE,
    upd_by       NUMBER,
    upd_date     DATE,
    com_id       NUMBER,
    FOREIGN KEY (empid) REFERENCES employees (id),
    FOREIGN KEY (shift_id) REFERENCES shifts (shift_id),
    CONSTRAINT uq_roster UNIQUE (empid, duty_date) -- one shift per employee per day
);


 ipi ,
  vname ,
  vDesig,
  vDept,
  vJoindate,
  vloc,
  vnote,
  vPurpos,
  vContact,