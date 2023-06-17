CREATE DATABASE MelodicaDW;
GO

USE MelodicaDW;
GO

-- Create Dim_Customer table
CREATE TABLE Dim_Customer (
  CustomerKey INT IDENTITY(1,1) NOT NULL,
  CustomerID INT NOT NULL,
  FirstName NVARCHAR(50) NOT NULL,
  LastName NVARCHAR(50) NOT NULL,
  Company NVARCHAR(50),
  Address NVARCHAR(100),
  City NVARCHAR(50),
  State NVARCHAR(50),
  Country NVARCHAR(50),
  PostalCode NVARCHAR(20),
  Phone NVARCHAR(25),
  Email NVARCHAR(50) NOT NULL,
  SupportRepID INT,

  RowIsCurrent INT DEFAULT 1 NOT NULL,
  RowStartDate DATE DEFAULT '2000-01-01' NOT NULL,
  RowEndDate DATE DEFAULT '2999-12-31' NOT NULL,
  RowChangeReason VARCHAR(200) NULL
);

-- Create Dim_Track table
CREATE TABLE Dim_Track (
  TrackKey INT IDENTITY(1,1) NOT NULL,
  TrackID INT NOT NULL,
  Name NVARCHAR(200) NOT NULL,
  Artist NVARCHAR(200) NOT NULL,
  Album NVARCHAR(200) NOT NULL,
  MediaType NVARCHAR(200) NOT NULL,
  Genre NVARCHAR(200) NOT NULL,
  Composer NVARCHAR(200),
  Milliseconds INT NOT NULL,
  Bytes INT,
  UnitPrice DECIMAL(10, 2) NOT NULL,

  --RowIsCurrent INT DEFAULT 1 NOT NULL,
  --RowStartDate DATE DEFAULT '2000-01-01' NOT NULL,
  --RowEndDate DATE DEFAULT '2999-12-31' NOT NULL,
  --RowChangeReason VARCHAR(200) NULL
);

-- Create Dim_Invoice table
CREATE TABLE Dim_Invoice (
  InvoiceKey INT IDENTITY(1,1) NOT NULL ,
  InvoiceID INT NOT NULL,
  BillingAddress NVARCHAR(100),
  BillingCity NVARCHAR(50),
  BillingState NVARCHAR(50),
  BillingCountry NVARCHAR(50),
  BillingPostalCode NVARCHAR(20),
  Total NUMERIC(10, 2) NOT NULL,

  --RowIsCurrent INT DEFAULT 1 NOT NULL,
  --RowStartDate DATE DEFAULT '2000-01-01' NOT NULL,
  --RowEndDate DATE DEFAULT '2999-12-31' NOT NULL,
  --RowChangeReason VARCHAR(200) NULL
);

-- Create Fact_Invoice table
CREATE TABLE Fact_Invoice (
  InvoiceLineKey INT IDENTITY(1, 1),
  InvoiceKey INT NOT NULL,
  TrackKey INT NOT NULL,
  CustomerKey INT NOT NULL,
  DateKey CHAR(8) NOT NULL,
  UnitPrice DECIMAL(10, 2) NOT NULL,
  Quantity INT NOT NULL
  
);
--DROP TABLE Fact_Invoice;

-- Create Dim_Date table
CREATE TABLE DimDate(
	Date date,
	DateKey char(8) PRIMARY KEY, --  20230331
	Year int,
	Month int,
	Day int,
	DayAsWord varchar(20),
	isHoliday int, 
	isWeekend int,
	hodilayDescription nvarchar(50)
);
--DROP TABLE DimDate;

--Starting value of Date Range
declare @StartDate as date =	datefromparts(
	(select  year(  min(InvoiceDate) ) from  Chinook2021.dbo.Invoice) 
	, 1,1);
	
--End Value of Date Range	
declare @EndDate as date =	datefromparts(
	(select  year(  max(InvoiceDate) ) from  Chinook2022.dbo.Invoice) 
	, 12,31);

	   
DECLARE @CurrentDate AS DATE = @StartDate


while @CurrentDate<=@EndDate
BEGIN
	insert into dimdate(date ,	dateKey ,year ,	month ,	day , dayAsWord 
	,isHoliday, isWeekend)
	values(@CurrentDate
	, format( @CurrentDate, 'yyyyMMdd') 
	, year( @CurrentDate)
	, month(@CurrentDate)
	, day(@CurrentDate)
	, DATENAME(WEEKDAY, @CurrentDate)
	, 0
	, case 
		when   DATENAME(WEEKDAY, @CurrentDate)='Saturday' 
			or  DATENAME(WEEKDAY, @CurrentDate)='Sunday' THEN 1
		else 0  end
	);

	set @CurrentDate = dateadd(day,1, @CurrentDate)
END;


-- First Day of the Year (January 1st)
update DimDate set isHoliday = 1, 
	hodilayDescription= 'First Day of the Year' where day(date)= 1 and month(date)=1;

-- Theofaneia Day (January 6th)
update DimDate set isHoliday = 1, 
	hodilayDescription= 'Theofaneia' where day(date)= 6 and month(date)=1;

-- OXI Day (October 28th)
update DimDate set isHoliday = 1, 
	hodilayDescription= 'Oxi Day' where day(date)= 28 and month(date)=10;

-- Labor Day (May 1st)
UPDATE DimDate SET isHoliday = 1, 
    hodilayDescription = 'Labor Day' WHERE day(date) = 1 AND month(date) = 5;

-- Assumption of Mary (August 15th)
UPDATE DimDate SET isHoliday = 1, 
    hodilayDescription = 'Assumption of Mary' WHERE day(date) = 15 AND month(date) = 8;

-- Independence Day (March 25th)
UPDATE DimDate SET isHoliday = 1, 
    hodilayDescription = 'Independence Day' WHERE day(date) = 25 AND month(date) = 3;

-- Christmas Day (December 25th)
UPDATE DimDate SET isHoliday = 1, 
    hodilayDescription = 'Christmas Day' WHERE day(date) = 25 AND month(date) = 12;

-- Boxing Day (December 26th)
UPDATE DimDate SET isHoliday = 1, 
    hodilayDescription = 'Boxing Day' WHERE day(date) = 26 AND month(date) = 12;

------------------------------------------
-- ETL

-- Load Dim_Customer
INSERT INTO MelodicaDW.dbo.Dim_Customer (
  CustomerID, FirstName, LastName, Company,
  Address, City, State, Country,
  PostalCode, Phone, Email, SupportRepID
)
SELECT 
  CustomerID, FirstName, LastName, Company,
  Address, City, State, Country,
  PostalCode, Phone, Email, SupportRepID
FROM MelodicaStaging.dbo.Customers;

-- Load Dim_Track
INSERT INTO MelodicaDW.dbo.Dim_Track (
  TrackID, Name, Artist, Album, MediaType, Genre, Composer, Milliseconds, Bytes, UnitPrice)
SELECT 
  TrackID, Name, Artist, Album, MediaType, Genre, Composer, Milliseconds, Bytes, UnitPrice
 FROM MelodicaStaging.dbo.Tracks;

-- Load Dim_Invoice
INSERT INTO MelodicaDW.dbo.Dim_Invoice (
  InvoiceID, BillingAddress, BillingCity, BillingState, BillingCountry, BillingPostalCode, Total)
SELECT 
  InvoiceID, BillingAddress, BillingCity, BillingState, BillingCountry, BillingPostalCode,Total
FROM MelodicaStaging.dbo.Invoices;

-- Load Fact_Invoice
INSERT INTO MelodicaDW.dbo.Fact_Invoice (
  InvoiceKey, TrackKey, CustomerKey, DateKey, UnitPrice, Quantity)
SELECT 
  DI.InvoiceKey,
  DT.TrackKey,
  DC.CustomerKey,
  cast(FORMAT(I.InvoiceDate, 'yyyyMMdd')AS CHAR(8)) AS DateKey,
  IL.UnitPrice,
  IL.Quantity
FROM MelodicaStaging.dbo.InvoiceLines IL
JOIN MelodicaStaging.dbo.Invoices I ON IL.InvoiceId = I.InvoiceId
JOIN MelodicaDW.dbo.Dim_Invoice DI ON I.InvoiceId = DI.InvoiceID
JOIN MelodicaStaging.dbo.Tracks T ON IL.TrackId = T.TrackID
JOIN MelodicaDW.dbo.Dim_Track DT ON T.TrackID = DT.TrackID
JOIN MelodicaStaging.dbo.Customers C ON I.CustomerId = C.CustomerID
JOIN MelodicaDW.dbo.Dim_Customer DC ON C.CustomerID = DC.CustomerID;

-- Load DimDate
-- (Already populated in the data warehouse creation part)
------------------------------------------

--Relationships

-- Add primary key constraint for Dim_Customer
ALTER TABLE Dim_Customer ADD CONSTRAINT cust_pk PRIMARY KEY (CustomerKey);

-- Add primary key constraint for Dim_Track
ALTER TABLE Dim_Track ADD CONSTRAINT track_pk PRIMARY KEY (TrackKey);

-- Add primary key constraint for Dim_Invoice
ALTER TABLE Dim_Invoice ADD CONSTRAINT invoice_pk PRIMARY KEY (InvoiceKey);

--FK

ALTER TABLE Fact_Invoice ADD CONSTRAINT fact_invoice_invoicekey_fk FOREIGN KEY (InvoiceKey)
  REFERENCES Dim_Invoice(InvoiceKey);

ALTER TABLE Fact_Invoice ADD CONSTRAINT fact_invoice_trackkey_fk FOREIGN KEY (TrackKey)
  REFERENCES Dim_Track(TrackKey);

ALTER TABLE Fact_Invoice ADD CONSTRAINT fact_invoice_customerkey_fk FOREIGN KEY (CustomerKey)
  REFERENCES Dim_Customer(CustomerKey);

ALTER TABLE Fact_Invoice ADD CONSTRAINT fact_invoice_datekey_fk FOREIGN KEY (DateKey)
  REFERENCES DimDate(DateKey);
