-- Leave Allocation Table
CREATE TABLE leave_allocation
(
    allocation_id      NUMBER PRIMARY KEY,
    empid              NUMBER NOT NULL,
    leave_typ          NUMBER NOT NULL,
    allocated_days     NUMBER (5, 2) NOT NULL,
    used_days          NUMBER (5, 2) DEFAULT 0,
    balance_days       NUMBER (5, 2),
    allocation_year    NUMBER,
    allocation_date    DATE DEFAULT SYSDATE,
    valid_from         DATE NOT NULL,
    valid_to           DATE NOT NULL,
    status             VARCHAR2 (20),
    typ                VARCHAR2 (20),
    ent_date           DATE DEFAULT SYSDATE,
    ent_by             NUMBER,
    upd_date           DATE,
    upd_by             NUMBER,
    com_id             NUMBER
);
/
-- Index for Leave Allocation
CREATE INDEX idx_leave_allocation_empid ON leave_allocation (empid);
-- Sequence for Leave Allocation
CREATE SEQUENCE hr_leave_allocation_seq;

-- Trigger for Leave Allocation ID
CREATE OR REPLACE TRIGGER trg_hr_leave_allocation
    BEFORE INSERT ON hr_leave_allocation
    FOR EACH ROW
BEGIN
    :NEW.allocation_id := hr_leave_allocation_seq.NEXTVAL;
    :NEW.balance_days := :NEW.allocated_days - :NEW.used_days;
END;
/