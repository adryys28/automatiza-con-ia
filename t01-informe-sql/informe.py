"""Informe semanal de ventas: SQL Server -> gráfico + Excel -> correo.

Configuración por variables de entorno (o archivo .env):
  SQL_SERVIDOR, SQL_USUARIO, SQL_CLAVE, SQL_BD
  SMTP_SERVIDOR, SMTP_PUERTO, SMTP_USUARIO, SMTP_CLAVE, CORREO_DE, CORREO_PARA

Uso:
  python informe.py                 informe general a CORREO_PARA
  python informe.py --por-tienda    un informe por tienda a su responsable
  python informe.py --alerta 10     solo envía si las ventas caen un 10 % o más
"""
import os, io, sys, smtplib, argparse, datetime as dt
from email.message import EmailMessage
import pymssql
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from openpyxl import Workbook

CFG = {k: os.getenv(k, v) for k, v in {
    "SQL_SERVIDOR": "localhost", "SQL_USUARIO": "sa", "SQL_CLAVE": "", "SQL_BD": "TiendaDemo",
    "SMTP_SERVIDOR": "localhost", "SMTP_PUERTO": "1025", "SMTP_USUARIO": "", "SMTP_CLAVE": "",
    "CORREO_DE": "informes@empresa.local", "CORREO_PARA": "direccion@empresa.local"}.items()}

# 1. Consultas: semana actual frente a la anterior (%(tienda)s = NULL -> todas)
FILTRO = "(%(tienda)s IS NULL OR Tienda = %(tienda)s)"
SQL_KPI = f"""
SELECT SUM(CASE WHEN Fecha >  DATEADD(DAY,-7,CAST(GETDATE() AS DATE)) THEN Importe END) AS SemanaActual,
       SUM(CASE WHEN Fecha <= DATEADD(DAY,-7,CAST(GETDATE() AS DATE)) THEN Importe END) AS SemanaAnterior
FROM dbo.Ventas WHERE Fecha > DATEADD(DAY,-14,CAST(GETDATE() AS DATE)) AND {FILTRO};"""
SQL_CATEGORIAS = f"""
SELECT Categoria,
       SUM(CASE WHEN Fecha >  DATEADD(DAY,-7,CAST(GETDATE() AS DATE)) THEN Importe ELSE 0 END) AS Actual,
       SUM(CASE WHEN Fecha <= DATEADD(DAY,-7,CAST(GETDATE() AS DATE)) THEN Importe ELSE 0 END) AS Anterior
FROM dbo.Ventas WHERE Fecha > DATEADD(DAY,-14,CAST(GETDATE() AS DATE)) AND {FILTRO}
GROUP BY Categoria ORDER BY Actual DESC;"""
SQL_TOP = f"""
SELECT TOP 5 Producto, SUM(Unidades) AS Unidades, SUM(Importe) AS Importe FROM dbo.Ventas
WHERE Fecha > DATEADD(DAY,-7,CAST(GETDATE() AS DATE)) AND {FILTRO}
GROUP BY Producto ORDER BY Importe DESC;"""
SQL_TIENDAS = "SELECT DISTINCT Tienda FROM dbo.Ventas ORDER BY Tienda;"


def conectar():
    return pymssql.connect(CFG["SQL_SERVIDOR"], CFG["SQL_USUARIO"], CFG["SQL_CLAVE"], CFG["SQL_BD"])


def consultar(con, tienda=None):
    cur = con.cursor()
    p = {"tienda": tienda}
    cur.execute(SQL_KPI, p); actual, anterior = cur.fetchone()
    cur.execute(SQL_CATEGORIAS, p); categorias = [(c, float(a), float(b)) for c, a, b in cur.fetchall()]
    cur.execute(SQL_TOP, p); top = cur.fetchall()
    return float(actual or 0), float(anterior or 0), categorias, top


def euros(x):
    return f"{x:,.0f} €".replace(",", ".")


def variacion(actual, anterior):
    return (actual - anterior) / anterior * 100 if anterior else 0.0


# 2. Observaciones automáticas: lo que más sube y lo que más baja
def observaciones(categorias):
    cambios = [(c, variacion(a, b)) for c, a, b in categorias if b]
    if not cambios:
        return []
    sube = max(cambios, key=lambda x: x[1]); baja = min(cambios, key=lambda x: x[1])
    notas = [f"{sube[0]} es la categoría que más crece ({sube[1]:+.1f} %)."]
    if baja[1] < 0:
        notas.append(f"Atención a {baja[0]}: cae un {abs(baja[1]):.1f} % respecto a la semana anterior.")
    return notas


# 3. Gráfico de ventas por categoría
def grafico(categorias):
    fig, ax = plt.subplots(figsize=(7, 3.6), dpi=120)
    nombres = [c[0] for c in categorias][::-1]
    valores = [c[1] for c in categorias][::-1]
    ax.barh(nombres, valores, color="#2563eb")
    for i, v in enumerate(valores):
        ax.text(v, i, " " + euros(v), va="center", fontsize=9)
    ax.set_title("Ventas por categoría (últimos 7 días)", loc="left", fontsize=11)
    ax.spines[["top", "right"]].set_visible(False)
    ax.xaxis.set_visible(False)
    fig.tight_layout()
    buf = io.BytesIO(); fig.savefig(buf, format="png"); plt.close(fig)
    return buf.getvalue()


# 4. Excel con el detalle
def excel(categorias, top):
    wb = Workbook()
    ws = wb.active; ws.title = "Categorías"
    ws.append(["Categoría", "Esta semana (€)", "Semana anterior (€)", "Variación %"])
    for c, a, b in categorias:
        ws.append([c, a, b, round(variacion(a, b), 1)])
    ws2 = wb.create_sheet("Top productos")
    ws2.append(["Producto", "Unidades", "Importe (€)"]); [ws2.append([p, u, float(i)]) for p, u, i in top]
    buf = io.BytesIO(); wb.save(buf)
    return buf.getvalue()


# 5. Correo HTML con KPI, observaciones, gráfico y Excel adjunto
def correo(para, ambito, actual, anterior, categorias, top, alerta=False):
    var = variacion(actual, anterior)
    color = "#16a34a" if var >= 0 else "#dc2626"
    filas = "".join(f"<tr><td>{p}</td><td align='right'>{u}</td><td align='right'>{euros(float(i))}</td></tr>"
                    for p, u, i in top)
    notas = "".join(f"<li>{n}</li>" for n in observaciones(categorias))
    hoy = dt.date.today().strftime("%d/%m/%Y")
    msg = EmailMessage()
    prefijo = "⚠️ ALERTA: caída de ventas · " if alerta else "Informe semanal de ventas · "
    msg["Subject"] = f"{prefijo}{ambito} · {hoy} · {euros(actual)} ({var:+.1f} %)"
    msg["From"], msg["To"] = CFG["CORREO_DE"], para
    msg.set_content(f"Ventas últimos 7 días ({ambito}): {euros(actual)} ({var:+.1f} % vs semana anterior).")
    msg.add_alternative(f"""
<div style="font-family:Segoe UI,Arial;max-width:640px">
  <h2 style="margin:0">Informe semanal de ventas · {ambito}</h2><p style="color:#64748b;margin-top:4px">{hoy}</p>
  <p style="font-size:28px;margin:8px 0"><b>{euros(actual)}</b>
     <span style="color:{color};font-size:18px">{var:+.1f} % vs semana anterior</span></p>
  <ul style="background:#f8fafc;padding:10px 26px;border-radius:8px">{notas}</ul>
  <img src="cid:grafico" width="600">
  <h3>Top 5 productos</h3>
  <table cellpadding="6" style="border-collapse:collapse;width:100%">
    <tr style="background:#f1f5f9"><th align="left">Producto</th><th align="right">Uds.</th><th align="right">Importe</th></tr>{filas}
  </table>
  <p style="color:#64748b;font-size:12px">Generado automáticamente desde SQL Server. Detalle en el Excel adjunto.</p>
</div>""", subtype="html")
    msg.get_payload()[1].add_related(grafico(categorias), "image", "png", cid="<grafico>")
    msg.add_attachment(excel(categorias, top), maintype="application",
                       subtype="vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                       filename=f"ventas_{ambito.lower()}_{dt.date.today():%Y%m%d}.xlsx")
    return msg


def enviar(msg):
    with smtplib.SMTP(CFG["SMTP_SERVIDOR"], int(CFG["SMTP_PUERTO"])) as s:
        if CFG["SMTP_USUARIO"]:
            s.starttls(); s.login(CFG["SMTP_USUARIO"], CFG["SMTP_CLAVE"])
        s.send_message(msg)


# 6. Programa principal: general, por tienda o solo si hay alerta
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--por-tienda", action="store_true", help="Un informe por tienda a su responsable")
    ap.add_argument("--alerta", type=float, help="Enviar solo si las ventas caen este %% o más")
    a = ap.parse_args()
    with conectar() as con:
        if a.por_tienda:
            cur = con.cursor(); cur.execute(SQL_TIENDAS)
            ambitos = [(t, f"tienda.{t.lower()}@empresa.local") for (t,) in cur.fetchall()]
        else:
            ambitos = [(None, CFG["CORREO_PARA"])]
        for tienda, para in ambitos:
            actual, anterior, categorias, top = consultar(con, tienda)
            var = variacion(actual, anterior)
            nombre = tienda or "General"
            if a.alerta is not None and var > -a.alerta:
                print(f"{nombre}: {euros(actual)} ({var:+.1f} %) · sin alerta, no se envía")
                continue
            enviar(correo(para, nombre, actual, anterior, categorias, top, alerta=a.alerta is not None))
            print(f"{nombre}: {euros(actual)} ({var:+.1f} %) · enviado a {para}")


if __name__ == "__main__":
    try:
        main()
    except pymssql.Error as e:
        sys.exit(f"Error de SQL Server: {e}")
    except (smtplib.SMTPException, OSError) as e:
        sys.exit(f"Error al enviar el correo: {e}")
