<#
.SYNOPSIS  Días que le quedan al certificado SSL de cada web o servicio.
.EXAMPLE   .\Comprobar-Certificados.ps1 -Destinos 'intranet.empresa.com:443','correo.empresa.com:443' -DiasAviso 30
#>
param(
    [Parameter(Mandatory)][string[]]$Destinos,
    [int]$DiasAviso = 30
)

foreach ($destino in $Destinos) {
    $servidor, $puerto = $destino -split ':'
    if (-not $puerto) { $puerto = 443 }
    try {
        $tcp = New-Object Net.Sockets.TcpClient
        $tcp.Connect($servidor, [int]$puerto)
        # Aceptamos cualquier certificado: queremos LEERLO aunque esté caducado o sea autofirmado
        $ssl = New-Object Net.Security.SslStream($tcp.GetStream(), $false, { $true })
        $ssl.AuthenticateAsClient($servidor)
        $cert = New-Object Security.Cryptography.X509Certificates.X509Certificate2($ssl.RemoteCertificate)
        $dias = [int]($cert.NotAfter - (Get-Date)).TotalDays
        [pscustomobject]@{
            Destino  = $destino
            Caduca   = $cert.NotAfter.ToString('dd/MM/yyyy')
            DiasRest = $dias
            Estado   = if ($dias -lt 0) { 'CADUCADO' } elseif ($dias -le $DiasAviso) { 'ALERTA' } else { 'OK' }
        }
    } catch {
        [pscustomobject]@{ Destino = $destino; Caduca = '-'; DiasRest = $null; Estado = 'ERROR: ' + $_.Exception.InnerException.Message }
    } finally {
        if ($ssl) { $ssl.Dispose() }; if ($tcp) { $tcp.Dispose() }
    }
}
