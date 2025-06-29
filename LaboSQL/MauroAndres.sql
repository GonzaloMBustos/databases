-- Consulta 1
-- Clientes con mayor gasto
SELECT 
    c.FirstName, 
    c.LastName, 
    SUM(i.Total) AS TotalGastado
FROM 
    Customer c
INNER JOIN 
    Invoice i ON c.CustomerId = i.CustomerId
GROUP BY 
    c.CustomerId, c.FirstName, c.LastName
HAVING 
    SUM(i.Total) > (
        SELECT AVG(TotalGastado)
        FROM (
            SELECT CustomerId, SUM(Total) AS TotalGastado
            FROM Invoice
            GROUP BY CustomerId
        ) AS Subquery
    )
ORDER BY 
    TotalGastado DESC;


GO

-- Consulta 2 
--Clientes con compras de distintos g�neros
SELECT 
    c.FirstName,
    c.LastName,
    COUNT(DISTINCT t.GenreId) AS CantidadGeneros
FROM 
    Customer c
JOIN 
    Invoice i ON c.CustomerId = i.CustomerId
JOIN 
    InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN 
    Track t ON il.TrackId = t.TrackId
GROUP BY 
    c.CustomerId, c.FirstName, c.LastName
HAVING 
    COUNT(DISTINCT t.GenreId) > 1
ORDER BY 
    CantidadGeneros DESC;


GO
-- Consulta 3
--Albumes con canciones m�s largas que el promedio
WITH AvgDuration AS (
    SELECT AVG(Milliseconds) AS Promedio FROM Track
)
SELECT a.Title
FROM Album a
JOIN Track t ON a.AlbumId = t.AlbumId
JOIN AvgDuration avg ON 1 = 1
GROUP BY a.AlbumId, a.Title, avg.Promedio
HAVING MIN(t.Milliseconds) > avg.Promedio
ORDER BY a.Title ASC;



GO
-- Consulta 4 
--  Artistas con m�s de 10 �lbumes
SELECT 
    a.Name,
    COUNT(DISTINCT al.AlbumId) AS CantidadAlbumes
FROM 
    Artist a
JOIN 
    Album al ON al.ArtistId = a.ArtistId
GROUP BY 
    a.ArtistId, a.Name
HAVING 
    COUNT(DISTINCT al.AlbumId) > 10
ORDER BY 
    CantidadAlbumes DESC;



GO
