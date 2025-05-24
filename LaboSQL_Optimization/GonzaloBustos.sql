-- Consulta 1
-- Clientes con mayor gasto
WITH TotalSpentPerCustomer (CustomerId, FirstName, LastName, TotalGastado) AS (
    SELECT c.CustomerId, c.FirstName, c.LastName, SUM(Total) as TotalGastado FROM Customer c
    INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId, c.FirstName, c.LastName
) SELECT FirstName, LastName, TotalGastado FROM TotalSpentPerCustomer WHERE TotalGastado > (
    SELECT AVG(TotalGastado)
    FROM TotalSpentPerCustomer
) ORDER BY TotalGastado DESC;


GO

-- Consulta 2 
--Clientes con compras de distintos g�neros

WITH GenreCountByCustomer(FirstName, LastName, CantidadGeneros) AS (
SELECT c.FirstName, c.LastName, COUNT(DISTINCT tr.GenreId) genreCount FROM Customer c
    INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
    INNER JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
    INNER JOIN Track tr ON tr.TrackId = il.TrackId
    GROUP BY c.FirstName, c.LastName, tr.GenreId
) SELECT FirstName, LastName, CantidadGeneros FROM GenreCountByCustomer WHERE CantidadGeneros > 1 ORDER BY CantidadGeneros DESC;


GO
-- Consulta 3
--Albumes con canciones m�s largas que el promedio

WITH AlbumsWithSongsWithLessThanAverageDuration (AlbumId) AS 
 (SELECT al.AlbumId FROM Album al INNER JOIN Track tr ON al.AlbumId = tr.AlbumId WHERE tr.Milliseconds < (SELECT AVG(Milliseconds) FROM Track) GROUP BY al.AlbumId
) SELECT al.Title FROM Album al LEFT JOIN AlbumsWithSongsWithLessThanAverageDuration aswltad ON aswltad.AlbumId = al.AlbumId;

GO
-- Consulta 4 
--  Artistas con m�s de 10 �lbumes

WITH AlbumCountByArtist(Name, CantidadAlbumes) AS
(SELECT ar.Name, COUNT(AlbumId) CantidadAlbumes FROM Artist ar INNER JOIN Album al ON ar.ArtistId = al.ArtistId GROUP BY ar.Name)
SELECT Name, CantidadAlbumes FROM AlbumCountByArtist WHERE CantidadAlbumes > 10 ORDER BY CantidadAlbumes DESC;


GO
