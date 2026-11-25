-- Usuario de SOLO LECTURA para el informe (nunca uses 'sa' en un script programado)
USE master;
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'informes')
    CREATE LOGIN informes WITH PASSWORD = '$(CLAVE_INFORMES)', CHECK_POLICY = ON;
GO
USE TiendaDemo;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'informes')
    CREATE USER informes FOR LOGIN informes;
ALTER ROLE db_datareader ADD MEMBER informes;
GO
