# Análisis de Ventas de un E-commerce — SQL + Power BI

Proyecto de portfolio que aplica modelado relacional, consultas SQL y un
dashboard interactivo en Power BI sobre un caso simulado de e-commerce
argentino, con 4 categorías de productos y 3 canales de venta.

## Dashboard

![Dashboard](dashboard_recortado.webp)

## Modelo de datos

4 tablas relacionadas por claves primarias/foráneas:
- **clientes** — provincia, ciudad, segmento, fecha de alta
- **productos** — categoría, precio y costo unitario
- **pedidos** — fecha, canal, estado
- **detalle_pedidos** — línea a línea de cada pedido

## Habilidades demostradas

**SQL:** CREATE TABLE, claves primarias/foráneas, SELECT, WHERE (AND/OR,
BETWEEN, LIKE, IN, IS NULL), GROUP BY/HAVING, INNER/LEFT JOIN, UNION,
subconsultas.

**Power BI:** Power Query, modelado de datos, medidas DAX (CALCULATE,
comparación año contra año, acumulado YTD), segmentadores y visualizaciones
interactivas.

## Archivos del repositorio

- `proyecto_ventas.sql` — esquema y 14 consultas SQL
- `medidas_dax.txt` — medidas DAX del modelo
- `clientes.csv`, `productos.csv`, `pedidos.csv`, `detalle_pedidos.csv` — dataset
- `*.pbix` — archivo de Power BI con el modelo y el dashboard completos

## Autor

Tomás Zeitune — [LinkedIn](tu-link-de-linkedin-acá)
