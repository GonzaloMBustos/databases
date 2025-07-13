-- Consulta 1
SELECT c.FirstName, c.LastName, c.Country, COUNT(tr.TrackId) LatinTrackCount FROM Customer c
    INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
    INNER JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
    INNER JOIN Track tr ON tr.TrackId = il.TrackId
    INNER JOIN Genre gr ON gr.GenreId = tr.GenreId
    WHERE gr.Name = 'Latin'
    GROUP BY c.CustomerId, c.FirstName, c.LastName, c.Country
    ORDER BY LatinTrackCount DESC;


GO

-- Consulta 2 
SELECT e.FirstName FirstNameEmployee, e.LastName LastNameEmployee, c.FirstName FirstNameCustomer, c.LastName LastNameCustomer, SUM(i.Total) TotalSpent FROM Employee e
    INNER JOIN Customer c ON c.SupportRepId = e.EmployeeId
    INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
    GROUP BY e.EmployeeId, e.FirstName, e.LastName, c.CustomerId, c.FirstName, c.LastName
    HAVING SUM(i.Total) > 45
    ORDER BY TotalSpent DESC;



GO
-- Consulta 3
WITH SongsBoughtPerCustomer(CustomerId, TrackId, UnitPrice) AS (
    SELECT c.CustomerId, il.TrackId, il.UnitPrice FROM Customer c
        INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
        INNER JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
        GROUP BY c.CustomerId, il.TrackId, il.UnitPrice
)
SELECT c.FirstName, c.LastName, c.Country, tr.Name TrackName, sbpc.UnitPrice FROM Customer c
    INNER JOIN SongsBoughtPerCustomer sbpc ON sbpc.CustomerId = c.CustomerId
    INNER JOIN Track tr ON sbpc.TrackId = tr.TrackId
    WHERE sbpc.UnitPrice = (SELECT MAX(UnitPrice) FROM SongsBoughtPerCustomer WHERE CustomerId = c.CustomerId);




GO
-- Consulta 4
WITH TotalSalesByGenre(GenreId, TotalRevenue) AS (
    SELECT gr.GenreId, SUM(il.UnitPrice * il.Quantity) FROM Genre gr
        INNER JOIN Track tr ON tr.GenreId = gr.GenreId
        INNER JOIN InvoiceLine il ON il.TrackId = tr.TrackId
        INNER JOIN Invoice i ON i.InvoiceId = il.InvoiceId
        GROUP BY gr.GenreId
)
SELECT gr.Name GenreName, tsbg.TotalRevenue FROM Genre gr
    INNER JOIN TotalSalesByGenre tsbg ON tsbg.GenreId = gr.GenreId
    WHERE tsbg.TotalRevenue > 100
    ORDER BY tsbg.TotalRevenue DESC;




GO
