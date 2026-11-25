-- Base de datos de ejemplo (datos ficticios) para el vídeo T01
IF DB_ID('TiendaDemo') IS NULL CREATE DATABASE TiendaDemo;
GO
USE TiendaDemo;
GO
DROP TABLE IF EXISTS dbo.Ventas;
CREATE TABLE dbo.Ventas (
    Id         INT IDENTITY PRIMARY KEY,
    Fecha      DATE          NOT NULL,
    Producto   NVARCHAR(60)  NOT NULL,
    Categoria  NVARCHAR(30)  NOT NULL,
    Unidades   INT           NOT NULL,
    Importe    DECIMAL(10,2) NOT NULL,
    Tienda     NVARCHAR(30)  NOT NULL
);
GO
-- 120 días de ventas generadas de forma reproducible
DECLARE @Productos TABLE (Producto NVARCHAR(60), Categoria NVARCHAR(30), Precio DECIMAL(10,2));
INSERT @Productos VALUES
 (N'Portátil 14"', N'Informática', 749), (N'Monitor 27"', N'Informática', 229), (N'Ratón inalámbrico', N'Accesorios', 24.9),
 (N'Teclado mecánico', N'Accesorios', 79), (N'Auriculares BT', N'Audio', 59), (N'Altavoz portátil', N'Audio', 45),
 (N'Disco SSD 1TB', N'Componentes', 89), (N'Memoria RAM 16GB', N'Componentes', 52), (N'Webcam HD', N'Accesorios', 39),
 (N'Tablet 10"', N'Informática', 299);
DECLARE @Tiendas TABLE (Tienda NVARCHAR(30)); INSERT @Tiendas VALUES (N'Madrid'), (N'Valencia'), (N'Sevilla'), (N'Online');
;WITH Dias AS (SELECT TOP (120) DATEADD(DAY, -ROW_NUMBER() OVER (ORDER BY (SELECT 1)) + 1, CAST(GETDATE() AS DATE)) AS Fecha
               FROM sys.all_objects)
INSERT dbo.Ventas (Fecha, Producto, Categoria, Unidades, Importe, Tienda)
SELECT d.Fecha, p.Producto, p.Categoria, u.Unidades, u.Unidades * p.Precio, t.Tienda
FROM Dias d CROSS JOIN @Productos p CROSS JOIN @Tiendas t
CROSS APPLY (SELECT ABS(CHECKSUM(CONCAT(d.Fecha, p.Producto, t.Tienda))) % 6
                    + CASE WHEN DATEPART(WEEKDAY, d.Fecha) IN (1, 7) THEN 2 ELSE 0 END AS Unidades) u
WHERE u.Unidades > 0;
GO
SELECT COUNT(*) AS Filas, MIN(Fecha) AS Desde, MAX(Fecha) AS Hasta, SUM(Importe) AS Total FROM dbo.Ventas;
