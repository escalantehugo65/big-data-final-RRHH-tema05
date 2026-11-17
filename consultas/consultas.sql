SELECT
    departamento, 
    ROUND(AVG(salario), 2) AS salario_promedio
FROM tabla_final 
GROUP BY departamento 
ORDER BY salario_promedio DESC;

SELECT 
    ROUND(SUM(salario), 2) AS masa_salarial_total
FROM tabla_final;

SELECT 
    modalidad, 
    COUNT(*) AS cantidad_empleados
FROM tabla_final 
GROUP BY modalidad 
ORDER BY cantidad_empleados DESC;

SELECT 
    EXTRACT(YEAR FROM fecha_ingreso) AS anio,
    COUNT(*) AS cantidad_ingresos
FROM tabla_final 
GROUP BY anio 
ORDER BY anio ASC;

SELECT 
    cargo, 
    ROUND(AVG(salario), 2) AS salario_promedio
FROM tabla_final 
GROUP BY cargo 
ORDER BY salario_promedio DESC 
LIMIT 3;
