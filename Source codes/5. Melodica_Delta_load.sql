-- Step 1: Transfer new or changed data to the MelodicaStaging database
USE MelodicaStaging;
GO

IF OBJECT_ID('MelodicaStaging.dbo.InvoiceLines', 'U') IS NOT NULL
    DROP TABLE MelodicaStaging.dbo.InvoiceLines;
GO
IF OBJECT_ID('MelodicaStaging.dbo.Invoices', 'U') IS NOT NULL
    DROP TABLE MelodicaStaging.dbo.Invoices;
GO

IF OBJECT_ID('MelodicaStaging.dbo.Tracks', 'U') IS NOT NULL
    DROP TABLE MelodicaStaging.dbo.Tracks;
GO
IF OBJECT_ID('MelodicaStaging.dbo.Customers', 'U') IS NOT NULL
    DROP TABLE MelodicaStaging.dbo.Customers;
GO

-- Copy Invoice data from Chinook database to MelodicaStaging
SELECT InvoiceId, CustomerId, InvoiceDate, BillingAddress, BillingCity, BillingState, BillingCountry, BillingPostalCode, Total
INTO MelodicaStaging.dbo.Invoices
FROM Chinook2022.dbo.Invoice;

-- Copy InvoiceLine data from Chinook database to MelodicaStaging
SELECT InvoiceLineId, InvoiceId, TrackId, UnitPrice, Quantity
INTO MelodicaStaging.dbo.InvoiceLines
FROM Chinook2022.dbo.InvoiceLine;

-- Copy Customer data from Chinook database to MelodicaStaging
SELECT CustomerId, FirstName, LastName, Company, Address, City, State, Country, PostalCode, Phone, Email, SupportRepId
INTO MelodicaStaging.dbo.Customers
FROM Chinook2022.dbo.Customer;

-- Copy Track data from Chinook database to MelodicaStaging
SELECT TrackId, tr.Name, ar.Name as Artist, al.Title as Album, med.Name as MediaType, ge.Name as Genre, Composer, Milliseconds, Bytes, UnitPrice
INTO MelodicaStaging.dbo.Tracks
FROM Chinook2022.dbo.Track tr
INNER JOIN Chinook2022.dbo.Album al ON al.AlbumId = tr.AlbumId
INNER JOIN Chinook2022.dbo.Artist ar ON ar.ArtistId = al.ArtistId
INNER JOIN Chinook2022.dbo.MediaType med ON med.MediaTypeId = tr.MediaTypeId
INNER JOIN Chinook2022.dbo.Genre ge ON ge.GenreId = tr.GenreId

-- Step 2: Load new or changed data into the MelodicaDW fact table
USE MelodicaDW;
GO
BEGIN TRANSACTION;

DECLARE @NewStartDate CHAR(8) = (SELECT CAST(MAX(DateKey) AS CHAR(8)) FROM MelodicaDW.dbo.Fact_Invoice);


-- Load Dim_Invoice 
INSERT INTO MelodicaDW.dbo.Dim_Invoice (
  InvoiceID, BillingAddress, BillingCity, BillingState, BillingCountry, BillingPostalCode, Total)
SELECT DISTINCT
  I.InvoiceID, I.BillingAddress, I.BillingCity, I.BillingState, I.BillingCountry, I.BillingPostalCode, I.Total
FROM MelodicaStaging.dbo.Invoices I
LEFT JOIN MelodicaDW.dbo.Dim_Invoice DI ON I.InvoiceID = DI.InvoiceID
WHERE CAST(FORMAT(I.InvoiceDate, 'yyyyMMdd') AS CHAR(8)) > @NewStartDate
AND DI.InvoiceID IS NULL;

-- Load Dim_Track
INSERT INTO MelodicaDW.dbo.Dim_Track (
  TrackID, Name, Artist, Album, MediaType, Genre, Composer, Milliseconds, Bytes, UnitPrice)
SELECT DISTINCT
  T.TrackID, T.Name, T.Artist, T.Album, T.MediaType, T.Genre, T.Composer, T.Milliseconds, T.Bytes, T.UnitPrice
FROM MelodicaStaging.dbo.Tracks T
LEFT JOIN MelodicaDW.dbo.Dim_Track DT ON T.TrackID = DT.TrackID
WHERE DT.TrackID IS NULL;

-- Load Dim_Customer
--INSERT INTO MelodicaDW.dbo.Dim_Customer (
--  CustomerID, FirstName, LastName, Company, Address, City, State, Country, PostalCode, Phone, Email, SupportRepID)
--SELECT 
--  C.CustomerID, C.FirstName, C.LastName, C.Company, C.Address, C.City, C.State, C.Country, C.PostalCode, C.Phone, C.Email, C.SupportRepID
--FROM MelodicaStaging.dbo.Customers C
--LEFT JOIN MelodicaDW.dbo.Dim_Customer DC ON C.CustomerID = DC.CustomerID
--WHERE DC.CustomerID IS NULL;

-- Already loaded

-- Load FACT_Invoice 
INSERT INTO MelodicaDW.dbo.Fact_Invoice (
  InvoiceKey, TrackKey, CustomerKey, DateKey, UnitPrice, Quantity)
SELECT DISTINCT
  DI.InvoiceKey,
  DT.TrackKey,
  DC.CustomerKey,
  CAST(FORMAT(I.InvoiceDate, 'yyyyMMdd') AS CHAR(8)) AS DateKey,
  IL.UnitPrice,
  IL.Quantity
FROM MelodicaStaging.dbo.InvoiceLines IL
JOIN MelodicaStaging.dbo.Invoices I ON IL.InvoiceId = I.InvoiceId
LEFT JOIN MelodicaDW.dbo.Dim_Invoice DI ON I.InvoiceId = DI.InvoiceID
JOIN MelodicaStaging.dbo.Tracks T ON IL.TrackId = T.TrackID
LEFT JOIN MelodicaDW.dbo.Dim_Track DT ON T.TrackID = DT.TrackID
LEFT JOIN MelodicaStaging.dbo.Customers C ON I.CustomerId = C.CustomerID
LEFT JOIN MelodicaDW.dbo.Dim_Customer DC ON C.CustomerID = DC.CustomerID AND DC.RowIsCurrent = 1
LEFT JOIN MelodicaDW.dbo.Fact_Invoice FI ON FI.DateKey = CAST(FORMAT(I.InvoiceDate, 'yyyyMMdd') AS CHAR(8)) AND FI.TrackKey = DT.TrackKey AND FI.CustomerKey = DC.CustomerKey
WHERE CAST(FORMAT(I.InvoiceDate, 'yyyyMMdd') AS CHAR(8)) > @NewStartDate
AND FI.InvoiceLineKey IS NULL;
GO


--Check that the new entries are correct
SELECT distinct *
FROM Fact_Invoice FI
ORDER BY DateKey DESC;

--SELECT TrackKey, CustomerKey, DateKey, COUNT(*)
--FROM Fact_Invoice
--GROUP BY TrackKey, CustomerKey, DateKey
--HAVING COUNT(*) > 1;

--SELECT distinct CustomerId, COUNT(*)
--FROM Dim_Customer
--GROUP BY CustomerId
--HAVING COUNT(*) > 1;

COMMIT TRANSACTION;
PRINT 'Transaction committed successfully.';

----Customer with no Orders
--select * from Chinook2022.dbo.Customer c left join Chinook2022.dbo.Invoice i on c.CustomerID = i.CustomerID
--where i.CustomerID is null;
----Customer with no Orders
--select * from Chinook2021.dbo.Customer c left join Chinook2021.dbo.Invoice i on c.CustomerID = i.CustomerID
--where i.CustomerID is null;
