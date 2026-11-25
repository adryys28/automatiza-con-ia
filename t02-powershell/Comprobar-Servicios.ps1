<#
.SYNOPSIS  ¿Responden los servidores? Comprueba puertos TCP y mide el tiempo de respuesta.
.EXAMPLE   .\Comprobar-Servicios.ps1 -Destinos 'sql01:1433','correo:25','web01:443'
#>
param(
    [Parameter(Mandatory)][string[]]$Destinos,
    [int]$TimeoutMs = 2000
)

foreach ($destino in $Destinos) {
    $servidor, $puerto = $destino -split ':'
    $tcp = New-Object Net.Sockets.TcpClient
    $reloj = [Diagnostics.Stopwatch]::StartNew()
    try {
        $ok = $tcp.ConnectAsync($servidor, [int]$puerto).Wait($TimeoutMs)
    } catch { $ok = $false }
    $reloj.Stop(); $tcp.Dispose()
    [pscustomobject]@{
        Destino = $destino
        Estado  = if ($ok) { 'OK' } else { 'CAÍDO' }
        Ms      = if ($ok) { $reloj.ElapsedMilliseconds } else { $null }
    }
}
