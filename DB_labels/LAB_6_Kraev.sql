USE TravelAgensy;
GO

IF OBJECT_ID('vw_IndexedClientTicket', 'V') IS NOT NULL
    DROP VIEW vw_IndexedClientTicket;
GO
/* =======================================================
   1. IDENTITY + CHECK + DEFAULT + встроенные функции
   Таблица Ticket
   ======================================================= */

IF OBJECT_ID('Ticket', 'U') IS NOT NULL
    DROP TABLE Ticket;
GO

CREATE TABLE Ticket
(
    TicketNumber BIGINT IDENTITY(1,1) PRIMARY KEY,
    BuyDate DATETIME NOT NULL DEFAULT GETDATE() CHECK (BuyDate <= GETDATE()),
    CruiseID INT NOT NULL,
    PassportNum BIGINT NOT NULL       
);
GO

INSERT INTO Ticket (BuyDate, CruiseID, PassportNum)
VALUES ('2011-01-01', 1005, 15000);
INSERT INTO Ticket (BuyDate, CruiseID, PassportNum)
VALUES ('2099-01-01', 1005, 15000);
INSERT INTO Ticket (CruiseID, PassportNum)
VALUES (1001, 15000);
INSERT INTO Ticket (CruiseID, PassportNum)
OUTPUT INSERTED.TicketNumber
VALUES (1005, 15000);
GO

SELECT SCOPE_IDENTITY();
SELECT @@IDENTITY;
SELECT IDENT_CURRENT('Ticket');
GO


/* =======================================================
   2. Первичный ключ GUID
   Таблица Client
   ======================================================= */

IF OBJECT_ID('Client', 'U') IS NOT NULL
    DROP TABLE Client;
GO

CREATE TABLE Client
(
    ClientID UNIQUEIDENTIFIER
        DEFAULT NEWID()
        PRIMARY KEY,
    PassportNum BIGINT NOT NULL,
    Surname NVARCHAR(50) NOT NULL,
    Name NVARCHAR(50) NOT NULL,
    Middlename NVARCHAR(50),
    CreateDate DATETIME DEFAULT GETDATE()
);
GO



/* =======================================================
   3. Первичный ключ на основе SEQUENCE
   Таблица Ticket
   ======================================================= */

IF OBJECT_ID('Ticket', 'U') IS NOT NULL
    DROP TABLE Ticket;
GO

IF OBJECT_ID('TicketSeq', 'SO') IS NOT NULL
    DROP SEQUENCE TicketSeq;
GO

CREATE SEQUENCE TicketSeq
    AS BIGINT
    START WITH 1000
    INCREMENT BY 1;
GO

CREATE TABLE Ticket
(
    TicketNumber BIGINT
        PRIMARY KEY
        DEFAULT NEXT VALUE FOR TicketSeq,
    BuyDate DATETIME DEFAULT GETDATE(),
    CruiseID INT NOT NULL,
    PassportNum BIGINT NOT NULL
);
GO

INSERT INTO Ticket (CruiseID, PassportNum)
VALUES (1001, 15000);
INSERT INTO Ticket (CruiseID, PassportNum)
VALUES (1005, 15000);
GO

SELECT TicketNumber from Ticket
GO

/* =======================================================
   4. Все виды целостности
   ======================================================= */

/* DELETE */
-- Очистка
IF OBJECT_ID('Ticket', 'U') IS NOT NULL DROP TABLE Ticket;
IF OBJECT_ID('Client', 'U') IS NOT NULL DROP TABLE Client;
GO

-- Родитель
CREATE TABLE Client
(
    PassportNum BIGINT PRIMARY KEY,
    Name NVARCHAR(50)
);
GO

-- Дочерняя таблица
CREATE TABLE Ticket
(
    TicketNumber BIGINT IDENTITY(1,1) PRIMARY KEY,
    PassportNum BIGINT NOT NULL,
    CruiseID INT,
    CONSTRAINT FK_Ticket_Client FOREIGN KEY (PassportNum)
        REFERENCES Client(PassportNum)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

-- Данные
INSERT INTO Client VALUES (1001, N'Иванов');
INSERT INTO Ticket (PassportNum, CruiseID) VALUES (1001, 1);
GO

/*попытка удалить*/
SELECT * FROM Ticket;


GO

/*CASCADE */

-- Очистка
DROP TABLE Ticket;
DROP TABLE Client;
GO

CREATE TABLE Client
(
    PassportNum BIGINT PRIMARY KEY,
    Name NVARCHAR(50)
);

CREATE TABLE Ticket
(
    TicketNumber BIGINT IDENTITY(1,1) PRIMARY KEY,
    PassportNum BIGINT NOT NULL,
    CruiseID INT,
    CONSTRAINT FK_Ticket_Client FOREIGN KEY (PassportNum)
        REFERENCES Client(PassportNum)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
GO

INSERT INTO Client VALUES (1001, N'Иванов');
INSERT INTO Ticket (PassportNum, CruiseID) VALUES (1001, 1);
GO

-- Изменение родителя
UPDATE Client SET PassportNum = 2001 WHERE PassportNum = 1001;
SELECT * FROM Ticket; -- Ticket автоматически обновился

-- Удаление родителя
DELETE FROM Client WHERE PassportNum = 2001;
SELECT * FROM Ticket; -- Ticket удалился автоматически

/* SET NULL*/
-- Очистка
DROP TABLE Ticket;
DROP TABLE Client;
GO

CREATE TABLE Client
(
    PassportNum BIGINT PRIMARY KEY,
    Name NVARCHAR(50)
);

CREATE TABLE Ticket
(
    TicketNumber BIGINT IDENTITY(1,1) PRIMARY KEY,
    PassportNum BIGINT NULL,
    CruiseID INT,
    CONSTRAINT FK_Ticket_Client FOREIGN KEY (PassportNum)
        REFERENCES Client(PassportNum)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
GO

INSERT INTO Client VALUES (1001, N'Иванов');
INSERT INTO Ticket (PassportNum, CruiseID) VALUES (1001, 1);
GO

-- Удаление родителя
DELETE FROM Client WHERE PassportNum = 1001;
SELECT * FROM Ticket; -- PassportNum стал NULL

/*SET DEFAULT */
-- Очистка
DROP TABLE Ticket;
DROP TABLE Client;
GO

-- Создаём родителя со строкой по умолчанию
CREATE TABLE Client
(
    PassportNum BIGINT PRIMARY KEY,
    Name NVARCHAR(50)
);
INSERT INTO Client VALUES (0, N'Не указан'); -- для DEFAULT
GO

-- Дочерняя таблица
CREATE TABLE Ticket
(
    TicketNumber BIGINT IDENTITY(1,1) PRIMARY KEY,
    PassportNum BIGINT NOT NULL DEFAULT 0,
    CruiseID INT,
    CONSTRAINT FK_Ticket_Client FOREIGN KEY (PassportNum)
        REFERENCES Client(PassportNum)
        ON DELETE SET DEFAULT
        ON UPDATE CASCADE
);
GO

INSERT INTO Client VALUES (1001, N'Иванов');
INSERT INTO Ticket (PassportNum, CruiseID) VALUES (1001, 1);
GO

-- Удаление родителя
DELETE FROM Client WHERE PassportNum = 1001;
SELECT * FROM Ticket; -- PassportNum стал 0