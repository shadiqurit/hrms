/* Formatted on 4/22/2025 1:46:04 PM (QP5 v5.362) */
SELECT src.SLNO,
       src.EMPCODE,
       src.EXAMNAME,
       src.EXAMGROUP,
       src.BOARD,
       src.CLAS,
       src.PASSYEAR,
       src.REMARKS,
       src.INSTITUTE,
       src.USERNAME,
       src.SUBJECT_NAME
  FROM HR_EMPEXAMDET@IPIHR src;


SELECT ID,
       EMP_ID,
       EXAM,
       SUB_GROUP,
       PASSING_YEAR,
       DURATION,
       BOARD,
       CGPA,
       REMARKS,
       ENT_BY,
       ENT_DATE,
       UPD_BY,
       UPD_DATE,
       MIME_TYPE,
       FILE_NAME,
       UPD_AT,
       ATTACHMENT,
       SLNO,
       EMPCODE,
       EXAMGROUP,
       BOARD_N,
       CLAS,
       PASSYEAR,
       INSTITUTE,
       SUBJECT_NAME
  FROM emp_education;

SELECT DISTINCT EXAMNAME
  FROM HR_EMPEXAMDET@IPIHR
 WHERE EMPCODE IN ('IPI-006045',
                   'IPI-008315',
                   'IPI-008726',
                   'IPI-008511',
                   'IPI-008710',
                   'IPI-008711',
                   'IPI-008619',
                   'IPI-008240',
                   'IPI-008310',
                   'IPI-008855',
                   'IPI-009894',
                   'IPI-009895',
                   'IPI-009555',
                   'IPI-009556',
                   'IPI-009554',
                   'IPI-009903',
                   'IPI-009904',
                   'IPI-009905');

SELECT SLNO,
       EMPCODE,
       EXAMNAME,
       0        EXAM_ID,
       EXAMGROUP,
       GROUP_SUB_ID,
       BOARD,
       BOARD_ID,
       CLAS     RESULT,
       PASSYEAR,
       REMARKS,
       INSTITUTE,
       USERNAME,
       SUBJECT_NAME
  FROM HR_EMPEXAMDET@IPIHR he, employees ee, EXAMS ex
 WHERE he.EMPCODE = ee.emp_id AND he.EXAMNAME = ex.name;
 
 
 /* Formatted on 4/22/2025 2:03:57 PM (QP5 v5.362) */
MERGE INTO emp_education tgr
     USING (SELECT src.SLNO,
                   src.EMPCODE,
                   src.EXAMNAME,
                   src.EXAMGROUP,
                   src.BOARD     BOARD_N,
                   src.CLAS,
                   src.PASSYEAR,
                   src.REMARKS,
                   src.INSTITUTE,
                   src.SUBJECT_NAME
              FROM HR_EMPEXAMDET@IPIHR src) src
        ON (tgr.SLNO = src.SLNO AND tgr.EMPCODE = src.EMPCODE)
WHEN MATCHED
THEN
    UPDATE SET tgr.EXAMNAME = src.EXAMNAME,
               tgr.EXAMGROUP = src.EXAMGROUP,
               tgr.BOARD_N = src.BOARD_N,
               tgr.CLAS = src.CLAS,
               tgr.PASSYEAR = src.PASSYEAR,
               tgr.REMARKS = src.REMARKS,
               tgr.INSTITUTE = src.INSTITUTE,
               tgr.SUBJECT_NAME = src.SUBJECT_NAME
WHEN NOT MATCHED
THEN
    INSERT     (SLNO,
                EMPCODE,
                EXAMNAME,
                EXAMGROUP,
                BOARD_N,
                CLAS,
                PASSYEAR,
                REMARKS,
                INSTITUTE,
                SUBJECT_NAME)
        VALUES (src.SLNO,
                src.EMPCODE,
                src.EXAMNAME,
                src.EXAMGROUP,
                src.BOARD_N,
                src.CLAS,
                src.PASSYEAR,
                src.REMARKS,
                src.INSTITUTE,
                src.SUBJECT_NAME);