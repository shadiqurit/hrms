CREATE TABLE T_MENU
(
    PID                 NUMBER NOT NULL,
    PARENT_PID          NUMBER,
    MENU_NAME           NVARCHAR2 (100),
    MENU_LINK           NVARCHAR2 (200),
    STATUS              NVARCHAR2 (1),
    DESCRIPTION         NVARCHAR2 (200),
    SORT_BY             NUMBER,
    ENT_BY              NUMBER,
    UPD_BY              NUMBER,
    ENT_DATE            DATE DEFAULT SYSDATE,
    UPD_DATE            DATE,
    ICON_IMG            VARCHAR2 (250 BYTE),
    MENU_NAME_BANGLA    VARCHAR2 (250 BYTE)
);
/


ALTER TABLE T_MENU
    ADD (CONSTRAINT T_MENU_C01 CHECK (PARENT_PID <> PID) ENABLE VALIDATE,
         CONSTRAINT T_MENU_CON_PK PRIMARY KEY (PID));


CREATE OR REPLACE TRIGGER T_T_MENU_PK_AUTO
    BEFORE INSERT OR UPDATE
    ON T_MENU
    FOR EACH ROW
BEGIN
    IF :NEW.PID IS NULL
    THEN
        SELECT NVL (MAX (PID), 0) + 1 INTO :NEW.PID FROM T_MENU;
    END IF;
END T_T_MENU_PK_AUTO;
/


ALTER TABLE T_MENU
    ADD (
        CONSTRAINT T_MENU_CON FOREIGN KEY (PARENT_PID)
            REFERENCES T_MENU (PID)
            ENABLE VALIDATE);
/

CREATE TABLE USER_MENU
(
    PID           NUMBER NOT NULL,
    PID_GROUP     NUMBER NOT NULL,
    PAGE_ID       NUMBER,
    PERMISSION    NUMBER (1) DEFAULT 1
);


ALTER TABLE USER_MENU
    ADD (CONSTRAINT C_USER_MENU_PK PRIMARY KEY (PID),
         CONSTRAINT C_USER_MENU_U01 UNIQUE (PID_GROUP, PAGE_ID));
/

CREATE TABLE T_STATUS
(
    ID        NUMBER (1),
    STATUS    VARCHAR2 (30 BYTE)
);

ALTER TABLE T_STATUS
    ADD (CONSTRAINT T_STATUS_PK PRIMARY KEY (ID));

SET DEFINE OFF;

INSERT INTO T_STATUS (ID, STATUS)
     VALUES (1, 'Active');

INSERT INTO T_STATUS (ID, STATUS)
     VALUES (2, 'In active');

COMMIT;

CREATE TABLE USER_GROUP
(
    ID            NUMBER,
    GROUP_NAME    VARCHAR2 (50 BYTE)
);

ALTER TABLE USER_GROUP
    ADD (CONSTRAINT USER_GROUP_PK PRIMARY KEY (ID));

SET DEFINE OFF;

INSERT INTO USER_GROUP (ID, GROUP_NAME)
     VALUES (0, 'Default');

INSERT INTO USER_GROUP (ID, GROUP_NAME)
     VALUES (1, 'Admin');

INSERT INTO USER_GROUP (ID, GROUP_NAME)
     VALUES (2, 'HR');

INSERT INTO USER_GROUP (ID, GROUP_NAME)
     VALUES (3, 'Accounts');

INSERT INTO USER_GROUP (ID, GROUP_NAME)
     VALUES (96, 'Cheif Financial Officer');

INSERT INTO USER_GROUP (ID, GROUP_NAME)
     VALUES (97, 'Directors');

INSERT INTO USER_GROUP (ID, GROUP_NAME)
     VALUES (98, 'Executive Director');

INSERT INTO USER_GROUP (ID, GROUP_NAME)
     VALUES (99, 'Managing Director');



COMMIT;
/

       
INSERT INTO T_MENU (PID,
                    PARENT_PID,
                    MENU_NAME,
                    MENU_LINK,
                    STATUS,
                    DESCRIPTION,
                    SORT_BY,
                    ENT_BY,
                    UPD_BY,
                    UPD_DATE,
                    ENT_DATE,
                    ICON_IMG,
                    MENU_NAME_BANGLA)
     VALUES (1,
             NULL,
             N'Home',
             N'1',
             N'1',
             N'Home pages',
             0,
             NULL,
             NULL,
             SYSDATE,
             SYSDATE,
             NULL,
             NULL);

INSERT INTO T_MENU (PID,
                    PARENT_PID,
                    MENU_NAME,
                    MENU_LINK,
                    STATUS,
                    DESCRIPTION,
                    SORT_BY,
                    ENT_BY,
                    UPD_BY,
                    UPD_DATE,
                    ENT_DATE,
                    ICON_IMG,
                    MENU_NAME_BANGLA)
     VALUES (2,
             NULL,
             N'System Administration',
             NULL,
             N'1',
             NULL,
             1,
             NULL,
             NULL,
             SYSDATE,
             SYSDATE,
             NULL,
             NULL);

COMMIT;
SET DEFINE OFF;

INSERT INTO T_MENU (PID,
                    PARENT_PID,
                    MENU_NAME,
                    MENU_LINK,
                    STATUS,
                    DESCRIPTION,
                    SORT_BY,
                    ENT_BY,
                    UPD_BY,
                    UPD_DATE,
                    ENT_DATE,
                    ICON_IMG,
                    MENU_NAME_BANGLA)
     VALUES (3,
             2,
             N'Menus',
             N'99',
             N'1',
             NULL,
             11,
             NULL,
             NULL,
             SYSDATE,
             SYSDATE,
             'fa-arrow-right-alt',
             NULL);

INSERT INTO T_MENU (PID,
                    PARENT_PID,
                    MENU_NAME,
                    MENU_LINK,
                    STATUS,
                    DESCRIPTION,
                    SORT_BY,
                    ENT_BY,
                    UPD_BY,
                    UPD_DATE,
                    ENT_DATE,
                    ICON_IMG,
                    MENU_NAME_BANGLA)
     VALUES (4,
             2,
             N'Menu Permission',
             N'992',
             N'1',
             NULL,
             12,
             NULL,
             NULL,
             SYSDATE,
             SYSDATE,
             'fa-arrow-right-alt',
             NULL);

COMMIT;
/

SET DEFINE OFF;