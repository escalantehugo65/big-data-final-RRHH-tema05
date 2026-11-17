CREATE OR REPLACE TABLE rrhh_raw AS SELECT * FROM raw_rrhh;
CREATE OR REPLACE TABLE raw_empleados AS SELECT * FROM raw_rrhh;

CREATE OR REPLACE TABLE evaluacion_reglas AS
WITH conteo_duplicados AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER (PARTITION BY id_empleado ORDER BY rowid) AS rn_id
    FROM raw_rrhh
)
SELECT 
    id_empleado, 
    nombre, 
    apellido, 
    email, 
    fecha_ingreso, 
    departamento, 
    cargo, 
    salario, 
    modalidad,
    CASE 
        WHEN id_empleado IS NULL OR TRIM(id_empleado) = '' THEN 'id_nulo'
        WHEN rn_id > 1 THEN 'id_duplicado'
        WHEN nombre IS NULL OR TRIM(nombre) = '' THEN 'nombre_incompleto'
        WHEN apellido IS NULL OR TRIM(apellido) = '' THEN 'apellido_incompleto'
        WHEN email IS NULL OR TRIM(email) = '' OR email NOT LIKE '%@%.%' THEN 'email_invalido'
        WHEN departamento IS NULL OR TRIM(departamento) = '' OR departamento NOT IN ('Tecnologia', 'Finanzas', 'RRHH', 'Comercial') THEN 'departamento_invalido'
        WHEN cargo IS NULL OR TRIM(cargo) = '' THEN 'cargo_invalido'
        WHEN salario IS NULL OR salario <= 0 THEN 'salario_invalido'
        WHEN fecha_ingreso IS NULL OR TRY_STRPTIME(fecha_ingreso, '%Y-%m-%d') IS NULL THEN 'fecha_invalida'
        WHEN modalidad IS NULL OR LOWER(TRIM(modalidad)) NOT IN ('presencial', 'remoto', 'hibrido') THEN 'modalidad_invalida'
        ELSE NULL
    END AS motivo_rechazo
FROM conteo_duplicados;

CREATE OR REPLACE TABLE rechazados AS
SELECT 
    id_empleado, 
    nombre, 
    apellido, 
    email, 
    fecha_ingreso, 
    departamento, 
    cargo, 
    salario, 
    modalidad, 
    motivo_rechazo
FROM evaluacion_reglas
WHERE motivo_rechazo IS NOT NULL;

CREATE OR REPLACE TABLE validos AS
SELECT 
    id_empleado, 
    nombre, 
    apellido, 
    email, 
    fecha_ingreso, 
    departamento, 
    cargo, 
    salario, 
    modalidad
FROM evaluacion_reglas
WHERE motivo_rechazo IS NULL;

CREATE OR REPLACE TABLE "válidos" AS
SELECT * FROM validos;
