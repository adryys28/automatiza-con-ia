<#
.SYNOPSIS  Informe diario de salud: ejecuta los 5 scripts y envía UN correo con todo (y opcionalmente a Teams).
.EXAMPLE   .\Informe-Salud.ps1                      # usa config.psd1
.EXAMPLE   .\Informe-Salud.ps1 -SoloSiHayAlertas    # silencio si todo está bien
#>
param(
    [string]$Config = (Join-Path $PSScriptRoot 'config.psd1'),
    [switch]$SoloSiHayAlertas
)
$ErrorActionPreference = 'Stop'
$c = Import-PowerShellDataFile $Config
$dir = $PSScriptRoot

$bloques = [ordered]@{
    'Espacio en disco'      = & "$dir\Comprobar-Disco.ps1" -UmbralPct $c.Disco.UmbralPct
    'Certificados SSL'      = & "$dir\Comprobar-Certificados.ps1" -Destinos $c.Certificados.Destinos -DiasAviso $c.Certificados.DiasAviso
    'Servidores y puertos'  = & "$dir\Comprobar-Servicios.ps1" -Destinos $c.Servicios.Destinos
    'Copias de seguridad'   = foreach ($r in $c.Copias) { & "$dir\Comprobar-Copias.ps1" @r }
    'Limpieza de logs'      = foreach ($r in $c.Limpieza) { & "$dir\Limpiar-Antiguos.ps1" @r }
}

$alertas = @($bloques.Values | ForEach-Object { $_ } | Where-Object { $_.PSObject.Properties['Estado'] -and $_.Estado -ne 'OK' }).Count
foreach ($nombre in $bloques.Keys) { Write-Host "== $nombre"; $bloques[$nombre] | Format-Table -AutoSize | Out-String | Write-Host }
if ($SoloSiHayAlertas -and $alertas -eq 0) { Write-Host 'Todo OK: no se envía nada.'; return }

# --- HTML: semáforo por fila
$estilo = '<style>body{font-family:Segoe UI,Arial}table{border-collapse:collapse;width:100%;margin-bottom:18px}' +
          'th{background:#f1f5f9;text-align:left}td,th{padding:6px;border-bottom:1px solid #e2e8f0}</style>'
$html = "<h2>Salud de los servidores · $(Get-Date -Format 'dd/MM/yyyy HH:mm')</h2>"
$html += if ($alertas) { "<p style='color:#dc2626;font-size:18px'><b>$alertas alerta(s)</b></p>" } else { "<p style='color:#16a34a;font-size:18px'><b>Todo correcto</b></p>" }
foreach ($nombre in $bloques.Keys) {
    $tabla = $bloques[$nombre] | ConvertTo-Html -Fragment | Out-String
    $tabla = $tabla -replace '<td>OK</td>', "<td style='color:#16a34a'><b>OK</b></td>" `
                    -replace '<td>((ALERTA|CADUCADO|CA(Í|&#205;)DO|ERROR)[^<]*)</td>', "<td style='color:#dc2626'><b>`$1</b></td>"
    $html += "<h3>$nombre</h3>$tabla"
}
$asunto = if ($alertas) { "⚠️ $alertas alerta(s) · Salud de los servidores" } else { '✅ Todo OK · Salud de los servidores' }

$correo = @{
    SmtpServer = $c.Correo.Servidor; Port = $c.Correo.Puerto; From = $c.Correo.De; To = $c.Correo.Para
    Subject = $asunto; Body = "$estilo$html"; BodyAsHtml = $true; Encoding = [Text.Encoding]::UTF8
}
if ($c.Correo.UsarSsl) { $correo.UseSsl = $true }
if ($env:SMTP_USUARIO) {
    $clave = ConvertTo-SecureString $env:SMTP_CLAVE -AsPlainText -Force
    $correo.Credential = New-Object PSCredential($env:SMTP_USUARIO, $clave)
}
Send-MailMessage @correo -WarningAction SilentlyContinue
Write-Host "Enviado: $asunto"

if ($env:TEAMS_WEBHOOK) {
    $tarjeta = @{ type = 'message'; attachments = @(@{ contentType = 'application/vnd.microsoft.card.adaptive'; content = @{
        type = 'AdaptiveCard'; version = '1.4'; body = @(@{ type = 'TextBlock'; text = $asunto; weight = 'Bolder'; wrap = $true }) } }) }
    Invoke-RestMethod -Uri $env:TEAMS_WEBHOOK -Method Post -ContentType 'application/json' -Body ($tarjeta | ConvertTo-Json -Depth 8) | Out-Null
    Write-Host 'Aviso enviado a Teams'
}
