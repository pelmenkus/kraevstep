USE TravelAgensy;
GO

-- удаление объектов если уже существуют
IF OBJECT_ID('vw_IndexedClientTicket', 'V') IS NOT NULL
    DROP VIEW vw_IndexedClientTicket;
GO

IF OBJECT_ID('vw_ClientTicket', 'V') IS NOT NULL
    DROP VIEW vw_ClientTicket;
GO

IF OBJECT_ID('vw_Client', 'V') IS NOT NULL
    DROP VIEW vw_Client;
GO

IF OBJECT_ID('Ticket', 'U') IS NOT NULL
    DROP TABLE Ticket;
GO

IF OBJECT_ID('Client', 'U') IS NOT NULL
    DROP TABLE Client;
GO

IF OBJECT_ID('TicketSeq', 'SO') IS NOT NULL
    DROP SEQUENCE TicketSeq;
GO

CREATE SEQUENCE TicketSeq
    AS BIGINT
    START WITH 1000
    INCREMENT BY 1;
GO

CREATE TABLE Client
(
    ClientID UNIQUEIDENTIFIER
        DEFAULT NEWID()
        PRIMARY KEY,

    PassportNum BIGINT NOT NULL UNIQUE,

    Surname NVARCHAR(50) NOT NULL,
    Name NVARCHAR(50) NOT NULL,
    Middlename NVARCHAR(50) DEFAULT NULL,

    CreateDate DATETIME DEFAULT GETDATE()
);
GO


CREATE TABLE Ticket
(
    TicketNumber BIGINT
        PRIMARY KEY
        DEFAULT NEXT VALUE FOR TicketSeq,

    BuyDate DATETIME DEFAULT GETDATE(),

    CruiseID INT NOT NULL,

    PassportNum BIGINT NOT NULL,

    CONSTRAINT FK_Ticket_Client
        FOREIGN KEY (PassportNum)
        REFERENCES Client(PassportNum)
);
GO

INSERT INTO Client(PassportNum,Surname,Name) VALUES (1000, N'ivanov', N'ivan');
INSERT INTO Client(PassportNum,Surname,Name) VALUES (1001, N'ivanov', N'ivaan');
INSERT INTO Client(PassportNum,Surname,Name) VALUES (1002, N'ivanov', N'ivaan');
INSERT INTO Ticket (PassportNum, CruiseID) VALUES (1000, 14);
INSERT INTO Client (PassportNum, Surname, Name) VALUES (1003, N'Ivanow', N'Ivan');
INSERT INTO Ticket (CruiseID, PassportNum) VALUES (10, 1001);
INSERT INTO Ticket (PassportNum, CruiseID) VALUES (1000, 1);
INSERT INTO Ticket (PassportNum, CruiseID) VALUES (1003, 1);
INSERT INTO Ticket (PassportNum, CruiseID) VALUES (1002, 1);
GO

/* ѕредставление на основе одной таблицы */

CREATE VIEW vw_Client
AS
SELECT
    PassportNum,
    Surname,
    Name,
    Middlename,
    CreateDate
FROM Client;
GO

SELECT *
FROM vw_Client;
GO

/* ѕредставление на основе св€занных таблиц */

CREATE VIEW vw_ClientTicket
AS
SELECT
    c.PassportNum,
    c.Surname,
    c.Name,
    t.TicketNumber,
    t.CruiseID,
    t.BuyDate
FROM Client c
JOIN Ticket t
    ON c.PassportNum = t.PassportNum;
GO

SELECT *
FROM vw_ClientTicket;
GO
/* index Client */
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

CREATE NONCLUSTERED INDEX idx_Client_Surname
ON Client (PassportNum)
INCLUDE (Name, Middlename);
GO

/*test*/
SELECT *
FROM vw_ClientTicket
GO

/* индексированное представление */
CREATE VIEW vw_IndexedClientTicket
WITH SCHEMABINDING AS
SELECT
    c.PassportNum,
    c.Surname,
    c.Name,
    t.TicketNumber,
    t.CruiseID,
    t.BuyDate
FROM dbo.Client c
JOIN dbo.Ticket t
    ON c.PassportNum = t.PassportNum;
GO

/*test_indexedview*/

SELECT *
FROM vw_IndexedClientTicket
GO


CREATE UNIQUE CLUSTERED INDEX idx_IndexedClientTicket
ON vw_IndexedClientTicket (PassportNum);
GO

Delete from Ticket where TicketNumber=1002;
CREATE UNIQUE CLUSTERED INDEX idx_IndexedClientTicket
ON vw_IndexedClientTicket (PassportNum);
GO

SELECT 
    OBJECT_NAME(s.object_id) AS TableName,
    i.name AS IndexName,
    s.user_seeks,
    s.user_scans
FROM sys.dm_db_index_usage_stats s
JOIN sys.indexes i
    ON s.object_id = i.object_id
    AND s.index_id = i.index_id
WHERE OBJECT_NAME(s.object_id) IN ('Client','Ticket');
GO

SELECT *
FROM vw_ClientTicket;
GO



