--Queries auxiliares

SELECT 
    object_name(cols.object_id) tabla
    ,cols.name columna
    ,ind.name indice
    ,ind.type_desc tipo
    ,ind.is_unique 
    FROM 
    sys.columns cols, sys.indexes ind , sys.index_columns ind_cols
    where 
    cols.object_id = ind.object_id
    and cols.object_id = ind_cols.object_id
    and cols.column_id = ind_cols.column_id
    and ind.index_id = ind_cols.index_id
    and object_name(cols.object_id) LIKE 'SalesOrderDetail'
    order by object_name(cols.object_id), ind.name;


SELECT TABLE_NAME, COLUMN_NAME, IS_NULLABLE, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'WorkOrder';


----------------------------------


-- Consulta A

SELECT * 

FROM Sales.SalesOrderDetail d

JOIN Production.Product p 

  ON d.ProductID = p.ProductID

WHERE p.ProductID = 870;


-- Consulta B

SELECT * 

FROM Sales.SalesOrderDetail d

JOIN Production.Product p 

  ON d.ProductID = p.ProductID

WHERE p.Color = 'Black';