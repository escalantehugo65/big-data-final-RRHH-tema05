INSTALL sqlite;
LOAD sqlite;

CREATE OR REPLACE TABLE raw_rrhh AS
SELECT * FROM sqlite_scan(?, 'empleados');
