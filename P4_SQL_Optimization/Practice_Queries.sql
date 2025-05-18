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
    and object_name(cols.object_id) LIKE 'WorkOrder'
    order by object_name(cols.object_id), ind.name;


SELECT TABLE_NAME, COLUMN_NAME, IS_NULLABLE, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'WorkOrder';

-- Convenciones de nomenclatura de índice de SQL Server
-- clustered ordenado, unclustered desordenado en relacion a la pagina (cada id puede estar en distintas paginas)
-- • PK_ Primary Key, clustered
-- • AK_ unclestered, unique
-- • IX_ unclestered, no unique

-- Comandos

-- Ctrl + M  hace la consulta y dice el plan que ejecutó

-- O

-- View > Command Palette > Run current query with actual plan



--consulta 1
select NationalIDNumber, HireDate from HumanResources.Employee 
where NationalIDNumber='121491555';

select NationalIDNumber, BusinessEntityID from HumanResources.Employee 
where NationalIDNumber= '121491555';

-- respuesta: uno es parte del indice otro no

--consulta 2

select NationalIDNumber, BusinessEntityID from HumanResources.Employee 
where NationalIDNumber= '121491555';

select NationalIDNumber, BusinessEntityID from HumanResources.Employee 
where NationalIDNumber= 121491555;

-- castea cada uno de los entries de la tabla al int y compara contra el valor pasado => muy costoso

--consulta 3

select count(UnitPrice) from sales.SalesOrderDetail;

select count(CarrierTrackingNumber) from sales.SalesOrderDetail;

-- no nulleable => contar campos no nulleables, cuento todos los registros
-- los nulls tambien son parte de los indices
-- si es nulleable => tengo que ir sumando todos los que no sean null

--consulta 4
select p.ProductNumber from Sales.SpecialOffer so
join Sales.SpecialOfferProduct sop on so.SpecialOfferID = sop.SpecialOfferID
join Production.Product p on sop.ProductID = p.ProductID

select * from Sales.SpecialOffer so
join Sales.SpecialOfferProduct sop on so.SpecialOfferID = sop.SpecialOfferID
join Production.Product p on sop.ProductID = p.ProductID

-- acceder a todos los valores de ambas tablas contra solamente uno (que esta presente en un solo join)
-- specialOffer <-> SpecialOfferProduct <-> Product
-- integridad referencial (por ser bases de datos relacional), se evita un join

--consulta 5

select AddressID, City, StateProvinceID, ModifiedDate
from  Person.Address
where StateProvinceID = 32

select AddressID, City, StateProvinceID, ModifiedDate
from Person.Address
where StateProvinceID = 20

-- por estadistica sabe mas o menos cuantos hay de cada id, entonces si hay muchos hace un scan, sino hace key  lookup y seek

--consulta 6


Select AddressLine1, AddressLine2, City from Person.Address 
where AddressLine1 like '1%';

Select AddressLine1, AddressLine2, City from Person.Address 
where AddressLine1 NOT like '1%';

Select AddressLine1, AddressLine2, City, ModifiedDate from Person.Address 
where AddressLine1 like '1%';

-- query 1 todos los campos estan en el indice y en el mismo orden, entonces usa el index seek (busca directo)
-- query 2 todos los otros
-- query 3, modifiedDate no esta en ningun indice entonces tengo que ir y buscarlo todos

--consulta 7

select count(EndDate) from Production.WorkOrder

select count(OrderQty) from Production.WorkOrder

-- EndDate es nulleable => hay que ir a buscarlo
-- OrderQty no es nulleable => hay que contar todos los registros entonces uso un indice cualquiera, pero ahora este indice es mas chico (smallint), entonces lo prefiero

--consulta 8
--Dada la siguiente consulta:
select e.* from HumanResources.Employee as e where e.Gender = 'F'

-- lo que quiero no pertenece a ningun indice, entonces tengo que buscar todo => clustered index

-- Ejecutarla y ver el plan de ejecución,
-- Luego crear el siguiente índice:
CREATE INDEX IX_Employee_Test ON HumanResources.Employee (Gender)
--WITH (DROP_EXISTING = ON) ;
-- Volver a ejecutarla. ¿Qué ocurrió con el índice?

-- agregar el indice con baja selectividad (pocas opciones, M o F en este caso) puede no servir (1/2 de la tabla no es suficiente)

--Consulta 9

select soh.* from Sales.SalesOrderHeader soh
join Sales.SalesOrderDetail sod
    on soh.SalesOrderID = sod.SalesOrderID
where soh.SalesOrderID = 71832 ;

select soh.* from Sales.SalesOrderHeader soh
join Sales.SalesOrderDetail sod
    on soh.SalesOrderID = sod.SalesOrderID

--consulta 10

select distinct(CardType) from Sales.CreditCard;

select distinct(CardNumber) from Sales.CreditCard;
 
-- por selectividad, una funcion de hash tiene sentido para baja selectividad para agruparlos en pocos grupos
-- entonces tipos de tarjeta seran credito o debito
-- pero numero de tarjeta hay que recorrer uno por uno

-- estadistica es muy pesada de actualizar, entonces no se hace por cada query, se decide hacer en momentos de baja usabilidad
