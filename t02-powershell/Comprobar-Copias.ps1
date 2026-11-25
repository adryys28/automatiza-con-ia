<#
.SYNOPSIS  ¿Se hizo la copia de seguridad? Revisa la copia más reciente: antigüedad y tamaño.
.EXAMPLE   .\Comprobar-Copias.ps1 -Ruta '\\nas\backups\sql' -Filtro '*.bak' -HorasMax 26 -TamanoMinMB 50
#>
param(
    [Parameter(Mandatory)][string]$Ruta,
    [string]$Filtro = '*',
    [int]$HorasMax = 26,
    [double]$TamanoMinMB = 1
)

$ultima = Get-ChildItem -Path $Ruta -Filter $Filtro -File -ErrorAction SilentlyContinue |
          Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $ultima) {
    return [pscustomobject]@{ Ruta = $Ruta; Ultima = '-'; Horas = $null; MB = $null; Estado = 'ALERTA: no hay copias' }
}
$horas = [int][math]::Round(((Get-Date) - $ultima.LastWriteTime).TotalHours)
$mb    = [int][math]::Round($ultima.Length / 1MB)
$estado = if ($horas -gt $HorasMax) { "ALERTA: tiene $horas h" }
          elseif ($mb -lt $TamanoMinMB) { "ALERTA: solo $mb MB" }
          else { 'OK' }
[pscustomobject]@{ Ruta = $Ruta; Ultima = $ultima.Name; Horas = $horas; MB = $mb; Estado = $estado }
