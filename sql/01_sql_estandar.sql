/* =========================================
PARTE 2 · SQL ESTÁNDAR

Suponemos que tenemos las siguientes tablas:
   
   Tablas:
     Arrendatario (RUT, Nombre, Apellido)
     Arrienda     (RUT, Id_casa, Deuda)  -- Deuda >= 0
     Teléfonos    (RUT, Telefono)
     Dueño        (RUT, Nombre, Apellido)
     Casa         (Id_casa, RUT, Nro, Calle, Comuna) -- RUT = dueño
   ========================================= */

/* 1) Arrendatarios que arriendan la casa en calle Carrera nº 1024, Santiago */
SELECT at.RUT, at.Nombre, at.Apellido
FROM Casa AS c
JOIN Arrienda AS ar ON ar.Id_casa = c.Id_casa
JOIN Arrendatario at ON at.RUT = ar.RUT
WHERE c.Calle = 'Carrera'
  AND c.Nro   = 1024
  AND c.Comuna = 'Santiago';

/* 2) ¿Cuánto le deben a María Pérez? (solo deudas > 0) */
SELECT COALESCE(SUM(ar.Deuda), 0) AS deuda_total
FROM Dueño AS d
JOIN Casa AS c      ON c.RUT = d.RUT
JOIN Arrienda AS ar ON ar.Id_casa = c.Id_casa
WHERE d.Nombre = 'María' AND d.Apellido = 'Pérez'
  AND ar.Deuda > 0;

/* 3) Deuda total para cada dueño (incluye dueños sin deuda) */
SELECT d.RUT, d.Nombre, d.Apellido,
       COALESCE(SUM(CASE WHEN ar.Deuda > 0 THEN ar.Deuda ELSE 0 END), 0) AS deuda_total
FROM Dueño AS d
LEFT JOIN Casa AS c      ON c.RUT = d.RUT
LEFT JOIN Arrienda AS ar ON ar.Id_casa = c.Id_casa
GROUP BY d.RUT, d.Nombre, d.Apellido
ORDER BY deuda_total DESC;

/* 4) Liste todas las personas de la base (dueños ∪ arrendatarios, sin duplicados) */
SELECT RUT, Nombre, Apellido FROM Arrendatario
UNION
SELECT RUT, Nombre, Apellido FROM Dueño;

/* 5) Dueños que poseen tres o más casas */
SELECT d.RUT, d.Nombre, d.Apellido, COUNT(DISTINCT c.Id_casa) AS casas
FROM Dueño AS d
JOIN Casa AS c ON c.RUT = d.RUT
GROUP BY d.RUT, d.Nombre, d.Apellido
HAVING COUNT(DISTINCT c.Id_casa) >= 3;

/* 6) Dueños que tengan deudores en TODAS sus casas (cada casa del dueño tiene al menos un arriendo con Deuda > 0) */
SELECT d.RUT, d.Nombre, d.Apellido
FROM Dueño AS d
JOIN Casa AS c       ON c.RUT = d.RUT
LEFT JOIN Arrienda AS ar ON ar.Id_casa = c.Id_casa
GROUP BY d.RUT, d.Nombre, d.Apellido
HAVING COUNT(DISTINCT c.Id_casa) > 0
   AND COUNT(DISTINCT CASE WHEN ar.Deuda > 0 THEN c.Id_casa END)
       = COUNT(DISTINCT c.Id_casa);

/* 7) Estadísticas sobre # de arrendatarios por casa (promedio, varianza muestral, máximo, mínimo, moda, mediana)

   Usamos CTE para "una tabla virtual" y poder tener el número de arrendatarios por casa (distintos RUT).
*/
WITH cnt AS (
  SELECT a.Id_casa, COUNT(DISTINCT a.RUT) AS arrs
  FROM Arrienda a
  GROUP BY a.Id_casa
)
-- 7A) Versión con agregados estándar
SELECT
  AVG(arrs) AS promedio,
  VAR_SAMP(arrs) AS varianza,
  MAX(arrs) AS maximo,
  MIN(arrs) AS minimo,
  -- moda: valor de arrs con mayor frecuencia
  (SELECT arrs
   FROM (
     SELECT arrs, COUNT(*) AS freq,
            ROW_NUMBER() OVER(ORDER BY COUNT(*) DESC, arrs) AS rn
     FROM cnt
     GROUP BY arrs
   ) AS m
   WHERE rn = 1) AS moda,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY arrs) AS mediana
FROM cnt;
