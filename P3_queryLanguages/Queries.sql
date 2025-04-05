SELECT * FROM Customer;

-- EJERCICIOS PRACTICA DE LENGUAJES DE CONSULTA
-- 2.1)
SELECT FirstName, LastName FROM Customer WHERE Country = 'Brazil';
SELECT c.FirstName, i.InvoiceId, i.InvoiceDate FROM Invoice i INNER JOIN Customer c ON i.CustomerId = c.CustomerId;
SELECT t.Name, ar.Name FROM (Track t INNER JOIN Album al ON t.AlbumId = al.AlbumId) INNER JOIN Artist ar ON ar.ArtistId = al.ArtistId;
SELECT pl.Name playlistName FROM (Playlist pl INNER JOIN PlaylistTrack pltrack ON pl.PlaylistId = pltrack.PlaylistId) 
    INNER JOIN Track tr ON tr.TrackId = pltrack.TrackId
    INNER JOIN Album al ON tr.AlbumId = al.AlbumId
    INNER JOIN Artist ar ON ar.ArtistId = al.ArtistId
    WHERE ar.Name = 'Iron Maiden'
    GROUP BY pl.Name
    HAVING COUNT(*) > 10;

SELECT pl.Name, COUNT(DISTINCT al.AlbumId) FROM (Playlist pl INNER JOIN PlaylistTrack pltrack ON pl.PlaylistId = pltrack.PlaylistId) 
    INNER JOIN Track tr ON tr.TrackId = pltrack.TrackId
    INNER JOIN Album al ON tr.AlbumId = al.AlbumId
    GROUP BY pl.Name;

SELECT employee.FirstName, employee.LastName FROM Customer customer
    INNER JOIN Employee employee ON customer.SupportRepId = employee.EmployeeId
    INNER JOIN Invoice invoice ON customer.CustomerId = invoice.CustomerId
    INNER JOIN InvoiceLine invoiceLine ON invoiceLine.InvoiceId = invoice.InvoiceId
    WHERE DATEDIFF(YEAR, employee.BirthDate, GETDATE()) >= 25
    GROUP BY employee.FirstName, employee.LastName
    HAVING COUNT(DISTINCT invoiceLine.InvoiceLineId) > 10;

-- EJERCICIOS EN CLASE
SELECT Track.Name temuko, Genre.Name generoso, MediaType.Name mp3 from Track inner join Genre ON Track.GenreId = Genre.GenreId inner join MediaType on Track.MediaTypeId = MediaType.MediaTypeId;

SELECT t.Name, g.Name, m.Name from Track t, Genre g, MediaType m WHERE t.GenreId = g.GenreId AND t.MediaTypeId = m.MediaTypeId;

SELECT g.name, COUNT() from Genre g, Track t WHERE g.GenreId = t.GenreId GROUP BY t.GenreId, g.Name; /*ESTA MAL, LA CORRECTA ESTA ABAJO*/

SELECT g.name, COUNT(t.TrackId) from Genre g LEFT JOIN Track t on g.GenreId = t.GenreId GROUP BY t.GenreId, g.Name;

SELECT * FROM Artist ar LEFT OUTER JOIN Album al ON ar.ArtistId = al.ArtistId WHERE al.AlbumId IS NULL;

SELECT ar.* from artist ar WHERE ar.ArtistId not in (
SELECT DISTINCT ArtistId from Album
);

SELECT ar.Name, COUNT(tr.TrackId)
FROM Artist ar
INNER JOIN Album al on ar.ArtistId = al.ArtistId
INNER JOIN Track tr on tr.AlbumId = al.AlbumId
GROUP By ar.ArtistId, ar.Name
HAVING COUNT(tr.TrackId)>50
ORDER by COUNT(tr.TrackId) DESC;