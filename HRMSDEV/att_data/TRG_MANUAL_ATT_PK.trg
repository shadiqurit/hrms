CREATE OR REPLACE TRIGGER trg_manual_att_pk
    BEFORE INSERT OR UPDATE
    ON manual_att
    FOR EACH ROW
DECLARE
    v_count   NUMBER;
BEGIN
    IF :new.id IS NULL
    THEN
        SELECT NVL (MAX (id), 0) + 1 INTO :new.id FROM manual_att;
    END IF;

    SELECT COUNT (*)
      INTO v_count
      FROM MANUAL_ATT
     WHERE     EMPID = :NEW.EMPID
           AND (   TRUNC (M_INTIME) = TRUNC (:NEW.M_INTIME)
                OR TRUNC (M_OUTTIME) = TRUNC (:NEW.M_OUTTIME)
                OR TRUNC (M_INTIME) = TRUNC (:NEW.M_OUTTIME)
                OR TRUNC (M_OUTTIME) = TRUNC (:NEW.M_INTIME));

    -- If a duplicate exists, raise an exception to prevent the insert
    IF v_count > 0
    THEN
        RAISE_APPLICATION_ERROR (
            -20001,'Employee cannot apply on the same date twice.');
    END IF;
END;
/
