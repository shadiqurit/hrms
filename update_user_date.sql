/*Update Master*/
DECLARE
    l_user_id NUMBER;
BEGIN
    -- Get the currently logged-in user ID
    l_user_id := :user_id;

    IF :P11_ID IS NOT NULL THEN
        -- Update
        UPDATE DEPARTMENTS
        SET upd_by = l_user_id,
            upd_date = sysdate
        WHERE id = :P11_ID;
    END IF;
 exception 
    when others then 
    null;
END;
/


/*Update Details*/
DECLARE
    l_user_id NUMBER;
BEGIN
    -- Get the currently logged-in user ID
    l_user_id := :user_id;

    IF :ID IS NOT NULL THEN
        -- Update
        UPDATE PURCHASE_DTL
        SET upd_by = l_user_id,
            upd_date = sysdate
        WHERE id = :ID;
    END IF;
 exception 
    when others then 
    null;
END;
