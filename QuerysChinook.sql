/*
================================================================================
 MÓDULO DE CONSULTAS
 PROYECTO   : Chinook Database 
 MOTOR DBMS : PostgreSQL
 AUTOR      : Luis Chochom  2890 - 13 - 11600
================================================================================
*/


-- ============================================================================
-- 1. DIRECTORIO Y DATOS DE CONTACTO DE CLIENTES
-- Objetivo: Proyectar el listado nominal y de localización de los clientes.
-- ============================================================================
SELECT 
    c.customer_id AS id_cliente,
    c.first_name || ' ' || c.last_name AS nombre_completo,
    c.email AS correo_electronico,
    COALESCE(c.company, 'Particular') AS empresa
FROM customer c
ORDER BY c.customer_id ASC;

/*
  Notas técnicas:
  - Se utiliza la concatenación explícita (||) para consolidar el nombre del cliente.
  - Se implementa COALESCE para el manejo de valores nulos en la razón social.
*/


-- ============================================================================
-- 2. DIVERSIFICACIÓN GEOGRÁFICA (PAÍSES UNICOS)
-- Objetivo: Determinar la presencia territorial del catálogo de usuarios.
-- ============================================================================
SELECT 
    c.country AS pais_residencia,
    COUNT(c.customer_id) AS total_clientes_registrados
FROM customer c
GROUP BY c.country
ORDER BY pais_residencia ASC;

/*
  Notas técnicas:
  - A diferencia de un DISTINCT simple, GROUP BY con agregación ofrece mayor contexto 
    de la distribución de la muestra por país además de omitir duplicados.
*/


-- ============================================================================
-- 3. FILTRADO DE MÉTRICAS OPERATIVAS EN PISTAS (PRECIO Y DURACIÓN)
-- Objetivo: Identificar el inventario de audio de alta duración y costo extendido.
-- Umbrales: Duración > 300,000 ms (5 min), Precio > $0.99.
-- ============================================================================
WITH pistas_premium AS (
    SELECT 
        track_id,
        name AS titulo_cancion,
        ROUND(milliseconds / 60000.0, 2) AS duracion_minutos,
        unit_price AS precio_unitario
    FROM track
    WHERE unit_price > 0.99
)
SELECT 
    track_id,
    titulo_cancion,
    duracion_minutos,
    precio_unitario
FROM pistas_premium
WHERE duracion_minutos > 5.00
ORDER BY duracion_minutos DESC;

/*
  Notas técnicas:
  - Se emplea una CTE (Common Table Expression) para transformar milisegundos a minutos 
    antes de aplicar la restricción final, mejorando la interpretabilidad de la métrica.
*/


-- ============================================================================
-- 4. CRITERIOS SEGMENTADOS CON EVALUACIÓN LÓGICA (AND / OR)
-- Objetivo: Recuperar clientes de Brasil o clientes en USA con dominio Yahoo.
-- ============================================================================
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.country,
    c.email
FROM customer c
WHERE c.country = 'Brazil'
   OR (c.country = 'USA' AND LOWER(c.email) LIKE '%@yahoo.%')
ORDER BY c.country, c.last_name;

/*
  Análisis de Álgebra Booleana:
  - La expresión evaluada es: P OR (Q AND R).
  - La precedencia exige paréntesis en (Q AND R) para evitar que el operador AND 
    absorba la condición de Brasil y condicione la totalidad de los registros al dominio Yahoo.
*/


-- ============================================================================
-- 5. PERTENENCIA DE DOMINIO GEOGRÁFICO EN UNIÓN EUROPEA
-- Objetivo: Auditar usuarios ubicados en Alemania, Francia o España.
-- ============================================================================
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS cliente,
    c.country AS pais,
    c.city AS ciudad
FROM customer c
WHERE c.country IN ('Germany', 'France', 'Spain')
ORDER BY c.country ASC, c.city ASC;

/*
  Notas técnicas:
  - Sintaxis declarativa mediante operador IN, equivalente a la unión disyuntiva 
    (country = 'Germany' OR country = 'France' OR country = 'Spain').
*/


-- ============================================================================
-- 6. ACOTACIÓN DE RANGOS CONTINUOS DE TIEMPO
-- Objetivo: Extraer canciones con duración en el intervalo [3 min, 4 min].
-- Limites en ms: [180,000 ms , 240,000 ms].
-- ============================================================================
SELECT 
    t.track_id,
    t.name AS nombre_pista,
    t.milliseconds AS duracion_ms,
    TO_CHAR(INTERVAL '1 millisecond' * t.milliseconds, 'MI:SS') AS formato_tiempo
FROM track t
WHERE t.milliseconds BETWEEN 180000 AND 240000
ORDER BY t.milliseconds ASC;

/*
  Notas técnicas:
  - BETWEEN define un rango inclusivo cerrado [A, B]. 
  - Se añade un formateo de tiempo dinámico con la función TO_CHAR para salida MI:SS.
*/


-- ============================================================================
-- 7. BÚSQUEDA DE PATRONES DE TEXTO Y SENSIBILIDAD DE CAJA
-- Objetivo: Comparar la evaluación de coincidencias usando LIKE vs ILIKE.
-- ============================================================================

-- Búsqueda Case-Sensitive (Estricta):
SELECT track_id, name 
FROM track 
WHERE name LIKE '%Love%'
ORDER BY track_id;

-- Búsqueda Case-Insensitive (Agnóstica a mayúsculas/minúsculas):
SELECT track_id, name 
FROM track 
WHERE name ILIKE '%Love%'
ORDER BY track_id;

/*
  Diferencia Técnica en PostgreSQL:
  - LIKE evalúa coincidencia exacta según el collation de la base de datos (sensible a caja).
  - ILIKE es una extensión del estándar SQL en PostgreSQL que fuerza la conversión
    a minúsculas antes de la comparación (equivalente a WHERE LOWER(name) LIKE '%love%').
*/


-- ============================================================================
-- 8. TRATAMIENTO DE VALORES TRI-VALUADOS (LOGICA LÓGICA NULL)
-- Objetivo: Identificar registros con ausencia y presencia de metadatos opcionales.
-- ============================================================================

-- Consulta 8.1: Clientes sin entidad corporativa asociada
SELECT customer_id, first_name, last_name, company
FROM customer
WHERE company IS NULL;

-- Consulta 8.2: Clientes con línea de telefacsímil (Fax) habilitada
SELECT customer_id, first_name, last_name, fax
FROM customer
WHERE fax IS NOT NULL;

/*
  Fundamento Teórico:
  En lógica de tres valores (SQL 3VL: TRUE, FALSE, UNKNOWN), las comparaciones con NULL 
  utilizando operadores relacionales (=, !=) retornan UNKNOWN. Por ello, es mandatorio 
  el uso de los predicados unarios 'IS NULL' e 'IS NOT NULL'.
*/


-- ============================================================================
-- 9. RANKING TOP N MEDIANTE ORDENAMIENTO DETERMINISTA
-- Objetivo: Listar las 10 canciones de mayor extensión temporal.
-- ============================================================================
SELECT 
    t.track_id,
    t.name AS cancion,
    t.milliseconds AS duracion_ms,
    ROUND(t.milliseconds / 60000.0, 2) AS duracion_min
FROM track t
ORDER BY t.milliseconds DESC, t.track_id ASC
LIMIT 10;

/*
  Notas técnicas:
  - Se añade 'track_id ASC' como clave de ordenamiento secundaria para garantizar 
    un comportamiento determinista si existen colisiones de duración en el top.
*/


-- ============================================================================
-- 10. PAGINACIÓN DE RESULTADOS CON FUNCIONES DE VENTANA Y LIMIT/OFFSET
-- Objetivo: Dividir la entidad customer en bloques continuos de 5 registros.
-- ============================================================================

-- Bloque 1: Registro 1 al 5 (Página 1)
SELECT 
    customer_id, 
    first_name || ' ' || last_name AS nombre_cliente,
    email
FROM customer
ORDER BY customer_id ASC
LIMIT 5 OFFSET 0;

-- Bloque 2: Registro 6 al 10 (Página 2)
SELECT 
    customer_id, 
    first_name || ' ' || last_name AS nombre_cliente,
    email
FROM customer
ORDER BY customer_id ASC
LIMIT 5 OFFSET 5;

/*
  Mapeo Arquitectural de Paginación:
  - Fórmula del OFFSET: OFFSET = (Número_Página - 1) * Registros_Por_Página.
  - Para Página 1: (1 - 1) * 5 = 0
  - Para Página 2: (2 - 1) * 5 = 5
*/