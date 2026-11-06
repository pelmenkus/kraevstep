USE master;
GO
IF DB_ID(N'TravelAgensy') IS NOT NULL 
DROP DATABASE TravelAgensy;
GO

CREATE DATABASE TravelAgensy
ON 
(
    NAME = TravelAgensy_dat,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\TravelAgensy_dat.mdf',
    SIZE = 10MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5%
)
LOG ON 
( 
  NAME = TravelAgensy_log,
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\TravelAgensy_log.ldf',
  SIZE = 5MB, MAXSIZE = 25MB,
  FILEGROWTH = 5MB
);
GO

USE TravelAgensy
GO

if object_id (N'Cruise') is not null
Drop table Cruise;
GO

CREATE TABLE Cruise (
    CruiseId INT PRIMARY KEY,
    CruiseName NVARCHAR (50),
    CrData Datetime,
    TicketPrice Money,
    CruiseLong Datetime,
    TownBegin varchar (50),
    TownEnd varchar (50),
    CruiseType NVARCHAR (30)
);

ALTER DATABASE TravelAgensy
ADD FILEGROUP TravelAgensyFileGroup;

ALTER DATABASE TravelAgensy
ADD FILE
(
    NAME = TravelAgensy_FileGroupData,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\TravelAgensy_Filegroup_data.ndf',
    SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5%
)
TO FILEGROUP TravelAgensyFileGroup;

ALTER DATABASE TravelAgensy
MODIFY FILEGROUP TravelAgensyFileGroup DEFAULT;

CREATE TABLE Client (
    PassportNum INT PRIMARY KEY,
    Name NVARCHAR(50),
    Surname NVARCHAR (50),
    Middlename NVARCHAR (50),
    Phone NVARCHAR(15)    
);

ALTER DATABASE TravelAgensy
MODIFY FILEGROUP [primary] DEFAULT;
GO

DROP TABLE Client;
ALTER DATABASE TravelAgensy
REMOVE FILE TravelAgensy_FileGroupData;

ALTER DATABASE TravelAgensy
REMOVE FILEGROUP TravelAgensyFileGroup;
GO

CREATE SCHEMA TravelAgensy_schema;
GO
ALTER SCHEMA TravelAgensy_schema
TRANSFER dbo.Cruise;

DROP TABLE TravelAgensy_schema.Cruise;

DROP SCHEMA TravelAgensy_schema;
