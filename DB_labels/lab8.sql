USE TravelAgensy;
GO

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

-- 1)   Создать хранимую процедуру, производящую выборку из
--      некоторой таблицы и возвращающую результат выборки в виде курсора.

IF OBJECT_ID('GetTicketsCursor', 'P') IS NOT NULL
    DROP PROCEDURE GetTicketsCursor;
GO

CREATE PROCEDURE GetTicketsCursor
AS
BEGIN
    DECLARE TicketsCursor CURSOR FOR
    SELECT TicketNumber, CruiseID, PassportNum
    FROM Ticket;

    OPEN TicketsCursor;
    RETURN;
END;
GO

-- 2)   Модифицировать хранимую процедуру п.1. таким образом, чтобы выборка осуществлялась 
--      с формированием столбца, значение которого формируется пользовательской функцией

IF OBJECT_ID('dbo.GetTicketWithFee', 'FN') IS NOT NULL
    DROP FUNCTION dbo.GetTicketWithFee;
GO

CREATE FUNCTION dbo.GetTicketWithFee (@CruiseID INT)
RETURNS MONEY
AS
BEGIN
    -- например, наценка 10% за круиз
    RETURN @CruiseID * 100 * 1.1;
END;
GO

-- Хранимая процедура с курсором и расчетом через функцию
IF OBJECT_ID('GetTicketsWithFeeCursor', 'P') IS NOT NULL
    DROP PROCEDURE GetTicketsWithFeeCursor;
GO

CREATE PROCEDURE GetTicketsWithFeeCursor
AS
BEGIN
    DECLARE FeeCursor CURSOR FOR
    SELECT TicketNumber, PassportNum, dbo.GetTicketWithFee(CruiseID) AS Fee
    FROM Ticket;

    OPEN FeeCursor;
    RETURN;
END;
GO

-- 3)   Создать хранимую процедуру, вызывающую процедуру п.1., осуществляющую прокрутку 
--      возвращаемого курсора и выводящую сообщения, сформированные из записей при выполнении 
--      условия, заданного еще одной пользовательской функцией.

-- доп функция

IF OBJECT_ID('dbo.IsVIPTicket', 'FN') IS NOT NULL
    DROP FUNCTION dbo.IsVIPTicket;
GO

CREATE FUNCTION dbo.IsVIPTicket (@CruiseID INT)
RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN @CruiseID >= 5 THEN 1 ELSE 0 END;
END;
GO

-- Хранимая процедура, выводящая сообщения через курсор
IF OBJECT_ID('DisplayTickets', 'P') IS NOT NULL
    DROP PROCEDURE DisplayTickets;
GO

CREATE PROCEDURE DisplayTickets
AS
BEGIN
    DECLARE @TicketNumber BIGINT, @CruiseID INT, @PassportNum BIGINT;

    DECLARE TicketCursor CURSOR FOR
    SELECT TicketNumber, CruiseID, PassportNum
    FROM Ticket;

    OPEN TicketCursor;
    FETCH NEXT FROM TicketCursor INTO @TicketNumber, @CruiseID, @PassportNum;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF dbo.IsVIPTicket(@CruiseID) = 1
            PRINT CONCAT('VIP Ticket ', @TicketNumber, ' for Passport ', @PassportNum, ' on Cruise ', @CruiseID);
        ELSE
            PRINT CONCAT('Regular Ticket ', @TicketNumber, ' for Passport ', @PassportNum, ' on Cruise ', @CruiseID);

        FETCH NEXT FROM TicketCursor INTO @TicketNumber, @CruiseID, @PassportNum;
    END;

    CLOSE TicketCursor;
    DEALLOCATE TicketCursor;
END;
GO

-- 4)   Модифицировать хранимую процедуру п.2. таким образом, чтобы выборка формировалась 
--      с помощью табличной функции.

IF OBJECT_ID('dbo.GetTicketsWithFeeTable', 'TF') IS NOT NULL
    DROP FUNCTION dbo.GetTicketsWithFeeTable;
GO

CREATE FUNCTION dbo.GetTicketsWithFeeTable()
RETURNS @ResultTable TABLE (
    TicketNumber BIGINT,
    PassportNum BIGINT,
    CruiseID INT,
    Fee MONEY
)
AS
BEGIN
    INSERT INTO @ResultTable (TicketNumber, PassportNum, CruiseID, Fee)
    SELECT TicketNumber, PassportNum, CruiseID, dbo.GetTicketWithFee(CruiseID) AS Fee
    FROM Ticket;

    RETURN;
END;
GO

-- Хранимая процедура для работы с табличной функцией
IF OBJECT_ID('GetTicketsFromTableFunction', 'P') IS NOT NULL
    DROP PROCEDURE GetTicketsFromTableFunction;
GO

CREATE PROCEDURE GetTicketsFromTableFunction
AS
BEGIN
    DECLARE @TicketNumber BIGINT, @PassportNum BIGINT, @Fee MONEY;

    DECLARE TableCursor CURSOR FOR
    SELECT TicketNumber, PassportNum, Fee
    FROM dbo.GetTicketsWithFeeTable();

    OPEN TableCursor;
    FETCH NEXT FROM TableCursor INTO @TicketNumber, @PassportNum, @Fee;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT CONCAT('Ticket ', @TicketNumber, ' for Passport ', @PassportNum, ' has fee: ', @Fee);
        FETCH NEXT FROM TableCursor INTO @TicketNumber, @PassportNum, @Fee;
    END;

    CLOSE TableCursor;
    DEALLOCATE TableCursor;
END;
GO

-- =======================================================
-- Тестируем
-- =======================================================

-- Вставляем тестовые данные
INSERT INTO Client (PassportNum, Surname, Name) VALUES (1001, N'Ivanov', N'Ivan');
INSERT INTO Client (PassportNum, Surname, Name) VALUES (1002, N'Petrov', N'Petr');

INSERT INTO Ticket (CruiseID, PassportNum) VALUES (1, 1001);
INSERT INTO Ticket (CruiseID, PassportNum) VALUES (6, 1001); -- VIP
INSERT INTO Ticket (CruiseID, PassportNum) VALUES (3, 1002);
GO

-- Запуск процедур
EXEC DisplayTickets;
EXEC GetTicketsFromTableFunction;
GO
