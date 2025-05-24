SELECT * FROM Customer;

-- EJERCICIOS PRACTICA DE LENGUAJES DE CONSULTA
-- 2.1)
-- a)
SELECT FirstName, LastName FROM Customer WHERE Country = 'Brazil';

-- b)
SELECT c.FirstName, i.InvoiceId, i.InvoiceDate FROM Invoice i INNER JOIN Customer c ON i.CustomerId = c.CustomerId;

-- c)
SELECT t.Name, ar.Name FROM (Track t INNER JOIN Album al ON t.AlbumId = al.AlbumId) INNER JOIN Artist ar ON ar.ArtistId = al.ArtistId;

-- e)
SELECT pl.Name playlistName FROM (Playlist pl INNER JOIN PlaylistTrack pltrack ON pl.PlaylistId = pltrack.PlaylistId) 
    INNER JOIN Track tr ON tr.TrackId = pltrack.TrackId
    INNER JOIN Album al ON tr.AlbumId = al.AlbumId
    INNER JOIN Artist ar ON ar.ArtistId = al.ArtistId
    WHERE ar.Name = 'Iron Maiden'
    GROUP BY pl.Name
    HAVING COUNT(*) > 10;

-- f)
SELECT pl.Name, COUNT(DISTINCT al.AlbumId) FROM (Playlist pl INNER JOIN PlaylistTrack pltrack ON pl.PlaylistId = pltrack.PlaylistId) 
    INNER JOIN Track tr ON tr.TrackId = pltrack.TrackId
    INNER JOIN Album al ON tr.AlbumId = al.AlbumId
    GROUP BY pl.Name;

-- g)
SELECT employee.FirstName, employee.LastName FROM Customer customer
    INNER JOIN Employee employee ON customer.SupportRepId = employee.EmployeeId
    INNER JOIN Invoice invoice ON customer.CustomerId = invoice.CustomerId
    INNER JOIN InvoiceLine invoiceLine ON invoiceLine.InvoiceId = invoice.InvoiceId
    WHERE DATEDIFF(YEAR, employee.BirthDate, GETDATE()) >= 25
    GROUP BY employee.FirstName, employee.LastName
    HAVING COUNT(DISTINCT invoiceLine.InvoiceLineId) > 10;

-- h)
SELECT c.FirstName, i.InvoiceId, i.InvoiceDate FROM Invoice i RIGHT OUTER JOIN Customer c ON i.CustomerId = c.CustomerId;

-- i)
SELECT e.FirstName, e.LastName FROM Employee e
    INNER JOIN Customer c ON c.SupportRepId = e.EmployeeId
    INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY e.FirstName, e.LastName, e.EmployeeId, c.CustomerId
    HAVING COUNT(DISTINCT i.InvoiceId) > 10;

-- si interprete bien el ejercicio, quieren todos los empleados que tienen clientes con mas de 10 facturas, pero no existen clientes con mas de 10 facturas
SELECT c.CustomerId FROM Customer c INNER JOIN Invoice i ON c.CustomerId = i.CustomerId GROUP BY c.CustomerId HAVING COUNT(i.InvoiceId) > 10;

-- j)
SELECT e.FirstName nombre_empleado, e.LastName apellido_empleado, b.FirstName nombre_jefe, b.LastName apellido_jefe FROM Employee e LEFT OUTER JOIN Employee b ON e.ReportsTo = b.EmployeeId;

-- k) ya lo habia hecho sin que falten empleados

-- l) mira, como la quantity siempre es 1 por cada invoice line, no hace falta que sume cada line, pero deberia hacerlo mas que nada para practicar cosas dificiles
-- SELECT c.FirstName, c.LastName, AVG(COUNT(il.InvoiceLineId)) FROM Customer c
--     INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
--     INNER JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
--     GROUP BY c.FirstName, c.LastName, c.CustomerId;
-- LO DE ACA ARRIBA ^ ESTA MAL, TENGO QUE USAR SUBQUERIES PARA RESOLVERLO JE

SELECT c.FirstName, c.LastName, AVG(TracksPerInvoiceCount.tracksPerInvoice) FROM Customer c
    INNER JOIN (
        SELECT i.CustomerId, COUNT(DISTINCT il.InvoiceLineId) tracksPerInvoice FROM Invoice i INNER JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId GROUP BY i.CustomerId, i.InvoiceId
    ) AS TracksPerInvoiceCount ON TracksPerInvoiceCount.CustomerId = c.CustomerId GROUP BY c.FirstName, c.LastName, c.CustomerId;

-- m) ya estoy re pajoso mal
-- voy a tener que CONTAR asi que fija un COUNT
-- los tracks de genero Rock comprados por los clientes que soporta cada empleado
-- necesito Employee, Customer, Invoice, InvoiceLine, Track y Genre
SELECT e.FirstName, e.LastName, COUNT(DISTINCT tr.TrackId) FROM Employee e
    INNER JOIN Customer c ON e.EmployeeId = c.SupportRepId
    INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
    INNER JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
    INNER JOIN Track tr ON tr.TrackId = il.TrackId
    INNER JOIN Genre gen ON tr.GenreId = gen.GenreId
    WHERE gen.Name = 'Rock'
    GROUP BY e.FirstName, e.LastName, e.EmployeeId;

-- 2.3)
-- a)
SELECT al.Title FROM Album al INNER JOIN Track tr ON al.AlbumId = tr.AlbumId INNER JOIN PlaylistTrack pltr ON pltr.TrackId = tr.TrackId INNER JOIN Playlist pl ON pl.PlaylistId = pltr.PlaylistId
GROUP BY al.AlbumId, al.Title HAVING COUNT(DISTINCT pl.PlaylistId) = (SELECT COUNT(*) FROM Playlist);

-- b)

WITH PlaylistCountByAlbum AS (
    SELECT al.AlbumId, al.ArtistId, COUNT(DISTINCT pl.PlaylistId) count FROM Album al
        INNER JOIN Track tr ON al.AlbumId = tr.AlbumId
        INNER JOIN PlaylistTrack pltr ON pltr.TrackId = tr.TrackId
        INNER JOIN Playlist pl ON pl.PlaylistId = pltr.PlaylistId
    GROUP BY al.AlbumId, al.ArtistId)
    SELECT ar.Name, plcba.count FROM PlaylistCountByAlbum plcba INNER JOIN Artist ar ON plcba.ArtistId = ar.ArtistId WHERE plcba.count = (SELECT MIN(count) FROM PlaylistCountByAlbum) GROUP BY ar.ArtistId, ar.Name, plcba.count;

-- 2.4)
-- SELECT pl.Name FROM Playlist pl WHERE pl.PlaylistId NOT IN (SELECT Playlist.PlaylistId FROM Playlist INNER JOIN PlaylistTrack);

SELECT pl.Name FROM Playlist pl WHERE pl.PlaylistId NOT IN (
	SELECT pl2.PlaylistId FROM Playlist pl2 INNER JOIN PlaylistTrack pltr ON pl2.PlaylistId = pltr.PLaylistId
	INNER JOIN Track tr ON tr.TrackId = pltr.TrackId
	INNER JOIN Album al ON al.AlbumId = tr.AlbumId
	INNER JOIN Artist ar ON ar.ArtistId = al.ArtistId
	WHERE ar.Name = 'Black Sabbath' OR ar.Name = 'Chico Buarque'
	GROUP BY pl2.PlaylistId
);

-- EJERCICIOS EN CLASE
SELECT Track.Name temuko, Genre.Name generoso, MediaType.Name mp3 from Track inner join Genre ON Track.GenreId = Genre.GenreId inner join MediaType on Track.MediaTypeId = MediaType.MediaTypeId;

SELECT t.Name, g.Name, m.Name from Track t, Genre g, MediaType m WHERE t.GenreId = g.GenreId AND t.MediaTypeId = m.MediaTypeId;

SELECT g.name, COUNT(*) from Genre g, Track t WHERE g.GenreId = t.GenreId GROUP BY t.GenreId, g.Name; /*ESTA MAL, LA CORRECTA ESTA ABAJO*/

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
