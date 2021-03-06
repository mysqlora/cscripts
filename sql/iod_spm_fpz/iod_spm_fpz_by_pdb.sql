SET PAGES 100 LIN 80;
CL COL BRE
ALTER SESSION SET container = CDB$ROOT;
SELECT name, con_id, open_mode FROM v$pdbs ORDER BY name;
ACC pdb_name PROMPT 'PDB Name (opt, default all): ';
PRO Report Only Flag [Y|N]. Y=Report Only. N=Demote SPB.
ACC report_only PROMPT 'Enter Report Only Flag [Y|N] (opt, default Y): ';
WHENEVER SQLERROR EXIT SUCCESS;
PRO Error "ORA-01476: divisor is equal to zero" just means v$database.open_mode is not "READ WRITE"
SELECT CASE open_mode WHEN 'READ WRITE' THEN open_mode ELSE TO_CHAR(1/0) END open_mode FROM v$database;
SET ECHO OFF VER OFF FEED OFF HEA OFF PAGES 0 TAB OFF LINES 300 TRIMS ON SERVEROUT ON SIZE UNLIMITED;
COL report_file NEW_V report_file;
SELECT '/tmp/iod_spm_fpz_&&pdb_name._'||TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS') report_file FROM DUAL;
SPO &&report_file..txt;
EXEC c##iod.iod_spm.fpz(p_report_only => NVL(SUBSTR(UPPER(TRIM('&&report_only.')), 1, 1), 'Y'), p_pdb_name => UPPER(TRIM('&&pdb_name.')));
SPO OFF;
HOS zip -mj &&report_file..zip &&report_file..txt
HOS unzip -l &&report_file..zip