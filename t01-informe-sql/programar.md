# Programarlo cada lunes a las 8:00

## Windows (Programador de tareas, PowerShell como administrador)
```powershell
$accion   = New-ScheduledTaskAction -Execute "python.exe" -Argument "C:\informes\informe.py" -WorkingDirectory "C:\informes"
$cuando   = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 8:00
Register-ScheduledTask -TaskName "Informe semanal de ventas" -Action $accion -Trigger $cuando -RunLevel Highest
```
Variables (servidor, usuario, claves) con `setx SQL_CLAVE "..."` o un archivo `.env` fuera del repositorio.

## Linux (cron)
```
0 8 * * 1  cd /opt/informes && /usr/bin/python3 informe.py >> informe.log 2>&1
```
