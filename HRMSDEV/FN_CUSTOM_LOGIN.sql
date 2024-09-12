CREATE OR REPLACE FUNCTION HRMS.fn_custom_login (
        p_username IN VARCHAR2,
        p_password IN VARCHAR2
    ) RETURN BOOLEAN IS v_password VARCHAR2 (4000);
v_stored_password VARCHAR2 (4000);
v_count NUMBER;
BEGIN
SELECT COUNT (*) INTO v_count
FROM employees
WHERE UPPER (emp_id) = UPPER (p_username);
IF v_count != 0 THEN
SELECT passw INTO v_stored_password
FROM employees
WHERE UPPER (emp_id) = UPPER (p_username);
v_password := p_password;
IF v_password = v_stored_password THEN RETURN TRUE;
ELSE RETURN FALSE;
END IF;
END IF;
END fn_custom_login;
/