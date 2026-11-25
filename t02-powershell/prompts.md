# Prompts para que la IA te genere cada script

Pégalos en Claude (o tu asistente de IA). Pide siempre: compatible con Windows PowerShell 5.1 y PowerShell 7, que devuelva objetos (no texto) y que no borre nada sin un parámetro explícito.

1. **Disco**: «Script de PowerShell que liste el espacio de todas las unidades (total, libre, % de uso) y marque ALERTA si el uso supera un umbral que paso como parámetro. Devuelve objetos.»
2. **Certificados**: «Script de PowerShell que, para una lista de servidor:puerto, se conecte por TLS, lea el certificado aunque esté caducado o sea autofirmado, y devuelva la fecha de caducidad, los días que quedan y un estado OK/ALERTA/CADUCADO según un umbral de días.»
3. **Servicios**: «Script de PowerShell que compruebe si responden una lista de servidor:puerto por TCP, con un tiempo máximo de espera, y devuelva estado y milisegundos de respuesta.»
4. **Limpieza**: «Script de PowerShell que busque archivos con más de N días en una ruta y filtro dados. Por defecto solo debe SIMULAR y decir cuántos archivos y MB borraría; solo borra si paso -Borrar.»
5. **Copias**: «Script de PowerShell que revise la copia de seguridad más reciente de una carpeta y marque ALERTA si tiene más de X horas o pesa menos de Y MB.»
6. **Informe**: «Script que ejecute los cinco anteriores con los parámetros de un archivo config.psd1, y envíe un único correo HTML con una tabla por comprobación, los estados en verde o rojo y el número de alertas en el asunto. Opción -SoloSiHayAlertas.»
