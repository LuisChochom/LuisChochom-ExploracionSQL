# SQL Queries - Chinook Database (PostgreSQL)

Consultas sobre la base de datos **Chinook**, desarrolladas en **PostgreSQL** para demostrar distintas técnicas de query SQL sobre tablas como `customer` y `track`.

## Resumen de consultas

| # | Tema | Qué realiza |
|---|------|-------------|
| 1 | Directorio de clientes | Lista nombre, email y empresa (con `COALESCE`) de todos los clientes. |
| 2 | Distribución geográfica | Cuenta clientes agrupados por país con `GROUP BY`. |
| 3 | Filtrado de pistas | Usa una CTE para encontrar canciones largas (>5 min) y caras (> $0.99). |
| 4 | Condiciones AND/OR | Filtra clientes de Brasil o de USA con email de Yahoo (lógica booleana). |
| 5 | `IN` geográfico | Lista clientes de Alemania, Francia o España con `IN`. |
| 6 | Rango de tiempo | Extrae canciones entre 3 y 4 min usando `BETWEEN` y formatea con `TO_CHAR`. |
| 7 | `LIKE` vs `ILIKE` | Compara coincidencias sensibles e insensibles a mayúsculas en nombres de pistas. |
| 8 | Lógica NULL | Identifica clientes sin empresa (`IS NULL`) y con fax (`IS NOT NULL`). |
| 9 | Top 10 | Lista las 10 canciones más largas con `ORDER BY` y `LIMIT`. |
| 10 | Paginación | divide clientes en bloques de 5 registros usando `LIMIT`/`OFFSET`. |

Archivo: `QuerysChinook.sql`