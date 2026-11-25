@{
    Disco        = @{ UmbralPct = 85 }
    Certificados = @{ DiasAviso = 30; Destinos = @('intranet.empresa.local:443', 'correo.empresa.local:443') }
    Servicios    = @{ Destinos = @('sql01:1433', 'correo:25', 'web01:443') }
    Copias       = @( @{ Ruta = 'D:\Backups\SQL'; Filtro = '*.bak'; HorasMax = 26; TamanoMinMB = 50 } )
    Limpieza     = @( @{ Ruta = 'D:\Logs'; Dias = 30; Filtro = '*.log' } )   # añade Borrar = $true cuando lo hayas revisado
    Correo       = @{ Servidor = 'smtp.office365.com'; Puerto = 587; UsarSsl = $true
                      De = 'alertas@empresa.com'; Para = @('sistemas@empresa.com') }
}
