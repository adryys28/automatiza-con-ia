# T01 · Informe semanal de SQL Server por correo

Código del vídeo **"Automatiza tus informes de SQL Server con IA"**. Probado con SQL Server 2022 y Python 3.13. Datos de ejemplo ficticios.

## Qué hace
Cada vez que lo ejecutas: consulta las ventas de los últimos 7 días frente a los 7 anteriores, escribe conclusiones automáticas, dibuja un gráfico, adjunta un Excel y lo envía por correo. Opciones: un informe por tienda (`--por-tienda`) y modo alerta (`--alerta 10`).

## Probarlo en 5 minutos (con Docker)
```bash
docker run -d --name sql -e ACCEPT_EULA=Y -e MSSQL_PID=Developer -e 'MSSQL_SA_PASSWORD=<tu_clave>' -p 1433:1433 mcr.microsoft.com/mssql/server:2022-latest
docker run -d --name mail -p 1025:1025 -p 8025:8025 axllent/mailpit
docker cp 01_crear_datos.sql sql:/tmp/ && docker exec sql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P '<tu_clave>' -C -i /tmp/01_crear_datos.sql
pip install -r requirements.txt
SQL_CLAVE='<tu_clave>' python informe.py          # el correo aparece en http://localhost:8025
```
En Windows (PowerShell): `$env:SQL_CLAVE='<tu_clave>'; python informe.py`

## Archivos
| Archivo | Para qué |
|---|---|
| `informe.py` | El script del vídeo |
| `prompt.md` | El prompt para que la IA te lo genere adaptado a tus tablas |
| `programar.md` | Programarlo cada lunes (Windows y Linux) |
| `01_crear_datos.sql` | Base de datos de ejemplo |
| `02_usuario_lectura.sql` | Usuario de solo lectura (`sqlcmd ... -v CLAVE_INFORMES='...'`) |

## ¿Lo quieres listo para empresa?
**Pack Pro**: informes configurables sin tocar código, SQL Server y PostgreSQL, avisos en Teams, stock bajo y facturas vencidas, instaladores para Windows y Linux, y guía paso a paso. Enlace en la descripción del vídeo.

¿Prefieres que te lo monte en tu empresa? Escríbeme: adrian@povedaops.com
