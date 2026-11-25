# Programar el informe cada mañana

## Windows (PowerShell como administrador)
```powershell
$accion = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File C:\scripts\Informe-Salud.ps1" -WorkingDirectory "C:\scripts"
$cuando = New-ScheduledTaskTrigger -Daily -At 7:30
Register-ScheduledTask -TaskName "Salud de los servidores" -Action $accion -Trigger $cuando -User "NT AUTHORITY\SYSTEM" -RunLevel Highest
```
Si el correo necesita usuario y contraseña, defínelos como variables de entorno del sistema `SMTP_USUARIO` y `SMTP_CLAVE`.

## Linux (cron, con PowerShell 7 instalado)
```
30 7 * * *  pwsh -NoProfile -File /opt/scripts/Informe-Salud.ps1 >> /var/log/salud.log 2>&1
```

## Nota sobre Send-MailMessage
Microsoft lo marca como obsoleto porque no garantiza conexiones seguras en todos los casos. Funciona con relés SMTP internos y con Microsoft 365 (puerto 587 con TLS), pero para entornos exigentes la alternativa es enviar con Microsoft Graph.
