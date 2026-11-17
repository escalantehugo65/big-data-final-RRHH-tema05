CREATE OR REPLACE TABLE tabla_final AS
WITH union_total AS (
    SELECT 
        id_empleado,
        TRIM(nombre) AS nombre,
        TRIM(apellido) AS apellido,
        TRIM(email) AS email,
        CAST(fecha_ingreso AS DATE) AS fecha_ingreso,
        departamento,
        cargo,
        CAST(salario AS DOUBLE) AS salario,
        LOWER(TRIM(modalidad)) AS modalidad
    FROM validos

    UNION ALL

    SELECT 
        id_empleado,
        nombre,
        apellido,
        email,
        CAST(fecha_ingreso AS DATE) AS fecha_ingreso,
        departamento,
        cargo,
        CAST(salario AS DOUBLE) AS salario,
        modalidad
    FROM rechazados_limpios
)
SELECT DISTINCT * FROM union_total;


-- Se detiene la ejecuión si pasan datos inválidos

SELECT CASE WHEN COUNT(*) = 0 THEN true
    ELSE error('tabla_final contiene registros inválidos; revisar la limpieza') END
FROM tabla_final
WHERE id_empleado IS NULL OR TRIM(id_empleado) = ''
   OR nombre IS NULL OR TRIM(nombre) = ''
   OR apellido IS NULL OR TRIM(apellido) = ''
   OR email IS NULL OR email NOT LIKE '%@%.%'
   OR departamento IS NULL OR departamento NOT IN ('Tecnologia', 'Finanzas', 'RRHH', 'Comercial')
   OR cargo IS NULL OR TRIM(cargo) = ''
   OR salario IS NULL OR salario <= 0
   OR fecha_ingreso IS NULL
   OR modalidad IS NULL OR modalidad NOT IN ('presencial', 'remoto', 'hibrido');

SELECT CASE WHEN COUNT(*) = COUNT(DISTINCT id_empleado) THEN true
    ELSE error('tabla_final contiene identificadores repetidos') END
FROM tabla_final;
