/* ============================================================
   PROYECTO: Análisis de Ventas de un e-commerce argentino
   Autor: Tomás Zeitune
   Objetivo: aplicar los conceptos aprendidos en el curso de SQL
   sobre un caso realista de ventas online (clientes, productos,
   pedidos y detalle de pedidos).
   ============================================================ */


/* ------------------------------------------------------------
   1. CONSTRUCCIÓN DE LA BASE: tablas, tipos de dato,
      clave primaria y claves foráneas
   ------------------------------------------------------------ */

DROP TABLE IF EXISTS detalle_pedidos;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;

CREATE TABLE clientes (
    id_cliente     INTEGER PRIMARY KEY,
    nombre         TEXT NOT NULL,
    email          TEXT NOT NULL,
    provincia      TEXT NOT NULL,
    ciudad         TEXT NOT NULL,
    fecha_alta     DATE NOT NULL,
    segmento       TEXT NOT NULL           -- 'Particular' o 'Empresa'
);

CREATE TABLE productos (
    id_producto      INTEGER PRIMARY KEY,
    nombre_producto  TEXT NOT NULL,
    categoria        TEXT NOT NULL,
    precio_unitario  NUMERIC(10,2) NOT NULL,
    costo_unitario   NUMERIC(10,2) NOT NULL
);

CREATE TABLE pedidos (
    id_pedido      INTEGER PRIMARY KEY,
    id_cliente     INTEGER NOT NULL,
    fecha_pedido   DATE NOT NULL,
    canal          TEXT NOT NULL,          -- Sitio web / App móvil / Marketplace
    estado         TEXT NOT NULL,          -- Completado / Cancelado / Pendiente
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE detalle_pedidos (
    id_detalle              INTEGER PRIMARY KEY,
    id_pedido                INTEGER NOT NULL,
    id_producto               INTEGER NOT NULL,
    cantidad                  INTEGER NOT NULL,
    precio_unitario_venta     NUMERIC(10,2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- Carga de datos (INSERT): ver clientes.csv, productos.csv, pedidos.csv
-- y detalle_pedidos.csv adjuntos, generados para este proyecto.
-- Ejemplo de carga masiva en PostgreSQL:
-- \copy clientes FROM 'clientes.csv' DELIMITER ',' CSV HEADER;
-- \copy productos FROM 'productos.csv' DELIMITER ',' CSV HEADER;
-- \copy pedidos FROM 'pedidos.csv' DELIMITER ',' CSV HEADER;
-- \copy detalle_pedidos FROM 'detalle_pedidos.csv' DELIMITER ',' CSV HEADER;


/* ------------------------------------------------------------
   2. CONSULTAS BÁSICAS: SELECT, alias, DISTINCT, COUNT, LIMIT
   ------------------------------------------------------------ */

-- 2.1 Columnas puntuales con alias
SELECT
    nombre          AS cliente,
    provincia       AS provincia_cliente,
    segmento
FROM clientes;

-- 2.2 Valores únicos de una columna
SELECT DISTINCT provincia FROM clientes;

-- 2.3 Cantidad de pedidos cargados
SELECT COUNT(*) AS total_pedidos FROM pedidos;

-- 2.4 Los 10 pedidos más recientes
SELECT id_pedido, fecha_pedido, canal, estado
FROM pedidos
ORDER BY fecha_pedido DESC
LIMIT 10;


/* ------------------------------------------------------------
   3. FILTROS: WHERE, AND / OR, BETWEEN, LIKE, IN, IS NULL
   ------------------------------------------------------------ */

-- 3.1 Pedidos completados de un canal específico
SELECT *
FROM pedidos
WHERE estado = 'Completado' AND canal = 'Sitio web';

-- 3.2 Clientes de Buenos Aires o Córdoba
SELECT nombre, provincia
FROM clientes
WHERE provincia = 'Buenos Aires' OR provincia = 'Córdoba';

-- 3.3 Pedidos realizados en un rango de fechas (BETWEEN)
SELECT id_pedido, fecha_pedido, estado
FROM pedidos
WHERE fecha_pedido BETWEEN '2026-01-01' AND '2026-03-31';

-- 3.4 Productos cuyo nombre empieza con "Remera" (LIKE)
SELECT nombre_producto, categoria, precio_unitario
FROM productos
WHERE nombre_producto LIKE 'Remera%';

-- 3.5 Pedidos hechos por canales específicos (IN)
SELECT id_pedido, canal
FROM pedidos
WHERE canal IN ('App móvil', 'Marketplace');

-- 3.6 Chequeo de valores nulos (ejemplo de patrón, aunque en este
-- dataset no hay nulos porque los datos están curados)
SELECT *
FROM clientes
WHERE email IS NULL;


/* ------------------------------------------------------------
   4. AGRUPAR Y ORDENAR: agregación, GROUP BY, HAVING, ORDER BY
   ------------------------------------------------------------ */

-- 4.1 Ventas totales, ticket promedio y cantidad de pedidos por canal
SELECT
    p.canal,
    COUNT(DISTINCT p.id_pedido)                              AS cantidad_pedidos,
    SUM(d.cantidad * d.precio_unitario_venta)                AS ventas_totales,
    AVG(d.cantidad * d.precio_unitario_venta)                AS ticket_promedio,
    MAX(d.cantidad * d.precio_unitario_venta)                AS venta_maxima,
    MIN(d.cantidad * d.precio_unitario_venta)                AS venta_minima
FROM pedidos p
JOIN detalle_pedidos d ON d.id_pedido = p.id_pedido
WHERE p.estado = 'Completado'
GROUP BY p.canal
ORDER BY ventas_totales DESC;

-- 4.2 Provincias con más de 30 pedidos completados (HAVING filtra
-- sobre el grupo ya calculado, a diferencia de WHERE)
SELECT
    c.provincia,
    COUNT(DISTINCT p.id_pedido) AS cantidad_pedidos
FROM clientes c
JOIN pedidos p ON p.id_cliente = c.id_cliente
WHERE p.estado = 'Completado'
GROUP BY c.provincia
HAVING COUNT(DISTINCT p.id_pedido) > 30
ORDER BY cantidad_pedidos DESC;

-- Orden de ejecución de esta consulta:
-- FROM/JOIN -> WHERE -> GROUP BY -> HAVING -> ORDER BY -> LIMIT


/* ------------------------------------------------------------
   5. UNIR TABLAS: INNER JOIN, LEFT JOIN, UNION, subconsultas
   ------------------------------------------------------------ */

-- 5.1 INNER JOIN: ventas por categoría de producto
-- (solo trae categorías que efectivamente tuvieron ventas)
SELECT
    pr.categoria,
    SUM(d.cantidad * d.precio_unitario_venta) AS ventas_totales
FROM detalle_pedidos d
INNER JOIN productos pr ON pr.id_producto = d.id_producto
INNER JOIN pedidos pe ON pe.id_pedido = d.id_pedido
WHERE pe.estado = 'Completado'
GROUP BY pr.categoria
ORDER BY ventas_totales DESC;

-- 5.2 LEFT JOIN: todos los clientes, hayan comprado o no
-- (útil para detectar clientes inactivos)
SELECT
    c.id_cliente,
    c.nombre,
    COUNT(p.id_pedido) AS cantidad_pedidos
FROM clientes c
LEFT JOIN pedidos p ON p.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre
ORDER BY cantidad_pedidos ASC;

-- 5.3 UNION: apilar dos listas de "clientes a contactar"
-- (clientes sin compras + clientes con pedidos cancelados)
SELECT c.id_cliente, c.nombre, 'Sin compras' AS motivo
FROM clientes c
LEFT JOIN pedidos p ON p.id_cliente = c.id_cliente
WHERE p.id_pedido IS NULL

UNION

SELECT c.id_cliente, c.nombre, 'Tuvo un pedido cancelado' AS motivo
FROM clientes c
JOIN pedidos p ON p.id_cliente = c.id_cliente
WHERE p.estado = 'Cancelado';

-- 5.4 Subconsulta: clientes cuyo ticket promedio supera el
-- ticket promedio general de la tienda
SELECT nombre, ticket_promedio_cliente
FROM (
    SELECT
        c.nombre,
        AVG(d.cantidad * d.precio_unitario_venta) AS ticket_promedio_cliente
    FROM clientes c
    JOIN pedidos p ON p.id_cliente = c.id_cliente
    JOIN detalle_pedidos d ON d.id_pedido = p.id_pedido
    WHERE p.estado = 'Completado'
    GROUP BY c.nombre
) AS tickets_por_cliente
WHERE ticket_promedio_cliente > (
    SELECT AVG(d.cantidad * d.precio_unitario_venta)
    FROM detalle_pedidos d
    JOIN pedidos p ON p.id_pedido = d.id_pedido
    WHERE p.estado = 'Completado'
)
ORDER BY ticket_promedio_cliente DESC;

/* ============================================================
   FIN DEL SCRIPT
   Este mismo dataset (clientes.csv, productos.csv, pedidos.csv,
   detalle_pedidos.csv) se conecta luego en Power BI vía Power
   Query para construir el modelo y el dashboard del proyecto.
   ============================================================ */
