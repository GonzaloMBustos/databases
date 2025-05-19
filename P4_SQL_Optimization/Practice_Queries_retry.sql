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
    and object_name(cols.object_id) LIKE 'CreditCard'
    order by object_name(cols.object_id), ind.name;


SELECT TABLE_NAME, COLUMN_NAME, IS_NULLABLE, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'CreditCard';

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

-- •	NationalIdNumber tiene un índice unclustered. Como el índice non-clustered no contiene toda la información de cada registro tiene que hacer un key-lookup usando el clustered para poder traer el HireDate.
-- Hace dos lecturas: primero sobre el índice para resolver el where y después usa el operador key lookup para traerse el HireDate.

-- •	En el segundo caso va directo a la hoja y trae los datos. No necesita hacer un key-lookup porque la hoja además de contener el índice non-clustered, contiene el índice clustered que también se pide.

-- basicamente el unclustered index se usa en ambas, pero como el rowid que se almacena es el PK (clustered idx), en el primero el HireDate no es la PK pero en el 2do BusinessEntityID si es la PK, entonces puede devolver directo

--consulta 2

select NationalIDNumber, BusinessEntityID from HumanResources.Employee 
where NationalIDNumber= '121491555';

select NationalIDNumber, BusinessEntityID from HumanResources.Employee 
where NationalIDNumber= 121491555;

-- en el primero simplemente usa el NationalIDNumber para aprovecharse de la estructura del arbol del indice pero en el segundo tiene que castear cada uno de los NationalIDNumber a int para poder compararlo contra
-- el entero provisto, porque NationalIDNumber es un nvarchar y no un int

--consulta 3

select count(UnitPrice) from sales.SalesOrderDetail;

select count(CarrierTrackingNumber) from sales.SalesOrderDetail;

-- count(column) cuenta solamente los no nulos, entonces al ser nulleable CarrierTrackingNumber, no puede contar por el unclustered index porque necesita ver si el CarrierTrackingNumber es realmente nulo

--consulta 4
select p.ProductNumber from Sales.SpecialOffer so
join Sales.SpecialOfferProduct sop on so.SpecialOfferID = sop.SpecialOfferID
join Production.Product p on sop.ProductID = p.ProductID

select * from Sales.SpecialOffer so
join Sales.SpecialOfferProduct sop on so.SpecialOfferID = sop.SpecialOfferID
join Production.Product p on sop.ProductID = p.ProductID

-- el primero no tiene que listar nada de las 3 tablas, solamente devolver el productNumber de los productos que sean parte de las ofertas especiales, y agarrarlo de la PK del Product.
-- en cambio en el 2do tiene que devolver todas las columnas resultantes del join, por lo que no es suficiente solamente unir por producto y devolver, sino que tienen que listar todo
-- INTEGRIDAD REFERENCIAL

--consulta 5

select AddressID, City, StateProvinceID, ModifiedDate
from  Person.Address
where StateProvinceID = 32

select AddressID, City, StateProvinceID, ModifiedDate
from Person.Address
where StateProvinceID = 20

-- por estadistica, la cantidad de stateProvinceID = 20 son muchos mas que los 32, por lo tanto en el del 32 hace menos busquedas aprovechando la estructura del arbol (seek y key lookup) y en el 2do conviene mas hacer el scan

--consulta 6


Select AddressLine1, AddressLine2, City from Person.Address 
where AddressLine1 like '1%';

Select AddressLine1, AddressLine2, City from Person.Address 
where AddressLine1 NOT like '1%';

Select AddressLine1, AddressLine2, City, ModifiedDate from Person.Address 
where AddressLine1 like '1%';

-- addressLine1 es parte del indice, entonces para el primero basta con usar el indice para buscar solo aquellos que cumplan con LIKE '1%'
-- en el segundo caso, tiene que recorrer todo el indice porque tiene que agarrar todos los que no arrancan con '1%', por lo tanto ese TODOS requiere ir uno por uno en el idx
-- finalmente como el ModifiedDate no es parte del indice, hay que hacer un index scan del idx clustered para poder obtener el dato de modifiedDate

--consulta 7

select count(EndDate) from Production.WorkOrder

select count(OrderQty) from Production.WorkOrder

-- endDate es nulleable, orderQty no
-- como endDate es nulleable y no es parte de ningun indice hay que recorrer el indice clustered completo para asegurarse de no contar los NULL
-- en el 2do caso tambien hay que hacer un scan completo porque no es parte de ningun indice el orderqty, pero como es no nulleable, puede aprovecharse de algun OTRO indice (mas chico, como el de ScrapReasonID)
-- que esta armado con smallint en vez de int.  puede hacerlo porque al ser no nulleable es suficiente con contar todo un indice

--consulta 8
--Dada la siguiente consulta:
select e.* from HumanResources.Employee as e where e.Gender = 'F'

-- Ejecutarla y ver el plan de ejecución,
-- Luego crear el siguiente índice:
CREATE INDEX IX_Employee_Test ON HumanResources.Employee (Gender)
-- WITH (DROP_EXISTING = ON) ;
DROP INDEX IX_Employee_Test ON HumanResources.Employee;
-- Volver a ejecutarla. ¿Qué ocurrió con el índice?

-- en el primer caso se hace un clustered index scan dado que no hay ningun indice que pueda sacar beneficio de buscar por genero, por lo tanto hay que recorrer todo el indice para devolver los valores.
-- en el segundo caso se mantuvo la busqueda por clustered index scan dado que la selectividad de generos es baja, por lo tanto de todas maneras le conviene al motor hacer un scan por el indice clustered
-- en vez de recorrer un unclustered por genero

--Consulta 9

select soh.* from Sales.SalesOrderHeader soh
join Sales.SalesOrderDetail sod
    on soh.SalesOrderID = sod.SalesOrderID
where soh.SalesOrderID = 71832 ;

select soh.* from Sales.SalesOrderHeader soh
join Sales.SalesOrderDetail sod
    on soh.SalesOrderID = sod.SalesOrderID

-- en el primero ambas tablas hacen un clustered index seek porque el SalesOrderId es parte del cluster index de cada una, por lo tanto tiene sentido aprovecharlo al buscar uno solo de los SalesOrderID
-- se usa un nested join ya que la cantidad de elementos es muy baja
-- en cambio en la segunda query se usa un merge join porque la cantidad de elementos es muy alta pero vienen ordenados (por ser clustered index scan)

--consulta 10

select distinct(CardType) from Sales.CreditCard;

select distinct(CardNumber) from Sales.CreditCard;

-- el cardNumber es parte de un nonclustered index
-- cardType no es parte de ningun indice
-- al no ser el cardType parte de ningun indice, se usa el clustered index para recorrer toda la tabla y se usa tambien un hash match para poder matchear por tipo de tarjeta. el hash match funciona bien para tablas grandes
-- no necesariamente ordenadas y que se organizan en pocos grupos
-- en cambio en la segunda al ser el cardNumber parte del clustered index, es suficiente con devolver todas las entradas del indice (por eso se hace un scan). quiere hacer un distinct sobre un elemento que es unique