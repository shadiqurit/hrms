/* Formatted on 7/21/2025 5:51:58 PM (QP5 v5.362) */
DROP SEQUENCE hr_leave_allocation_seq;

DELETE FROM LEAVE_ALLOCATION;

COMMIT;

CREATE SEQUENCE hr_leave_allocation_seq;

BEGIN
    p_leave_allocation (2025);
END;

--LEAVE_ALLOCATION

--LEAVE_CONSUMPTION