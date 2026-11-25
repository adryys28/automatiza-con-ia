<#
.SYNOPSIS  Borra archivos más antiguos que N días. Por defecto SOLO SIMULA: usa -Borrar para borrar de verdad.
.EXAMPLE   .\Limpiar-Antiguos.ps1 -Ruta 'D:\Logs' -Dias 30 -Filtro '*.log'           # simulación
.EXAMPLE   .\Limpiar-Antiguos.ps1 -Ruta 'D:\Logs' -Dias 30 -Filtro '*.log' -Borrar   # borra
#>
param(
    [Parameter(Mandatory)][string]$Ruta,
    [int]$Dias = 30,
    [string]$Filtro = '*',
    [switch]$Borrar
)

$limite   = (Get-Date).AddDays(-$Dias)
$antiguos = Get-ChildItem -Path $Ruta -Filter $Filtro -File -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -lt $limite }
$mb = [int][math]::Round((($antiguos | Measure-Object Length -Sum).Sum) / 1MB)

if ($Borrar) {
    $antiguos | Remove-Item -Force
    $accion = 'BORRADOS'
} else {
    $accion = 'SIMULACIÓN (usa -Borrar)'
}
[pscustomobject]@{ Ruta = $Ruta; Archivos = @($antiguos).Count; MB = $mb; Accion = $accion }
