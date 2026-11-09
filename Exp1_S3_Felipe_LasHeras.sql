SET VERIFY OFF;

/* =====================================================================
   CASO 1: ANALISIS DE PROPIEDAD
   ===================================================================== */
SELECT UPPER(p.id_tipo_propiedad)                          AS "TIPO",
       COUNT(p.nro_propiedad)                              AS "TOTAL_PROPIEDADES",
       TO_CHAR(MAX(p.valor_arriendo), '$9G999G999')        AS "MAX_ARRIENDO",
       TO_CHAR(ROUND(AVG(p.valor_arriendo)), '$9G999G999') AS "PROMEDIO_ARRIENDO",
       TO_CHAR(MIN(p.valor_arriendo), '$9G999G999')        AS "MIN_ARRIENDO",
       CASE
           WHEN MAX(p.valor_arriendo) <= 1000000 THEN 'ESTÁNDAR'
           ELSE 'PREMIUM'
       END                                                 AS "CLASIFICACION",
       TO_CHAR(SUM(NVL(p.valor_gasto_comun, 0)), '$9G999G999') AS "TOTAL_GASTOS_COMUNES"
FROM propiedad p
GROUP BY p.id_tipo_propiedad
HAVING SUM(NVL(p.valor_gasto_comun, 0)) > &VALOR_TOTAL_GASTO_COMUN
ORDER BY SUM(NVL(p.valor_gasto_comun, 0)) DESC;
/* =====================================================================
   CASO 2: ANÁLISIS DE ANTIGÜEDAD DE EMPLEADOS
   ===================================================================== */
SELECT UPPER(e.nombre_emp || ' ' || e.appaterno_emp)           AS "Nombre Empleado",
       TO_CHAR(NVL(e.sueldo_emp, 0), '$9G999G999')             AS "Sueldo con Formato",
       CASE
           WHEN NVL(e.sueldo_emp, 0) > 2000000 THEN 'ALTO'
           ELSE 'MEDIO'
       END                                                     AS "Clasificación Sueldo",
       TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12)       AS "Años Antigüedad",
       'Corresponde bono '
       || CASE
              WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12) <= 10 THEN ' 5%: '
              WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12) <= 20 THEN '10%: '
              ELSE '15%: '
          END
       || TO_CHAR(ROUND(NVL(e.sueldo_emp, 0) *
              CASE
                  WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12) <= 10 THEN 0.05
                  WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12) <= 20 THEN 0.10
                  ELSE 0.15
              END), '$9G999G999')                              AS "BONO"
FROM empleado e
WHERE e.id_categoria_emp = 3
  AND e.id_sucursal <> &CODIGO_SUCURSAL
  AND TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12) > 5
ORDER BY e.sueldo_emp DESC;

/* =====================================================================
   CASO 3: LISTA DE CLIENTES
   ===================================================================== */

SELECT CASE
           WHEN NVL(c.renta_cli, 0) >= 1000000 THEN 'PREMIUM'
           WHEN NVL(c.renta_cli, 0) >= 600000  THEN 'ALTA'
           WHEN NVL(c.renta_cli, 0) >= 300000  THEN 'MEDIA'
           ELSE 'BAJA'
       END                                                  AS "CLASIFICACION_RENTA",
       COUNT(c.numrut_cli)                                  AS "CANTIDAD_CLIENTES",
       TO_CHAR(ROUND(AVG(NVL(c.renta_cli, 0))), '$9G999G999') AS "RENTA_PROMEDIO",
       -- NVL2 entrega 1 si el cliente tiene celular y 0 si es nulo
       CASE
           WHEN SUM(NVL2(c.celular_cli, 1, 0)) = 0 THEN 'Clientes Sin Teléfono'
           ELSE 'Clientes con Teléfono'
       END                                                  AS "ESTADO_TELEFONO"
FROM cliente c
GROUP BY CASE
             WHEN NVL(c.renta_cli, 0) >= 1000000 THEN 'PREMIUM'
             WHEN NVL(c.renta_cli, 0) >= 600000  THEN 'ALTA'
             WHEN NVL(c.renta_cli, 0) >= 300000  THEN 'MEDIA'
             ELSE 'BAJA'
         END
HAVING AVG(NVL(c.renta_cli, 0)) > 200000
ORDER BY AVG(NVL(c.renta_cli, 0)) DESC;