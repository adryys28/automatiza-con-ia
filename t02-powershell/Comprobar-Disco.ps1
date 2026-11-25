<#
.SYNOPSIS  Espacio en disco de todas las unidades, con alerta por encima de un umbral.
.EXAMPLE   .\Comprobar-Disco.ps1 -UmbralPct 85
#>
param([int]$UmbralPct = 85)

Get-PSDrive -PSProvider FileSystem |
    Where-Object { $_.Name -ne 'Temp' -and ($_.Used + $_.Free) -gt 0 } |   # 'Temp:' es la carpeta temporal, no un disco
    ForEach-Object {
        $total = $_.Used + $_.Free
        $pct   = [int][math]::Round($_.Used / $total * 100)
        [pscustomobject]@{
            Unidad  = $_.Root
            TotalGB = [int][math]::Round($total / 1GB)
            LibreGB = [int][math]::Round($_.Free / 1GB)
            UsoPct  = $pct
            Estado  = if ($pct -ge $UmbralPct) { 'ALERTA' } else { 'OK' }
        }
    }
