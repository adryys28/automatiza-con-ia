# Añade tu propia comprobación con IA

Prompt de ejemplo (servicios de Windows detenidos):

> Escribe un script de PowerShell llamado Comprobar-ServiciosWindows.ps1, compatible con Windows PowerShell 5.1 y PowerShell 7,
> que reciba una lista de nombres de servicios de Windows (por ejemplo MSSQLSERVER, W3SVC, Spooler) y devuelva un objeto por
> servicio con las propiedades Servicio, Estado del servicio, Tipo de inicio y una propiedad Estado que valga 'OK' si está en
> ejecución y 'ALERTA' si está detenido teniendo inicio automático. Devuelve objetos, no texto, y no modifiques ningún servicio.

Después, en Informe-Salud.ps1, añade una línea más al bloque $bloques:

    'Servicios de Windows' = & "$dir\Comprobar-ServiciosWindows.ps1" -Servicios $c.ServiciosWindows

Como devuelve una columna Estado, el informe la cuenta como alerta y la pinta en rojo sin tocar nada más.
