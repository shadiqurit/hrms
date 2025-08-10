/* Formatted on 7/29/2025 1:44:05 PM (QP5 v5.362) */
SELECT lr.leave_id,
lr.empid,
lr.leave_type,
lr.leave_balance,
lr.leave_taken,
lr.applied_date,
lr.l_start_date,
lr.l_end_date,
lr.proposed_days,
lr.leave_purpose,
lr.app_leave_typ,
lr.leave_address,
CASE
    WHEN leave_status = 'P' THEN 'Pending'
   WHEN leave_status = 'R' THEN 'Rejcted'
    WHEN leave_status = 'F' THEN 'Forwarded'
    WHEN leave_status = 'A' THEN 'Approved'
END    AS leave_status,
lr.ent_date,
lr.ent_by,
lr.upd_date,
lr.upd_by,
lr.comments
  FROM leave_request lr, leave_app_history lh
 WHERE lr.leave_id = lh.leave_id AND empid = :user_id