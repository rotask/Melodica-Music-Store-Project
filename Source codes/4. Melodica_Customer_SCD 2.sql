-- Step 1: Create a staging table for customers in Chinook2022
USE MelodicaStaging;
GO

IF OBJECT_ID('MelodicaStaging.dbo.Customers', 'U') IS NOT NULL
  DROP TABLE MelodicaStaging.dbo.Customers;

SELECT
  CustomerID,
  FirstName,
  LastName,
  Company,
  Address,
  City,
  State,
  Country,
  PostalCode,
  Phone,
  Email,
  SupportRepId
INTO dbo.Customers
FROM Chinook2022.dbo.Customer;

-- Step 2: Use the MERGE statement to handle inserts, updates, and soft deletes
USE MelodicaDW;
GO

-- Dropping primary key and foreign key constraints
ALTER TABLE Fact_Invoice DROP CONSTRAINT fact_invoice_customerkey_fk;
ALTER TABLE Dim_Customer DROP CONSTRAINT cust_pk;

GO

-- Merge statement for Dim_Customer
INSERT INTO MelodicaDW.dbo.Dim_Customer (
  CustomerID, FirstName, LastName, Company,
  Address, City, State, Country,
  PostalCode, Phone, Email, SupportRepID, RowStartDate, RowChangeReason
)
SELECT 
  CustomerID, FirstName, LastName, Company,
  Address, City, State, Country,
  PostalCode, Phone, Email, SupportRepID, CAST(GetDate() AS Date),ActionName

FROM

(MERGE MelodicaDW.dbo.Dim_Customer AS target
USING MelodicaStaging.dbo.Customers AS source
ON target.CustomerId = source.CustomerId

-- Update existing records
WHEN MATCHED AND (
  target.FirstName <> source.FirstName COLLATE Latin1_General_CI_AS
  OR target.LastName <> source.LastName COLLATE Latin1_General_CI_AS
  OR target.Company <> source.Company COLLATE Latin1_General_CI_AS
  OR target.Address <> source.Address COLLATE Latin1_General_CI_AS
  OR target.City <> source.City COLLATE Latin1_General_CI_AS
  OR target.State <> source.State COLLATE Latin1_General_CI_AS
  OR target.Country <> source.Country COLLATE Latin1_General_CI_AS
  OR target.PostalCode <> source.PostalCode COLLATE Latin1_General_CI_AS
  OR target.Phone <> source.Phone COLLATE Latin1_General_CI_AS
  OR target.Email <> source.Email COLLATE Latin1_General_CI_AS
  OR target.SupportRepId <> source.SupportRepId 
  )
THEN
  UPDATE
  SET target.RowIsCurrent = 0,
      target.RowEndDate = DATEADD(day, -1, CAST(GETDATE() AS DATE)),
      target.RowChangeReason = 'Customer information updated'

-- Insert new records
WHEN NOT MATCHED BY TARGET THEN
  INSERT (
    CustomerId,
	FirstName,
    LastName,
    Company,
    Address,
    City,
    State,
    Country,
	PostalCode,
	Phone,
	Email,
	SupportRepId,
    RowStartDate,
    RowEndDate,
    RowIsCurrent,
    RowChangeReason)
  VALUES (
    source.CustomerId,
    source.FirstName,
    source.LastName,
    source.Company,
    source.Address,
    source.City,
    source.State,
    source.Country,
	source.PostalCode,
	source.Phone,
	source.Email,
	source.SupportRepId,  
    CAST(GETDATE() AS DATE),
    '2999-12-31',
    1,
    'New customer')

-- Update records removed from the source
WHEN NOT MATCHED BY SOURCE AND target.RowIsCurrent = 1 THEN
  UPDATE
  SET target.RowEndDate = DATEADD(day, -1, CAST(GETDATE() AS DATE)),
      target.RowIsCurrent = 0,
      target.RowChangeReason = 'Customer removed from source'

-- Output results
OUTPUT
	$action as ActionName,
	source.CustomerId,
    source.FirstName,
    source.LastName,
    source.Company,
    source.Address,
    source.City,
    source.State,
    source.Country,
	source.PostalCode,
	source.Phone,
	source.Email,
	source.SupportRepId) AS MergeOutput
WHERE MergeOutput.ActionName='UPDATE'
--AND CustomerId IS NOT NULL

-- Re-adding primary key and foreign key constraints
ALTER TABLE Dim_Customer
ADD CONSTRAINT cust_pk PRIMARY KEY (CustomerKey);

ALTER TABLE Fact_Invoice
ADD CONSTRAINT fact_invoice_customerkey_fk FOREIGN KEY (CustomerKey) REFERENCES Dim_Customer(CustomerKey);

GO

-- Verify the results
SELECT *
FROM MelodicaDW.dbo.Dim_Customer;
-- Show rows affected
--PRINT 'Rows affected by INSERT: ' + CAST(@@ROWCOUNT AS nvarchar(10));