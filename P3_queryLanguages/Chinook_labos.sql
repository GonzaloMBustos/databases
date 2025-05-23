-- SOL 2023

/*
Obtener la cantidad de ventas por país ordenadas de mayor a
menor. La consulta debe devolver país y cantidad de ventas.
*/
SELECT BillingCountry, COUNT(InvoiceId) as NumberOfSales FROM Invoice
GROUP BY BillingCountry
ORDER BY NumberOfSales DESC
/*
Obtener los clientes cuyas compras en total superan los 40 pesos.
Devolver ID del cliente, y la cantidad total gastada de cada cliente
ordenada de mayor a menor.
*/
SELECT c.CustomerId, SUM(Total) as TotalSpend FROM Customer c
INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
HAVING SUM(Total) > 40
ORDER BY TotalSpend DESC
/*
¿Cuál es el promedio de álbumes por PlayList? La respuesta debe
ser un número.
*/
WITH AlbumsPerPlaylist (PlaylistId, NumberOfAlbums) AS (
SELECT PlaylistId, COUNT(DISTINCT AlbumId) NumberOfAlbums FROM PlaylistTrack pt
INNER JOIN Track t ON pt.TrackId = t.TrackId
GROUP BY PlaylistId
)
SELECT AVG(NumberOfAlbums) FROM AlbumsPerPlaylist
/*
Obtener la cantidad de ventas de cada vendedor al año y ordenar
de mayor a menor por cantidad de ventas. Se debe devolver
EmployeeId, año y cantidad de ventas.
*/
SELECT c.SupportRepId as EmployeeId, YEAR(i.InvoiceDate) as YearOfSell, COUNT(InvoiceId) as
NumberOfSales FROM Invoice i
INNER JOIN Customer c ON i.CustomerId = c.CustomerId
GROUP BY c.SupportRepId, YEAR(i.InvoiceDate)
ORDER BY NumberOfSales DESC
/*
Obtener las Playlist cuyos tracks sean todos del mismo género.
Devolver la PlaylistId y su nombre junto con el id del género y su
nombre.
*/
WITH PlayslistsWithOnlyOneGenre(PlaylistId) AS (
SELECT pt.PlaylistId FROM PlaylistTrack pt
INNER JOIN Track t ON pt.TrackId = t.TrackId
INNER JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY pt.PlaylistId
HAVING COUNT(DISTINCT g.GenreId) = 1
)
SELECT DISTINCT p.PlaylistId, p.Name, g.GenreId, g.Name FROM
PlayslistsWithOnlyOneGenre pog
INNER JOIN Playlist p ON pog.PlaylistId = p.PlaylistId
INNER JOIN PlaylistTrack pt ON pog.PlaylistId = pt.PlaylistId
INNER JOIN Track t ON pt.TrackId = t.TrackId
INNER JOIN Genre g ON t.GenreId = g.GenreId
/*
Devolver, si es que lo hubiera, el nombre y el id del género que no
haya sido comprado aún por ningún cliente.
*/
SELECT * FROM Genre g
WHERE g.GenreId NOT IN (
SELECT DISTINCT t.GenreId FROM Track t
INNER JOIN InvoiceLine il ON t.TrackId = il.TrackId
)

-- SOL 2022

-- 1. Obtener la facturación anual por país.
select i.billing_country, date_part('year',i.invoice_date),
sum(i.total)
from invoice i
GROUP BY i.billing_country, date_part('year',i.invoice_date)
-- 2. Cuáles son los clientes que realizaron más compras
with count_invoice_by_customer as (
 select c.customer_id, count(i.invoice_id) as count_invoice
 from customer c
 left join invoice i on c.customer_id = i.customer_id
 GROUP BY c.customer_id
)
select cibc.customer_id
from count_invoice_by_customer cibc
where cibc.count_invoice = (select max(count_invoice) from
count_invoice_by_customer)
-- 3. Obtener el track de mayor duración para cada género indicando el
-- título del Álbum al que pertenece.
with time_duration_track_by_genre as (
 select t.genre_id, max(t.milliseconds) as duration_max
 from genre g
 left join track t on t.genre_id = g.genre_id
 group by t.genre_id
), track_max_duraction_by_genre as (
 select t.track_id, tdbg.genre_id, tdbg.duration_max
 from time_duration_track_by_genre tdbg
 inner join track t on
 tdbg.duration_max = t.milliseconds and tdbg.genre_id =
t.genre_id
)
select al.title, tm.track_id, tm.genre_id, tm.duration_max
from track_max_duraction_by_genre tm
inner join track t on t.track_id = tm.track_id
inner join album al on al.album_id = t.album_id
-- 4. Cuáles son las playlist más vendidas
with playlist_invoice as (
 select plt.playlist_id, il.invoice_id
 from playlist_track plt
 inner join track t on t.track_id = plt.track_id
 inner join invoice_line il on il.track_id = t.track_id
), count_invoice_by_playlist as (
 select pin.playlist_id, count(distinct pin.invoice_id) as
count_invoice
 from playlist_invoice pin
 group by pin.playlist_id
)
select cibp.playlist_id
from count_invoice_by_playlist cibp
where cibp.count_invoice = (select max(count_invoice) from
count_invoice_by_playlist)
-- 5. Listar playlists con tracks de más de tres artistas.
with count_artist_by_playlist as (
 select plt.playlist_id, count(DISTINCT al.artist_id) as
count_artist
 from playlist_track plt
 inner join track t on t.track_id = plt.track_id
 inner join album al on al.album_id = t.album_id
 GROUP BY plt.playlist_id
)
select ca.playlist_id
from count_artist_by_playlist ca
where ca.count_artist > 3
-- 6. Realizar una consulta correlacionada que devuelva, si es que lo
-- hubiera, todos los customers que tengan como representante de
-- ventas un empleado de otra ciudad a la que pertenece el cliente.
-- Es decir que cliente y vendedor son de distintas ciudades.
select c.customer_id
from customer c
where EXISTS (
 select e.employee_id
 from employee e
 where
 c.support_rep_id = e.employee_id and
 e.city != c.city AND
 e.state != c.state
)