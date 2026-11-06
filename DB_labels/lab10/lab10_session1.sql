USE TravelAgensy;
GO

/* =======================================================
   Подготовка тестовых данных
   ======================================================= */

IF OBJECT_ID('Ticket', 'U') IS NOT NULL
    DROP TABLE Ticket;
GO

CREATE TABLE Ticket
(
    TicketNumber BIGINT IDENTITY(1,1) PRIMARY KEY,
    BuyDate DATETIME DEFAULT GETDATE(),
    CruiseID INT NOT NULL,
    PassportNum BIGINT NOT NULL
);
GO

INSERT INTO Ticket (CruiseID, PassportNum)
VALUES (1, 1001),
       (2, 1002),
       (3, 1003);
GO


/* =======================================================
   1. Dirty Read (грязное чтение)
   ======================================================= */

BEGIN TRANSACTION;

UPDATE Ticket
SET CruiseID = 99
WHERE TicketNumber = 1;

WAITFOR DELAY '00:00:10';   -- держим грязные данные
GO

ROLLBACK TRANSACTION;

GO


/* =======================================================
   2. READ COMMITTED (ожидание блокировки)
   ======================================================= */

BEGIN TRANSACTION;

UPDATE Ticket
SET CruiseID = 77
WHERE TicketNumber = 1;
WAITFOR DELAY '00:00:10';
COMMIT TRANSACTION;
GO

/* =======================================================
   3. REPEATABLE READ
   ======================================================= */

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;

SELECT *
FROM Ticket
WHERE TicketNumber = 1;
WAITFOR DELAY '00:00:10';

-- теперь другая сессия не сможет UPDATE эту строку
COMMIT TRANSACTION;
GO


/* =======================================================
   4. SERIALIZABLE (блокировка диапазона)
   ======================================================= */

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;

SELECT *
FROM Ticket
WHERE CruiseID BETWEEN 1 AND 5;
WAITFOR DELAY '00:00:10';

-- другая сессия не сможет INSERT в этот диапазон
COMMIT TRANSACTION;
GO


/* =======================================================
   Просмотр блокировок
   ======================================================= */

/*SELECT 
    request_session_id AS SessionID,
    resource_type AS ResourceType,
    request_mode AS LockMode,
    request_status AS LockStatus
FROM sys.dm_tran_locks;
GO*/
