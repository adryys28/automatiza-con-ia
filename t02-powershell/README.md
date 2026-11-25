# T02 · 5 scripts de PowerShell que todo administrador debería tener

Código del vídeo [**"5 scripts de PowerShell que todo administrador de sistemas debería tener"**](https://www.youtube.com/@PovedaOps). Probado con PowerShell 7.4 contra servicios reales; escrito para ser compatible con Windows PowerShell 5.1.

| Script | Qué hace |
|---|---|
| `Comprobar-Disco.ps1` | Uso de cada unidad con alerta por umbral |
| `Comprobar-Certificados.ps1` | Días que le quedan a cada certificado SSL |
| `Comprobar-Servicios.ps1` | Servidores y puertos que no responden, con tiempo de respuesta |
| `Limpiar-Antiguos.ps1` | Borra archivos de más de N días (por defecto solo simula; `-Borrar` para borrar) |
| `Comprobar-Copias.ps1` | Antigüedad y tamaño de la última copia de seguridad |
| `Informe-Salud.ps1` | Ejecuta todo con `config.psd1` y envía un correo (y Teams). `-SoloSiHayAlertas` |

```powershell
.\Comprobar-Disco.ps1 -UmbralPct 85
.\Comprobar-Certificados.ps1 -Destinos 'intranet.empresa.com:443' -DiasAviso 30
.\Comprobar-Servicios.ps1 -Destinos 'sql01:1433','web01:443'
.\Limpiar-Antiguos.ps1 -Ruta 'D:\Logs' -Dias 30 -Filtro '*.log'
.\Comprobar-Copias.ps1 -Ruta 'D:\Backups' -Filtro '*.bak' -HorasMax 26 -TamanoMinMB 50
.\Informe-Salud.ps1 -SoloSiHayAlertas
```
- `prompts.md`: los prompts para que la IA te los genere o adapte.
- `programar.md`: tarea programada de Windows y cron.

¿Lo quieres listo para tu empresa? Lista de espera del Pack Pro de monitorización en la descripción del vídeo · Proyectos a medida: adrian@povedaops.com
