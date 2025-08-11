## 1) Explique la función NVL. ¿Es mejor usar un NVL que un Case When? Explique su respuesta.
**Se puede resumir en como si tuvieramos un plan B.**
Si un dato viene vacío (NULL), NVL pone un valor por defecto.

Ejemplo de negocio: si el bono de un vendedor viene vacío, tráelo como 0 para no inflar comisiones.

Traducción: “Si hay dato, úsalo; si no hay, usa este otro”.

¿Cuándo usarlo?: Cuando solo necesitas un reemplazo simple (ej. “si está vacío, pon 0”).

Si la lógica tiene varios casos (“si es A haz esto, si es B aquello…”), es mejor un CASE (que es como un “si… entonces…” de varios niveles).

COALESCE es como un NVL múltiple: prueba varias columnas y usa la primera que tenga valor.

Ejemplo sencillo: “Si el descuento no viene, asúmelo en 0%”.

## 2) Explique la función Left Join. En que casos es mas relevante usar un Left Join, en vez de un Inner Join.
Devuelve todas las filas de la tabla izquierda y las coincidentes de la derecha; cuando no hay match, las columnas derechas vienen NULL.

**INNER JOIN** = solo los que aparecen en ambas listas (clientes que sí compraron).
**LEFT JOIN** = todos los de A, y si compró, traes sus compras; si no, lo ves con espacios en blanco.

¿Cuándo usar cada uno?

    - INNER: cuando te interesan solo los que cumplen la condición (p. ej., “ventas del mes”).

    - LEFT: cuando quieres mantener el universo completo (p. ej., “todos los clientes, compren o no”) para detectar huecos o oportunidades.


## 3) Explique la función row_number() Over (Partition by … Order by…). Danos un ejemplo en el cual es funcional esta función.
Asigna un índice incremental por partición en el orden indicado.

Se puede visualizar como un ranking por cliente: primera compra = 1, segunda = 2, etc.

Es muy útil para quedarte con una sola fila representativa por grupo (último, primero, top, etc.).

**Caso típico**: quedarte con el último registro por grupo.

```sql
SELECT *
FROM (
  SELECT a.*,
         ROW_NUMBER() OVER(
           PARTITION BY a.RUT
           ORDER BY a.FechaAlta DESC
         ) AS rn
  FROM Arrendatario a
)
WHERE rn = 1;
```

## 4) Explique que es un Cursor y cuando son Implícitos y Explícitos.

Un cursor es como un lector fila por fila de una tabla.

    - Implícito: Oracle lo maneja solo cuando haces cosas simples (insertar, actualizar o leer una fila). Tú no ves el cursor.

    - Explícito: cuando quieres recorrer muchas filas y hacer algo por cada una (p. ej., enviar un correo o acumular un cálculo por registro). Ahí sí abres el cursor, lees fila por fila y cierras.

Ejemplo de negocio:

“Para cada cliente con deuda, genera una notificación personalizada”.
Eso es típico de un cursor explícito: iterar clientes y ejecutar una acción por cada uno.

```plsql
DECLARE
  CURSOR c_deuda IS
    SELECT d.RUT, SUM(a.Deuda) deuda
    FROM Dueño d
    JOIN Casa c ON c.RUT = d.RUT
    JOIN Arrienda a ON a.Id_casa = c.Id_casa
    GROUP BY d.RUT;
  v_rut Dueño.RUT%TYPE; v_deuda NUMBER;
BEGIN
  OPEN c_deuda;
  LOOP
    FETCH c_deuda INTO v_rut, v_deuda;
    EXIT WHEN c_deuda%NOTFOUND;
    -- procesar fila...
  END LOOP;
  CLOSE c_deuda;
END;
/
```

Con FOR cursor_loop Oracle hace el OPEN/FETCH/CLOSE por ti.

## 5) ¿Crees que desde Oracle puedes crear una ETL y que sea funcional? Justifica tu respuesta.
Sí. Hay herramientas con mejor especialidad para esto, pero sí se puede hacer:

    - Entrar los datos (archivos, BD, conexiones, csv o cualquier tipo de data).

    - Transformarlos (limpiar, deduplicar, unir, calcular, todo en SQL pero dentro de Oracle).

    - Programar que corra por ejemplo cada noche con alertas (jobs con alerta en fallo).

¿Cuándo conviene?: 
    - Cuando la fuente y el destino están en Oracle y necesitas velocidad y control (todo ocurre dentro del motor, menos tráfico de datos).

    - Cuando quieres pocas piezas: una BD que ingiere, transforma y sirve.

¿Cuándo NO conviene?

- Cuando necesitas muchos conectores (APIs, otros clouds, otras BD), versionar pipelines, o orquestar varios sistemas; ahí es mejor sumarle una herramienta externa (Airflow, etc.).


