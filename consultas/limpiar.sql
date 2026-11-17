CREATE OR REPLACE TABLE rechazados_limpios AS
SELECT 
    id_empleado,
    TRIM(nombre) AS nombre,
    TRIM(apellido) AS apellido,
    COALESCE(
        CASE WHEN email LIKE '%@%.%' THEN TRIM(email) ELSE NULL END,
        LOWER(TRIM(nombre)) || '.' || LOWER(TRIM(apellido)) || CAST(CAST(SUBSTR(id_empleado, 4) AS INT) AS VARCHAR) || '@tecnosur.com'
    ) AS email,
    CAST(
        CASE 
            WHEN TRY_STRPTIME(fecha_ingreso, '%Y-%m-%d') IS NOT NULL THEN fecha_ingreso
            ELSE STRFTIME(STRPTIME(fecha_ingreso, '%d/%m/%Y'), '%Y-%m-%d')
        END AS VARCHAR
    ) AS fecha_ingreso,
    COALESCE(
        CASE WHEN departamento IN ('Tecnologia', 'Finanzas', 'RRHH', 'Comercial') THEN departamento ELSE NULL END,
        CASE 
            WHEN cargo IN ('Analista de datos', 'Desarrollador', 'Soporte tecnico') THEN 'Tecnologia'
            WHEN cargo IN ('Contador', 'Tesorero') THEN 'Finanzas'
            WHEN cargo IN ('Generalista', 'Reclutador') THEN 'RRHH'
            WHEN cargo IN ('Ejecutivo de cuentas', 'Vendedor') THEN 'Comercial'
        END
    ) AS departamento,
    cargo,
    ABS(salario) AS salario,
    LOWER(TRIM(modalidad)) AS modalidad
FROM rechazados
WHERE motivo_rechazo <> 'id_duplicado';
