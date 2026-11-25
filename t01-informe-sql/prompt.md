# Prompt para que la IA te construya el informe

Copia y pega en Claude (o tu asistente de IA), cambiando lo que está entre corchetes:

> Crea un script de Python que se conecte a mi SQL Server ([servidor], base de datos [BD], tabla [Ventas] con columnas [Fecha, Producto, Categoria, Unidades, Importe]) y genere un informe de los últimos 7 días:
> 1. Total de ventas y variación en % frente a los 7 días anteriores.
> 2. Gráfico de barras de ventas por categoría.
> 3. Top 5 productos por importe.
> 4. Un Excel adjunto con el detalle.
> Envíalo por correo en HTML (KPI arriba, gráfico incrustado y tabla) a [destinatario] usando SMTP [servidor:puerto].
> Lee contraseñas y servidores de variables de entorno, nunca en el código. Usa pymssql, matplotlib y openpyxl.
> Explícame cómo programarlo cada lunes a las 8:00 en Windows.
