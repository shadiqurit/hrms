SELECT src.SLNO,
       src.EMPCODE,
       src.EXAMNAME,
       src.EXAMGROUP,
       src.BOARD BOARD_N,
       src.CLAS,
       src.PASSYEAR,
       src.REMARKS,
       src.INSTITUTE,       
       src.SUBJECT_NAME
  FROM HR_EMPEXAMDET@IPIHR src;


SELECT tgr.SLNO,
       tgr.EMPCODE,
       tgr.EXAMNAME,
       tgr.EXAMGROUP,
       tgr.BOARD_N,
       tgr.CLAS,
       tgr.PASSYEAR,
       tgr.REMARKS,
       tgr.INSTITUTE,
       tgr.SUBJECT_NAME
  FROM emp_education tgr;