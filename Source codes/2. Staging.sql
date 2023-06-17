CREATE DATABASE MelodicaStaging;
GO

USE MelodicaStaging;
GO

-- Copy Customer data from Chinook database to MelodicaStaging
SELECT CustomerId, FirstName, LastName, Company, Address, City, State, Country, PostalCode, Phone, Email, SupportRepId
INTO MelodicaStaging.dbo.Customers
FROM Chinook2021.dbo.Customer;

-- Copy Track data from Chinook database to MelodicaStaging
SELECT TrackId, tr.Name, ar.Name as Artist, al.Title as Album, med.Name as MediaType, ge.Name as Genre, Composer, Milliseconds, Bytes, UnitPrice
INTO MelodicaStaging.dbo.Tracks
FROM Chinook2021.dbo.Track tr
INNER JOIN Chinook2021.dbo.Album al ON al.AlbumId = tr.AlbumId
INNER JOIN Chinook2021.dbo.Artist ar ON ar.ArtistId = al.ArtistId
INNER JOIN Chinook2021.dbo.MediaType med ON med.MediaTypeId = tr.MediaTypeId
INNER JOIN Chinook2021.dbo.Genre ge ON ge.GenreId = tr.GenreId

-- Copy Invoice data from Chinook database to MelodicaStaging
SELECT InvoiceId, CustomerId, InvoiceDate, BillingAddress, BillingCity, BillingState, BillingCountry, BillingPostalCode, Total
INTO MelodicaStaging.dbo.Invoices
FROM Chinook2021.dbo.Invoice;

-- Copy InvoiceLine data from Chinook database to MelodicaStaging
SELECT InvoiceLineId, InvoiceId, TrackId, UnitPrice, Quantity
INTO MelodicaStaging.dbo.InvoiceLines
FROM Chinook2021.dbo.InvoiceLine;
