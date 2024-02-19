BEGIN
    rdsadmin.rdsadmin_util.grant_sys_object('ALL_VIEWS', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('ALL_TAB_PARTITIONS', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('ALL_INDEXES', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('ALL_OBJECTS', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('ALL_TABLES', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('ALL_USERS', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('ALL_CATALOG', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('ALL_CONSTRAINTS', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('ALL_CONS_COLUMNS', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('ALL_TAB_COLS', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('ALL_IND_COLUMNS', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('ALL_LOG_GROUPS', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('V_$ARCHIVED_LOG', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('V_$LOG', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGFILE', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('V_$DATABASE', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('V_$THREAD', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('V_$PARAMETER', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('V_$NLS_PARAMETERS', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('V_$TIMEZONE_NAMES', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('V_$TRANSACTION', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('V_$CONTAINERS', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('DBA_REGISTRY', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('OBJ$', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('ALL_ENCRYPTED_COLUMNS', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGMNR_LOGS', 'DB_USER', 'SELECT');
    rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGMNR_CONTENTS','DB_USER','SELECT');
    --rdsadmin.rdsadmin_util.grant_sys_object('DBMS_LOGMNR', 'DB_USER', ' UTE');

-- (as of Oracle versions 12.1 and higher)
    rdsadmin.rdsadmin_util.grant_sys_object('REGISTRY$SQLPATCH', 'DB_USER', 'SELECT');

-- (for Amazon RDS Active Dataguard Standby (ADG))
    rdsadmin.rdsadmin_util.grant_sys_object('V_$STANDBY_LOG', 'DB_USER', 'SELECT');

-- (for transparent data encryption (TDE))

    rdsadmin.rdsadmin_util.grant_sys_object('ENC$', 'DB_USER', 'SELECT');

-- (for validation with LOB columns)
    --rdsadmin.rdsadmin_util.grant_sys_object('DBMS_CRYPTO', 'DB_USER', ' UTE');

-- (for binary reader)
    rdsadmin.rdsadmin_util.grant_sys_object('DBA_DIRECTORIES','DB_USER','SELECT');

-- Required when the source database is Oracle Data guard, and Oracle Standby is used in the latest release of DMS version 3.4.6, version 3.4.7, and higher.

    rdsadmin.rdsadmin_util.grant_sys_object('V_$DATAGUARD_STATS', 'DB_USER', 'SELECT');

    rdsadmin.rdsadmin_util.set_configuration('archivelog retention hours',24);
    commit;

    rdsadmin.rdsadmin_util.alter_supplemental_logging('ADD','PRIMARY KEY');


    rdsadmin.rdsadmin_master_util.create_archivelog_dir;
    rdsadmin.rdsadmin_master_util.create_onlinelog_dir;
END;


CREATE TABLE clientes (
                          cliente_id NUMBER PRIMARY KEY,
                          nome VARCHAR2(100),
                          email VARCHAR2(100),
                          endereco VARCHAR2(255)
);

INSERT INTO clientes (cliente_id, nome, email, endereco) VALUES (1, 'João Silva', 'joao.silva@email.com', 'Rua das Flores, 123');
INSERT INTO clientes (cliente_id, nome, email, endereco) VALUES (2, 'Maria Oliveira', 'maria.oliveira@email.com', 'Avenida Brasil, 456');
