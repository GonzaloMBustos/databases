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
    and object_name(cols.object_id) LIKE 'Person'
    order by object_name(cols.object_id), ind.name;


SELECT TABLE_NAME, COLUMN_NAME, IS_NULLABLE, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'Person';

-- 1
SELECT P.Name , P.ProductNumber
FROM Production.Product P
WHERE ProductNumber ='EC-R098';

SELECT P.ProductID , P.ProductNumber
FROM Production.Product P
WHERE ProductNumber ='EC-R098';

-- en la primer query se pide el Product.Name que no esta en ningun indice, junto con el ProductNumber, que es parte de un indice unclustered.
-- para resolver esta query el motor de bases de datos utiliza primero el indice de ProductNumber para luego hacer el keyLookup en el indice clustered de la tabla Product (ya que es necesario para obtener el ProductName).
-- en la segunda query no es necesario hacer el keyLookup dado que el RID asociado al unclustered index es exactamente el valor que se esperaba devolver, por lo que es suficiente con hacer el index seek en el unclustered
-- index y devolverlo.

-- 2
SELECT SalesOrderID, SalesOrderDetailID
FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 58950;

SELECT SalesOrderID, SalesOrderDetailID
FROM Sales.SalesOrderDetail
WHERE SalesOrderDetailID = 68531;

-- SalesOrderID es parte de la PK que define el indice clustered y es el primer registro de la PK
-- SalesOrderDetailID es parte de la PK del indice clustered pero es el segundo registro de la PK
-- both ints, productID too
-- The first query uses a cluster index seek and returns the result because it's filtering by SalesOrderID which is the first part of the PK that defines the clustered index
-- the second query cannot make use of the clustered index because even though SalesOrderDetailID is part of the PK, it's the second element of the PK, and the index seek searches in order.
-- However, it's using the unclustered index of ProductID and returning, I'm guessing that by statistics it knows that SalesOrderDetailID = 68531 corresponds to a certain ProductID
-- and directly returns because the SalesOrderID and SalesOrderDetailID are both part of the PK, which is stored in the unclustered index as ProductID => (SalesOrderID,SalesOrderDetailID)

-- asumo que lo que esta haciendo es buscar en cada una de las PKs asociadas a cada ProductID y devolviendo la que matchee.

-- 3
SELECT SalesOrderID, SalesOrderDetailID
FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 43683 AND SalesOrderDetailID = 240;

SELECT SalesOrderID, SalesOrderDetailID
FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 43683 OR SalesOrderDetailID = 240;

-- es medio lo mismo que dije en el 2 pero ahora que chequea por los dos valores
-- asumo que el IX_ se ve algo asi: | ProductID | SalesOrderID | SalesOrderDetailID |
-- y que puedo acceder a cualquiera de los datos
-- y recorro eso porque es mas chico y tiene todos los datos que necesito recorrer

-- 4
SELECT ProductID, PV.BusinessEntityID, Name
FROM Purchasing.ProductVendor PPV JOIN Purchasing.Vendor PV
ON (PPV.BusinessEntityID =PV.BusinessEntityID);

SELECT ProductID, PV.BusinessEntityID, Name
FROM Purchasing.ProductVendor PPV JOIN Purchasing.Vendor PV
ON (PPV.BusinessEntityID =PV.BusinessEntityID)
WHERE StandardPrice > $10;

SELECT ProductID, PV.BusinessEntityID, Name
FROM Purchasing.ProductVendor PPV JOIN Purchasing.Vendor PV
ON (PPV.BusinessEntityID =PV.BusinessEntityID)
WHERE StandardPrice > $10 AND Name LIKE N'F%';

-- lo que pasa en la primer query es que por un lado conseguimos toda la tabla del Vendor, y dado que estamos buscando por BusinessEntityID podemos hacer uso del Clustered index.
-- a su vez en la tabla de ProductVendor BusinessEntityID es parte de la PK del clustered index, pero al no ser la primera y el join hacerse en base al businessEntityID,
-- el motor elige usar el unclustered index que si lo utiliza.
-- dado que ambos indices estan ordenados para la columna que los une, se puede utilizar el merge join

-- la situacion es similar a la query anterior, pero ahora al necesitar mayor informacion que solo el productID y businessEntityID que son parte de las PKS de cada tabla,
-- hay que primero conseguir las tablas completas (clustered index de cada una), y luego se usa un hash match para realizar el join ya que funciona mejor para procesar joins de tablas
-- que no estan indexadas optimamente (en este caso sin registro del StandardPrice) y manejan muchos registros

-- en la tercera lo que esta haciendo es usar el cluster index de Vendor, ir uno por uno en el index tomando los businessEntities, buscandolos en el BusinessEntityID unclustered index
-- de ProductVendor, haciendo el join, y yendo a buscar a la tabla completa de ProductVendor cada uno de los keys para hacer la comparacion de StandardPrice y Name.
-- ME GUSTARIA SABER SI HAY ALGUNA MANERA MEJOR DE RESPONDER!

-- 5
SELECT P.Name, PSC.Name SubCatrom
FROM Production.Product P
JOIN Production.ProductSubcategory PSC
ON p.ProductSubcategoryID = psc.ProductSubcategoryID;

SELECT P.Name, PSC.Name SubCatrom
FROM Production.Product P
JOIN Production.ProductSubcategory PSC
ON p.ProductSubcategoryID = psc.ProductSubcategoryID
ORDER BY psc.ProductSubcategoryID;

-- en la primera vamos a querer buscar el nombre de la subcategory, y tenemos un unclustered index con ese name, por lo que hacemos un scan para conseguirnos todos esos
-- tambien tenemos que vamos a querer unir por ProductSubcategoryID, que nos require que busquemos la tabla completa de Product, dado que no hay ningun index con el subcatID
-- dado que tenemos muchos registros y no estan bien indexadas las tablas para esta query, se usa el hash match que funciona bien para estos casos

-- en la segunda query la tabla ProductSubcategory no hace falta que haga nada para tener los registros ordenados por ProdSubcatID porque es su cluster idx, por lo tanto ya estan ordenados
-- sin embargo la tabla de product no tiene ordenados los registros por subcategoryID, entocnces decide ordenarlos para poder usar un merge join (que requiere que los datos esten
-- ordenados correctamente para funcionar) y devolver todos los registros ordenados por subcategoryID


-- 6
SELECT count(NameStyle) FROM Person.Person;

SELECT count(Title) FROM Person.Person;

-- nameStyle no es nulleable y es de tipo bit
-- title es nulleable y es de tipo nvarchar

-- en la primer query, sabemos que siempre que se haga una agregacion sin group by se va a utilizar el stream aggregate para calcular el escalar,
-- pero al ser el nameStyle no nulleable, se puede tomar cualquier indice y simplemente contar la cantidad de registros total de la tabla

-- en cambio en la segunda query title es nulleable, por lo tanto es necesario acceder a la tabla completa de Person y validar 1 por 1 los titles que no son nulos

-- 7
SELECT jc.Resume FROM HumanResources.JobCandidate jc
INNER JOIN HumanResources.Employee e on jc.BusinessEntityID =e.BusinessEntityID
ORDER BY e.BusinessEntityID,jc.JobCandidateID;

SELECT JobCandidateID FROM HumanResources.JobCandidate jc
INNER JOIN HumanResources.Employee e on jc.BusinessEntityID =e.BusinessEntityID
ORDER BY e.BusinessEntityID,jc.JobCandidateID;

-- bueno la verdad que un toque de paja, despues de ultima lo hago... son las 12 de la noche y maniana se labura