-- PRACTICA LENGUAJES
-- 2.1 a)
SELECT c.FirstName, c.LastName FROM Customer c WHERE c.Country = 'Brazil';
-- 2.1 b)
SELECT c.FirstName, c.LastName, i.InvoiceDate, i.InvoiceId FROM Customer c
    INNER JOIN Invoice i ON i.CustomerId = c.CustomerId;
-- 2.1 c)
SELECT a.Name, tr.Name FROM Artist a
    INNER JOIN Album al ON al.ArtistId = a.ArtistId
    INNER JOIN Track tr ON tr.AlbumId = al.AlbumId;
-- 2.1 d)
SELECT pl.Name FROM Playlist pl
    INNER JOIN PlaylistTrack pltr ON pltr.PlaylistId = pl.PlaylistId
    INNER JOIN Track tr ON tr.TrackId = pltr.TrackId
    INNER JOIN MediaType mt ON mt.MediaTypeId = tr.MediaTypeId
    WHERE mt.Name = 'MPEG audio file' AND EXISTS (
        SELECT * FROM Track tr2 
            INNER JOIN PlaylistTrack pltr2 ON tr.TrackId = pltr2.TrackId
            INNER JOIN Playlist pl2 ON pl2.PlaylistId = pltr2.PlaylistId
            INNER JOIN MediaType mt2 ON mt.MediaTypeId = tr2.MediaTypeId
            WHERE mt2.Name = 'MPEG audio file' AND tr.TrackId != tr2.TrackId AND pl.PlaylistId = pl2.PlaylistId
    )
    GROUP BY pl.PlaylistId, pl.Name;
-- LA DE ARRIBA ES LA MIA, PARECE QUE NO ESTA DEL TODO BIEN (me esta agarrando la playlist con solo 1 cancion)... LA DE ABAJO ES LA DE CHATGPT
SELECT pl.Name
    FROM Playlist pl
    JOIN PlaylistTrack pltr ON pl.PlaylistId = pltr.PlaylistId
    JOIN Track tr ON tr.TrackId = pltr.TrackId
    JOIN MediaType mt ON mt.MediaTypeId = tr.MediaTypeId
    WHERE mt.Name = 'MPEG audio file'
    GROUP BY pl.PlaylistId, pl.Name
    HAVING COUNT(DISTINCT tr.TrackId) >= 2;
-- 2.1 e)
SELECT pl.Name FROM Playlist pl
    INNER JOIN PlaylistTrack pltr ON pl.PlaylistId = pltr.PlaylistId
    INNER JOIN Track tr ON pltr.TrackId = tr.TrackId
    INNER JOIN Album al ON tr.AlbumId = al.AlbumId
    INNER JOIN Artist ar ON al.ArtistId = ar.ArtistId
    WHERE ar.Name = 'Iron Maiden'
    GROUP BY pl.PlaylistId, pl.Name
    HAVING COUNT(DISTINCT tr.TrackId) > 10;
-- 2.1 f)
SELECT pl.Name PlaylistName, pl.PlaylistId, COUNT(DISTINCT al.AlbumId) AmountOfAlbums FROM Playlist pl
    LEFT JOIN PlaylistTrack pltr ON pl.PlaylistId = pltr.PlaylistId
    LEFT JOIN Track tr ON pltr.TrackId = tr.TrackId
    LEFT JOIN Album al ON tr.AlbumId = al.AlbumId
    GROUP BY pl.PlaylistId, pl.Name;
-- con LEFT JOIN me quedo incluso con las que no tienen albums por alguna razon, si hago INNER me quedo solo con las que tienen 1 o mas
-- 2.1 g)
WITH InvoicesWithMoreThanTenItems(InvoiceId, CustomerId) AS (
    SELECT i.InvoiceId, i.CustomerId FROM Invoice i
        INNER JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
        GROUP BY i.InvoiceId, i.CustomerId
        HAVING COUNT(DISTINCT il.InvoiceLineId) > 10
)
SELECT e.FirstName, e.LastName FROM Employee e
    INNER JOIN Customer c ON e.EmployeeId = c.SupportRepId
    INNER JOIN InvoicesWithMoreThanTenItems iwmtti ON iwmtti.CustomerId = c.CustomerId
    WHERE DATEADD(YEAR, 25, e.BirthDate) <= GETDATE()
    GROUP BY e.EmployeeId, e.FirstName, e.LastName;

-- 2.1 h)
SELECT c.FirstName, c.LastName, i.InvoiceDate, i.InvoiceId FROM Customer c
    LEFT JOIN Invoice i ON i.CustomerId = c.CustomerId;

-- 2.1 i)
WITH InvoicesWithMoreThanTenItems(InvoiceId, CustomerId) AS (
    SELECT i.InvoiceId, i.CustomerId FROM Invoice i
        INNER JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
        GROUP BY i.InvoiceId, i.CustomerId
        HAVING COUNT(DISTINCT il.InvoiceLineId) > 10
)
SELECT e.FirstName, e.LastName FROM Employee e
    INNER JOIN Customer c ON e.EmployeeId = c.SupportRepId
    INNER JOIN InvoicesWithMoreThanTenItems iwmtti ON iwmtti.CustomerId = c.CustomerId
    GROUP BY e.EmployeeId, e.FirstName, e.LastName;
-- o una alternativa podria ser
SELECT e.FirstName, e.LastName FROM Employee e INNER JOIN Customer c ON e.EmployeeId = c.SupportRepId INNER JOIN Invoice i ON i.CustomerId = c.CustomerId INNER JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
    GROUP BY e.EmployeeId, e.FirstName, e.LastName, i.InvoiceId
    HAVING COUNT(DISTINCT il.InvoiceLineId) > 10;
-- son lo mismo
-- uh, era con mas de 10 facturas, no mas de 10 items
SELECT e.FirstName, e.LastName FROM Employee e
    INNER JOIN Customer c ON e.EmployeeId = c.SupportRepId
    INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
    GROUP BY e.EmployeeId, e.FirstName, e.LastName
    HAVING COUNT(DISTINCT i.InvoiceId) > 10;

-- 2.1 j)
WITH BossLookup(BossId, BossName, BossLastName) AS (
    SELECT e.EmployeeId BossId, e.FirstName BossName, e.LastName BossLastName FROM Employee e
)
SELECT e.FirstName NombreEmpleado, e.LastName ApellidoEmpleado, bl.BossName, bl.BossLastName FROM Employee e
    LEFT JOIN BossLookup bl ON bl.BossId = e.ReportsTo;
-- 2.1 k)
-- ya me habia adelantado...
-- 2.1 l)
WITH AmountOfTracksPerInvoice(CustomerId, amountOfTracks) AS (
    SELECT i.CustomerId, COUNT(il.InvoiceLineId) FROM Invoice i
        INNER JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
        GROUP BY i.CustomerId, i.InvoiceId
)
SELECT c.CustomerId, c.FirstName, c.LastName, AVG(i.amountOfTracks) FROM Customer c
    INNER JOIN AmountOfTracksPerInvoice i ON i.CustomerId = c.CustomerId
    GROUP BY c.CustomerId, c.FirstName, c.LastName;

SELECT COUNT(*) AS NumTracks, COUNT(DISTINCT InvoiceId) AS NumInvoices
FROM InvoiceLine;

SELECT InvoiceId, COUNT(*) AS NumTracks
FROM InvoiceLine
GROUP BY InvoiceId
ORDER BY NumTracks;
-- bueno parece que todo me da 5, pero creo que esta bien igual la query

-- 2.1 m)
WITH RockTracksPerCustomer(CustomerId, RockTracksAmount) AS (
    SELECT c.CustomerId, COUNT(DISTINCT tr.TrackId) FROM Customer c
        INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
        INNER JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
        INNER JOIN Track tr ON tr.TrackId = il.TrackId
        INNER JOIN Genre gen ON gen.GenreId = tr.GenreId
        WHERE gen.Name = 'Rock'
        GROUP BY c.CustomerId
)
SELECT e.FirstName, e.LastName, SUM(rtpc.RockTracksAmount) RockTracksAmount FROM Employee e
    INNER JOIN Customer c ON e.EmployeeId = c.SupportRepId
    INNER JOIN RockTracksPerCustomer rtpc ON c.CustomerId = rtpc.CustomerId
    GROUP BY e.EmployeeId, e.FirstName, e.LastName;

-- 2.3 a)
SELECT al.Title FROM Album al
    INNER JOIN Track tr ON tr.AlbumId = al.AlbumId
    INNER JOIN PlaylistTrack pltr ON pltr.TrackId = tr.TrackId
    GROUP BY al.AlbumId, al.Title
    HAVING COUNT(DISTINCT pltr.PlaylistId) = (SELECT COUNT(*) FROM Playlist);

-- 2.3 b)
-- el INNER JOIN "elimina" las que no tienen playlists
WITH AlbumCountPerPlaylist(AlbumCount, ArtistId) AS (
    SELECT COUNT(DISTINCT al.AlbumId), al.ArtistId FROM Album al
        INNER JOIN Track tr ON al.AlbumId = tr.AlbumId
        INNER JOIN PlaylistTrack pltr ON pltr.TrackId = tr.TrackId
        GROUP BY al.ArtistId
)
SELECT * FROM Artist ar INNER JOIN AlbumCountPerPlaylist acpp ON ar.ArtistId = acpp.ArtistId WHERE acpp.AlbumCount = (SELECT MIN(AlbumCount) FROM AlbumCountPerPlaylist);

-- 2.4 a)
SELECT pl.Name FROM Playlist pl WHERE pl.PlaylistId NOT IN (
    SELECT pl.PlaylistId FROM Playlist pl
        INNER JOIN PlaylistTrack pltr ON pltr.PlaylistId = pl.PlaylistId
        INNER JOIN Track tr ON pltr.TrackId = tr.TrackId
        INNER JOIN Album al ON tr.AlbumId = al.AlbumId
        INNER JOIN Artist ar ON ar.ArtistId = al.ArtistId
        WHERE ar.Name = 'Black Sabbath' OR ar.Name = 'Chico Buarque'
)

-- 2.4 b)
SELECT c.CustomerId FROM Customer c
    INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
    INNER JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
    INNER JOIN Track tr ON il.TrackId = tr.TrackId
    GROUP BY c.CustomerId
    HAVING COUNT(DISTINCT tr.GenreId) = 1;

-- LABO SQL (Desaprobado)
-- Consulta 1
WITH TotalSpentPerCustomer(CustomerId, TotalSpent) AS (
    SELECT c.CustomerId, SUM(i.Total) FROM Customer c
        INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
        GROUP BY c.CustomerId
)
SELECT c.FirstName, c.LastName, tspc.TotalSpent FROM Customer c
    INNER JOIN TotalSpentPerCustomer tspc ON tspc.CustomerId = c.CustomerId
    WHERE tspc.TotalSpent > (SELECT AVG(TotalSpent) FROM TotalSpentPerCustomer)
    ORDER BY TotalSpent DESC;

-- Consulta 2
SELECT c.FirstName, c.LastName, COUNT(DISTINCT tr.GenreId) CantidadGeneros FROM Customer c
    INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
    INNER JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
    INNER JOIN Track tr ON tr.TrackId = il.TrackId
    GROUP BY c.CustomerId, c.FirstName, c.LastName
    HAVING COUNT(DISTINCT tr.GenreId) > 1
    ORDER BY CantidadGeneros DESC;

-- Consulta 3
SELECT al.Title FROM Album al
    INNER JOIN Track tr ON tr.AlbumId = al.AlbumId
    GROUP BY al.AlbumId, al.Title
    HAVING MIN(tr.Milliseconds) > (SELECT AVG(Milliseconds) FROM Track)
    ORDER BY al.Title ASC;

-- Consulta 4
SELECT ar.Name, COUNT(al.AlbumId) CantidadAlbumes FROM Artist ar
    INNER JOIN Album al ON al.ArtistId = ar.ArtistId
    GROUP BY ar.ArtistId, ar.Name
    HAVING COUNT(al.AlbumId) > 10
    ORDER BY CantidadAlbumes DESC;

-- LABO SQL 2C2023
-- Consulta 1
SELECT i.BillingCountry, COUNT(*) CantidadVentas FROM Invoice i
    GROUP BY i.BillingCountry
    ORDER BY CantidadVentas DESC;

-- Consulta 2
SELECT c.CustomerId, SUM(i.Total) CantidadGastada FROM Customer c
    INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
    GROUP BY c.CustomerId
    HAVING SUM(i.Total) > 40
    ORDER BY CantidadGastada DESC;

-- Consulta 3
WITH AlbumCountPerPlaylist(PlaylistId, AlbumCount) AS (
    SELECT pl.PlaylistId, COUNT(DISTINCT tr.AlbumId) AlbumCount FROM Playlist pl
        INNER JOIN PlaylistTrack pltr ON pltr.PlaylistId = pl.PlaylistId
        INNER JOIN Track tr ON tr.TrackId = pltr.TrackId
        GROUP BY pl.PlaylistId
)
SELECT AVG(AlbumCount) PromedioAlbumPorPlaylist FROM AlbumCountPerPlaylist;

-- Consulta 4
SELECT e.EmployeeId, YEAR(i.InvoiceDate) SaleYear, COUNT(DISTINCT i.InvoiceId) SaleCount FROM Employee e
    INNER JOIN Customer c ON c.SupportRepId = e.EmployeeId
    INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
    GROUP BY e.EmployeeId, YEAR(i.InvoiceDate)
    ORDER BY SaleCount DESC;

-- Consulta 5
WITH PlaylistsWithOneGenre(PlaylistId) AS (
    SELECT pl.PlaylistId FROM Playlist pl
    INNER JOIN PlaylistTrack pltr ON pl.PlaylistId = pltr.PlaylistId
    INNER JOIN Track tr ON tr.TrackId = pltr.TrackId
    INNER JOIN Genre gr ON gr.GenreId = tr.GenreId
    GROUP BY pl.PlaylistId
    HAVING COUNT(DISTINCT gr.GenreId) = 1
)
SELECT pl.PlaylistId, pl.Name, gr.GenreId, gr.Name FROM PlaylistsWithOneGenre plwog
    INNER JOIN Playlist pl ON plwog.PlaylistId = pl.PlaylistId
    INNER JOIN PlaylistTrack pltr ON pl.PlaylistId = pltr.PlaylistId
    INNER JOIN Track tr ON tr.TrackId = pltr.TrackId
    INNER JOIN Genre gr ON gr.GenreId = tr.GenreId
    GROUP BY pl.PlaylistId, pl.Name, gr.GenreId, gr.Name;

-- Consulta 6
SELECT * FROM Genre gr
    WHERE gr.GenreId NOT IN (
        SELECT genre.GenreId FROM Genre genre INNER JOIN Track tr ON tr.GenreId = genre.GenreId INNER JOIN InvoiceLine il ON il.TrackId = tr.TrackId
    );

-- maybe better
SELECT * 
FROM Genre gr
WHERE NOT EXISTS (
    SELECT 1 -- convention for checking existence
    FROM Track tr
    JOIN InvoiceLine il ON il.TrackId = tr.TrackId
    WHERE tr.GenreId = gr.GenreId
);

-- LABO SQL 1C2023
-- Consulta 1
SELECT YEAR(e.HireDate) Year, COUNT(*) EmployeesHired FROM Employee e
    GROUP BY YEAR(e.HireDate);

-- Consulta 2
SELECT ar.Name, COUNT(DISTINCT tr.TrackId) RockSongsCount FROM Artist ar
    INNER JOIN Album al ON al.ArtistId = ar.ArtistId
    INNER JOIN Track tr ON tr.AlbumId = al.AlbumId
    INNER JOIN Genre gr ON gr.GenreId = tr.GenreId
    WHERE gr.Name = 'Rock'
    GROUP BY ar.ArtistId, ar.Name;

-- Consulta 3
WITH EarningsPerArtist(ArtistId, Earnings) AS (
    SELECT ar.ArtistId, SUM(il.Quantity * il.UnitPrice) FROM Artist ar
        INNER JOIN Album al ON al.ArtistId = ar.ArtistId
        INNER JOIN Track tr ON tr.AlbumId = al.AlbumId
        INNER JOIN InvoiceLine il ON tr.TrackId = il.TrackId
        GROUP BY ar.ArtistId
)
SELECT ar.ArtistId, ar.Name, epa.Earnings FROM Artist ar INNER JOIN EarningsPerArtist epa ON epa.ArtistId = ar.ArtistId WHERE Earnings > 100;

-- Consulta 4
WITH MaxMinDurationByArtist(ArtistId, LongestTrackDuration, ShortestTrackDuration) AS (
    SELECT ar.ArtistId, MAX(tr.Milliseconds / 1000), MIN(tr.Milliseconds / 1000) FROM Artist ar
        INNER JOIN Album al ON al.ArtistId = ar.ArtistId
        INNER JOIN Track tr ON al.AlbumId = tr.AlbumId
        GROUP BY ar.ArtistId
)
SELECT ar.ArtistId, ar.Name, mmdba.LongestTrackDuration, (mmdba.LongestTrackDuration - mmdba.ShortestTrackDuration) TrackDurationDiff FROM Artist ar INNER JOIN MaxMinDurationByArtist mmdba ON ar.ArtistId = mmdba.ArtistId;

-- Consulta 5
SELECT c.CustomerId, c.FirstName, c.LastName, gr.GenreId, gr.Name, SUM(i.Total) TotalSpentByGenre FROM Customer c
    INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
    INNER JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
    INNER JOIN Track tr ON il.TrackId = tr.TrackId
    INNER JOIN Genre gr ON gr.GenreId = tr.GenreId
    GROUP BY c.CustomerId, c.FirstName, c.LastName, gr.GenreId, gr.Name
    ORDER BY c.CustomerId ASC;

-- Consulta 6
WITH LongestTracks(TrackId) AS (
    SELECT tr.TrackId FROM Track tr WHERE Milliseconds = (SELECT MAX(Milliseconds) FROM Track)
) SELECT pl.PlaylistId, pl.Name FROM Playlist pl INNER JOIN PlaylistTrack pltr ON pl.PlaylistId = pltr.PlaylistId INNER JOIN LongestTracks lt ON pltr.TrackId = lt.TrackId;

-- Retry monday labo 2025
-- Consulta 1
SELECT c.FirstName, c.LastName, SUM(i.Total) TotalGastado FROM Customer c
    INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId, c.FirstName, c.LastName
    HAVING SUM(i.Total) > (SELECT AVG(Total) FROM Invoice)
    ORDER BY TotalGastado DESC;

-- Consulta 2
SELECT c.FirstName, c.LastName, COUNT(DISTINCT tr.GenreId) CantidadGeneros FROM Customer c
    INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
    INNER JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
    INNER JOIN Track tr ON il.TrackId = tr.TrackId
    GROUP BY c.CustomerId, c.FirstName, c.LastName
    HAVING COUNT(DISTINCT tr.GenreId) > 1
    ORDER BY CantidadGeneros DESC;

-- Consulta 3
SELECT al.Title FROM Album al
    INNER JOIN Track tr ON tr.AlbumId = al.AlbumId
    GROUP BY al.AlbumId, al.Title
    HAVING MIN(tr.Milliseconds) > (SELECT AVG(Milliseconds) FROM Track)
    ORDER BY al.Title ASC;

-- Consulta 4
SELECT ar.Name, COUNT(DISTINCT al.AlbumId) CantidadAlbumes FROM Artist ar
    INNER JOIN Album al ON al.ArtistId = ar.ArtistId
    GROUP BY ar.ArtistId, ar.Name
    HAVING COUNT(DISTINCT al.AlbumId) > 10
    ORDER BY CantidadAlbumes DESC;

-- Redo (again) Practica Lenguajes
-- 2.1a
SELECT c.FirstName, c.LastName FROM Customer c WHERE c.Country = 'Brazil';

-- 2.1b
SELECT c.FirstName, c.LastName, i.InvoiceDate, i.InvoiceId FROM Customer c
    INNER JOIN Invoice i ON i.CustomerId = c.CustomerId;

-- 2.1c
SELECT tr.Name TrackName, ar.Name ArtistName FROM Track tr
    INNER JOIN Album al ON al.AlbumId = tr.AlbumId
    INNER JOIN Artist ar ON ar.ArtistId = al.ArtistId;

-- 2.1d
WITH MPEGCountPerPlaylist(PlaylistId, MPEGCount) AS (
    SELECT pl.PlaylistId, COUNT(DISTINCT tr.TrackId) FROM Playlist pl
        INNER JOIN PlaylistTrack pltr ON pltr.PlaylistId = pl.PlaylistId
        INNER JOIN Track tr ON tr.TrackId = pltr.TrackId
        INNER JOIN MediaType mt ON mt.MediaTypeId = tr.MediaTypeId
        WHERE mt.Name = 'MPEG audio file'
        GROUP BY pl.PlaylistId
)
SELECT pl.Name FROM Playlist pl
    INNER JOIN MPEGCountPerPlaylist mpegcpp ON mpegcpp.PlaylistId = pl.PlaylistId
    WHERE mpegcpp.MPEGCount > 1;
    -- nuevamente se podia hacer mas facil

-- 2.1e
SELECT pl.Name FROM Playlist pl
    INNER JOIN PlaylistTrack pltr ON pltr.PlaylistId = pl.PlaylistId
    INNER JOIN Track tr ON tr.TrackId = pltr.TrackId
    INNER JOIN Album al ON al.AlbumId = tr.AlbumId
    INNER JOIN Artist ar ON ar.ArtistId = al.ArtistId
    WHERE ar.Name = 'Iron Maiden'
    GROUP BY pl.PlaylistId, pl.Name
    HAVING COUNT(DISTINCT tr.TrackId) > 10;

-- 2.1f
SELECT pl.Name, COUNT(DISTINCT tr.AlbumId) CantidadAlbumes FROM Playlist pl
    INNER JOIN PlaylistTrack pltr ON pltr.PlaylistId = pl.PlaylistId
    INNER JOIN Track tr ON tr.TrackId = pltr.TrackId
    GROUP BY pl.PlaylistId, pl.Name;

-- 2.1g
WITH InvoicesWithMoreThanTenItems(InvoiceId) AS (
    SELECT i.InvoiceId FROM Invoice i
        INNER JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
        GROUP BY i.InvoiceId
        HAVING COUNT(DISTINCT il.InvoiceLineId) > 10
)
SELECT e.FirstName, e.LastName FROM Employee e
    INNER JOIN Customer c ON c.SupportRepId = e.EmployeeId
    INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
    INNER JOIN InvoicesWithMoreThanTenItems iwmtti ON iwmtti.InvoiceId = i.InvoiceId
    WHERE DATEADD(YEAR, 25, e.BirthDate) <= GETDATE()
    GROUP BY e.EmployeeId, e.FirstName, e.LastName;

-- 2.1h
SELECT c.FirstName, c.LastName FROM Customer c
    LEFT JOIN Invoice i ON i.CustomerId = c.CustomerId
    GROUP BY c.CustomerId, c.FirstName, c.LastName
    HAVING COUNT(DISTINCT i.InvoiceId) = 0;

SELECT c.FirstName, c.LastName, i.InvoiceDate, i.InvoiceId FROM Customer c
    LEFT JOIN Invoice i ON i.CustomerId = c.CustomerId;

-- 2.1i
WITH CustomersWithMoreThanTenInvoices(CustomerId) AS (
    SELECT c.CustomerId FROM Customer c
        INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
        GROUP BY c.CustomerId
        HAVING COUNT(DISTINCT i.InvoiceId) > 10
) SELECT e.FirstName, e.LastName FROM Employee e INNER JOIN Customer c ON e.EmployeeId = c.SupportRepId INNER JOIN CustomersWithMoreThanTenInvoices cwmtti ON cwmtti.CustomerId = c.CustomerId;

-- 2.1j
WITH Boss(EmployeeId, FirstName, LastName) AS (
    SELECT EmployeeId, FirstName, LastName FROM Employee
) SELECT e.FirstName, e.LastName, b.FirstName BossFirstName, b.LastName BossLastName FROM Employee e LEFT JOIN Boss b ON b.EmployeeId = e.ReportsTo;

-- 2.1k ya me habia adelantado otra vez

-- 2.1l
WITH TracksCountPerInvoice(InvoiceId, TracksCount) AS (
    SELECT i.InvoiceId, COUNT(DISTINCT il.TrackId) FROM Invoice i
        INNER JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
        GROUP BY i.InvoiceId
)
SELECT c.CustomerId, AVG(tcpi.TracksCount) FROM Customer c
    INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
    INNER JOIN TracksCountPerInvoice tcpi ON tcpi.InvoiceId = i.InvoiceId
    GROUP BY c.CustomerId;

-- 2.1m
SELECT e.EmployeeId, COUNT(tr.TrackId) FROM Employee e
    INNER JOIN Customer c ON c.SupportRepId = e.EmployeeId
    INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
    INNER JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
    INNER JOIN Track tr ON tr.TrackId = il.TrackId
    INNER JOIN Genre gr ON tr.GenreId = gr.GenreId
    WHERE gr.Name = 'Rock'
    GROUP BY e.EmployeeId;

-- 2.3a
SELECT al.Title FROM Album al
    INNER JOIN Track tr ON tr.AlbumId = al.AlbumId
    INNER JOIN PlaylistTrack pltr ON pltr.TrackId = tr.TrackId
    GROUP BY al.AlbumId, al.Title
    HAVING COUNT(DISTINCT pltr.PlaylistId) = (SELECT COUNT(*) FROM Playlist);

-- 2.3b
WITH AlbumInPlaylistPerArtistCount(ArtistId, AlbumCount) AS (
    SELECT ar.ArtistId, COUNT(DISTINCT al.AlbumId) FROM Artist ar
        INNER JOIN Album al ON al.ArtistId = ar.ArtistId
        INNER JOIN Track tr ON tr.AlbumId = al.AlbumId
        INNER JOIN PlaylistTrack pltr ON pltr.TrackId = tr.TrackId
        GROUP BY ar.ArtistId
)
SELECT ar.Name FROM Artist ar
    INNER JOIN Album al ON al.ArtistId = ar.ArtistId
    INNER JOIN Track tr ON tr.AlbumId = al.AlbumId
    INNER JOIN PlaylistTrack pltr ON pltr.TrackId = tr.TrackId
    GROUP BY ar.ArtistId, ar.Name
    HAVING COUNT(DISTINCT al.AlbumId) = (SELECT MIN(AlbumCount) FROM AlbumInPlaylistPerArtistCount);

-- 2.4a
SELECT pl.PlaylistId, pl.Name FROM Playlist pl
    WHERE pl.PlaylistId NOT IN (
        SELECT p.PlaylistId FROM Playlist p 
        INNER JOIN PlaylistTrack pltr ON p.PlaylistId = pltr.PlaylistId
        INNER JOIN Track tr ON pltr.TrackId = tr.TrackId
        INNER JOIN Album al ON tr.AlbumId = al.AlbumId
        INNER JOIN Artist ar ON ar.ArtistId = al.ArtistId
        WHERE ar.Name = 'Black Sabbath' OR ar.Name = 'Chico Buarque'
        GROUP BY p.PlaylistId
    );

-- 2.4b
SELECT c.FirstName, c.LastName FROM Customer c
    INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
    INNER JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
    INNER JOIN Track tr ON tr.TrackId = il.TrackId
    GROUP BY c.CustomerId, c.FirstName, c.LastName
    HAVING COUNT(DISTINCT tr.GenreId) = 1;

-- Otra vez Labo SQL 2C2023
-- C1
SELECT i.BillingCountry, COUNT(DISTINCT i.InvoiceId) CantVentas FROM Invoice i GROUP BY i.BillingCountry ORDER BY CantVentas DESC;

--C2
SELECT c.CustomerId, SUM(i.Total) TotalSpent FROM Customer c
    INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId
    HAVING SUM(i.Total) > 40
    ORDER BY TotalSpent DESC;

--C3
WITH AmountOfAlbumsPerPlaylist(PlaylistId, AmountOfAlbums) AS (
    SELECT pltr.PlaylistId, COUNT(DISTINCT tr.AlbumId) FROM PlaylistTrack pltr
        INNER JOIN Track tr ON pltr.TrackId = tr.TrackId
        GROUP BY pltr.PlaylistId
) SELECT AVG(AmountOfAlbums) FROM AmountOfAlbumsPerPlaylist;

-- C4
SELECT e.EmployeeId, YEAR(i.InvoiceDate), COUNT(DISTINCT i.InvoiceId) CantVentas FROM Employee e
    INNER JOIN Customer c ON c.SupportRepId = e.EmployeeId
    INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
    GROUP BY e.EmployeeId, YEAR(i.InvoiceDate)
    ORDER BY CantVentas DESC;

-- C5
WITH PlaylistsWithOneGenre(PlaylistId) AS (
    SELECT pl.PlaylistId FROM Playlist pl
    INNER JOIN PlaylistTrack pltr ON pltr.PlaylistId = pl.PlaylistId
    INNER JOIN Track tr ON pltr.TrackId = tr.TrackId
    GROUP BY pl.PlaylistId, pl.Name
    HAVING COUNT(DISTINCT tr.GenreId) = 1
) SELECT pl.PlaylistId, pl.Name, gr.GenreId, gr.Name FROM Playlist pl
    INNER JOIN PlaylistsWithOneGenre plwog ON pl.PlaylistId = plwog.PlaylistId
    INNER JOIN PlaylistTrack pltr ON pltr.PlaylistId = pl.PlaylistId
    INNER JOIN Track tr ON tr.TrackId = pltr.TrackId
    INNER JOIN Genre gr ON tr.GenreId = gr.GenreId
    GROUP BY pl.PlaylistId, pl.Name, gr.GenreId, gr.Name;

-- C6
SELECT gr.GenreId, gr.Name FROM Genre gr WHERE gr.GenreId NOT IN (
    SELECT tr.GenreId FROM Track tr
    INNER JOIN InvoiceLine il ON tr.TrackId = il.TrackId
);

-- a ver si me salen OTRA VEZ los dificiles de la practica
-- 2.3a
SELECT al.AlbumId, al.Title FROM Album al
    INNER JOIN Track tr ON al.AlbumId = tr.AlbumId
    INNER JOIN PlaylistTrack pltr ON pltr.TrackId = tr.TrackId
    GROUP BY al.AlbumId, al.Title
    HAVING COUNT(DISTINCT pltr.PlaylistId) = (SELECT COUNT(*) FROM Playlist);

-- 2.3b
WITH AlbumInPlaylistPerArtist(ArtistId, AlbumCount) AS (
    SELECT ar.ArtistId, COUNT(DISTINCT tr.AlbumId) FROM Artist ar
        INNER JOIN Album al ON al.ArtistId = ar.ArtistId
        INNER JOIN Track tr ON al.AlbumId = tr.AlbumId
        INNER JOIN PlaylistTrack pltr ON tr.TrackId = pltr.TrackId
        GROUP BY ar.ArtistId
) SELECT ar.Name, aippa.AlbumCount FROM Artist ar INNER JOIN AlbumInPlaylistPerArtist aippa ON aippa.ArtistId = ar.ArtistId WHERE aippa.AlbumCount = (SELECT MIN(AlbumCount) FROM AlbumInPlaylistPerArtist);

-- 2.4a
SELECT pl.Name FROM Playlist pl WHERE pl.PlaylistId NOT IN (
    SELECT pl.PlaylistId FROM Playlist pl
        INNER JOIN PlaylistTrack pltr ON pl.PlaylistId = pltr.PlaylistId
        INNER JOIN Track tr ON tr.TrackId = pltr.TrackId
        INNER JOIN Album al ON al.AlbumId = tr.AlbumId
        INNER JOIN Artist ar ON ar.ArtistId = al.ArtistId
        WHERE ar.Name = 'Black Sabbath' OR ar.Name = 'Chico Buarque'
)

-- 2.4b
SELECT c.FirstName, c.LastName FROM Customer c
    INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
    INNER JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
    INNER JOIN Track tr ON tr.TrackId = il.TrackId
    GROUP BY c.CustomerId, c.FirstName, c.LastName
    HAVING COUNT(DISTINCT tr.GenreId) = 1;