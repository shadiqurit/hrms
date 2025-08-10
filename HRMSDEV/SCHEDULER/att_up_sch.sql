BEGIN
   DBMS_SCHEDULER.create_job (
      job_name          => 'J_ATT_UPDATA',
      job_type          => 'PLSQL_BLOCK',
      job_action        => 'BEGIN p_att_up; END;',
      start_date        => SYSTIMESTAMP,
      repeat_interval   => 'FREQ=DAILY; BYHOUR=8,9,10,11; BYMINUTE=20,50',
      enabled           => TRUE);
END;
/